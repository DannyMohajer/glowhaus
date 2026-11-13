import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:test/test.dart';

/// An in-process BroadcastChannel: what one port posts reaches every other
/// port, asynchronously and in order.
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
      // A structured clone: no shared mutable state between "tabs".
      final copy = Map<String, Object?>.of(message);
      scheduleMicrotask(() {
        if (!other.closed) other._messages.add(copy);
      });
    }
  }

  @override
  void close() => closed = true;
}

void main() {
  late InMemoryBroker broker;
  late _Hub hub;
  late BridgeHost host;
  late List<String> joined;
  late List<String> left;

  BridgeHost makeHost(String id, {Map<String, Object?> welcome = const {}}) =>
      BridgeHost(
        broker: broker,
        port: hub.port(),
        hostId: id,
        onJoin: (guest) {
          joined.add(guest);
          return welcome;
        },
        onLeave: left.add,
      );

  void setUpBridge() {
    broker = InMemoryBroker();
    hub = _Hub();
    joined = [];
    left = [];
    host = makeHost('host-a', welcome: {'states': 'hello'});
  }

  test('a guest joins, then subscribes and publishes through the host', () {
    fakeAsync((async) {
      setUpBridge();
      final local = broker.client();
      final seenHere = <MqttMessage>[];
      unawaited(
        local
            .connect(clientId: 'local')
            .then((_) => local.subscribe('demo/#'))
            .then((_) => local.messages.listen(seenHere.add)),
      );
      unawaited(local.publishText('demo/retained', 'kept', retain: true));
      async.flushMicrotasks();

      final guest = BridgeGuest(port: hub.port(), guestId: 'tab-2');
      Map<String, Object?>? welcome;
      unawaited(guest.join().then((w) => welcome = w));
      async.flushMicrotasks();
      expect(welcome?['states'], 'hello');
      expect(joined, ['tab-2']);
      expect(guest.hostId, 'host-a');

      final remote = guest.connection();
      final seenThere = <MqttMessage>[];
      remote.messages.listen(seenThere.add);
      unawaited(
        remote
            .connect(clientId: 'remote')
            .then((_) => remote.subscribe('demo/#')),
      );
      async.flushMicrotasks();
      expect(remote.currentState, MqttConnectionState.connected);
      expect(broker.connectedClientIds, contains('remote'));
      expect(seenThere.single.retained, isTrue, reason: 'retained arrives');

      unawaited(remote.publishText('demo/from-tab', 'hi'));
      async.flushMicrotasks();
      expect(seenHere.map((m) => m.text), contains('hi'));

      unawaited(local.publishText('demo/to-tab', 'yo'));
      async.flushMicrotasks();
      expect(seenThere.last.text, 'yo');

      unawaited(host.close());
      async.flushMicrotasks();
    });
  });

  test('a guest that goes silent is dropped and its will is published', () {
    fakeAsync((async) {
      setUpBridge();
      final watcher = broker.client();
      final seen = <MqttMessage>[];
      unawaited(
        watcher
            .connect(clientId: 'watcher')
            .then((_) => watcher.subscribe('dev/+/availability'))
            .then((_) => watcher.messages.listen(seen.add)),
      );
      final port = hub.port();
      final guest = BridgeGuest(port: port, guestId: 'tab-2');
      unawaited(guest.join());
      async.flushMicrotasks();
      final device = guest.connection();
      unawaited(
        device.connect(
          clientId: 'device-lamp',
          will: MqttWill.text('dev/lamp/availability', 'offline', retain: true),
        ),
      );
      async.elapse(const Duration(seconds: 2));
      expect(broker.connectedClientIds, contains('device-lamp'));
      expect(left, isEmpty, reason: 'heartbeats keep it alive');

      // The tab is closed without a word.
      port.close();
      async.elapse(const Duration(seconds: 6));
      expect(left, ['tab-2']);
      expect(broker.connectedClientIds, isNot(contains('device-lamp')));
      expect(seen.single.text, 'offline');
      expect(broker.retained('dev/lamp/availability')?.text, 'offline');
      unawaited(host.close());
      async.flushMicrotasks();
    });
  });

  test('a guest that says bye leaves without wills', () {
    fakeAsync((async) {
      setUpBridge();
      final guest = BridgeGuest(port: hub.port(), guestId: 'tab-2');
      unawaited(guest.join());
      async.flushMicrotasks();
      final device = guest.connection();
      unawaited(
        device.connect(
          clientId: 'device-lamp',
          will: MqttWill.text('dev/lamp/availability', 'offline'),
        ),
      );
      async.flushMicrotasks();
      unawaited(guest.leave());
      async.flushMicrotasks();
      expect(left, ['tab-2']);
      expect(broker.connectedClientIds, isEmpty);
      expect(broker.retained('dev/lamp/availability'), isNull);
      expect(device.currentState, MqttConnectionState.disconnected);
      unawaited(host.close());
      async.flushMicrotasks();
    });
  });

  test('with two hosts, the guest stays with the first that answered', () {
    fakeAsync((async) {
      setUpBridge();
      final second = makeHost('host-b');
      final guest = BridgeGuest(port: hub.port(), guestId: 'tab-2');
      unawaited(guest.join());
      async.flushMicrotasks();
      expect(guest.hostId, 'host-a');
      final remote = guest.connection();
      unawaited(remote.connect(clientId: 'remote'));
      async.flushMicrotasks();
      expect(remote.currentState, MqttConnectionState.connected);
      expect(
        broker.connectedClientIds.where((id) => id == 'remote'),
        hasLength(1),
      );
      unawaited(host.close());
      unawaited(second.close());
      async.flushMicrotasks();
    });
  });

  test('join without a host times out', () {
    fakeAsync((async) {
      hub = _Hub();
      final guest = BridgeGuest(port: hub.port(), guestId: 'lonely');
      Object? error;
      unawaited(() async {
        try {
          await guest.join();
        } on TimeoutException catch (e) {
          error = e;
        }
      }());
      async.elapse(const Duration(seconds: 4));
      expect(error, isA<TimeoutException>());
    });
  });

  test(
    'the traffic log records what a tapped connection sends and receives',
    () {
      fakeAsync((async) {
        final broker = InMemoryBroker();
        final log = MqttTrafficLog(capacity: 3);
        final device = log.tap(broker.client(), who: 'lamp');
        final app = broker.client();
        final seen = <MqttMessage>[];
        unawaited(
          device
              .connect(clientId: 'lamp')
              .then((_) => device.subscribe('t/#'))
              .then((_) => device.messages.listen(seen.add)),
        );
        unawaited(app.connect(clientId: 'app'));
        async.flushMicrotasks();
        unawaited(app.publishText('t/set', 'on'));
        unawaited(device.publishText('t/state', 'is on', retain: true));
        async.flushMicrotasks();

        expect(seen.first.text, 'on', reason: 'still delivered');
        expect(log.entries.map((e) => (e.direction, e.topic, e.text)), [
          (TrafficDirection.received, 't/set', 'on'),
          (TrafficDirection.sent, 't/state', 'is on'),
          (TrafficDirection.received, 't/state', 'is on'),
        ]);
        expect(log.entries.every((e) => e.who == 'lamp'), isTrue);
        for (var i = 0; i < 5; i++) {
          unawaited(app.publishText('x/$i', '$i'));
        }
        unawaited(device.publishText('x/last', 'last'));
        async.flushMicrotasks();
        expect(log.entries, hasLength(3), reason: 'bounded');
        expect(log.entries.last.text, 'last');
      });
    },
  );
}
