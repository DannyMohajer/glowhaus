import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:test/test.dart';

void main() {
  final devices = DemoHome.devices();
  final descriptors = devices.map((d) => d.descriptor).toList();

  test('one home with four rooms and twelve devices', () {
    expect(DemoHome.home.id, DemoHome.homeId);
    expect(DemoHome.home.rooms.map((r) => r.name), [
      'Living Room',
      'Bedroom',
      'Kitchen',
      'Entrance',
    ]);
    expect(devices, hasLength(12));
  });

  test('ids are valid and unique', () {
    expect(Ids.isValidHomeId(DemoHome.homeId), isTrue);
    expect(descriptors.map((d) => d.id).toSet(), hasLength(12));
    for (final descriptor in descriptors) {
      expect(Ids.isValidDeviceId(descriptor.id), isTrue, reason: descriptor.id);
      for (final capability in descriptor.capabilities) {
        expect(
          Ids.isValidCapabilityId(capability.id),
          isTrue,
          reason: '${descriptor.id}/${capability.id}',
        );
      }
    }
  });

  test('every device sits in an existing room; every room has devices', () {
    final roomIds = DemoHome.home.rooms.map((r) => r.id).toSet();
    expect(descriptors.map((d) => d.roomHint).toSet(), roomIds);
  });

  test('covers every device type and every capability kind', () {
    expect(
      descriptors.map((d) => d.type).toSet(),
      DeviceType.values.toSet()..remove(DeviceType.unknown),
    );
    expect(
      descriptors.expand((d) => d.capabilities).map((c) => c.kind).toSet(),
      CapabilityKind.values.toSet()..remove(CapabilityKind.unknown),
    );
  });

  test('covers plain, dimmable and colour lights and a 3-gang switch', () {
    final lights = descriptors
        .where((d) => d.type == DeviceType.light)
        .map((d) => d.capabilities.map((c) => c.kind).toSet())
        .toList();
    expect(lights, anyElement(equals({CapabilityKind.onOff})));
    expect(
      lights,
      anyElement(equals({CapabilityKind.onOff, CapabilityKind.brightness})),
    );
    expect(lights.any((kinds) => kinds.contains(CapabilityKind.color)), isTrue);
    expect(
      descriptors
          .singleWhere((d) => d.type == DeviceType.wallSwitch)
          .capabilities
          .where((c) => c.kind == CapabilityKind.onOff),
      hasLength(3),
    );
  });

  test('initial state has exactly one matching entry per capability', () {
    for (final device in devices) {
      final descriptor = device.descriptor;
      expect(
        device.initialState.keys.toSet(),
        descriptor.capabilities.map((c) => c.id).toSet(),
        reason: descriptor.id,
      );
      for (final capability in descriptor.capabilities) {
        expect(
          device.initialState[capability.id]!.kind,
          capability.kind,
          reason: '${descriptor.id}/${capability.id}',
        );
      }
    }
  });

  test('typed configs parse', () {
    Capability capability(String deviceId, String id) => descriptors
        .singleWhere((d) => d.id == deviceId)
        .capabilities
        .singleWhere((c) => c.id == id);
    expect(
      capability('lr-thermostat', 'thermostat').thermostatConfig,
      isNotNull,
    );
    expect(
      capability('lr-lamp', 'colorTemperature').colorTemperatureConfig,
      isNotNull,
    );
    expect(capability('en-camera', 'camera').cameraConfig!.streams, isNotEmpty);
  });

  test('scenes only reference existing devices with valid patches', () {
    expect(DemoHome.home.scenes, isNotEmpty);
    for (final scene in DemoHome.home.scenes) {
      for (final action in scene.actions) {
        final descriptor = descriptors.singleWhere(
          (d) => d.id == action.deviceId,
        );
        for (final MapEntry(key: id, value: patch) in action.patches.entries) {
          final capability = descriptor.capabilities.singleWhere(
            (c) => c.id == id,
          );
          expect(patch.validate(capability), isNull, reason: scene.id);
        }
      }
    }
  });

  test('descriptors survive the wire format', () {
    for (final descriptor in descriptors) {
      expect(DeviceDescriptor.fromJson(descriptor.toJson()), descriptor);
    }
  });

  test('every default name has a translation key', () {
    final keys = <String?>[
      ...DemoHome.home.rooms.map((room) => room.nameKey),
      ...DemoHome.home.scenes.map((scene) => scene.nameKey),
      ...descriptors.map((descriptor) => descriptor.nameKey),
      for (final descriptor in descriptors)
        for (final capability in descriptor.capabilities)
          if (capability.label != null) capability.labelKey,
    ];
    expect(keys, everyElement(isNotNull));
    expect(keys.toSet(), DemoNames.all.toSet());
  });
}
