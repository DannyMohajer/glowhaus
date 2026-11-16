import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:test/test.dart';

const _latency = Duration(milliseconds: 200);
const _exact = SimulationConfig(latency: _latency, latencyJitter: 0);
final _epoch = DateTime.utc(2026, 11, 12, 12);

/// A connected transport on a fake clock, with everything it emitted.
class _Harness {
  new(
    this.async, {
    SimulationConfig config = _exact,
    Duration? ambientInterval,
  }) {
    transport = SimulatedTransport(
      homeId: DemoHome.homeId,
      devices: DemoHome.devices(),
      config: config,
      random: Random(7),
      clock: now,
      ambientInterval: ambientInterval,
    );
    transport.events.listen(events.add);
    transport.status.listen(statuses.add);
  }

  final FakeAsync async;
  late final SimulatedTransport transport;
  final events = <DeviceEvent>[];
  final statuses = <TransportStatus>[];
  var _commandCount = 0;

  DateTime now() => _epoch.add(async.elapsed);

  void connect() {
    unawaited(transport.connect());
    async.elapse(const Duration(milliseconds: 300));
  }

  DeviceCommand command(
    String deviceId,
    Map<String, CapabilityPatch> patches, {
    String? id,
    DateTime? issuedAt,
  }) => DeviceCommand(
    id: id ?? 'c${_commandCount++}',
    homeId: DemoHome.homeId,
    deviceId: deviceId,
    issuedAt: issuedAt ?? now(),
    patches: patches,
  );

  /// Sends and returns a holder that is filled when the result arrives.
  List<CommandResult> send(DeviceCommand command, {Duration? timeout}) {
    final results = <CommandResult>[];
    unawaited(
      (timeout == null
              ? transport.send(command)
              : transport.send(command, timeout: timeout))
          .then(results.add),
    );
    return results;
  }

  Iterable<DeviceStateChanged> statesOf(String deviceId) => events
      .whereType<DeviceStateChanged>()
      .where((event) => event.deviceId == deviceId);

  T state<T extends CapabilityState>(String deviceId, String capabilityId) =>
      transport.deviceState(deviceId)![capabilityId]! as T;
}

void _run(
  void Function(_Harness h) body, {
  SimulationConfig config = _exact,
  Duration? ambientInterval,
  bool connect = true,
}) {
  fakeAsync((async) {
    final harness = _Harness(
      async,
      config: config,
      ambientInterval: ambientInterval,
    );
    if (connect) harness.connect();
    body(harness);
    unawaited(harness.transport.dispose());
    async.flushMicrotasks();
  });
}

const _lampOff = {'onOff': CapabilityPatch.onOff(on: false)};

void main() {
  group('connection', () {
    test('goes through connecting to connected', () {
      _run(connect: false, (h) {
        expect(h.transport.currentStatus, TransportStatus.disconnected);
        unawaited(h.transport.connect());
        h.async.flushMicrotasks();
        expect(h.transport.currentStatus, TransportStatus.connecting);
        expect(h.events, isEmpty);
        h.async.elapse(const Duration(milliseconds: 300));
        expect(h.statuses, [
          TransportStatus.connecting,
          TransportStatus.connected,
        ]);
      });
    });

    test('announces every device with availability and state', () {
      _run((h) {
        final announced = h.events.whereType<DeviceAnnounced>().toList();
        expect(announced, hasLength(13));
        expect(h.events.whereType<DeviceAvailabilityChanged>(), hasLength(13));
        // The offline motion sensor publishes no state.
        expect(h.events.whereType<DeviceStateChanged>(), hasLength(12));
        expect(h.events.every((e) => e.homeId == DemoHome.homeId), isTrue);

        final offline = h.events.whereType<DeviceAvailabilityChanged>().where(
          (e) => e.availability == DeviceAvailability.offline,
        );
        expect(offline.single.deviceId, 'kt-motion');
      });
    });

    test('connect twice is a no-op; disconnect reports status', () {
      _run((h) {
        final before = h.events.length;
        unawaited(h.transport.connect());
        h.async.elapse(const Duration(seconds: 1));
        expect(h.events, hasLength(before));

        unawaited(h.transport.disconnect());
        h.async.flushMicrotasks();
        expect(h.statuses.last, TransportStatus.disconnected);
      });
    });

    test('commands sent while disconnected are unreachable at once', () {
      _run(connect: false, (h) {
        final result = h.send(h.command('lr-lamp', _lampOff));
        h.async.flushMicrotasks();
        expect(result.single, isA<CommandUnreachable>());
      });
    });
  });

  group('send', () {
    test('acks after the latency, then reports the new state', () {
      _run((h) {
        h.events.clear();
        final result = h.send(h.command('lr-lamp', _lampOff));

        h.async.elapse(_latency - const Duration(milliseconds: 1));
        expect(result, isEmpty);

        h.async.elapse(const Duration(milliseconds: 1));
        expect(result.single, const CommandResult.acked(commandId: 'c0'));
        expect(h.events, isEmpty, reason: 'state follows the ack');

        h.async.elapse(const Duration(milliseconds: 60));
        final state = h.statesOf('lr-lamp').single;
        expect(state.state['onOff'], const CapabilityState.onOff(on: false));
        expect(state.state.keys, hasLength(4), reason: 'full snapshot');
        expect(state.at, h.now());
      });
    });

    test('several capabilities in one command', () {
      _run((h) {
        final result = h.send(
          h.command('lr-lamp', const {
            'brightness': CapabilityPatch.brightness(level: 15),
            'color': CapabilityPatch.color(hue: 210),
          }),
        );
        h.async.elapse(_latency);
        expect(result.single.isSuccess, isTrue);
        expect(h.state<BrightnessState>('lr-lamp', 'brightness').level, 15);
        expect(
          h.state<ColorState>('lr-lamp', 'color'),
          const CapabilityState.color(hue: 210, saturation: 85),
        );
      });
    });

    test('one channel of a multi-channel switch', () {
      _run((h) {
        h.send(
          h.command('kt-switch', const {
            'ch2': CapabilityPatch.onOff(on: true),
          }),
        );
        h.async.elapse(_latency);
        expect(h.state<OnOffState>('kt-switch', 'ch1').on, isTrue);
        expect(h.state<OnOffState>('kt-switch', 'ch2').on, isTrue);
        expect(h.state<OnOffState>('kt-switch', 'ch3').on, isFalse);
      });
    });

    test('failure: rejected with busy, state untouched, nothing emitted', () {
      _run(config: _exact.copyWith(failureRate: 1), (h) {
        h.events.clear();
        final result = h.send(h.command('lr-lamp', _lampOff));
        h.async.elapse(const Duration(seconds: 1));
        expect(
          result.single,
          isA<CommandFailed>().having(
            (r) => r.code,
            'code',
            ProtocolErrorCode.busy,
          ),
        );
        expect(h.state<OnOffState>('lr-lamp', 'onOff').on, isTrue);
        expect(h.events, isEmpty);
      });
    });

    test('lost command: times out at the given timeout', () {
      _run(config: _exact.copyWith(timeoutRate: 1), (h) {
        final result = h.send(
          h.command('lr-lamp', _lampOff),
          timeout: const Duration(seconds: 2),
        );
        h.async.elapse(const Duration(milliseconds: 1999));
        expect(result, isEmpty);
        h.async.elapse(const Duration(milliseconds: 1));
        expect(result.single, const CommandResult.timedOut(commandId: 'c0'));
        expect(h.state<OnOffState>('lr-lamp', 'onOff').on, isTrue);
      });
    });

    test('latency longer than the timeout: timed out, then applied late', () {
      _run(config: _exact.copyWith(latency: const Duration(seconds: 3)), (h) {
        final result = h.send(
          h.command('lr-lamp', _lampOff),
          timeout: const Duration(seconds: 1),
        );
        h.async.elapse(const Duration(seconds: 2));
        expect(result.single, isA<CommandTimedOut>());
        expect(h.state<OnOffState>('lr-lamp', 'onOff').on, isTrue);
        // A slow device still acts; the app shows the reported state
        // when it finally arrives (the repository rolled back meanwhile).
        h.async.elapse(const Duration(seconds: 2));
        expect(h.state<OnOffState>('lr-lamp', 'onOff').on, isFalse);
        expect(
          h.statesOf('lr-lamp').last.state['onOff'],
          const OnOffState(on: false),
        );
      });
    });

    test(
      'offline or unknown device time out; a foreign home is unreachable',
      () {
        _run((h) {
          final results = [
            h.send(
              h.command('kt-motion', const {
                'motionSensor': CapabilityPatch.onOff(on: true),
              }),
            ),
            h.send(h.command('ghost', _lampOff)),
          ];
          final foreign = h.send(
            h.command('lr-lamp', _lampOff).copyWith(homeId: 'other'),
          );
          h.async.flushMicrotasks();
          expect(foreign.single, isA<CommandUnreachable>());
          h.async.elapse(Protocol.commandTimeout);
          for (final result in results) {
            expect(result.single, isA<CommandTimedOut>());
          }
        });
      },
    );

    test('validation errors use the protocol codes and are atomic', () {
      _run((h) {
        ProtocolErrorCode code(String device, Map<String, CapabilityPatch> p) {
          final result = h.send(h.command(device, p));
          h.async.elapse(_latency);
          return (result.single as CommandFailed).code;
        }

        expect(
          code('lr-lamp', const {
            'brightness': CapabilityPatch.brightness(level: 5),
            'ghost': CapabilityPatch.onOff(on: true),
          }),
          ProtocolErrorCode.unsupportedCapability,
        );
        expect(
          h.state<BrightnessState>('lr-lamp', 'brightness').level,
          55,
          reason: 'nothing applied',
        );
        expect(
          code('lr-lamp', const {
            'brightness': CapabilityPatch.brightness(level: 500),
          }),
          ProtocolErrorCode.outOfRange,
        );
        expect(
          code('lr-thermostat', const {
            'thermostat': CapabilityPatch.thermostat(setpoint: 40),
          }),
          ProtocolErrorCode.outOfRange,
        );
        expect(
          code('en-door', const {
            'contactSensor': CapabilityPatch.onOff(on: true),
          }),
          ProtocolErrorCode.readOnly,
        );
        expect(code('lr-lamp', const {}), ProtocolErrorCode.invalidPayload);
      });
    });

    test('commands older than 10 s are rejected as expired', () {
      _run((h) {
        final stale = h.command(
          'lr-lamp',
          _lampOff,
          issuedAt: h.now().subtract(const Duration(seconds: 11)),
        );
        final result = h.send(stale);
        h.async.elapse(_latency);
        expect(
          (result.single as CommandFailed).code,
          ProtocolErrorCode.expired,
        );
        expect(h.state<OnOffState>('lr-lamp', 'onOff').on, isTrue);
      });
    });

    test('a repeated commandId is re-acked without being applied again', () {
      _run((h) {
        final first = h.send(
          h.command('lr-curtain', const {
            'position': CapabilityPatch.position(target: 65),
          }, id: 'dup'),
        );
        h.async.elapse(const Duration(seconds: 2));
        expect(h.state<PositionState>('lr-curtain', 'position').position, 65);

        // Same id, different content: must be ignored.
        final second = h.send(
          h.command('lr-curtain', const {
            'position': CapabilityPatch.position(target: 0),
          }, id: 'dup'),
        );
        h.async.elapse(const Duration(seconds: 2));
        expect(second.single, first.single);
        expect(h.state<PositionState>('lr-curtain', 'position').target, 65);
      });
    });

    test('config can change while running', () {
      _run((h) {
        h.transport.config = _exact.copyWith(
          latency: const Duration(seconds: 1),
        );
        final result = h.send(h.command('lr-lamp', _lampOff));
        h.async.elapse(const Duration(milliseconds: 999));
        expect(result, isEmpty);
        h.async.elapse(const Duration(milliseconds: 1));
        expect(result, hasLength(1));
      });
    });

    test('jitter keeps latency within its spread', () {
      _run(
        config: const SimulationConfig(latency: _latency, latencyJitter: 0.5),
        (h) {
          for (var i = 0; i < 20; i++) {
            final result = h.send(h.command('lr-lamp', _lampOff));
            h.async.elapse(const Duration(milliseconds: 99));
            expect(result, isEmpty);
            h.async.elapse(const Duration(milliseconds: 202));
            expect(result, hasLength(1));
          }
        },
      );
    });
  });

  group('device behaviour', () {
    test('curtain acks at once, then moves to the target step by step', () {
      _run((h) {
        h.events.clear();
        final result = h.send(
          h.command('lr-curtain', const {
            'position': CapabilityPatch.position(target: 80),
          }),
        );
        h.async.elapse(_latency + const Duration(milliseconds: 60));
        expect(result.single.isSuccess, isTrue);
        expect(
          h.statesOf('lr-curtain').single.state['position'],
          const CapabilityState.position(
            position: 60,
            target: 80,
            moving: true,
          ),
        );

        h.async.elapse(const Duration(seconds: 5));
        final reports = h
            .statesOf('lr-curtain')
            .map((e) => e.state['position']! as PositionState)
            .toList();
        expect(reports.map((p) => p.position), [60, 65, 70, 75, 80]);
        expect(reports.map((p) => p.moving), [true, true, true, true, false]);
        expect(reports.every((p) => p.target == 80), isTrue);
      });
    });

    test('stop halts a moving curtain where it is', () {
      _run((h) {
        h.send(
          h.command('lr-curtain', const {
            'position': CapabilityPatch.position(target: 0),
          }),
        );
        h.async.elapse(const Duration(seconds: 1));
        h.send(
          h.command('lr-curtain', const {
            'position': CapabilityPatch.position(stop: true),
          }),
        );
        h.async.elapse(_latency);
        final stopped = h.state<PositionState>('lr-curtain', 'position');
        expect(stopped.moving, isFalse);
        expect(stopped.target, stopped.position);
        expect(stopped.position, inExclusiveRange(0, 60));

        h.async.elapse(const Duration(seconds: 5));
        expect(h.state<PositionState>('lr-curtain', 'position'), stopped);
      });
    });

    test('outlet power follows its switch', () {
      _run((h) {
        h.send(
          h.command('kt-outlet', const {
            'onOff': CapabilityPatch.onOff(on: false),
          }),
        );
        h.async.elapse(_latency);
        expect(h.state<PowerMeterState>('kt-outlet', 'powerMeter').watts, 0);

        h.send(
          h.command('kt-outlet', const {
            'onOff': CapabilityPatch.onOff(on: true),
          }),
        );
        h.async.elapse(_latency);
        expect(h.state<PowerMeterState>('kt-outlet', 'powerMeter').watts, 1180);
      });
    });

    test('thermostat action follows mode, setpoint and room temperature', () {
      _run((h) {
        ThermostatAction action() =>
            h.state<ThermostatState>('lr-thermostat', 'thermostat').action;
        void set(CapabilityPatch patch) {
          h.send(h.command('lr-thermostat', {'thermostat': patch}));
          h.async.elapse(_latency);
        }

        expect(action(), ThermostatAction.heating, reason: '22.5 > 20.8');
        set(const CapabilityPatch.thermostat(setpoint: 18));
        expect(action(), ThermostatAction.idle);
        set(const CapabilityPatch.thermostat(mode: ThermostatMode.cool));
        expect(action(), ThermostatAction.cooling);
        set(const CapabilityPatch.thermostat(mode: ThermostatMode.off));
        expect(action(), ThermostatAction.idle);
      });
    });

    test('ambient: live watts fluctuate and the room warms while heating', () {
      _run(ambientInterval: const Duration(seconds: 2), (h) {
        h.events.clear();
        h.async.elapse(const Duration(seconds: 10));

        final watts = h
            .statesOf('kt-outlet')
            .map((e) => (e.state['powerMeter']! as PowerMeterState).watts)
            .toList();
        expect(watts, hasLength(5));
        expect(watts.toSet().length, greaterThan(1));
        expect(watts.every((w) => (w - 1180).abs() < 1180 * 0.03), isTrue);
        expect(
          h.state<PowerMeterState>('kt-outlet', 'powerMeter').energyKwh,
          greaterThan(42.7),
        );

        expect(
          h
              .state<TemperatureSensorState>(
                'lr-thermostat',
                'temperatureSensor',
              )
              .celsius,
          closeTo(21.3, 1e-9),
        );
        expect(h.statesOf('kt-motion'), isEmpty, reason: 'offline');
      });
    });

    test('heating stops once the setpoint is reached', () {
      _run(ambientInterval: const Duration(seconds: 2), (h) {
        h.async.elapse(const Duration(minutes: 2));
        final thermostat = h.state<ThermostatState>(
          'lr-thermostat',
          'thermostat',
        );
        final celsius = h
            .state<TemperatureSensorState>('lr-thermostat', 'temperatureSensor')
            .celsius;
        expect(celsius, inInclusiveRange(22.3, 22.5));
        expect(thermostat.setpoint, 22.5);
      });
    });

    test('a device going offline and coming back', () {
      _run((h) {
        h.events.clear();
        unawaited(h.transport.setDeviceOnline('lr-lamp', online: false));
        h.async.flushMicrotasks();
        expect(
          (h.events.single as DeviceAvailabilityChanged).availability,
          DeviceAvailability.offline,
        );
        final result = h.send(h.command('lr-lamp', _lampOff));
        h.async.elapse(Protocol.commandTimeout);
        expect(result.single, isA<CommandTimedOut>());

        h.events.clear();
        unawaited(h.transport.setDeviceOnline('lr-lamp', online: true));
        h.async.flushMicrotasks();
        // Section 6 / 5.1: online and state on reconnect. The device's info
        // and announce repeat an unchanged descriptor, which is not news.
        expect(h.events.map((e) => e.runtimeType), [
          DeviceAvailabilityChanged,
          DeviceStateChanged,
        ]);
        expect(
          (h.events.first as DeviceAvailabilityChanged).availability,
          DeviceAvailability.online,
        );
      });
    });
  });
}
