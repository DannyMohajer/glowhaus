import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:glowhaus_device/glowhaus_device.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';

const _usage =
    '''
Runs the Glowhaus demo home (twelve virtual devices) against an MQTT broker.

Usage: dart run simulator/bin/simulator.dart [options]

  --host <host>        Broker host (default: localhost)
  --port <port>        Broker port (default: 8883, or 1883 with --no-tls)
  --no-tls             Plain MQTT instead of MQTT over TLS
  --ca-file <pem>      Also trust this CA, e.g. infra/certs/ca.crt
  --home <id>          Home id (default: ${DemoHome.homeId})
  --credentials <file> "username:password" per line; each device logs in as
                       <home>.<deviceId> (what infra/scripts/make-users.sh writes)
  --username <name>    One broker username for every device instead
  --password <secret>  Its password (or set GLOWHAUS_PASSWORD)
  --camera-url <url>   Stream URL the doorbell camera announces
  --latency <ms>       Mean command latency (default: 250)
  --failure-rate <p>   Share of commands rejected as busy, 0..1 (default: 0)
  --timeout-rate <p>   Share of commands lost on the way, 0..1 (default: 0)
  --watchdog <s>       Exit with status 1 after this many seconds with no
                       device connected, so a supervisor restarts it
                       (default: 120; 0 turns it off)
  --health-file <path> Write a heartbeat here every 5 s (for a healthcheck)
  --check-health <path> Exit 0 if that heartbeat is fresh and at least one
                       device is connected, 1 otherwise; then quit
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
  final healthToCheck = args.option('check-health');
  if (healthToCheck != null) {
    exitCode = _healthy(File(healthToCheck)) ? 0 : 1;
    return;
  }
  final tls = !args.flag('no-tls');
  final caFile = args.option('ca-file');
  final endpoint = MqttEndpoint(
    host: args.option('host') ?? 'localhost',
    port: int.parse(args.option('port') ?? (tls ? '8883' : '1883')),
    tls: tls,
    trustedCertificatePem: caFile == null
        ? null
        : File(caFile).readAsStringSync(),
  );
  final homeId = args.option('home') ?? DemoHome.homeId;
  final logins = _logins(args, homeId);
  final cameraUrl = args.option('camera-url');

  final home = VirtualHome(
    homeId: homeId,
    specs: [
      for (final spec in DemoHome.devices())
        if (cameraUrl == null) spec else _withCameraUrl(spec, cameraUrl),
    ],
    connectionFactory: (deviceId) => _LoggedConnection(
      MqttClientConnection(endpoint),
      login: logins(deviceId),
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
  // Devices that cannot reach the broker keep retrying with backoff, as real
  // ones would; their connection log shows why.
  await home.start();
  stdout.writeln(
    '${home.devices.length} devices started. Press Ctrl-C to stop.',
  );

  final healthFile = args.option('health-file');
  final watchdog = _Watchdog(
    connected: () => home.devices.values.where((d) => d.online).length,
    limit: Duration(seconds: int.parse(args.option('watchdog') ?? '120')),
    heartbeat: healthFile == null ? null : File(healthFile),
  )..start();

  final stop = Completer<void>();
  for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
    signal.watch().listen((_) {
      if (!stop.isCompleted) stop.complete();
    });
  }
  await stop.future;
  watchdog.stop();
  stdout.writeln('Stopping: devices say goodbye.');
  await home.dispose();
}

/// Notices a simulator that is alive but no longer doing anything: no device
/// connected for [limit] (a broker that never came back, a stuck client).
/// Exiting lets the supervisor (compose's restart policy) start it afresh.
/// The heartbeat file feeds the container healthcheck.
class _Watchdog {
  new({required this.connected, required this.limit, this.heartbeat});

  static const Duration tick = Duration(seconds: 5);

  final int Function() connected;
  final Duration limit;
  final File? heartbeat;
  Timer? _timer;
  DateTime _lastConnected = DateTime.now();

  void start() => _timer = Timer.periodic(tick, (_) => _check());

  void stop() => _timer?.cancel();

  void _check() {
    final now = DateTime.now();
    final count = connected();
    if (count > 0) _lastConnected = now;
    heartbeat?.writeAsStringSync('${now.millisecondsSinceEpoch} $count\n');
    if (limit > Duration.zero && now.difference(_lastConnected) > limit) {
      stderr.writeln(
        'Watchdog: no device connected for ${limit.inSeconds} s; exiting so '
        'the supervisor restarts the simulator.',
      );
      exit(1);
    }
  }
}

/// What `--check-health` reports: a heartbeat younger than three ticks that
/// counts at least one connected device.
bool _healthy(File heartbeat) {
  try {
    final [stamp, count] = heartbeat.readAsStringSync().trim().split(' ');
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(int.parse(stamp)),
    );
    return age < _Watchdog.tick * 3 && int.parse(count) > 0;
  } on Object {
    return false;
  }
}

/// Which login a device uses: one shared `--username`, or its own line in
/// the `--credentials` file under the name `<home>.<deviceId>`.
MqttLogin? Function(String deviceId) _logins(_Args args, String homeId) {
  final file = args.option('credentials');
  if (file != null) {
    final byUser = <String, String>{};
    for (final line in File(file).readAsLinesSync()) {
      final colon = line.indexOf(':');
      if (colon <= 0 || line.startsWith('#')) continue;
      byUser[line.substring(0, colon)] = line.substring(colon + 1).trim();
    }
    return (deviceId) {
      final username = '$homeId.$deviceId';
      final password = byUser[username];
      if (password == null) {
        stderr.writeln('$file has no line for $username; connecting without.');
        return null;
      }
      return MqttLogin(username: username, password: password);
    };
  }
  final username = args.option('username');
  if (username == null) return (_) => null;
  final password =
      args.option('password') ?? Platform.environment['GLOWHAUS_PASSWORD'];
  return (_) => MqttLogin(username: username, password: password);
}

/// The demo camera announces a placeholder stream; a real broker setup has a
/// real one (infra/ runs MediaMTX).
DeviceSpec _withCameraUrl(DeviceSpec spec, String url) {
  if (spec.descriptor.type != DeviceType.camera) return spec;
  final descriptor = spec.descriptor;
  return DeviceSpec(
    descriptor: descriptor.copyWith(
      capabilities: [
        for (final capability in descriptor.capabilities)
          if (capability.kind == CapabilityKind.camera)
            capability.copyWith(
              config: {
                ...capability.config,
                'streams': [
                  {'protocol': 'rtsp', 'url': url},
                ],
              },
            )
          else
            capability,
      ],
    ),
    initialState: spec.initialState,
    online: spec.online,
    onWatts: spec.onWatts,
  );
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
