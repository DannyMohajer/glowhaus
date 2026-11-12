import 'dart:async';
import 'dart:math';

import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:test/test.dart';

/// Collects a connection's messages and state changes.
class Spy {
  new(this.connection) {
    connection.messages.listen(messages.add);
    connection.state.listen(states.add);
  }

  final MqttConnection connection;
  final messages = <MqttMessage>[];
  final states = <MqttConnectionState>[];

  /// Lets queued stream events arrive.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  List<String> get texts => [for (final m in messages) '${m.topic}=${m.text}'];
}

void main() {
  late InMemoryBroker broker;

  setUp(() => broker = InMemoryBroker());
  tearDown(() => broker.close());

  Future<Spy> client(String id, {MqttWill? will}) async {
    final connection = broker.client();
    final spy = Spy(connection);
    await connection.connect(clientId: id, will: will);
    return spy;
  }

  test(
    'publish reaches matching subscribers, including the publisher',
    () async {
      final app = await client('app');
      final device = await client('device');
      await app.connection.subscribe('home/+/ack');
      await device.connection.subscribe('home/lamp/set');

      await app.connection.publishText('home/lamp/set', 'on');
      await device.connection.publishText('home/lamp/ack', 'ok');
      await app.settle();

      expect(device.texts, ['home/lamp/set=on']);
      expect(app.texts, ['home/lamp/ack=ok']);
      expect(app.messages.single.retained, isFalse);
    },
  );

  test(
    'retained: stored, delivered on subscribe, cleared by empty payload',
    () async {
      final device = await client('device');
      await device.connection.publishText(
        'home/lamp/state',
        'v1',
        retain: true,
      );
      await device.connection.publishText(
        'home/lamp/state',
        'v2',
        retain: true,
      );
      expect(broker.retained('home/lamp/state')?.text, 'v2');

      final late = await client('late-app');
      await late.connection.subscribe('home/+/state');
      await late.settle();
      expect(late.texts, ['home/lamp/state=v2']);
      expect(late.messages.single.retained, isTrue, reason: 'stored copy');

      // Live forward keeps retained=false even though the publisher set it.
      await device.connection.publishText(
        'home/lamp/state',
        'v3',
        retain: true,
      );
      await late.settle();
      expect(late.messages.last.retained, isFalse);

      await device.connection.publishText('home/lamp/state', '', retain: true);
      expect(broker.retained('home/lamp/state'), isNull);
      final later = await client('later-app');
      await later.connection.subscribe('#');
      await later.settle();
      expect(later.messages, isEmpty);
    },
  );

  test('a non-retained publish is not kept', () async {
    final app = await client('app');
    await app.connection.publishText('home/lamp/set', 'on');
    expect(broker.retainedCount, 0);
  });

  group('will', () {
    final will = MqttWill.text(
      'home/lamp/availability',
      'offline',
      retain: true,
    );

    test('published when the client is dropped', () async {
      final app = await client('app');
      await app.connection.subscribe('home/lamp/availability');
      final device = await client('device', will: will);
      await device.connection.publishText(
        'home/lamp/availability',
        'online',
        retain: true,
      );

      broker.drop('device');
      await app.settle();
      expect(app.texts, [
        'home/lamp/availability=online',
        'home/lamp/availability=offline',
      ]);
      expect(broker.retained('home/lamp/availability')?.text, 'offline');
      expect(device.connection.currentState, MqttConnectionState.disconnected);
      expect(device.states.last, MqttConnectionState.disconnected);
    });

    test('discarded on a clean disconnect', () async {
      final app = await client('app');
      await app.connection.subscribe('#');
      final device = await client('device', will: will);
      await device.connection.disconnect();
      await app.settle();
      expect(app.messages, isEmpty);
      expect(broker.connectedClientIds, ['app']);
    });

    test('a second connection with the same client id takes over', () async {
      final app = await client('app');
      await app.connection.subscribe('#');
      final first = await client('device', will: will);
      await first.connection.subscribe('home/lamp/set');
      final second = await client('device');
      await app.settle();

      expect(first.connection.currentState, MqttConnectionState.disconnected);
      expect(second.connection.currentState, MqttConnectionState.connected);
      expect(app.texts, ['home/lamp/availability=offline']);
      expect(broker.connectedClientIds, ['app', 'device']);

      // The old session's subscriptions are gone with it.
      await app.connection.publishText('home/lamp/set', 'on');
      await app.settle();
      expect(first.messages, isEmpty);
    });
  });

  group('QoS', () {
    test('delivered QoS is the lower of publish and subscription', () async {
      final app = await client('app');
      await app.connection.subscribe('q1/#');
      await app.connection.subscribe('q0/#', qos: MqttQos.atMostOnce);
      await app.connection.publishText('q1/a', 'x', qos: MqttQos.atMostOnce);
      await app.connection.publishText('q1/b', 'x');
      await app.connection.publishText('q0/a', 'x');
      await app.connection.publishText('q1/c', 'x', qos: MqttQos.exactlyOnce);
      await app.settle();
      expect(app.messages.map((m) => m.qos), [
        MqttQos.atMostOnce,
        MqttQos.atLeastOnce,
        MqttQos.atMostOnce,
        MqttQos.atLeastOnce,
      ]);
    });

    test(
      'overlapping subscriptions deliver once, at the highest QoS',
      () async {
        final app = await client('app');
        await app.connection.subscribe('home/#', qos: MqttQos.atMostOnce);
        await app.connection.subscribe('home/+/state');
        await app.connection.publishText('home/lamp/state', 'x');
        await app.settle();
        expect(app.messages, hasLength(1));
        expect(app.messages.single.qos, MqttQos.atLeastOnce);
      },
    );

    test('only QoS 0 can be lost', () async {
      broker = InMemoryBroker(qos0LossRate: 1, random: Random(1));
      final app = await client('app');
      await app.connection.subscribe('discovery', qos: MqttQos.atMostOnce);
      await app.connection.subscribe('home/+/ack');
      for (var i = 0; i < 20; i++) {
        await app.connection.publishText(
          'discovery',
          'q',
          qos: MqttQos.atMostOnce,
        );
        await app.connection.publishText('home/lamp/ack', 'ok');
      }
      await app.settle();
      expect(app.messages, hasLength(20));
      expect(app.messages.every((m) => m.topic == 'home/lamp/ack'), isTrue);
    });
  });

  test(r'wildcards and $ topics follow the spec', () async {
    final app = await client('app');
    await app.connection.subscribe('#');
    await app.connection.publishText(r'$SYS/broker/uptime', '1');
    await app.connection.publishText('home/lamp/state', 'x');
    await app.settle();
    expect(app.texts, ['home/lamp/state=x']);
  });

  test('unsubscribe stops delivery', () async {
    final app = await client('app');
    await app.connection.subscribe('home/+/state');
    await app.connection.unsubscribe('home/+/state');
    await app.connection.publishText('home/lamp/state', 'x');
    await app.settle();
    expect(app.messages, isEmpty);
  });

  test('latency delays delivery and drops it if the client leaves', () async {
    broker = InMemoryBroker(latency: const Duration(milliseconds: 20));
    final app = await client('app');
    await app.connection.subscribe('#');
    final gone = await client('gone');
    await gone.connection.subscribe('#');
    await app.connection.publishText('t', 'x');
    await gone.connection.disconnect();
    expect(app.messages, isEmpty, reason: 'not yet');
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(app.texts, ['t=x']);
    expect(gone.messages, isEmpty);
  });

  group('errors', () {
    test('publish and subscribe need a connection', () async {
      final connection = broker.client();
      expect(
        () => connection.publishText('t', 'x'),
        throwsA(isA<MqttConnectionException>()),
      );
      expect(
        () => connection.subscribe('t'),
        throwsA(isA<MqttConnectionException>()),
      );
    });

    test('invalid topics and filters are refused', () async {
      final app = await client('app');
      expect(
        () => app.connection.publishText('home/+', 'x'),
        throwsA(isA<MqttConnectionException>()),
      );
      expect(
        () => app.connection.subscribe('home/#/x'),
        throwsA(isA<MqttConnectionException>()),
      );
      expect(
        () => broker.client().connect(clientId: ''),
        throwsA(isA<MqttConnectionException>()),
      );
    });

    test('a closed broker refuses clients and drops the rest', () async {
      final app = await client('app');
      await broker.close();
      expect(app.connection.currentState, MqttConnectionState.disconnected);
      expect(() => broker.client(), throwsA(isA<MqttConnectionException>()));
    });

    test('reconnecting after a drop starts a clean session', () async {
      final device = await client('device');
      await device.connection.subscribe('home/lamp/set');
      broker.drop('device');
      await device.connection.connect(clientId: 'device');
      expect(device.connection.currentState, MqttConnectionState.connected);
      final app = await client('app');
      await app.connection.publishText('home/lamp/set', 'on');
      await device.settle();
      expect(device.messages, isEmpty, reason: 'subscriptions not restored');
      expect(device.states, [
        MqttConnectionState.connecting,
        MqttConnectionState.connected,
        MqttConnectionState.disconnected,
        MqttConnectionState.connecting,
        MqttConnectionState.connected,
      ]);
    });

    test('dispose closes the streams', () async {
      final app = await client('app');
      final done = app.connection.messages.toList();
      await app.connection.dispose();
      expect(await done, isEmpty);
      expect(
        () => app.connection.connect(clientId: 'app'),
        throwsA(isA<MqttConnectionException>()),
      );
    });
  });

  test('two brokers are isolated', () async {
    final other = InMemoryBroker();
    addTearDown(other.close);
    final a = await client('a');
    await a.connection.subscribe('#');
    final b = Spy(other.client());
    await b.connection.connect(clientId: 'b');
    await b.connection.publishText('t', 'x');
    await a.settle();
    expect(a.messages, isEmpty);
  });

  test('unawaited publishes keep their order', () async {
    final app = await client('app');
    await app.connection.subscribe('#');
    for (var i = 0; i < 5; i++) {
      unawaited(app.connection.publishText('t', '$i'));
    }
    await app.settle();
    expect(app.messages.map((m) => m.text), ['0', '1', '2', '3', '4']);
  });
}
