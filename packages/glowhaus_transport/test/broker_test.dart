// Runs only against a real broker: the Mosquitto in infra/docker-compose.yml
// with the simulator container beside it. CI starts both; locally:
//
//   infra/scripts/make-users.sh
//   docker compose -f infra/docker-compose.yml up -d --build mosquitto simulator
//   GLOWHAUS_BROKER_HOST=127.0.0.1 dart test test/broker_test.dart
//
// Without GLOWHAUS_BROKER_HOST every test here is skipped.
@Timeout(Duration(minutes: 2))
library;

import 'dart:async';
import 'dart:io';

import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:test/test.dart';

const String _home = DemoHome.homeId;
const TopicCodec _topics = TopicCodec();

/// Long enough for a slow CI runner, short enough to notice a denial.
const Duration _silence = Duration(seconds: 2);

void main() {
  final host = Platform.environment['GLOWHAUS_BROKER_HOST'];
  if (host == null) {
    test(
      'real broker',
      () {},
      skip: 'set GLOWHAUS_BROKER_HOST (see the header of this file)',
    );
    return;
  }
  final endpoint = MqttEndpoint(
    host: host,
    port: int.parse(Platform.environment['GLOWHAUS_BROKER_PORT'] ?? '1883'),
    tls: false,
  );
  final logins = _Credentials.load();

  MqttClientConnection connection() => MqttClientConnection(endpoint);

  group('MqttTransport against Mosquitto and the simulator container', () {
    late MqttTransport transport;
    late List<DeviceEvent> events;

    setUp(() {
      transport = MqttTransport(
        homeId: _home,
        connection: connection(),
        clientId: 'test-app-${DateTime.now().microsecondsSinceEpoch}',
        login: logins.app,
      );
      events = [];
      transport.events.listen(events.add);
    });

    tearDown(() => transport.dispose());

    test('every online demo device announces, with retained state', () async {
      await transport.connect();
      expect(transport.currentStatus, TransportStatus.connected);
      // kt-motion is offline in the demo: it announced once, before this
      // app session existed, and a QoS 0 announce is not retained. Over a
      // real broker a new session therefore does not see it. See the
      // "Known gap" note in infra/README.md.
      final expected = {
        for (final d in DemoHome.devices())
          if (d.online) d.descriptor.id,
      };
      await _until(
        () =>
            events.whereType<DeviceAnnounced>().map((e) => e.deviceId).toSet(),
        containsAll(expected),
        reason: 'the simulator answers the query for every online device',
      );
      await _until(
        () => events
            .whereType<DeviceStateChanged>()
            .map((e) => e.deviceId)
            .toSet()
            .containsAll(expected),
        isTrue,
        reason: 'retained state for every online device',
      );
    });

    test('a command is acked and the new state comes back', () async {
      await transport.connect();
      await _until(
        () => events.whereType<DeviceStateChanged>().any(
          (e) => e.deviceId == 'lr-ceiling',
        ),
        isTrue,
      );
      final before =
          events
                  .whereType<DeviceStateChanged>()
                  .lastWhere((e) => e.deviceId == 'lr-ceiling')
                  .state['onOff']!
              as OnOffState;
      final on = !before.on;
      final result = await transport.send(
        DeviceCommand(
          id: 'it-${DateTime.now().microsecondsSinceEpoch}',
          homeId: _home,
          deviceId: 'lr-ceiling',
          issuedAt: DateTime.now(),
          patches: {'onOff': CapabilityPatch.onOff(on: on)},
        ),
        timeout: const Duration(seconds: 10),
      );
      expect(result, isA<CommandAcked>());
      await _until(
        () => events.whereType<DeviceStateChanged>().any(
          (e) =>
              e.deviceId == 'lr-ceiling' &&
              (e.state['onOff']! as OnOffState).on == on,
        ),
        isTrue,
        reason: 'the device reports the requested value',
      );
    });
  });

  group('ACLs bind every identity to its own topics', () {
    late _Client app;
    late _Client lamp;

    setUp(() async {
      app = await _Client.connect(connection(), 'acl-app', logins.app);
      lamp = await _Client.connect(
        connection(),
        'acl-lamp',
        logins.device('lr-lamp'),
      );
    });

    tearDown(() async {
      await app.dispose();
      await lamp.dispose();
    });

    test("a device cannot publish another device's ack or state", () async {
      await app.subscribe(_topics.allDevicesFilter(_home, DeviceChannel.ack));
      await app.subscribe(
        _topics.device(_home, 'lr-ceiling', DeviceChannel.state),
      );
      final retainedCeiling = await app.next(
        (m) => m.topic.endsWith('lr-ceiling/state'),
      );
      expect(retainedCeiling.retained, isTrue, reason: 'the real one');

      // Forged: the lamp's identity on the ceiling light's topics.
      await lamp.publish(
        _topics.device(_home, 'lr-ceiling', DeviceChannel.ack),
        '{"forged":true}',
      );
      await lamp.publish(
        _topics.device(_home, 'lr-ceiling', DeviceChannel.state),
        '{"forged":true}',
      );
      // Its own ack: allowed. It arrives after the forged ones would have.
      await lamp.publish(
        _topics.device(_home, 'lr-lamp', DeviceChannel.ack),
        '{"own":true}',
      );
      final own = await app.next((m) => m.text == '{"own":true}');
      expect(own.topic, _topics.device(_home, 'lr-lamp', DeviceChannel.ack));
      expect(
        app.received.where((m) => m.text == '{"forged":true}'),
        isEmpty,
        reason: 'the broker dropped both forged messages',
      );
    });

    test("a device cannot read another device's commands", () async {
      await lamp.subscribe(
        _topics.device(_home, 'kt-motion', DeviceChannel.set),
      );
      await lamp.subscribe(_topics.device(_home, 'lr-lamp', DeviceChannel.set));
      // kt-motion is offline in the demo, so nothing else reacts to this.
      await app.publish(
        _topics.device(_home, 'kt-motion', DeviceChannel.set),
        '{"probe":"other"}',
      );
      await app.publish(
        _topics.device(_home, 'lr-lamp', DeviceChannel.set),
        '{"probe":"own"}',
      );
      final own = await lamp.next((m) => m.text == '{"probe":"own"}');
      expect(own.topic, _topics.device(_home, 'lr-lamp', DeviceChannel.set));
      expect(
        lamp.received.where((m) => m.text == '{"probe":"other"}'),
        isEmpty,
      );
    });

    test('nobody reaches another home', () async {
      await app.subscribe('glowhaus/other-home/#');
      await app.subscribe(_topics.allDevicesFilter(_home, DeviceChannel.ack));
      await app.publish(
        'glowhaus/other-home/lr-lamp/state',
        '{"leak":true}',
        retain: true,
      );
      await lamp.publish('glowhaus/other-home/lr-lamp/state', '{"leak":true}');
      await lamp.publish(
        _topics.device(_home, 'lr-lamp', DeviceChannel.ack),
        '{"own":true}',
      );
      await app.next((m) => m.text == '{"own":true}');
      await Future<void>.delayed(_silence);
      expect(app.received.where((m) => m.text == '{"leak":true}'), isEmpty);
    });

    test(
      "a will on another device's availability is never published",
      () async {
        // Mosquitto applies the ACL when it would publish the will, not at
        // connect. A client-id takeover is an ungraceful disconnect, so it
        // triggers the will without closing the socket by hand.
        final availability = _topics.device(
          _home,
          'lr-ceiling',
          DeviceChannel.availability,
        );
        await app.subscribe(
          _topics.allDevicesFilter(_home, DeviceChannel.availability),
        );
        await app.next((m) => m.topic == availability && m.retained);

        final id = 'acl-will-${DateTime.now().microsecondsSinceEpoch}';
        final forged = connection();
        await forged.connect(
          clientId: id,
          will: MqttWill.text(availability, '{"online":false,"forged":true}'),
          login: logins.device('lr-lamp'),
        );
        final takeover = connection();
        await takeover.connect(clientId: id, login: logins.device('lr-lamp'));

        // Control: the same takeover with a will on the lamp's own topic.
        final own = _topics.device(
          _home,
          'lr-lamp',
          DeviceChannel.availability,
        );
        final honest = connection();
        await honest.connect(
          clientId: '$id-own',
          will: MqttWill.text(own, '{"online":false,"control":true}'),
          login: logins.device('lr-lamp'),
        );
        final takeover2 = connection();
        await takeover2.connect(
          clientId: '$id-own',
          login: logins.device('lr-lamp'),
        );
        try {
          final control = await app.next((m) => m.text.contains('"control"'));
          expect(control.topic, own);
          expect(
            app.received.where((m) => m.text.contains('"forged"')),
            isEmpty,
          );
        } finally {
          for (final c in [forged, takeover, honest, takeover2]) {
            await c.dispose();
          }
        }
      },
    );
  });
}

/// A raw MQTT client for the ACL tests: keeps what it received.
class _Client {
  new _(this._connection);

  final MqttConnection _connection;
  final received = <MqttMessage>[];
  final _arrivals = StreamController<MqttMessage>.broadcast();

  static Future<_Client> connect(
    MqttConnection connection,
    String clientIdPrefix,
    MqttLogin login,
  ) async {
    final client = _Client._(connection);
    connection.messages.listen((message) {
      client.received.add(message);
      client._arrivals.add(message);
    });
    await connection.connect(
      clientId: '$clientIdPrefix-${DateTime.now().microsecondsSinceEpoch}',
      login: login,
    );
    return client;
  }

  Future<void> subscribe(String filter) => _connection.subscribe(filter);

  Future<void> publish(String topic, String text, {bool retain = false}) =>
      _connection.publishText(topic, text, retain: retain);

  /// The next received message matching [test], already received or not.
  Future<MqttMessage> next(bool Function(MqttMessage) test) async {
    for (final message in received) {
      if (test(message)) return message;
    }
    return await _arrivals.stream
        .firstWhere(test)
        .timeout(const Duration(seconds: 15));
  }

  Future<void> dispose() async {
    await _connection.dispose();
    await _arrivals.close();
  }
}

/// `infra/secrets/credentials`, or the file GLOWHAUS_CREDENTIALS names.
class _Credentials {
  factory load() {
    final path =
        Platform.environment['GLOWHAUS_CREDENTIALS'] ??
        '../../infra/secrets/credentials';
    final byUser = <String, String>{};
    for (final line in File(path).readAsLinesSync()) {
      final colon = line.indexOf(':');
      if (colon <= 0 || line.startsWith('#')) continue;
      byUser[line.substring(0, colon)] = line.substring(colon + 1).trim();
    }
    return _Credentials._(byUser);
  }

  new _(this._byUser);

  final Map<String, String> _byUser;

  MqttLogin get app => _login('$_home.app');

  MqttLogin device(String deviceId) => _login('$_home.$deviceId');

  MqttLogin _login(String username) {
    final password = _byUser[username];
    if (password == null) {
      throw StateError('no credentials for $username; run make-users.sh');
    }
    return MqttLogin(username: username, password: password);
  }
}

/// Polls [read] until it matches, for up to 45 s.
Future<void> _until<T>(
  T Function() read,
  Matcher matcher, {
  String? reason,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 45));
  while (true) {
    final value = read();
    if (matcher.matches(value, {})) return;
    if (DateTime.now().isAfter(deadline)) {
      expect(value, matcher, reason: reason);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
