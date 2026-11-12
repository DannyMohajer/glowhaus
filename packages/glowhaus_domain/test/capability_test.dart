import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:test/test.dart';

void main() {
  final thermostat = Capability.of(
    CapabilityKind.thermostat,
    config: const {
      'minSetpoint': 16,
      'maxSetpoint': 30,
      'step': 0.5,
      'modes': ['off', 'heat', 'cool'],
      'fanModes': ['auto', 'low'],
    },
  );

  group('CapabilityKind.isWritable', () {
    test('controls are writable, sensors are not', () {
      expect(
        CapabilityKind.values.where((k) => k.isWritable),
        unorderedEquals([
          CapabilityKind.onOff,
          CapabilityKind.brightness,
          CapabilityKind.color,
          CapabilityKind.colorTemperature,
          CapabilityKind.position,
          CapabilityKind.thermostat,
          CapabilityKind.lock,
        ]),
      );
    });

    test('every writable kind has a patch and vice versa', () {
      const patches = <CapabilityPatch>[
        CapabilityPatch.onOff(on: true),
        CapabilityPatch.brightness(level: 1),
        CapabilityPatch.color(hue: 1),
        CapabilityPatch.colorTemperature(kelvin: 3000),
        CapabilityPatch.position(target: 1),
        CapabilityPatch.thermostat(setpoint: 20),
        CapabilityPatch.lock(locked: true),
      ];
      expect(
        patches.map((p) => p.kind),
        unorderedEquals(CapabilityKind.values.where((k) => k.isWritable)),
      );
    });
  });

  group('typed config', () {
    test('thermostat', () {
      final config = thermostat.thermostatConfig!;
      expect(config.minSetpoint, 16);
      expect(config.step, 0.5);
      expect(config.modes, [
        ThermostatMode.off,
        ThermostatMode.heat,
        ThermostatMode.cool,
      ]);
    });

    test('is null for other kinds or malformed config', () {
      expect(Capability.of(CapabilityKind.onOff).thermostatConfig, isNull);
      expect(Capability.of(CapabilityKind.thermostat).thermostatConfig, isNull);
    });

    test('camera streams', () {
      final camera = Capability.of(
        CapabilityKind.camera,
        config: const {
          'streams': [
            {'protocol': 'rtsp', 'url': 'rtsp://192.168.1.40:8554/door'},
          ],
        },
      );
      expect(camera.cameraConfig!.streams.single.protocol, 'rtsp');
    });
  });

  group('validate', () {
    ProtocolErrorCode? check(CapabilityPatch patch, [Capability? capability]) =>
        patch.validate(capability ?? Capability.of(patch.kind));

    test('accepts valid patches', () {
      expect(check(const CapabilityPatch.onOff(on: true)), isNull);
      expect(check(const CapabilityPatch.brightness(level: 0)), isNull);
      expect(check(const CapabilityPatch.brightness(level: 100)), isNull);
      expect(check(const CapabilityPatch.color(hue: 359)), isNull);
      expect(check(const CapabilityPatch.position(target: 50)), isNull);
      expect(check(const CapabilityPatch.position(stop: true)), isNull);
      expect(check(const CapabilityPatch.lock(locked: false)), isNull);
      expect(
        check(
          const CapabilityPatch.thermostat(
            setpoint: 21.5,
            mode: ThermostatMode.heat,
            fan: FanMode.low,
          ),
          thermostat,
        ),
        isNull,
      );
    });

    test('range errors', () {
      const outOfRange = ProtocolErrorCode.outOfRange;
      expect(check(const CapabilityPatch.brightness(level: 101)), outOfRange);
      expect(check(const CapabilityPatch.brightness(level: -1)), outOfRange);
      expect(check(const CapabilityPatch.color(hue: 360)), outOfRange);
      expect(check(const CapabilityPatch.color(saturation: 101)), outOfRange);
      expect(check(const CapabilityPatch.position(target: 120)), outOfRange);
    });

    test('colour temperature respects config limits', () {
      final capability = Capability.of(
        CapabilityKind.colorTemperature,
        config: const {'minKelvin': 2200, 'maxKelvin': 6500},
      );
      expect(
        check(const CapabilityPatch.colorTemperature(kelvin: 2700), capability),
        isNull,
      );
      expect(
        check(const CapabilityPatch.colorTemperature(kelvin: 9000), capability),
        ProtocolErrorCode.outOfRange,
      );
    });

    test('thermostat limits, step and allowed modes', () {
      const outOfRange = ProtocolErrorCode.outOfRange;
      ProtocolErrorCode? t({
        double? setpoint,
        ThermostatMode? mode,
        FanMode? fan,
      }) => check(
        CapabilityPatch.thermostat(setpoint: setpoint, mode: mode, fan: fan),
        thermostat,
      );
      expect(t(setpoint: 15.5), outOfRange);
      expect(t(setpoint: 30.5), outOfRange);
      expect(t(setpoint: 21.3), outOfRange);
      expect(t(mode: ThermostatMode.auto), outOfRange);
      expect(t(fan: FanMode.high), outOfRange);
      expect(t(setpoint: 16), isNull);
      expect(t(setpoint: 30), isNull);
    });

    test('empty or contradictory patches are invalid', () {
      const invalid = ProtocolErrorCode.invalidPayload;
      expect(check(const CapabilityPatch.color()), invalid);
      expect(check(const CapabilityPatch.position()), invalid);
      expect(
        check(const CapabilityPatch.position(target: 5, stop: true)),
        invalid,
      );
      expect(check(const CapabilityPatch.position(stop: false)), invalid);
      expect(check(const CapabilityPatch.thermostat(), thermostat), invalid);
    });

    test('wrong target capability', () {
      expect(
        check(
          const CapabilityPatch.onOff(on: true),
          Capability.of(CapabilityKind.contactSensor),
        ),
        ProtocolErrorCode.readOnly,
      );
      expect(
        check(
          const CapabilityPatch.onOff(on: true),
          Capability.of(CapabilityKind.brightness),
        ),
        ProtocolErrorCode.invalidPayload,
      );
    });
  });

  group('applyTo', () {
    test('sets only the given fields', () {
      const state = CapabilityState.thermostat(
        setpoint: 21,
        mode: ThermostatMode.heat,
        fan: FanMode.auto,
        action: ThermostatAction.heating,
      );
      expect(
        const CapabilityPatch.thermostat(setpoint: 23).applyTo(state),
        const CapabilityState.thermostat(
          setpoint: 23,
          mode: ThermostatMode.heat,
          fan: FanMode.auto,
          action: ThermostatAction.heating,
        ),
      );
      expect(
        const CapabilityPatch.color(saturation: 10)
            .applyTo(const CapabilityState.color(hue: 200, saturation: 80)),
        const CapabilityState.color(hue: 200, saturation: 10),
      );
    });

    test('position target starts movement, stop ends it', () {
      const resting = CapabilityState.position(position: 20, target: 20);
      const moving = CapabilityState.position(
        position: 20,
        target: 80,
        moving: true,
      );
      expect(
        const CapabilityPatch.position(target: 80).applyTo(resting),
        moving,
      );
      expect(
        const CapabilityPatch.position(stop: true).applyTo(moving),
        resting,
      );
      expect(
        const CapabilityPatch.position(target: 20).applyTo(resting),
        resting,
      );
    });

    test('leaves mismatched or missing state untouched', () {
      const state = CapabilityState.lock(locked: true);
      expect(const CapabilityPatch.onOff(on: true).applyTo(state), state);
      expect(const CapabilityPatch.onOff(on: true).applyTo(null), isNull);
    });
  });

  group('isSatisfiedBy', () {
    test('simple values', () {
      const patch = CapabilityPatch.onOff(on: true);
      expect(
        patch.isSatisfiedBy(const CapabilityState.onOff(on: true)),
        isTrue,
      );
      expect(
        patch.isSatisfiedBy(const CapabilityState.onOff(on: false)),
        isFalse,
      );
      expect(patch.isSatisfiedBy(null), isFalse);
      expect(
        patch.isSatisfiedBy(const CapabilityState.lock(locked: true)),
        isFalse,
      );
    });

    test('partial patches only compare their own fields', () {
      const state = CapabilityState.thermostat(
        setpoint: 23,
        mode: ThermostatMode.cool,
      );
      expect(
        const CapabilityPatch.thermostat(setpoint: 23).isSatisfiedBy(state),
        isTrue,
      );
      expect(
        const CapabilityPatch.thermostat(
          setpoint: 23,
          mode: ThermostatMode.heat,
        ).isSatisfiedBy(state),
        isFalse,
      );
    });

    test('curtain is satisfied by the target, before it arrives', () {
      const patch = CapabilityPatch.position(target: 80);
      expect(
        patch.isSatisfiedBy(
          const CapabilityState.position(
            position: 30,
            target: 80,
            moving: true,
          ),
        ),
        isTrue,
      );
      expect(
        patch.isSatisfiedBy(
          const CapabilityState.position(position: 30, target: 30),
        ),
        isFalse,
      );
      expect(
        const CapabilityPatch.position(stop: true).isSatisfiedBy(
          const CapabilityState.position(position: 30, target: 30),
        ),
        isTrue,
      );
    });
  });

  test('state kind matches its wire tag', () {
    const states = <CapabilityState>[
      CapabilityState.onOff(on: true),
      CapabilityState.brightness(level: 1),
      CapabilityState.color(hue: 1, saturation: 1),
      CapabilityState.colorTemperature(kelvin: 2700),
      CapabilityState.position(position: 0, target: 0),
      CapabilityState.thermostat(setpoint: 20, mode: ThermostatMode.off),
      CapabilityState.powerMeter(watts: 1),
      CapabilityState.lock(locked: true),
      CapabilityState.temperatureSensor(celsius: 1),
      CapabilityState.humiditySensor(percent: 1),
      CapabilityState.motionSensor(motion: false),
      CapabilityState.contactSensor(open: false),
      CapabilityState.camera(streaming: true),
    ];
    expect(
      states.map((s) => s.kind),
      CapabilityKind.values.where((k) => k != CapabilityKind.unknown),
    );
    for (final state in states) {
      expect(state.toJson()['kind'], state.kind.name);
      expect(state.toWire(), isNot(contains('kind')));
      expect(CapabilityState.fromWire(state.kind, state.toWire()), state);
    }
  });
}
