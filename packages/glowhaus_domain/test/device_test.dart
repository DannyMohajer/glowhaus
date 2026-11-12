import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:test/test.dart';

void main() {
  const wallSwitch = Device(
    id: 'kt-switch',
    homeId: 'demo-home',
    type: DeviceType.wallSwitch,
    name: 'Kitchen switch',
    capabilities: [
      Capability(id: 'ch1', kind: CapabilityKind.onOff, label: 'Ceiling'),
      Capability(id: 'ch2', kind: CapabilityKind.onOff, label: 'Counter'),
    ],
    state: {
      'ch1': CapabilityState.onOff(on: false),
      'ch2': CapabilityState.onOff(on: false),
    },
    availability: DeviceAvailability.online,
  );

  final lamp = Device(
    id: 'lr-lamp',
    homeId: 'demo-home',
    type: DeviceType.light,
    name: 'Lamp',
    capabilities: [
      Capability.of(CapabilityKind.onOff),
      Capability.of(CapabilityKind.brightness),
    ],
    state: const {
      'onOff': CapabilityState.onOff(on: true),
      'brightness': CapabilityState.brightness(level: 40),
    },
    availability: DeviceAvailability.online,
  );

  test('capability lookups', () {
    expect(lamp.has(CapabilityKind.brightness), isTrue);
    expect(lamp.has(CapabilityKind.color), isFalse);
    expect(lamp.capability('brightness')?.kind, CapabilityKind.brightness);
    expect(lamp.capability('nope'), isNull);
    expect(wallSwitch.capabilitiesOf(CapabilityKind.onOff), hasLength(2));
  });

  test('typed state access', () {
    expect(lamp.stateOf<BrightnessState>('brightness')?.level, 40);
    expect(lamp.stateOf<OnOffState>('brightness'), isNull);
    expect(lamp.firstState<OnOffState>()?.on, isTrue);
    expect(lamp.firstState<LockState>(), isNull);
  });

  test('isOn is true when any channel is on', () {
    expect(wallSwitch.isOn, isFalse);
    expect(
      wallSwitch.applyPatches(const {
        'ch2': CapabilityPatch.onOff(on: true),
      }).isOn,
      isTrue,
    );
  });

  test('isActive needs a reachable device that is doing something', () {
    expect(lamp.isActive, isTrue);
    expect(
      lamp.copyWith(availability: DeviceAvailability.offline).isActive,
      isFalse,
    );
    expect(wallSwitch.isActive, isFalse);

    final thermostat = Device(
      id: 't',
      homeId: 'demo-home',
      type: DeviceType.thermostat,
      name: 'T',
      capabilities: [Capability.of(CapabilityKind.thermostat)],
      state: const {
        'thermostat': CapabilityState.thermostat(
          setpoint: 22,
          mode: ThermostatMode.heat,
        ),
      },
    );
    expect(thermostat.isActive, isTrue);
    expect(
      thermostat.applyPatches(const {
        'thermostat': CapabilityPatch.thermostat(mode: ThermostatMode.off),
      }).isActive,
      isFalse,
    );
  });

  test('applyPatches is an immutable overlay', () {
    const patches = {
      'onOff': CapabilityPatch.onOff(on: false),
      'brightness': CapabilityPatch.brightness(level: 90),
      'ghost': CapabilityPatch.lock(locked: true),
    };
    final next = lamp.applyPatches(patches);
    expect(next.stateOf<OnOffState>('onOff')?.on, isFalse);
    expect(next.stateOf<BrightnessState>('brightness')?.level, 90);
    expect(next.state.containsKey('ghost'), isFalse);
    expect(lamp.stateOf<BrightnessState>('brightness')?.level, 40);
    expect(lamp.applyPatches(const {}), same(lamp));
  });

  test('satisfies compares reported state with pending patches', () {
    const patches = {'brightness': CapabilityPatch.brightness(level: 90)};
    expect(lamp.satisfies(patches), isFalse);
    expect(lamp.applyPatches(patches).satisfies(patches), isTrue);
    expect(lamp.satisfies(const {}), isTrue);
  });

  test('fromDescriptor uses the room hint unless a room is given', () {
    final descriptor = DeviceDescriptor(
      id: 'lr-lamp',
      type: DeviceType.light,
      name: 'Lamp',
      capabilities: [Capability.of(CapabilityKind.onOff)],
      roomHint: 'living-room',
      firmware: '1.0.0',
    );
    final hinted = Device.fromDescriptor(descriptor, homeId: 'demo-home');
    expect(hinted.roomId, 'living-room');
    expect(hinted.firmware, '1.0.0');
    expect(hinted.availability, DeviceAvailability.unknown);
    expect(hinted.state, isEmpty);
    expect(
      Device.fromDescriptor(
        descriptor,
        homeId: 'demo-home',
        roomId: 'bedroom',
      ).roomId,
      'bedroom',
    );
  });

  group('names', () {
    final descriptor = DeviceDescriptor(
      id: 'lr-lamp',
      type: DeviceType.light,
      name: 'Floor lamp',
      nameKey: 'demo.floorLamp',
      capabilities: [Capability.of(CapabilityKind.onOff)],
    );

    test('the descriptor name key carries over to the device', () {
      final device = Device.fromDescriptor(descriptor, homeId: 'h');
      expect(device.nameKey, 'demo.floorLamp');
      expect(
        DeviceDescriptor.fromJson(descriptor.toJson()).nameKey,
        'demo.floorLamp',
      );
    });

    test('renaming clears the key, even to the default text', () {
      final device = Device.fromDescriptor(descriptor, homeId: 'h');
      final renamed = device.renamed('Floor lamp');
      expect(renamed.name, 'Floor lamp');
      expect(renamed.nameKey, isNull);
    });

    test('rooms and scenes drop their key when renamed', () {
      const room = Room(id: 'r', name: 'Kitchen', nameKey: 'demo.kitchen');
      const scene = Scene(id: 's', name: 'Away', nameKey: 'demo.away');
      expect(room.renamed('Küche').nameKey, isNull);
      expect(room.renamed('Küche').name, 'Küche');
      expect(scene.renamed('Out').nameKey, isNull);
      expect(Room.fromJson(room.toJson()).nameKey, 'demo.kitchen');
    });

    test('a descriptor without a key decodes with none', () {
      final json = descriptor.toJson()..remove('nameKey');
      expect(DeviceDescriptor.fromJson(json).nameKey, isNull);
    });
  });

  test('command results map to lifecycle statuses', () {
    expect(
      const CommandResult.acked(commandId: 'c').status,
      CommandStatus.acked,
    );
    expect(
      const CommandResult.failed(
        commandId: 'c',
        code: ProtocolErrorCode.busy,
      ).status,
      CommandStatus.failed,
    );
    expect(
      const CommandResult.timedOut(commandId: 'c').status,
      CommandStatus.timedOut,
    );
    expect(const CommandResult.acked(commandId: 'c').isSuccess, isTrue);
    expect(const CommandResult.timedOut(commandId: 'c').isSuccess, isFalse);
  });
}
