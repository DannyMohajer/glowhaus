import 'dart:convert';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:test/test.dart';

Map<String, dynamic> _json(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

/// Encodes and decodes through real JSON text.
Map<String, dynamic> _wire(Map<String, dynamic> json) =>
    _json(jsonEncode(json));

const _thermostatCapabilities = [
  Capability(
    id: 'thermostat',
    kind: CapabilityKind.thermostat,
    config: {
      'minSetpoint': 16,
      'maxSetpoint': 30,
      'step': 0.5,
      'modes': ['off', 'heat', 'cool', 'auto'],
      'fanModes': ['auto', 'low', 'medium', 'high'],
    },
  ),
  Capability(id: 'temperatureSensor', kind: CapabilityKind.temperatureSensor),
];

void main() {
  group('discovery', () {
    const announce = '''
{
  "v": 1, "type": "announce", "ts": 1794500000000,
  "device": {
    "id": "lr-lamp", "type": "light", "name": "Floor lamp",
    "manufacturer": "Glowhaus Labs", "model": "GL-RGB-1", "firmware": "1.0.0",
    "roomHint": "living-room",
    "capabilities": [
      { "id": "onOff", "kind": "onOff" },
      { "id": "brightness", "kind": "brightness" },
      { "id": "color", "kind": "color" },
      { "id": "colorTemperature", "kind": "colorTemperature",
        "config": { "minKelvin": 2200, "maxKelvin": 6500 } }
    ]
  }
}''';

    test('parses the announce example from the spec', () {
      final message = DiscoveryMessage.fromJson(_json(announce));
      expect(message, isA<DiscoveryAnnounce>());
      final device = (message as DiscoveryAnnounce).device;
      expect(device.id, 'lr-lamp');
      expect(device.type, DeviceType.light);
      expect(device.roomHint, 'living-room');
      expect(device.capabilities.map((c) => c.kind), [
        CapabilityKind.onOff,
        CapabilityKind.brightness,
        CapabilityKind.color,
        CapabilityKind.colorTemperature,
      ]);
      expect(
        device.capabilities.last.colorTemperatureConfig,
        const ColorTemperatureConfig(minKelvin: 2200, maxKelvin: 6500),
      );
    });

    test('announce round trips', () {
      final message = DiscoveryMessage.fromJson(_json(announce));
      expect(DiscoveryMessage.fromJson(_wire(message.toJson())), message);
      expect(message.toJson()['type'], 'announce');
      expect(message.toJson()['v'], 1);
    });

    test('query and bye round trip', () {
      const query = DiscoveryMessage.query(ts: 1);
      const bye = DiscoveryMessage.bye(ts: 2, deviceId: 'lr-lamp');
      expect(_wire(query.toJson()), {'v': 1, 'type': 'query', 'ts': 1});
      expect(DiscoveryMessage.fromJson(_wire(query.toJson())), query);
      expect(DiscoveryMessage.fromJson(_wire(bye.toJson())), bye);
    });

    test('switch type and channel labels', () {
      final descriptor = DeviceDescriptor.fromJson(
        _json('''
{ "id": "kt-switch", "type": "switch", "name": "Kitchen switch",
  "capabilities": [
    { "id": "ch1", "kind": "onOff", "label": "Ceiling" },
    { "id": "ch2", "kind": "onOff", "label": "Counter" } ] }'''),
      );
      expect(descriptor.type, DeviceType.wallSwitch);
      expect(descriptor.capabilities[1].label, 'Counter');
      expect(descriptor.toJson()['type'], 'switch');
    });

    test('unknown device type and capability kind are tolerated', () {
      final descriptor = DeviceDescriptor.fromJson(
        _json(
          '''
{ "id": "x1", "type": "sprinkler", "name": "Sprinkler", "futureField": 7,
  "capabilities": [
    { "id": "onOff", "kind": "onOff" },
    { "id": "flow", "kind": "flowMeter", "config": { "unit": "l/min" } } ] }''',
        ),
      );
      expect(descriptor.type, DeviceType.unknown);
      expect(descriptor.capabilities[1].kind, CapabilityKind.unknown);
    });
  });

  group('availability', () {
    test('online with ts', () {
      final payload = AvailabilityPayload.fromJson(
        _json('{"v":1,"status":"online","ts":1794500000000}'),
      );
      expect(payload.availability, DeviceAvailability.online);
      expect(AvailabilityPayload.fromJson(_wire(payload.toJson())), payload);
    });

    test('last will has no ts and omits it when encoded', () {
      final payload = AvailabilityPayload.fromJson(
        _json('{"v":1,"status":"offline"}'),
      );
      expect(payload.availability, DeviceAvailability.offline);
      expect(_wire(payload.toJson()), {'v': 1, 'status': 'offline'});
    });
  });

  group('state', () {
    const source = '''
{ "v": 1, "ts": 1794500000000,
  "state": {
    "thermostat": { "setpoint": 22.5, "mode": "heat", "fan": "auto", "action": "heating" },
    "temperatureSensor": { "celsius": 20.8 } } }''';

    test('decodes the thermostat example', () {
      final state = StatePayload.fromJson(_json(source))
          .decode(_thermostatCapabilities);
      expect(state, {
        'thermostat': const CapabilityState.thermostat(
          setpoint: 22.5,
          mode: ThermostatMode.heat,
          fan: FanMode.auto,
          action: ThermostatAction.heating,
        ),
        'temperatureSensor': const CapabilityState.temperatureSensor(
          celsius: 20.8,
        ),
      });
    });

    test('encode then decode is lossless and untagged', () {
      final state = <String, CapabilityState>{
        'thermostat': const CapabilityState.thermostat(
          setpoint: 24,
          mode: ThermostatMode.cool,
        ),
        'temperatureSensor': const CapabilityState.temperatureSensor(
          celsius: 21,
        ),
      };
      final payload = StatePayload.encode(state, ts: 5);
      final wire = _wire(payload.toJson());
      expect((wire['state'] as Map)['thermostat'], isNot(contains('kind')));
      expect(
        StatePayload.fromJson(wire).decode(_thermostatCapabilities),
        state,
      );
    });

    test('integers are accepted where numbers are expected', () {
      final state = StatePayload.fromJson(
        _json(
          '{"v":1,"ts":1,"state":{"thermostat":{"setpoint":24,"mode":"cool"}}}',
        ),
      ).decode(_thermostatCapabilities);
      expect((state['thermostat']! as ThermostatState).setpoint, 24.0);
    });

    test('ignores unknown fields, unknown ids, unknown kinds, bad entries', () {
      final state =
          StatePayload.fromJson(
            _json('''
{ "v": 1, "ts": 1, "extra": true,
  "state": {
    "onOff": { "on": true, "futureField": "x" },
    "ghost": { "on": true },
    "flow": { "rate": 3 },
    "brightness": { "level": "bright" } } }'''),
          ).decode(const [
            Capability(id: 'onOff', kind: CapabilityKind.onOff),
            Capability(id: 'flow', kind: CapabilityKind.unknown),
            Capability(id: 'brightness', kind: CapabilityKind.brightness),
          ]);
      expect(state, {'onOff': const CapabilityState.onOff(on: true)});
    });

    test('position reports current, target and moving', () {
      final state = StatePayload.fromJson(
        _json(
          '{"v":1,"ts":1,"state":{"position":'
          '{"position":40,"target":100,"moving":true}}}',
        ),
      ).decode([Capability.of(CapabilityKind.position)]);
      expect(
        state['position'],
        const CapabilityState.position(position: 40, target: 100, moving: true),
      );
    });
  });

  group('set', () {
    final command = DeviceCommand(
      id: 'c-1007',
      homeId: 'demo-home',
      deviceId: 'lr-thermostat',
      issuedAt: DateTime.fromMillisecondsSinceEpoch(1794500001000),
      patches: const {
        'thermostat': CapabilityPatch.thermostat(
          setpoint: 24,
          mode: ThermostatMode.cool,
        ),
      },
    );

    test('command encodes to the spec shape, only fields being changed', () {
      expect(_wire(command.toPayload().toJson()), {
        'v': 1,
        'commandId': 'c-1007',
        'ts': 1794500001000,
        'set': {
          'thermostat': {'setpoint': 24.0, 'mode': 'cool'},
        },
      });
    });

    test('device side decodes back to the same patches', () {
      final payload = SetPayload.fromJson(_wire(command.toPayload().toJson()));
      final decoded = payload.decode(_thermostatCapabilities);
      expect(decoded.error, isNull);
      expect(decoded.patches, command.patches);
    });

    SetPayload set(Map<String, Map<String, dynamic>> body, {int v = 1}) =>
        SetPayload(commandId: 'c1', ts: 0, set: body, v: v);

    test('unknown capability rejects the whole command', () {
      final decoded = set({
        'thermostat': {'setpoint': 22},
        'ghost': {'on': true},
      }).decode(_thermostatCapabilities);
      expect(decoded.error, ProtocolErrorCode.unsupportedCapability);
      expect(decoded.patches, isEmpty);
    });

    test('read-only capability', () {
      expect(
        set({
          'temperatureSensor': {'celsius': 30},
        }).decode(_thermostatCapabilities).error,
        ProtocolErrorCode.readOnly,
      );
    });

    test('out of range value', () {
      expect(
        set({
          'thermostat': {'setpoint': 45},
        }).decode(_thermostatCapabilities).error,
        ProtocolErrorCode.outOfRange,
      );
    });

    test('malformed value and empty set', () {
      expect(
        set({
          'thermostat': {'setpoint': 'warm'},
        }).decode(_thermostatCapabilities).error,
        ProtocolErrorCode.invalidPayload,
      );
      expect(
        set({}).decode(_thermostatCapabilities).error,
        ProtocolErrorCode.invalidPayload,
      );
    });

    test('higher protocol version', () {
      expect(
        set({
          'thermostat': {'setpoint': 22},
        }, v: 2).decode(_thermostatCapabilities).error,
        ProtocolErrorCode.unsupportedVersion,
      );
    });

    test('expires 10 s after ts', () {
      final payload = command.toPayload();
      DateTime at(int ms) =>
          DateTime.fromMillisecondsSinceEpoch(payload.ts + ms);
      expect(payload.isExpired(at(0)), isFalse);
      expect(payload.isExpired(at(10000)), isFalse);
      expect(payload.isExpired(at(10001)), isTrue);
      expect(payload.isExpired(at(-60000)), isFalse);
    });
  });

  group('ack', () {
    test('success', () {
      final ack = AckPayload.fromJson(
        _json('{"v":1,"commandId":"c1","ok":true,"ts":1794500000120}'),
      );
      expect(ack.toResult(), const CommandResult.acked(commandId: 'c1'));
      expect(AckPayload.fromJson(_wire(ack.toJson())), ack);
    });

    test('failure with snake_case code', () {
      final ack = AckPayload.fromJson(
        _json(
          '{"v":1,"commandId":"c1","ok":false,'
          '"error":{"code":"out_of_range","message":"level must be 0..100"}}',
        ),
      );
      expect(
        ack.toResult(),
        const CommandResult.failed(
          commandId: 'c1',
          code: ProtocolErrorCode.outOfRange,
          message: 'level must be 0..100',
        ),
      );
      expect((_wire(ack.toJson())['error'] as Map)['code'], 'out_of_range');
    });

    test('every error code has the documented wire name', () {
      String wire(ProtocolErrorCode code) =>
          AckError(code: code).toJson()['code'] as String;
      expect(ProtocolErrorCode.values.map(wire), [
        'invalid_payload',
        'unsupported_version',
        'unsupported_capability',
        'read_only',
        'out_of_range',
        'busy',
        'hardware_fault',
        'not_allowed',
        'expired',
        'unknown',
      ]);
    });

    test('unknown code and missing error are generic failures', () {
      final unknown = AckPayload.fromJson(
        _json('{"v":1,"commandId":"c1","ok":false,"error":{"code":"melted"}}'),
      );
      final missing = AckPayload.fromJson(
        _json('{"v":1,"commandId":"c1","ok":false}'),
      );
      for (final ack in [unknown, missing]) {
        final result = ack.toResult();
        expect(result.status, CommandStatus.failed);
        expect((result as CommandFailed).code, ProtocolErrorCode.unknown);
      }
    });
  });

  test('home with rooms and a scene round trips through JSON', () {
    const home = Home(
      id: 'demo-home',
      name: 'Demo',
      rooms: [
        Room(id: 'living-room', name: 'Living', kind: RoomKind.livingRoom),
      ],
      scenes: [
        Scene(
          id: 'movie',
          name: 'Movie night',
          actions: [
            SceneAction(
              deviceId: 'lr-lamp',
              patches: {
                'onOff': CapabilityPatch.onOff(on: true),
                'brightness': CapabilityPatch.brightness(level: 20),
              },
            ),
          ],
        ),
      ],
      members: [
        HomeMember(
          user: User(id: 'u1', name: 'Daniel'),
          role: Role.owner,
        ),
      ],
    );
    expect(Home.fromJson(_wire(home.toJson())), home);
    expect(home.room('living-room')?.name, 'Living');
    expect(home.room('nope'), isNull);
  });
}
