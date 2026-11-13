import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';

const _usage =
    '''
Runs the Glowhaus demo home (twelve virtual devices) against an MQTT broker.

Usage: dart run simulator/bin/simulator.dart [options]

  --host <host>        Broker host (default: localhost)
  --port <port>        Broker port (default: 8883, or 1883 with --no-tls)
  --no-tls             Plain MQTT instead of MQTT over TLS
  --home <id>          Home id (default: ${DemoHome.homeId})
  --username <name>    Broker username
  --password <secret>  Broker password (or set GLOWHAUS_PASSWORD)
  --latency <ms>       Mean command latency (default: 250)
  --failure-rate <p>   Share of commands rejected as busy, 0..1 (default: 0)
  --timeout-rate <p>   Share of commands lost on the way, 0..1 (default: 0)
  --help               This text

The devices follow docs/protocol.md: a retained last will, retained state,
one ack per command, an announce on every discovery query. Stop with Ctrl-C;
every device then publishes "offline" and disconnects cleanly.
''';

Future<void> main(List<String> arguments) async {
  final args = _Args(arguments);
  if (args.flag('help')) {
    stdout.write(_usage);
    return;
  }
  final tls = !args.flag('no-tls');
  final endpoint = MqttEndpoint(
    host: args.option('host') ?? 'localhost',
    port: int.parse(args.option('port') ?? (tls ? '8883' : '1883')),
    tls: tls,
  );
  final username = args.option('username');
  final password =
      args.option('password') ?? Platform.environment['GLOWHAUS_PASSWORD'];
  final homeId = args.option('home') ?? DemoHome.homeId;

  final home = VirtualHome(
    homeId: homeId,
    specs: DemoHome.devices(),
    connectionFactory: () => _LoggedConnection(
      MqttClientConnection(endpoint),
      login: username == null
          ? null
          : MqttLogin(username: username, password: password),
    ),
    config: SimulationConfig(
      latency: Duration(
        milliseconds: int.parse(args.option('latency') ?? '250'),
      ),
      failureRate: double.parse(args.option('failure-rate') ?? '0'),
      timeoutRate: double.parse(args.option('timeout-rate') ?? '0'),
    ),
  );

  stdout.writeln('Glowhaus simulator: home "$homeId" on $endpoint');
  try {
    await home.start();
  } on MqttConnectionException catch (error) {
    stderr.writeln('Could not connect: ${error.message}');
    exitCode = 1;
    return;
  }
  stdout.writeln('${home.devices.length} devices up. Press Ctrl-C to stop.');

  final stop = Completer<void>();
  for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
    signal.watch().listen((_) {
      if (!stop.isCompleted) stop.complete();
    });
  }
  await stop.future;
  stdout.writeln('Stopping: devices say goodbye.');
  await home.dispose();
}

/// Adds the login to every connect and logs link changes per device.
class _LoggedConnection implements MqttConnection {
  new(this._inner, {this.login});

  final MqttConnection _inner;
  final MqttLogin? login;
  String _clientId = '';

  @override
  MqttConnectionState get currentState => _inner.currentState;

  @override
  Stream<MqttConnectionState> get state => _inner.state.map((state) {
    stdout.writeln('[$_clientId] ${state.name}');
    return state;
  });

  @override
  Stream<MqttMessage> get messages => _inner.messages;

  @override
  Future<void> connect({
    required String clientId,
    MqttWill? will,
    MqttLogin? login,
    Duration keepAlive = const Duration(seconds: 30),
  }) {
    _clientId = clientId;
    return _inner.connect(
      clientId: clientId,
      will: will,
      login: login ?? this.login,
      keepAlive: keepAlive,
    );
  }

  @override
  Future<void> subscribe(String filter, {MqttQos qos = MqttQos.atLeastOnce}) =>
      _inner.subscribe(filter, qos: qos);

  @override
  Future<void> unsubscribe(String filter) => _inner.unsubscribe(filter);

  @override
  Future<void> publish(
    String topic,
    Uint8List payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) => _inner.publish(topic, payload, qos: qos, retain: retain);

  @override
  Future<void> disconnect() => _inner.disconnect();

  @override
  Future<void> dispose() => _inner.dispose();
}

/// `--name value`, `--name=value` and `--flag`.
class _Args {
  new(List<String> raw) {
    for (var i = 0; i < raw.length; i++) {
      final arg = raw[i];
      if (!arg.startsWith('--')) continue;
      final body = arg.substring(2);
      final eq = body.indexOf('=');
      if (eq >= 0) {
        _values[body.substring(0, eq)] = body.substring(eq + 1);
      } else if (i + 1 < raw.length && !raw[i + 1].startsWith('--')) {
        _values[body] = raw[++i];
      } else {
        _values[body] = '';
      }
    }
  }

  final Map<String, String> _values = {};

  String? option(String name) {
    final value = _values[name];
    return value == null || value.isEmpty ? null : value;
  }

  bool flag(String name) => _values.containsKey(name);
}
