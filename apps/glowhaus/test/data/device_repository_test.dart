import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

import '../helpers/fake_transport.dart';

const _lamp = 'lr-lamp';
const _lampState = <String, CapabilityState>{
  'onOff': CapabilityState.onOff(on: true),
  'brightness': CapabilityState.brightness(level: 55),
  'color': CapabilityState.color(hue: 28, saturation: 85),
  'colorTemperature': CapabilityState.colorTemperature(kelvin: 2700),
};
const _off = {'onOff': CapabilityPatch.onOff(on: false)};

void main() {
  late FakeTransport transport;
  late DeviceRepository repository;
  late List<CommandFailure> failures;

  bool lampOn() => repository.device(_lamp)!.device.isOn;
  bool lampPending() => repository.device(_lamp)!.pending;

  Future<void> setUpRepository() async {
    transport = FakeTransport();
    repository = DeviceRepository(
      transport,
      clock: () => DateTime.utc(2026, 11, 12, 12),
    );
    failures = [];
    repository.failures.listen(failures.add);
    await repository.start();
    transport.seed(DemoHome.devices());
  }

  setUp(setUpRepository);
  tearDown(() => repository.dispose());

  group('devices from transport events', () {
    test('builds every announced device with room, state and availability', () {
      expect(repository.current, hasLength(13));
      final lamp = repository.device(_lamp)!.device;
      expect(lamp.homeId, DemoHome.homeId);
      expect(lamp.roomId, DemoHome.livingRoom);
      expect(lamp.isOnline, isTrue);
      expect(lamp.state, _lampState);
      expect(repository.device('kt-motion')!.device.isOffline, isTrue);
      expect(repository.device('ghost'), isNull);
    });

    test('start connects the transport and is repeatable', () async {
      expect(transport.currentStatus, TransportStatus.connected);
      await repository.start();
      transport.reportState(_lamp, {
        ..._lampState,
        'brightness': const CapabilityState.brightness(level: 10),
      });
      expect(
        repository
            .device(_lamp)!
            .device
            .stateOf<BrightnessState>('brightness')!
            .level,
        10,
        reason: 'events are handled once',
      );
    });

    test('watchAll starts with the current list and follows changes', () async {
      final seen = <int>[];
      final sub = repository.watchAll().listen(
        (views) => seen.add(views.length),
      );
      await pumpEventQueue();
      transport.emit(
        const DeviceRemoved(homeId: DemoHome.homeId, deviceId: _lamp),
      );
      await pumpEventQueue();
      expect(seen, [13, 12]);
      await sub.cancel();
    });

    test('watch follows one device and skips unrelated changes', () async {
      final seen = <bool?>[];
      final sub = repository
          .watch(_lamp)
          .listen((view) => seen.add(view?.device.isOn));
      await pumpEventQueue();
      transport
        ..reportState('lr-ceiling', const {
          'onOff': CapabilityState.onOff(on: false),
          'brightness': CapabilityState.brightness(level: 70),
        })
        ..reportState(_lamp, {
          ..._lampState,
          'onOff': const CapabilityState.onOff(on: false),
        });
      await pumpEventQueue();
      expect(seen, [true, false]);
      await sub.cancel();
    });

    test('availability changes are reflected; re-announce keeps state', () {
      transport
        ..emit(
          const DeviceAvailabilityChanged(
            homeId: DemoHome.homeId,
            deviceId: _lamp,
            availability: DeviceAvailability.offline,
          ),
        )
        ..emit(
          DeviceAnnounced(
            homeId: DemoHome.homeId,
            descriptor: DemoHome.devices()
                .firstWhere((d) => d.descriptor.id == _lamp)
                .descriptor
                .copyWith(name: 'Renamed lamp'),
          ),
        );
      final lamp = repository.device(_lamp)!.device;
      expect(lamp.isOffline, isTrue);
      expect(lamp.name, 'Renamed lamp');
      expect(lamp.state, _lampState);
    });

    test('status starts with the current value', () async {
      expect(await repository.status.first, TransportStatus.connected);
    });
  });

  group('optimistic commands', () {
    test('value shows at once and the device is marked pending', () {
      unawaited(repository.send(_lamp, _off));
      expect(lampOn(), isFalse);
      expect(lampPending(), isTrue);
      expect(repository.device(_lamp)!.isPending('onOff'), isTrue);
      expect(repository.device(_lamp)!.isPending('brightness'), isFalse);

      final command = transport.lastCommand;
      expect(command.deviceId, _lamp);
      expect(command.homeId, DemoHome.homeId);
      expect(command.patches, _off);
      expect(command.issuedAt, DateTime.utc(2026, 11, 12, 12));
    });

    test(
      'an ack alone does not end pending; the matching state does',
      () async {
        final result = repository.send(_lamp, _off);
        transport.ack();
        expect((await result).isSuccess, isTrue);
        expect(lampPending(), isTrue, reason: 'acked, state not reported yet');
        expect(lampOn(), isFalse);

        transport.applyAndReport(_lampState);
        expect(lampPending(), isFalse);
        expect(lampOn(), isFalse);
      },
    );

    test('unrelated state while waiting keeps the optimistic value', () async {
      final result = repository.send(_lamp, _off);
      transport.ack();
      await result;
      transport.reportState(_lamp, {
        ..._lampState,
        'brightness': const CapabilityState.brightness(level: 60),
      });
      expect(lampPending(), isTrue);
      expect(lampOn(), isFalse, reason: 'overlay still applied');
      expect(
        repository
            .device(_lamp)!
            .device
            .stateOf<BrightnessState>('brightness')!
            .level,
        60,
        reason: 'other reported values come through',
      );
    });

    test(
      'state that already matches when the ack arrives ends pending',
      () async {
        final result = repository.send(_lamp, _off);
        transport.applyAndReport(_lampState);
        expect(lampPending(), isTrue, reason: 'not acked yet');
        transport.ack();
        await result;
        expect(lampPending(), isFalse);
      },
    );

    test('rejected: rolls back and reports the failure', () async {
      final result = repository.send(_lamp, _off);
      transport.reject(ProtocolErrorCode.busy);
      expect(await result, isA<CommandFailed>());
      expect(lampOn(), isTrue, reason: 'rolled back to the reported state');
      expect(lampPending(), isFalse);

      await pumpEventQueue();
      expect(failures.single.device.id, _lamp);
      expect(failures.single.timedOut, isFalse);
      expect(failures.single.code, ProtocolErrorCode.busy);
    });

    test('timed out: rolls back and reports the failure', () async {
      final result = repository.send(_lamp, _off);
      transport.timeOut();
      expect(await result, isA<CommandTimedOut>());
      expect(lampOn(), isTrue);
      expect(lampPending(), isFalse);

      await pumpEventQueue();
      expect(failures.single.timedOut, isTrue);
      expect(failures.single.code, isNull);
    });

    group('applied after a timeout', () {
      late List<LateApply> lateApplies;
      final lampOff = {
        ..._lampState,
        'onOff': const CapabilityState.onOff(on: false),
      };

      setUp(() {
        lateApplies = [];
        repository.lateApplies.listen(lateApplies.add);
      });

      Future<void> timeOutOff() async {
        final result = repository.send(_lamp, _off);
        transport.timeOut();
        await result;
        await pumpEventQueue();
        expect(failures.single.timedOut, isTrue);
        expect(lampOn(), isTrue, reason: 'rolled back');
      }

      test('a matching state afterwards is noted once', () async {
        await timeOutOff();
        transport.reportState(_lamp, lampOff);
        await pumpEventQueue();
        expect(lateApplies.single.device.id, _lamp);
        expect(lampOn(), isFalse);
        expect(lampPending(), isFalse, reason: 'no overlay is re-applied');

        transport.reportState(_lamp, lampOff);
        await pumpEventQueue();
        expect(lateApplies, hasLength(1), reason: 'said once');
      });

      test('a state that does not match is not it', () async {
        await timeOutOff();
        transport.reportState(_lamp, {
          ..._lampState,
          'brightness': const CapabilityState.brightness(level: 20),
        });
        await pumpEventQueue();
        expect(lateApplies, isEmpty);
      });

      test('a newer command for the device takes over', () async {
        await timeOutOff();
        final again = repository.send(_lamp, _off);
        transport.ack();
        await again;
        transport.reportState(_lamp, lampOff);
        await pumpEventQueue();
        expect(lateApplies, isEmpty, reason: 'the second command did it');
      });

      test('only within the window', () {
        fakeAsync((async) {
          transport = FakeTransport();
          repository = DeviceRepository(transport);
          lateApplies = [];
          repository.lateApplies.listen(lateApplies.add);
          unawaited(repository.start());
          transport.seed(DemoHome.devices());
          async.flushMicrotasks();

          unawaited(repository.send(_lamp, _off));
          transport.timeOut();
          async
            ..flushMicrotasks()
            ..elapse(const Duration(seconds: 31));
          transport.reportState(_lamp, lampOff);
          async.flushMicrotasks();
          expect(lateApplies, isEmpty);
        });
      });

      test('a command for a value already shown is not watched', () async {
        final result = repository.send(_lamp, const {
          'onOff': CapabilityPatch.onOff(on: true),
        });
        transport.timeOut();
        await result;
        transport.reportState(_lamp, _lampState);
        await pumpEventQueue();
        expect(lateApplies, isEmpty);
      });
    });

    test(
      'unreachable: rolls back and reports it as a connection problem',
      () async {
        final result = repository.send(_lamp, _off);
        transport.unreachable();
        expect(await result, isA<CommandUnreachable>());
        expect(lampOn(), isTrue);
        expect(lampPending(), isFalse);

        await pumpEventQueue();
        expect(failures.single.unreachable, isTrue);
        expect(failures.single.timedOut, isFalse);
        expect(failures.single.code, isNull);
      },
    );

    test(
      'losing the broker drops acked values waiting for their state',
      () async {
        final result = repository.send(_lamp, _off);
        transport.ack();
        await result;
        expect(lampPending(), isTrue, reason: 'acked, waiting for state');

        transport.setStatus(TransportStatus.reconnecting);
        expect(lampPending(), isFalse);
        expect(lampOn(), isTrue, reason: 'last reported state shows');
        expect(failures, isEmpty, reason: 'nothing to apologise for');

        // What the device reports after the reconnect is the truth.
        transport
          ..setStatus(TransportStatus.connected)
          ..reportState(_lamp, {
            ..._lampState,
            'onOff': const CapabilityState.onOff(on: false),
          });
        expect(lampOn(), isFalse);
      },
    );

    test(
      'rollback returns to the latest reported state, not the old one',
      () async {
        final result = repository.send(_lamp, _off);
        transport
          ..reportState(_lamp, {
            ..._lampState,
            'brightness': const CapabilityState.brightness(level: 5),
          })
          ..timeOut();
        await result;
        final lamp = repository.device(_lamp)!.device;
        expect(lamp.isOn, isTrue);
        expect(lamp.stateOf<BrightnessState>('brightness')!.level, 5);
      },
    );

    test('two commands in flight: one fails, the other stays', () async {
      final first = repository.send(_lamp, _off);
      final firstCommand = transport.lastCommand;
      final second = repository.send(_lamp, const {
        'brightness': CapabilityPatch.brightness(level: 90),
      });
      expect(transport.sent.map((c) => c.id).toSet(), hasLength(2));

      transport.reject(ProtocolErrorCode.busy, firstCommand);
      await first;
      var lamp = repository.device(_lamp)!;
      expect(lamp.device.isOn, isTrue);
      expect(lamp.device.stateOf<BrightnessState>('brightness')!.level, 90);
      expect(lamp.pendingCapabilities, {'brightness'});

      transport.ack();
      await second;
      transport.applyAndReport(_lampState);
      lamp = repository.device(_lamp)!;
      expect(lamp.pending, isFalse);
      expect(lamp.device.stateOf<BrightnessState>('brightness')!.level, 90);
    });

    test(
      'later command on the same capability wins while both are pending',
      () {
        unawaited(
          repository.send(_lamp, const {
            'brightness': CapabilityPatch.brightness(level: 20),
          }),
        );
        unawaited(
          repository.send(_lamp, const {
            'brightness': CapabilityPatch.brightness(level: 80),
          }),
        );
        expect(
          repository
              .device(_lamp)!
              .device
              .stateOf<BrightnessState>('brightness')!
              .level,
          80,
        );
      },
    );

    test(
      'curtain: pending ends when the target is reported, while moving',
      () async {
        const curtain = 'lr-curtain';
        final result = repository.send(curtain, const {
          'position': CapabilityPatch.position(target: 100),
        });
        PositionState position() => repository
            .device(curtain)!
            .device
            .stateOf<PositionState>('position')!;
        expect(position().target, 100);
        expect(position().moving, isTrue);

        transport.ack();
        await result;
        expect(repository.device(curtain)!.pending, isTrue);

        transport.reportState(curtain, const {
          'position': CapabilityState.position(
            position: 65,
            target: 100,
            moving: true,
          ),
        });
        expect(repository.device(curtain)!.pending, isFalse);
        expect(position().position, 65, reason: 'reported progress shows');
      },
    );

    test('a removed device drops its pending commands', () {
      unawaited(repository.send(_lamp, _off));
      transport.emit(
        const DeviceRemoved(homeId: DemoHome.homeId, deviceId: _lamp),
      );
      expect(repository.device(_lamp), isNull);
    });
  });

  test('acked but never confirmed: the optimistic value is dropped after '
      'the settle timeout', () {
    fakeAsync((async) {
      final transport = FakeTransport();
      final repository = DeviceRepository(transport);
      unawaited(repository.start());
      async.flushMicrotasks();
      transport.seed(DemoHome.devices());

      unawaited(repository.send(_lamp, _off));
      transport.ack();
      async.flushMicrotasks();
      expect(repository.device(_lamp)!.pending, isTrue);

      async.elapse(Protocol.stateSettleTimeout - const Duration(seconds: 1));
      expect(repository.device(_lamp)!.device.isOn, isFalse);

      async.elapse(const Duration(seconds: 1));
      expect(repository.device(_lamp)!.pending, isFalse);
      expect(repository.device(_lamp)!.device.isOn, isTrue);
    });
  });

  test('command ids are unique', () {
    for (var i = 0; i < 50; i++) {
      unawaited(repository.send(_lamp, _off));
    }
    final ids = transport.sent.map((c) => c.id).toSet();
    expect(ids, hasLength(50));
    expect(ids.every(Ids.isValidCommandId), isTrue);
  });
}
