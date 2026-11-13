import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:test/test.dart';

/// An in-process BroadcastChannel (see glowhaus_mqtt's bridge_test).
class _Hub {
  final _ports = <_Port>[];

  _Port port() {
    final port = _Port(this);
    _ports.add(port);
    return port;
  }
}

class _Port implements BridgePort {
  new(this._hub);

  final _Hub _hub;
  final _messages = StreamController<Map<String, Object?>>.broadcast();
  bool closed = false;

  @override
  Stream<Map<String, Object?>> get messages => _messages.stream;

  @override
  void post(Map<String, Object?> message) {
    if (closed) return;
    for (final other in _hub._ports) {
      if (identical(other, this) || other.closed) continue;
      final copy = Map<String, Object?>.of(message);
      scheduleMicrotask(() {
        if (!other.closed) other._messages.add(copy);
      });
    }
  }

  @override
  void close() => closed = true;
}

class _Tabs {
  new(this.async) {
    demo = SimulatedTransport(
      homeId: DemoHome.homeId,
      devices: DemoHome.devices(),
      connectDelay: Duration.zero,
      ambientInterval: null,
      config: const SimulationConfig(latency: Duration(milliseconds: 50)),
    );
    demo.events.listen(events.add);
    host = DemoBridgeHost(demo, hub.port(), hostId: 'app-tab');
    host.devicesAway.listen(away.add);
    unawaited(demo.connect());
    async.elapse(const Duration(milliseconds: 100));
  }

  final FakeAsync async;
  final hub = _Hub();
  late final SimulatedTransport demo;
  late final DemoBridgeHost host;
  final events = <DeviceEvent>[];
  final away = <bool>[];
  late _Port guestPort;

  RemoteDemoHome join({String guestId = 'devices-tab'}) {
    guestPort = hub.port();
    RemoteDemoHome? remote;
    unawaited(
      RemoteDemoHome.join(
        guestPort,
        guestId: guestId,
        ambientInterval: null,
      ).then((r) => remote = r),
    );
    async.elapse(const Duration(milliseconds: 500));
    return remote!;
  }

  CommandResult? send(String deviceId, Map<String, CapabilityPatch> patches) {
    CommandResult? result;
    unawaited(
      demo
          .send(
            DeviceCommand(
              id: 'c-${DateTime.now().microsecondsSinceEpoch}',
              homeId: DemoHome.homeId,
              deviceId: deviceId,
              issuedAt: DateTime.now(),
              patches: patches,
            ),
          )
          .then((r) => result = r),
    );
    async.elapse(const Duration(seconds: 1));
    return result;
  }

  Future<void> close() async {
    await host.close();
    await demo.dispose();
  }
}

const _lampOn = {'onOff': CapabilityPatch.onOff(on: true)};

bool _isOn(Map<String, CapabilityState>? state) =>
    state?.values.whereType<OnOffState>().any((s) => s.on) ?? false;

void main() {
  test(
    'the devices move to the other tab, state and all, and answer there',
    () {
      fakeAsync((async) {
        final tabs = _Tabs(async);
        expect(tabs.send('lr-lamp', _lampOn), isA<CommandAcked>());
        expect(_isOn(tabs.demo.deviceState('lr-lamp')), isTrue);

        final remote = tabs.join();
        expect(tabs.away, [true]);
        expect(tabs.demo.devicesAway, isTrue);
        expect(
          tabs.demo.home.devices.values.where((d) => d.online),
          isEmpty,
          reason: 'the devices left this tab',
        );
        final lamp = remote.home.device('lr-lamp')!;
        expect(lamp.online, isTrue);
        expect(_isOn(lamp.state), isTrue, reason: 'carried over');
        expect(
          remote.home.device('kt-motion')!.online,
          isFalse,
          reason: 'offline stays offline',
        );

        // A command from the app tab, answered by the device in the other.
        expect(
          tabs.send('lr-ceiling', {
            'onOff': const CapabilityPatch.onOff(on: true),
          }),
          isA<CommandAcked>(),
        );
        expect(_isOn(remote.home.stateOf('lr-ceiling')), isTrue);
        expect(
          remote.traffic.entries.map((e) => (e.who, e.direction, e.topic)),
          contains((
            'lr-ceiling',
            TrafficDirection.received,
            'glowhaus/demo-home/lr-ceiling/set',
          )),
        );

        // Someone presses the lamp's own button in the devices tab.
        tabs.events.clear();
        unawaited(
          lamp.pressLocal({'onOff': const CapabilityPatch.onOff(on: false)}),
        );
        async.elapse(const Duration(milliseconds: 100));
        final reported = tabs.events.whereType<DeviceStateChanged>().last;
        expect(reported.deviceId, 'lr-lamp');
        expect(_isOn(reported.state), isFalse);

        unawaited(remote.leave());
        unawaited(tabs.close());
        async.flushMicrotasks();
      });
    },
  );

  test('after a clean leave the devices come home with their latest state, '
      'an unplugged one still unplugged', () {
    fakeAsync((async) {
      final tabs = _Tabs(async);
      final remote = tabs.join();
      unawaited(remote.home.device('lr-lamp')!.pressLocal(_lampOn));
      unawaited(remote.home.setOnline('kt-switch', online: false));
      async.elapse(const Duration(milliseconds: 200));

      unawaited(remote.leave());
      async.elapse(const Duration(milliseconds: 200));
      expect(tabs.away, [true, false]);
      expect(tabs.demo.devicesAway, isFalse);
      final home = tabs.demo.home;
      expect(home.device('lr-lamp')!.online, isTrue);
      expect(_isOn(home.stateOf('lr-lamp')), isTrue);
      expect(home.device('kt-switch')!.online, isFalse);
      expect(home.device('kt-motion')!.online, isFalse);
      unawaited(tabs.close());
      async.flushMicrotasks();
    });
  });

  test('when the devices tab vanishes, its wills are not mistaken for '
      'unplugging', () {
    fakeAsync((async) {
      // The tab is gone, without a goodbye.
      final tabs = _Tabs(async)..join();
      tabs.guestPort.close();
      async.elapse(const Duration(seconds: 6));
      expect(tabs.away.last, isFalse);
      final online = tabs.demo.home.devices.values
          .where((d) => d.online)
          .map((d) => d.id)
          .toSet();
      expect(online, {
        for (final spec in DemoHome.devices())
          if (spec.online) spec.descriptor.id,
      });
      final lastAvailability = tabs.events
          .whereType<DeviceAvailabilityChanged>()
          .where((e) => e.deviceId == 'lr-lamp')
          .last;
      expect(lastAvailability.availability, DeviceAvailability.online);
      unawaited(tabs.close());
      async.flushMicrotasks();
    });
  });

  test('a second devices tab takes over: the first is sent away, the second '
      'carries on from the broker, no device runs twice', () {
    fakeAsync((async) {
      final tabs = _Tabs(async);
      final first = tabs.join(guestId: 'tab-1');
      unawaited(first.home.device('lr-lamp')!.pressLocal(_lampOn));
      unawaited(first.home.setOnline('kt-switch', online: false));
      async.elapse(const Duration(milliseconds: 200));
      var firstEvicted = false;
      unawaited(first.evicted.then((_) => firstEvicted = true));

      final second = tabs.join(guestId: 'tab-2');
      async.elapse(const Duration(milliseconds: 100));
      expect(firstEvicted, isTrue);
      expect(
        first.home.devices.values.where((d) => d.online),
        isEmpty,
        reason: 'the first tab stopped its devices',
      );
      expect(tabs.away, isNot(contains(false)), reason: 'never came home');
      expect(tabs.demo.home.devices.values.where((d) => d.online), isEmpty);

      final lamp = second.home.device('lr-lamp')!;
      expect(lamp.online, isTrue);
      expect(_isOn(lamp.state), isTrue, reason: 'from the retained state');
      expect(second.home.device('kt-switch')!.online, isFalse);
      expect(second.home.device('kt-motion')!.online, isFalse);
      expect(
        tabs.demo.broker.connectedClientIds.where(
          (id) => id.contains('lr-lamp'),
        ),
        hasLength(1),
      );

      expect(_isOn(second.home.stateOf('br-reading')), isFalse);
      expect(tabs.send('br-reading', _lampOn), isA<CommandAcked>());
      expect(_isOn(second.home.stateOf('br-reading')), isTrue);
      expect(_isOn(first.home.stateOf('br-reading')), isFalse);

      unawaited(second.leave());
      async.elapse(const Duration(milliseconds: 200));
      expect(tabs.away.last, isFalse);
      expect(_isOn(tabs.demo.home.stateOf('lr-lamp')), isTrue);
      unawaited(tabs.close());
      async.flushMicrotasks();
    });
  });

  test('no app tab: joining times out', () {
    fakeAsync((async) {
      Object? error;
      unawaited(() async {
        try {
          await RemoteDemoHome.join(_Hub().port(), guestId: 'alone');
        } on TimeoutException catch (e) {
          error = e;
        }
      }());
      async.elapse(const Duration(seconds: 4));
      expect(error, isA<TimeoutException>());
    });
  });
}
