// The extra CA an app user pastes (MqttEndpoint.trustedCertificatePem) must
// be trusted for that broker connection only: its own SecurityContext, never
// SecurityContext.defaultContext, which every other socket in the process
// (HTTP, other brokers) uses.
//
// No keys are committed: a throwaway CA and server certificate are made with
// the openssl CLI in a temporary directory. Without openssl the test skips.
@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:glowhaus_mqtt/glowhaus_mqtt.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;
  late SecureServerSocket server;
  late String caPem;
  var handshakes = 0;

  Future<void> openssl(List<String> args) async {
    final result = await Process.run(
      'openssl',
      args,
      workingDirectory: dir.path,
    );
    if (result.exitCode != 0) {
      throw StateError('openssl ${args.first} failed: ${result.stderr}');
    }
  }

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('glowhaus-ca-test');
    // A CA that exists only for this test, and a localhost certificate
    // signed by it.
    await openssl([
      'req',
      '-x509',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-days',
      '1',
      '-keyout',
      'ca.key',
      '-out',
      'ca.crt',
      '-subj',
      '/CN=Glowhaus throwaway test CA',
      '-addext',
      'basicConstraints=critical,CA:TRUE',
      '-addext',
      'keyUsage=critical,keyCertSign,cRLSign',
    ]);
    await openssl([
      'req',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-keyout',
      'server.key',
      '-out',
      'server.csr',
      '-subj',
      '/CN=localhost',
    ]);
    await File('${dir.path}/ext.cnf').writeAsString(
      'subjectAltName=DNS:localhost,IP:127.0.0.1\n'
      'extendedKeyUsage=serverAuth\n',
    );
    await openssl([
      'x509',
      '-req',
      '-in',
      'server.csr',
      '-days',
      '1',
      '-CA',
      'ca.crt',
      '-CAkey',
      'ca.key',
      '-CAcreateserial',
      '-out',
      'server.crt',
      '-extfile',
      'ext.cnf',
    ]);
    caPem = await File('${dir.path}/ca.crt').readAsString();

    final context = SecurityContext()
      ..useCertificateChain('${dir.path}/server.crt')
      ..usePrivateKey('${dir.path}/server.key');
    // A socket only arrives here after a completed handshake. It is not an
    // MQTT broker: it hangs up, which is all this test needs.
    server = await SecureServerSocket.bind('localhost', 0, context)
      ..listen(
        (socket) {
          handshakes++;
          unawaited(socket.close());
        },
        onError: (_) {}, // failed handshakes
      );
  });

  tearDownAll(() async {
    await server.close();
    await dir.delete(recursive: true);
  });

  MqttEndpoint endpoint({String? ca}) => MqttEndpoint.tcp(
    'localhost',
    port: server.port,
    trustedCertificatePem: ca,
  );

  Future<MqttConnectionException> connectFails(MqttEndpoint endpoint) async {
    final connection = MqttClientConnection(
      endpoint,
      connectTimeout: const Duration(seconds: 3),
    );
    try {
      await connection.connect(clientId: 'ca-test');
      fail('connect should not succeed against a non-MQTT server');
    } on MqttConnectionException catch (e) {
      return e;
    } finally {
      await connection.dispose();
    }
  }

  test('with the pasted CA the TLS handshake completes', () async {
    final before = handshakes;
    final failure = await connectFails(endpoint(ca: caPem));
    // mqtt_client makes up to three attempts; each one gets through TLS.
    expect(handshakes, greaterThan(before), reason: 'TLS got through');
    expect(failure.reason, isNot(MqttConnectFailure.untrusted));
  }, skip: _skipWithoutOpenssl());

  test('without it the same server is untrusted', () async {
    final before = handshakes;
    final failure = await connectFails(endpoint());
    expect(failure.reason, MqttConnectFailure.untrusted);
    expect(handshakes, before);
  }, skip: _skipWithoutOpenssl());

  test('the CA never reaches the default context, before or after', () async {
    // A connection that trusts the CA exists in the same process...
    await connectFails(endpoint(ca: caPem));
    // ...and a plain socket on the default context still refuses the
    // server, so the CA was not added globally.
    await expectLater(
      SecureSocket.connect('localhost', server.port),
      throwsA(isA<HandshakeException>()),
    );
    // Same for another broker connection without a CA of its own.
    expect(
      (await connectFails(endpoint())).reason,
      MqttConnectFailure.untrusted,
    );
  }, skip: _skipWithoutOpenssl());
}

String? _skipWithoutOpenssl() {
  try {
    final result = Process.runSync('openssl', ['version']);
    return result.exitCode == 0 ? null : 'openssl not available';
  } on ProcessException {
    return 'openssl not available';
  }
}
