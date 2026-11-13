import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:glowhaus/features/device/cubit/device_cubit.dart';
import 'package:glowhaus/features/feedback/app_cubits.dart';
import 'package:glowhaus/features/rooms/cubit/rooms_cubit.dart';
import 'package:glowhaus/features/shared/room_overview.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

import '../helpers/fakes.dart';

void main() {
  late TestHome home;

  setUp(() async {
    home = TestHome();
    await home.start();
  });
  tearDown(() => home.devices.dispose());

  group('DashboardCubit', () {
    DashboardCubit build() => DashboardCubit(home.homes, home.devices);

    test('starts with the owner and scenes, not yet loaded', () {
      final cubit = build();
      expect(cubit.state.userName, 'Daniel');
      expect(cubit.state.scenes, hasLength(3));
      expect(cubit.state.loaded, isFalse);
      addTearDown(cubit.close);
    });

    blocTest<DashboardCubit, DashboardState>(
      'groups devices by room and counts the active ones',
      build: build,
      verify: (cubit) {
        final state = cubit.state;
        expect(state.loaded, isTrue);
        expect(state.rooms.map((r) => r.room.id), [
          'living-room',
          'bedroom',
          'kitchen',
          'entrance',
        ]);
        expect(state.rooms.map((r) => r.devices.length), [4, 2, 3, 3]);
        // ceiling, lamp, thermostat, wall switch, outlet. The lock and the
        // offline sensor do not count.
        expect(state.activeCount, 5);
        expect(state.rooms.first.celsius, 20.8);
        expect(state.rooms[2].celsius, isNull);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'room filter narrows the visible rooms',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.selectRoom('kitchen');
        expect(cubit.state.visibleRooms.single.room.id, 'kitchen');
        cubit.selectRoom(null);
      },
      verify: (cubit) => expect(cubit.state.visibleRooms, hasLength(4)),
    );

    blocTest<DashboardCubit, DashboardState>(
      'toggle sends the opposite of the current state, optimistically',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.toggle(home.device('lr-lamp'));
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(home.transport.lastCommand.patches, {
          'onOff': const CapabilityPatch.onOff(on: false),
        });
        final lamp = cubit.state.rooms.first.devices.firstWhere(
          (v) => v.device.id == 'lr-lamp',
        );
        expect(lamp.device.isOn, isFalse);
        expect(lamp.pending, isTrue);
        expect(cubit.state.activeCount, 4);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'a rejected toggle comes back',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.toggle(home.device('lr-lamp'));
        home.transport.reject(ProtocolErrorCode.busy);
        await pumpEventQueue();
      },
      verify: (cubit) => expect(cubit.state.activeCount, 5),
    );

    test('toggle ignores devices without a switch', () async {
      final cubit = build()..toggle(home.device('lr-curtain'));
      expect(home.transport.sent, isEmpty);
      await cubit.close();
    });
  });

  group('RoomsCubit', () {
    blocTest<RoomsCubit, List<RoomOverview>>(
      'has the rooms immediately and follows device changes',
      build: () => RoomsCubit(home.homes, home.devices),
      act: (cubit) async {
        expect(cubit.state, hasLength(4));
        await pumpEventQueue();
        home.transport.emit(
          const DeviceRemoved(homeId: DemoHome.homeId, deviceId: 'en-camera'),
        );
        await pumpEventQueue();
      },
      verify: (cubit) => expect(cubit.state.last.devices, hasLength(2)),
    );
  });

  group('RoomCubit', () {
    RoomCubit build([String roomId = 'kitchen']) =>
        RoomCubit(home.homes, home.devices, roomId);

    blocTest<RoomCubit, RoomState>(
      'lists the devices of its room and the types present',
      build: build,
      verify: (cubit) {
        expect(cubit.state.room?.name, 'Kitchen');
        expect(cubit.state.devices.map((v) => v.device.id), [
          'kt-switch',
          'kt-outlet',
          'kt-motion',
        ]);
        expect(cubit.state.types, [
          DeviceType.wallSwitch,
          DeviceType.outlet,
          DeviceType.sensor,
        ]);
      },
    );

    blocTest<RoomCubit, RoomState>(
      'filter narrows the devices; it resets when its type disappears',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.setFilter(DeviceType.outlet);
        expect(cubit.state.visibleDevices.single.device.id, 'kt-outlet');
        home.transport.emit(
          const DeviceRemoved(homeId: DemoHome.homeId, deviceId: 'kt-outlet'),
        );
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(cubit.state.filter, isNull);
        expect(cubit.state.visibleDevices, hasLength(2));
      },
    );

    blocTest<RoomCubit, RoomState>(
      'toggle sends the requested value',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.toggle(home.device('kt-outlet'), on: false);
      },
      verify: (_) => expect(home.transport.lastCommand.patches, {
        'onOff': const CapabilityPatch.onOff(on: false),
      }),
    );

    test('an unknown room has no room and no devices', () async {
      final cubit = build('attic');
      await pumpEventQueue();
      expect(cubit.state.room, isNull);
      expect(cubit.state.devices, isEmpty);
      await cubit.close();
    });
  });

  group('DeviceCubit', () {
    DeviceCubit build([String id = 'lr-thermostat']) =>
        DeviceCubit(home.homes, home.devices, id);

    blocTest<DeviceCubit, DeviceState>(
      'resolves the device and its room',
      build: build,
      verify: (cubit) {
        expect(cubit.state.view?.device.name, 'Thermostat');
        expect(cubit.state.room?.id, 'living-room');
        expect(cubit.state.resolved, isTrue);
      },
    );

    blocTest<DeviceCubit, DeviceState>(
      'set sends one capability and shows it as pending',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.set('thermostat', const CapabilityPatch.thermostat(setpoint: 24));
        await pumpEventQueue();
      },
      verify: (cubit) {
        final view = cubit.state.view!;
        expect(view.isPending('thermostat'), isTrue);
        expect(
          view.device.stateOf<ThermostatState>('thermostat')!.setpoint,
          24,
        );
        expect(home.transport.lastCommand.deviceId, 'lr-thermostat');
      },
    );

    blocTest<DeviceCubit, DeviceState>(
      'setAll sends several capabilities as one command',
      build: () => build('lr-lamp'),
      act: (cubit) async {
        await pumpEventQueue();
        cubit.setAll(const {
          'onOff': CapabilityPatch.onOff(on: true),
          'brightness': CapabilityPatch.brightness(level: 20),
        });
      },
      verify: (_) {
        expect(home.transport.sent, hasLength(1));
        expect(home.transport.lastCommand.patches.keys, {
          'onOff',
          'brightness',
        });
      },
    );

    blocTest<DeviceCubit, DeviceState>(
      'a timed-out change is rolled back',
      build: build,
      act: (cubit) async {
        await pumpEventQueue();
        cubit.set('thermostat', const CapabilityPatch.thermostat(setpoint: 24));
        home.transport.timeOut();
        await pumpEventQueue();
      },
      verify: (cubit) {
        expect(cubit.state.view!.pending, isFalse);
        expect(
          cubit.state.view!.device
              .stateOf<ThermostatState>('thermostat')!
              .setpoint,
          22.5,
        );
      },
    );

    blocTest<DeviceCubit, DeviceState>(
      'an unknown device resolves to nothing',
      build: () => build('ghost'),
      verify: (cubit) {
        expect(cubit.state.view, isNull);
        expect(cubit.state.resolved, isTrue);
      },
    );
  });

  group('app-wide cubits', () {
    blocTest<ConnectionCubit, TransportStatus>(
      'ConnectionCubit follows the transport',
      build: () => ConnectionCubit(home.devices),
      act: (cubit) async {
        await pumpEventQueue();
        home.transport.setStatus(TransportStatus.reconnecting);
        await pumpEventQueue();
      },
      expect: () => [TransportStatus.connected, TransportStatus.reconnecting],
    );

    blocTest<FeedbackCubit, FeedbackState>(
      'FeedbackCubit reports each rolled-back command once',
      build: () => FeedbackCubit(home.devices),
      act: (cubit) async {
        for (final outcome in [
          () => home.transport.timeOut(),
          () => home.transport.reject(ProtocolErrorCode.busy),
        ]) {
          final result = home.devices.send('lr-lamp', const {
            'onOff': CapabilityPatch.onOff(on: false),
          });
          outcome();
          await result;
          await pumpEventQueue();
        }
      },
      verify: (cubit) {
        expect(cubit.state.sequence, 2);
        expect(cubit.state.failure!.code, ProtocolErrorCode.busy);
        expect(cubit.state.failure!.device.id, 'lr-lamp');
      },
    );

    test('FeedbackCubit notes a timed-out command applied late', () async {
      final cubit = FeedbackCubit(home.devices);
      final result = home.devices.send('lr-lamp', const {
        'onOff': CapabilityPatch.onOff(on: false),
      });
      home.transport.timeOut();
      await result;
      await pumpEventQueue();
      expect(cubit.state.failure!.timedOut, isTrue);

      home.transport.reportState('lr-lamp', {
        ...home.device('lr-lamp').state,
        'onOff': const CapabilityState.onOff(on: false),
      });
      await pumpEventQueue();
      expect(cubit.state.sequence, 2);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.lateApply!.device.id, 'lr-lamp');
      await cubit.close();
    });

    test('successful commands produce no feedback', () async {
      final cubit = FeedbackCubit(home.devices);
      final result = home.devices.send('lr-lamp', const {
        'onOff': CapabilityPatch.onOff(on: false),
      });
      home.transport.ack();
      await result;
      await pumpEventQueue();
      expect(cubit.state.sequence, 0);
      expect(cubit.state.failure, isNull);
      await cubit.close();
    });
  });

  test('DeviceView equality ignores set order', () {
    final device = home.device('lr-lamp');
    expect(
      DeviceView(device: device, pendingCapabilities: const {'a', 'b'}),
      DeviceView(device: device, pendingCapabilities: const {'b', 'a'}),
    );
    expect(
      DeviceView(device: device),
      isNot(DeviceView(device: device, pendingCapabilities: const {'a'})),
    );
  });
}
