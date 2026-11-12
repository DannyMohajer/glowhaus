import 'package:flutter/widgets.dart' hide LockState;
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

Device _demo(
  String id, {
  Map<String, CapabilityState>? state,
  bool online = true,
}) {
  final seed = DemoHome.devices().firstWhere((d) => d.descriptor.id == id);
  return Device.fromDescriptor(
    seed.descriptor,
    homeId: DemoHome.homeId,
  ).copyWith(
    state: state ?? seed.initialState,
    availability: online
        ? DeviceAvailability.online
        : DeviceAvailability.offline,
  );
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fa = lookupAppLocalizations(const Locale('fa'));
  final readings = Readings(en);

  group('primaryToggle', () {
    test('a light toggles its on/off capability', () {
      final toggle = primaryToggle(_demo('lr-lamp'))!;
      expect(toggle.on, isTrue);
      expect(toggle.patchesFor(on: false), {
        'onOff': const CapabilityPatch.onOff(on: false),
      });
    });

    test('a multi-channel switch toggles every channel together', () {
      final toggle = primaryToggle(_demo('kt-switch'))!;
      expect(toggle.on, isTrue, reason: 'one channel is on');
      expect(toggle.patchesFor(on: false), {
        for (final id in ['ch1', 'ch2', 'ch3'])
          id: const CapabilityPatch.onOff(on: false),
      });
    });

    test('a lock locks and unlocks', () {
      final toggle = primaryToggle(_demo('en-lock'))!;
      expect(toggle.on, isTrue);
      expect(toggle.patchesFor(on: false), {
        'lock': const CapabilityPatch.lock(locked: false),
      });
    });

    test('a thermostat switches between off and its first mode', () {
      final toggle = primaryToggle(_demo('lr-thermostat'))!;
      expect(toggle.on, isTrue);
      expect(toggle.patchesFor(on: false), {
        'thermostat': const CapabilityPatch.thermostat(
          mode: ThermostatMode.off,
        ),
      });
      expect(toggle.patchesFor(on: true), {
        'thermostat': const CapabilityPatch.thermostat(
          mode: ThermostatMode.heat,
        ),
      });
    });

    test('curtains, sensors and cameras have no switch', () {
      for (final id in ['lr-curtain', 'br-climate', 'en-door', 'en-camera']) {
        expect(primaryToggle(_demo(id)), isNull, reason: id);
      }
    });

    test('every command it produces is valid for the device', () {
      for (final seed in DemoHome.devices()) {
        final device = _demo(seed.descriptor.id);
        final toggle = primaryToggle(device);
        if (toggle == null) continue;
        for (final on in [true, false]) {
          for (final MapEntry(:key, :value)
              in toggle.patchesFor(on: on).entries) {
            expect(value.validate(device.capability(key)!), isNull);
          }
        }
      }
    });
  });

  group('deviceStatus', () {
    String status(String id, {Map<String, CapabilityState>? state}) =>
        deviceStatus(readings, _demo(id, state: state));

    test('one line per kind of device', () {
      expect(status('lr-ceiling'), 'On · 70%');
      expect(status('br-reading'), 'Off');
      expect(status('kt-switch'), '1 of 3 on');
      expect(status('lr-curtain'), '60% open');
      expect(status('lr-thermostat'), '22.5° · Idle');
      expect(status('kt-outlet'), 'On · 1,180 W');
      expect(status('en-lock'), 'Locked');
      expect(status('br-climate'), '21.4° · 46%');
      expect(status('en-door'), 'Closed');
      expect(status('en-camera'), 'Live');
    });

    test('states in motion and exceptions', () {
      expect(
        status(
          'lr-curtain',
          state: const {
            'position': CapabilityState.position(
              position: 60,
              target: 100,
              moving: true,
            ),
          },
        ),
        'Opening…',
      );
      expect(
        status(
          'lr-curtain',
          state: const {
            'position': CapabilityState.position(position: 0, target: 0),
          },
        ),
        'Closed',
      );
      expect(
        status(
          'en-lock',
          state: const {
            'lock': CapabilityState.lock(locked: false, jammed: true),
          },
        ),
        'Jammed',
      );
      expect(status('lr-lamp', state: const {}), 'Waiting for device…');
    });

    test('offline wins over everything', () {
      expect(
        deviceStatus(readings, _demo('lr-lamp', online: false)),
        'Offline',
      );
    });

    test('Persian uses Persian digits', () {
      expect(deviceStatus(Readings(fa), _demo('lr-ceiling')), 'روشن · ۷۰٪');
      expect(Readings(fa).temperature(22.5), '۲۲٫۵°');
    });
  });

  test('deviceLooksOn reflects what a person would call "on"', () {
    expect(deviceLooksOn(_demo('lr-lamp')), isTrue);
    expect(deviceLooksOn(_demo('br-reading')), isFalse);
    expect(deviceLooksOn(_demo('lr-curtain')), isTrue, reason: 'open');
    expect(deviceLooksOn(_demo('en-door')), isFalse, reason: 'closed');
    expect(deviceLooksOn(_demo('en-camera')), isFalse);
  });

  test('every demo device and room kind has an icon and a type label', () {
    for (final seed in DemoHome.devices()) {
      expect(deviceIcon(_demo(seed.descriptor.id)), isA<IconData>());
    }
    for (final kind in RoomKind.values) {
      expect(roomIcon(kind), isA<IconData>());
    }
    expect(
      DeviceType.values.map((t) => deviceTypeLabel(en, t)).toSet(),
      hasLength(DeviceType.values.length),
    );
  });

  group('demo names', () {
    test('every default name of the demo home is translated', () {
      final names = [
        ...DemoHome.home.rooms.map((r) => r.name),
        ...DemoHome.home.scenes.map((s) => s.name),
        for (final seed in DemoHome.devices()) ...[
          seed.descriptor.name,
          ...seed.descriptor.capabilities.map((c) => c.label).nonNulls,
        ],
      ];
      for (final name in names) {
        expect(localizedName(en, name), name);
        expect(localizedName(fa, name), isNot(name), reason: name);
      }
    });

    test('names a user typed are shown as typed', () {
      expect(localizedName(fa, "Daniel's desk lamp"), "Daniel's desk lamp");
      expect(localizedName(fa, 'living room'), 'living room');
    });
  });
}
