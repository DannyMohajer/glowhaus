import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:test/test.dart';

const String _home = DemoHome.homeId;
const TopicCodec _topics = TopicCodec();
final DateTime _epoch = DateTime.utc(2026, 11, 13, 12);

/// An app-side observer that speaks raw MQTT, so these tests check the
/// bytes on the wire against docs/protocol.md rather than any app code.
/// A connection whose broker can be made to refuse connects.
class _FlakyConnection implements MqttConnection {
  new(this._inner);

  final MqttConnection _inner;
  bool refuse = false;

  @override
  MqttConnectionState get currentState => _inner.currentState;

  @override
  Stream<MqttConnectionState> get state => _inner.state;

  @override
  Stream<MqttMessage> get messages => _inner.messages;

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) {
    if (refuse) throw const MqttConnectionException('broker away');
    return _inner.connect(
      clientId: clientId,
      will: will,
      login: login,
      keepAlive: keepAlive,
    );
  }

  @override
  Future<void> subscribe(String filter, {MqttQos qos = MqttQos.atLeastOnce}) =>
      _inner.subscribe(filter, qos: qos);

  @override
  Future<void> unsubscribe(String filter) => _inner.unsubscribe(filter);

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) => _inner.publish(topic, payload, qos: qos, retain: retain);

  @override
  Future<void> disconnect() => _inner.disconnect();

  @override
  Future<void> dispose() => _inner.dispose();
}

class _Wire {
  new(this.async, this.broker) {
    connection = broker.client();
    connection.messages.listen(received.add);
  }

  final FakeAsync async;
  final InMemoryBroker broker;
  late final MqttConnection connection;
  final received = <MqttMessage>[];
  var _count = 0;

  DateTime now() => _epoch.add(async.elapsed);

  void connect() {
    unawaited(
      connection.connect(clientId: 'wire').then((_) async {
        await connection.subscribe('glowhaus/$_home/+/state');
        await connection.subscribe('glowhaus/$_home/+/ack');
        await connection.subscribe('glowhaus/$_home/+/availability');
        await connection.subscribe(
          _topics.discovery(_home),
          qos: MqttQos.atMostOnce,
        );
      }),
    );
    async.flushMicrotasks();
  }

  Iterable<MqttMessage> on(String deviceId, DeviceChannel channel) => received
      .where((m) => m.topic == _topics.device(_home, deviceId, channel));

  Map<String, dynamic> json(MqttMessage m) =>
      jsonDecode(m.text) as Map<String, dynamic>;

  Iterable<DiscoveryMessage> get discovery => received
      .where((m) => m.topic == _topics.discovery(_home))
      .map((m) => DiscoveryMessage.fromJson(json(m)));

  /// Publishes a set and returns its command id.
  String set(
    String deviceId,
    Map<String, Map<String, dynamic>> set, {
    String? id,
    int? ts,
    bool retain = false,
  }) {
    final commandId = id ?? 'w${_count++}';
    unawaited(
      connection.publishText(
        _topics.device(_home, deviceId, DeviceChannel.set),
        jsonEncode(
          SetPayload(
            commandId: commandId,
            ts: ts ?? now().millisecondsSinceEpoch,
            set: set,
          ).toJson(),
        ),
        retain: retain,
      ),
    );
    async.flushMicrotasks();
    return commandId;
  }

  void query() {
    unawaited(
      connection.publishText(
        _topics.discovery(_home),
        jsonEncode(
          DiscoveryMessage.query(ts: now().millisecondsSinceEpoch).toJson(),
        ),
        qos: MqttQos.atMostOnce,
      ),
    );
    async.flushMicrotasks();
  }

  List<AckPayload> acks(String deviceId) => [
    for (final m in on(deviceId, DeviceChannel.ack))
      AckPayload.fromJson(json(m)),
  ];

  List<StatePayload> states(String deviceId) => [
    for (final m in on(deviceId, DeviceChannel.state))
      StatePayload.fromJson(json(m)),
  ];

  List<String> availability(String deviceId) => [
    for (final m in on(deviceId, DeviceChannel.availability))
      json(m)['status'] as String,
  ];
}

void _run(
  void Function(_Wire wire, VirtualHome home) body, {
  SimulationConfig config = const SimulationConfig(
    latency: Duration(milliseconds: 100),
    latencyJitter: 0,
  ),
  Iterable<DeviceSpec>? specs,
  Duration? ambientInterval,
}) {
  fakeAsync((async) {
    final broker = InMemoryBroker();
    final wire = _Wire(async, broker)..connect();
    final home = VirtualHome(
      homeId: _home,
      specs: specs ?? DemoHome.devices(),
      connectionFactory: (_) => broker.client(),
      config: config,
      ambientInterval: ambientInterval,
      random: Random(5),
      clock: wire.now,
    );
    unawaited(home.start());
    async.flushMicrotasks();
    body(wire, home);
    unawaited(home.dispose());
    unawaited(broker.close());
    async.flushMicrotasks();
  });
}

const _lampOff = {
  'onOff': {'on': false},
};

void main() {
  test('revision 1.1: every device leaves its descriptor retained', () {
    _run((wire, home) {
      for (final spec in DemoHome.devices()) {
        final id = spec.descriptor.id;
        final retained = wire.broker.retained(
          _topics.device(_home, id, DeviceChannel.info),
        );
        expect(retained, isNotNull, reason: '$id has a retained info');
        final info = InfoPayload.fromJson(
          jsonDecode(retained!.text) as Map<String, dynamic>,
        );
        expect(info.device, spec.descriptor);
        expect(retained.qos, MqttQos.atLeastOnce);
      }
      expect(
        home.device('kt-motion')!.online,
        isFalse,
        reason: 'the offline motion sensor still left its info behind',
      );
    });
  });

  test('on connect: will registered, online + state retained, announce', () {
    _run((wire, home) {
      // Twelve devices: eleven online, the motion sensor announced then
      // offline (section 5.1 and 6).
      final announces = wire.discovery.whereType<DiscoveryAnnounce>();
      expect(announces.map((a) => a.device.id).toSet(), hasLength(13));
      expect(wire.availability('lr-lamp'), ['online']);
      expect(wire.availability('kt-motion'), ['offline']);
      expect(wire.states('lr-lamp'), hasLength(1));
      expect(wire.states('kt-motion'), isEmpty);

      final retained = wire.broker.retained(
        _topics.device(_home, 'lr-lamp', DeviceChannel.state),
      );
      expect(retained, isNotNull, reason: 'state is retained');
      expect(
        wire.broker
            .retained(
              _topics.device(_home, 'lr-lamp', DeviceChannel.availability),
            )
            ?.text,
        contains('"online"'),
      );
      expect(wire.broker.connectedClientIds, contains('device-$_home-lr-lamp'));
      expect(
        wire.broker.connectedClientIds,
        isNot(contains('device-$_home-kt-motion')),
      );
    });
  });

  test('every payload carries v: 1 and a ts', () {
    _run((wire, home) {
      for (final message in wire.received) {
        final json = wire.json(message);
        expect(json['v'], 1, reason: message.topic);
        expect(json['ts'], isA<int>(), reason: message.topic);
      }
    });
  });

  test('a query is answered by every online device, with jitter', () {
    _run((wire, home) {
      wire.received.clear();
      wire.query();
      expect(wire.discovery.whereType<DiscoveryAnnounce>(), isEmpty);
      wire.async.elapse(Protocol.announceJitter);
      final ids = wire.discovery
          .whereType<DiscoveryAnnounce>()
          .map((a) => a.device.id)
          .toSet();
      expect(ids, hasLength(12));
      expect(ids, isNot(contains('kt-motion')), reason: 'offline stays quiet');
    });
  });

  test('set: ack after the latency, state after the ack', () {
    _run((wire, home) {
      final id = wire.set('lr-lamp', _lampOff);
      wire.async.elapse(const Duration(milliseconds: 99));
      expect(wire.acks('lr-lamp'), isEmpty);
      wire.async.elapse(const Duration(milliseconds: 1));
      final ack = wire.acks('lr-lamp').single;
      expect(ack.commandId, id);
      expect(ack.ok, isTrue);
      expect(wire.states('lr-lamp'), hasLength(1), reason: 'not yet');
      wire.async.elapse(const Duration(milliseconds: 60));
      final state = wire.states('lr-lamp').last;
      expect(state.state['onOff'], {'on': false});
      expect(home.stateOf('lr-lamp')!['onOff'], const OnOffState(on: false));
      // Section 8.2: the ack is not retained; section 7: the state is.
      expect(wire.on('lr-lamp', DeviceChannel.ack).single.retained, isFalse);
      expect(
        wire.broker
            .retained(_topics.device(_home, 'lr-lamp', DeviceChannel.state))
            ?.text,
        contains('"on":false'),
      );
    });
  });

  test('validation: the protocol error codes, atomic', () {
    _run((wire, home) {
      // (device, set, expected error code)
      const cases = <(String, Map<String, Map<String, dynamic>>, String)>[
        (
          'lr-ceiling',
          {
            'nope': {'on': true},
          },
          'unsupported_capability',
        ),
        (
          'br-climate',
          {
            'temperatureSensor': {'celsius': 30},
          },
          'read_only',
        ),
        (
          'lr-ceiling',
          {
            'onOff': {'on': false},
            'brightness': {'level': 101},
          },
          'out_of_range',
        ),
        ('lr-ceiling', {}, 'invalid_payload'),
      ];
      for (final (device, set, code) in cases) {
        wire.received.clear();
        wire.set(device, set);
        wire.async.elapse(const Duration(milliseconds: 200));
        final ack = wire.acks(device).single;
        expect(ack.ok, isFalse, reason: code);
        expect(ack.error!.code.name, _camel(code), reason: code);
        expect(wire.states(device), isEmpty, reason: 'nothing applied');
      }
      expect(home.stateOf('lr-ceiling')!['onOff'], const OnOffState(on: true));
    });
  });

  test('expired commands are rejected without being applied', () {
    _run((wire, home) {
      wire.set(
        'lr-lamp',
        _lampOff,
        ts: wire.now().millisecondsSinceEpoch - 11000,
      );
      wire.async.elapse(const Duration(milliseconds: 200));
      expect(
        wire.acks('lr-lamp').single.error!.code,
        ProtocolErrorCode.expired,
      );
      expect(home.stateOf('lr-lamp')!['onOff'], const OnOffState(on: true));
    });
  });

  test('a redelivered command gets the same ack and is applied once', () {
    _run((wire, home) {
      wire.set('lr-lamp', _lampOff, id: 'same');
      wire.async.elapse(const Duration(milliseconds: 200));
      wire.set('lr-lamp', const {
        'onOff': {'on': true},
      }, id: 'same');
      wire.async.elapse(const Duration(milliseconds: 200));
      final acks = wire.acks('lr-lamp');
      expect(acks, hasLength(2));
      expect(acks.every((a) => a.ok && a.commandId == 'same'), isTrue);
      expect(home.stateOf('lr-lamp')!['onOff'], const OnOffState(on: false));
      expect(wire.states('lr-lamp'), hasLength(2), reason: 'initial + one');
    });
  });

  test('a retained set is ignored', () {
    _run((wire, home) {
      wire.set('lr-lamp', _lampOff, retain: true);
      wire.async.elapse(const Duration(seconds: 1));
      // Delivered live, it is ignored by the retained-flag rule only when
      // the broker marks it so; a new subscriber would get it flagged.
      final late = VirtualDevice(
        homeId: _home,
        spec: DemoHome.devices().firstWhere(
          (d) => d.descriptor.id == 'lr-lamp',
        ),
        connection: wire.broker.client(),
        clock: wire.now,
      );
      unawaited(late.goOnline());
      wire.async.elapse(const Duration(seconds: 1));
      expect(late.state['onOff'], const OnOffState(on: true));
      unawaited(late.dispose());
    });
  });

  test('busy rejections and lost commands follow the config', () {
    _run(
      config: const SimulationConfig(
        latency: Duration(milliseconds: 10),
        latencyJitter: 0,
        failureRate: 1,
      ),
      (wire, home) {
        wire.set('lr-lamp', _lampOff);
        wire.async.elapse(const Duration(milliseconds: 50));
        expect(wire.acks('lr-lamp').single.error!.code, ProtocolErrorCode.busy);

        home.config = home.config.copyWith(failureRate: 0, timeoutRate: 1);
        wire.set('lr-lamp', _lampOff);
        wire.async.elapse(const Duration(seconds: 5));
        expect(wire.acks('lr-lamp'), hasLength(1), reason: 'lost: no ack');
        expect(home.stateOf('lr-lamp')!['onOff'], const OnOffState(on: true));
      },
    );
  });

  test('a curtain acks at once and reports progress while moving', () {
    _run((wire, home) {
      wire.set('lr-curtain', const {
        'position': {'target': 100},
      });
      wire.async.elapse(const Duration(milliseconds: 200));
      expect(wire.acks('lr-curtain').single.ok, isTrue);
      final first = wire.states('lr-curtain').last.state['position']!;
      expect(first['moving'], isTrue);
      expect(first['position'], 60);
      wire.async.elapse(const Duration(seconds: 4));
      final last = wire.states('lr-curtain').last.state['position']!;
      expect(last, {'position': 100, 'target': 100, 'moving': false});
      expect(wire.states('lr-curtain').length, greaterThan(5));
    });
  });

  test('going offline publishes offline itself; the will covers a crash', () {
    _run((wire, home) {
      unawaited(home.setOnline('lr-lamp', online: false));
      wire.async.flushMicrotasks();
      expect(wire.availability('lr-lamp'), ['online', 'offline']);
      expect(
        wire.broker.connectedClientIds,
        isNot(contains('device-$_home-lr-lamp')),
      );
      wire.set('lr-lamp', _lampOff);
      wire.async.elapse(const Duration(seconds: 1));
      expect(wire.acks('lr-lamp'), isEmpty, reason: 'nobody home');

      unawaited(home.setOnline('lr-lamp', online: true));
      wire.async.elapse(const Duration(seconds: 1));
      expect(wire.availability('lr-lamp'), ['online', 'offline', 'online']);

      // A crash: the broker publishes the will.
      wire.broker.drop('device-$_home-lr-lamp');
      wire.async.flushMicrotasks();
      expect(wire.availability('lr-lamp').last, 'offline');
      expect(home.device('lr-lamp')!.online, isFalse);

      // Then the device comes back by itself, after a second or so.
      wire.async.elapse(const Duration(milliseconds: 1600));
      expect(home.device('lr-lamp')!.online, isTrue);
      expect(wire.availability('lr-lamp').last, 'online');
      expect(wire.broker.connectedClientIds, contains('device-$_home-lr-lamp'));
    });
  });

  test('a broker that stays away is retried with growing pauses', () {
    fakeAsync((async) {
      final broker = InMemoryBroker();
      final wire = _Wire(async, broker)..connect();
      final flaky = _FlakyConnection(broker.client());
      final device = VirtualDevice(
        homeId: _home,
        spec: DemoHome.devices().firstWhere(
          (d) => d.descriptor.id == 'lr-lamp',
        ),
        connection: flaky,
        random: Random(1),
        clock: wire.now,
      );
      unawaited(device.start());
      async.flushMicrotasks();
      expect(device.online, isTrue);

      flaky.refuse = true;
      broker.drop(device.clientId);
      async.flushMicrotasks();
      expect(device.online, isFalse);

      // 1 s, 2 s, 4 s (each up to 50% longer): three tries within 11 s.
      async.elapse(const Duration(seconds: 11));
      expect(device.reconnectAttempts, 3);
      expect(device.online, isFalse);

      flaky.refuse = false;
      async.elapse(const Duration(seconds: 13));
      expect(device.online, isTrue, reason: 'the fourth try succeeds');
      expect(wire.availability('lr-lamp').last, 'online');

      unawaited(device.dispose());
      unawaited(broker.close());
      async.flushMicrotasks();
    });
  });

  test('a device that boots before its broker keeps trying', () {
    fakeAsync((async) {
      final broker = InMemoryBroker();
      final wire = _Wire(async, broker)..connect();
      VirtualDevice device(String id, _FlakyConnection connection) =>
          VirtualDevice(
            homeId: _home,
            spec: DemoHome.devices().firstWhere((d) => d.descriptor.id == id),
            connection: connection,
            random: Random(2),
            clock: wire.now,
          );
      final lampLink = _FlakyConnection(broker.client())..refuse = true;
      final motionLink = _FlakyConnection(broker.client())..refuse = true;
      final lamp = device('lr-lamp', lampLink);
      final motion = device('kt-motion', motionLink);

      var started = 0;
      unawaited(lamp.start().then((_) => started++));
      unawaited(motion.start().then((_) => started++));
      async.flushMicrotasks();
      expect(started, 2, reason: 'start does not throw on a missing broker');
      expect(lamp.online, isFalse);

      async.elapse(const Duration(seconds: 4));
      expect(lamp.reconnectAttempts, greaterThan(0));
      lampLink.refuse = false;
      motionLink.refuse = false;
      async.elapse(const Duration(seconds: 10));

      expect(lamp.online, isTrue);
      expect(wire.availability('lr-lamp').last, 'online');
      expect(motion.online, isFalse, reason: 'an offline spec stays offline');
      expect(wire.availability('kt-motion').last, 'offline');
      expect(
        wire.on('kt-motion', DeviceChannel.availability),
        isNotEmpty,
        reason: 'but it did get through once to say so',
      );

      unawaited(lamp.dispose());
      unawaited(motion.dispose());
      unawaited(broker.close());
      async.flushMicrotasks();
    });
  });

  test('a press on the device itself reports state, with no ack', () {
    _run((wire, home) {
      final lamp = home.device('lr-lamp')!;
      final wasOn = (lamp.state['onOff']! as OnOffState).on;
      var changes = 0;
      lamp.changes.listen((_) => changes++);
      wire.received.clear();
      unawaited(lamp.pressLocal({'onOff': CapabilityPatch.onOff(on: !wasOn)}));
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('lr-lamp').last.state['onOff'], {'on': !wasOn});
      expect(wire.on('lr-lamp', DeviceChannel.ack), isEmpty);
      expect(changes, greaterThan(0));

      // Pressing what it already is changes nothing and says nothing.
      wire.received.clear();
      unawaited(lamp.pressLocal({'onOff': CapabilityPatch.onOff(on: !wasOn)}));
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('lr-lamp'), isEmpty);

      // Unplugged: no power, so the button does nothing.
      unawaited(home.setOnline('lr-lamp', online: false));
      wire.async.elapse(const Duration(milliseconds: 100));
      wire.received.clear();
      unawaited(lamp.pressLocal({'onOff': CapabilityPatch.onOff(on: wasOn)}));
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('lr-lamp'), isEmpty);
      expect(lamp.state['onOff'], CapabilityState.onOff(on: !wasOn));
    });
  });

  test('a sensor reading is reported as state, read-only or not', () {
    _run((wire, home) {
      final door = home.device('en-door')!;
      wire.received.clear();
      unawaited(
        door.sense({
          'contactSensor': const CapabilityState.contactSensor(open: true),
        }),
      );
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('en-door').last.state['contactSensor'], {
        'open': true,
      });
      expect(wire.on('en-door', DeviceChannel.ack), isEmpty);

      // A reading for a capability the device lacks, or of another kind,
      // changes nothing and says nothing.
      wire.received.clear();
      unawaited(
        door.sense({
          'motionSensor': const CapabilityState.motionSensor(motion: true),
          'contactSensor': const CapabilityState.onOff(on: false),
        }),
      );
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('en-door'), isEmpty);

      // Unplugged, it notices nothing.
      unawaited(home.setOnline('en-door', online: false));
      wire.async.elapse(const Duration(milliseconds: 100));
      wire.received.clear();
      unawaited(
        door.sense({
          'contactSensor': const CapabilityState.contactSensor(open: false),
        }),
      );
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('en-door'), isEmpty);
      expect(
        door.state['contactSensor'],
        const CapabilityState.contactSensor(open: true),
      );
    });
  });

  test('a home snapshot survives the trip and resumes where it was', () {
    _run((wire, home) {
      unawaited(
        home.device('lr-lamp')!.pressLocal({
          'onOff': const CapabilityPatch.onOff(on: false),
        }),
      );
      unawaited(home.setOnline('kt-switch', online: false));
      wire.async.elapse(const Duration(milliseconds: 100));
      final snapshot = {
        for (final MapEntry(:key, :value) in home.snapshot().entries)
          key: DeviceSnapshot.fromJson(
            jsonDecode(jsonEncode(value.toJson())) as Map<String, Object?>,
            home.device(key)!.spec.descriptor.capabilities,
          ),
      };
      unawaited(home.stop());
      wire.async.elapse(const Duration(milliseconds: 100));

      unawaited(home.resume(snapshot));
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(home.device('lr-lamp')!.online, isTrue);
      expect(
        home.stateOf('lr-lamp')!['onOff'],
        const CapabilityState.onOff(on: false),
      );
      expect(home.device('kt-switch')!.online, isFalse);
      expect(wire.states('lr-lamp').last.state['onOff'], {'on': false});
    });
  });

  test('paused ambient: no drift, commands and presses still answered', () {
    _run(ambientInterval: const Duration(seconds: 1), (wire, home) {
      home.ambientPaused = true;
      wire.received.clear();
      wire.async.elapse(const Duration(seconds: 10));
      for (final id in ['kt-outlet', 'lr-thermostat', 'br-climate']) {
        expect(wire.states(id), isEmpty, reason: id);
      }

      wire.set('lr-lamp', _lampOff);
      wire.async.elapse(const Duration(milliseconds: 200));
      expect(wire.acks('lr-lamp').single.ok, isTrue);
      expect(wire.states('lr-lamp').last.state['onOff'], {'on': false});
      unawaited(
        home.device('br-reading')!.pressLocal(const {
          'onOff': CapabilityPatch.onOff(on: true),
        }),
      );
      wire.async.elapse(const Duration(milliseconds: 100));
      expect(wire.states('br-reading').last.state['onOff'], {'on': true});

      home.ambientPaused = false;
      wire.received.clear();
      wire.async.elapse(const Duration(seconds: 10));
      expect(wire.states('kt-outlet').length, greaterThan(5), reason: 'watts');
    });
  });

  group('a thermostat with the room to itself', () {
    /// The demo's thermostat, with the room it is in, off the wire.
    DeviceModel thermostat() => DeviceModel(
      DemoHome.devices().firstWhere((s) => s.descriptor.id == 'lr-thermostat'),
    );

    ThermostatState modeOf(DeviceModel model) =>
        model.state.values.whereType<ThermostatState>().single;

    double roomOf(DeviceModel model) =>
        model.state.values.whereType<TemperatureSensorState>().single.celsius;

    /// Two seconds of the demo's own rhythm, [times] over.
    List<ThermostatAction> run(DeviceModel model, int times) {
      final random = Random(7);
      return [
        for (var i = 0; i < times; i++)
          () {
            model.ambientTick(random, elapsed: const Duration(seconds: 2));
            return modeOf(model).action;
          }(),
      ];
    }

    test('heats to the setpoint and then rests there, instead of starting '
        'and stopping every two seconds', () {
      final model = thermostat();
      final setpoint = modeOf(model).setpoint;
      expect(roomOf(model), lessThan(setpoint), reason: 'a cold room');

      final actions = run(model, 60);
      expect(roomOf(model), setpoint);
      expect(modeOf(model).action, ThermostatAction.idle);
      // It heats, reaches the setpoint once, and is not heard from again.
      final settled = actions.indexOf(ThermostatAction.idle);
      expect(settled, greaterThan(0));
      expect(
        actions.skip(settled),
        everyElement(ThermostatAction.idle),
        reason: 'no flicking on and off at the setpoint',
      );
    });

    test('the room holds while it is on, and drifts back once it is off', () {
      final model = thermostat();
      run(model, 60);
      final setpoint = modeOf(model).setpoint;
      expect(roomOf(model), setpoint);

      model.applyLocal({
        'thermostat': const CapabilityPatch.thermostat(
          mode: ThermostatMode.off,
        ),
      });
      run(model, 20);
      expect(roomOf(model), lessThan(setpoint), reason: 'left to itself');
      expect(modeOf(model).action, ThermostatAction.idle);

      // Switched back on, it has something to do again.
      model.applyLocal({
        'thermostat': const CapabilityPatch.thermostat(
          mode: ThermostatMode.heat,
        ),
      });
      run(model, 1);
      expect(modeOf(model).action, ThermostatAction.heating);
    });
  });

  test('ambient drift publishes state without a command', () {
    _run(ambientInterval: const Duration(seconds: 1), (wire, home) {
      wire.received.clear();
      wire.async.elapse(const Duration(seconds: 10));
      expect(wire.states('kt-outlet').length, greaterThan(5), reason: 'watts');
      expect(wire.on('kt-outlet', DeviceChannel.ack), isEmpty);
    });
  });
}

String _camel(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
