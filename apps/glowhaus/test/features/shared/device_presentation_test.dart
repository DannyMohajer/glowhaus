import 'package:flutter/widgets.dart' hide LockState;
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart' show DeviceTone;

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

    test('a thermostat switches back on in its last active mode', () {
      ThermostatMode resumes(ThermostatMode? last) {
        final device = _demo(
          'lr-thermostat',
          state: {
            'thermostat': CapabilityState.thermostat(
              setpoint: 21,
              mode: ThermostatMode.off,
              lastActiveMode: last,
            ),
          },
        );
        final toggle = primaryToggle(device)!;
        expect(toggle.on, isFalse);
        final patch =
            toggle.patchesFor(on: true)['thermostat']! as ThermostatPatch;
        return patch.mode!;
      }

      expect(resumes(ThermostatMode.cool), ThermostatMode.cool);
      expect(resumes(ThermostatMode.auto), ThermostatMode.auto);
      expect(resumes(ThermostatMode.heat), ThermostatMode.heat);
      // Never reported: the first mode the device supports.
      expect(resumes(null), ThermostatMode.heat);
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
      expect(deviceStatus(Readings(fa), _demo('lr-ceiling')), 'روشن، ۷۰٪');
      expect(Readings(fa).temperature(22.5), '\u200E۲۲٫۵°\u200E');
    });
  });

  group('deviceTone', () {
    test('switchable devices are active while on', () {
      expect(deviceTone(_demo('lr-lamp')), DeviceTone.active);
      expect(deviceTone(_demo('br-reading')), DeviceTone.neutral);
      expect(deviceTone(_demo('lr-thermostat')), DeviceTone.active);
      expect(
        deviceTone(_demo('lr-lamp', online: false)),
        DeviceTone.neutral,
        reason: 'offline',
      );
    });

    test('a curtain position is not "on"', () {
      expect(deviceTone(_demo('lr-curtain')), DeviceTone.neutral);
      expect(
        deviceTone(
          _demo(
            'lr-curtain',
            state: const {
              'position': CapabilityState.position(position: 100, target: 100),
            },
          ),
        ),
        DeviceTone.neutral,
      );
    });

    test('locked is calm, unlocked or jammed asks for attention', () {
      Device lock({required bool locked, bool jammed = false}) => _demo(
        'en-lock',
        state: {'lock': CapabilityState.lock(locked: locked, jammed: jammed)},
      );
      expect(deviceTone(lock(locked: true)), DeviceTone.neutral);
      expect(deviceTone(lock(locked: false)), DeviceTone.attention);
      expect(
        deviceTone(lock(locked: false, jammed: true)),
        DeviceTone.attention,
      );
      // The tile switch still shows "locked" as on.
      expect(primaryToggle(lock(locked: true))!.on, isTrue);
    });

    test('an open door asks for attention; sensors are otherwise calm', () {
      expect(deviceTone(_demo('en-door')), DeviceTone.neutral);
      expect(
        deviceTone(
          _demo(
            'en-door',
            state: const {
              'contactSensor': CapabilityState.contactSensor(open: true),
            },
          ),
        ),
        DeviceTone.attention,
      );
      expect(deviceTone(_demo('en-camera')), DeviceTone.neutral);
      expect(deviceTone(_demo('br-climate')), DeviceTone.neutral);
    });
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
    test('every seeded key is translated, and English matches the seed', () {
      final named = <(String, String?)>[
        for (final room in DemoHome.home.rooms) (room.name, room.nameKey),
        for (final scene in DemoHome.home.scenes) (scene.name, scene.nameKey),
        for (final seed in DemoHome.devices()) ...[
          (seed.descriptor.name, seed.descriptor.nameKey),
          for (final capability in seed.descriptor.capabilities)
            if (capability.label != null)
              (capability.label!, capability.labelKey),
        ],
      ];
      for (final (name, key) in named) {
        expect(translatedName(en, name: name, key: key), name);
        expect(
          translatedName(fa, name: name, key: key),
          isNot(name),
          reason: name,
        );
      }
    });

    test('a renamed device is shown as typed, even with a default name', () {
      final lamp = _demo('lr-lamp');
      expect(lamp.displayName(fa), fa.demoFloorLamp);
      expect(lamp.renamed('Floor lamp').displayName(fa), 'Floor lamp');
      expect(lamp.renamed("Daniel's lamp").displayName(fa), "Daniel's lamp");
    });

    test('names without a key or with an unknown key are shown as typed', () {
      expect(translatedName(fa, name: 'Living Room', key: null), 'Living Room');
      expect(translatedName(fa, name: 'Patio', key: 'vendor.patio'), 'Patio');
      final room = DemoHome.home.rooms.first;
      expect(room.displayName(fa), fa.demoRoomLivingRoom);
      expect(room.renamed('Salon').displayName(fa), 'Salon');
    });

    test('channel labels translate by key', () {
      final channel = _demo('kt-switch').capability('ch1')!;
      expect(channel.displayLabel(fa), fa.demoChannelCeiling);
      expect(channel.copyWith(labelKey: null).displayLabel(fa), channel.label);
      expect(Capability.of(CapabilityKind.onOff).displayLabel(fa), isNull);
    });
  });

  test('Persian keeps the degree sign right of the digits everywhere', () {
    final value = Readings(fa).temperature(22.5);
    bool degreeRightOfDigits(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontSize: 10)),
        textDirection: TextDirection.rtl,
      )..layout();
      double x(int i) => painter
          .getBoxesForSelection(
            TextSelection(baseOffset: i, extentOffset: i + 1),
          )
          .first
          .left;
      return x(text.indexOf('°')) > x(text.indexOf(RegExp('[۰-۹]')));
    }

    // Alone (dial), before Persian text (tiles), after it ("Now"), between.
    for (final text in [
      value,
      '$value${fa.listSeparator}${fa.stateHeating}',
      fa.currentTemperature(value),
      'اتاق${fa.listSeparator}$value${fa.listSeparator}گرم',
    ]) {
      expect(degreeRightOfDigits(text), isTrue, reason: text);
    }
  });
}
