// The app against the Docker broker in infra/, end to end, inside the real
// app: its sandbox and entitlements, its Connection settings code, and the
// platform's own certificate trust (on macOS, the keychain where
// infra/scripts/make-certs.sh installed the development CA).
//
// Start the stack first (see infra/README.md), then on a Mac:
//
//   flutter test integration_test/broker_tls_test.dart -d macos \
//     --dart-define=GLOWHAUS_TEST_PASSWORD="$(grep '^demo-home.app:' \
//       ../../infra/secrets/credentials | cut -d: -f2)"
//
// The password only travels as a build define; it is never written down.
// Without it the test is skipped.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/app/di/injection.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/features/connection/cubit/connection_settings_cubit.dart';
import 'package:glowhaus/features/connection/data/connection_settings.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:integration_test/integration_test.dart';

const _password = String.fromEnvironment('GLOWHAUS_TEST_PASSWORD');

/// Waits in real time (the broker is real) for [test] to hold.
Future<T> _until<T>(
  Stream<T> stream,
  bool Function(T) test, {
  Duration timeout = const Duration(seconds: 20),
}) => stream.firstWhere(test).timeout(timeout);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'connects to the Docker broker over TLS (8883), learns the demo home, '
    'and a command is acked and reported',
    skip: _password.isEmpty,
    (tester) async {
      await tester.runAsync(() async {
        await configureDependencies();
        final connection = getIt<ConnectionSettingsCubit>();
        final devices = getIt<DeviceRepository>();

        // The defaults are the stack's: localhost, TLS on 8883 off the web,
        // home demo-home, user demo-home.app. No extra CA: the keychain's.
        const broker = BrokerSettings();
        expect(broker.endpoint(web: false).tls, isTrue);
        expect(broker.endpoint(web: false).port, 8883);
        await connection.connect(broker, password: _password);

        await _until(devices.status, (s) => s == TransportStatus.connected);
        expect(connection.state.problem, isNull);

        final all = await _until(
          devices.watchAll(),
          (views) => views.length == 12,
        );
        final lamp = all.firstWhere((v) => v.device.id == 'br-reading').device;
        final wasOn = lamp.state.values.whereType<OnOffState>().any(
          (s) => s.on,
        );

        Future<void> toggle({required bool on}) async {
          final result = await devices.send('br-reading', {
            'onOff': CapabilityPatch.onOff(on: on),
          });
          expect(result, isA<CommandAcked>());
          await _until(
            devices.watchAll(),
            (views) => views
                .firstWhere((v) => v.device.id == 'br-reading')
                .device
                .state
                .values
                .whereType<OnOffState>()
                .any((s) => s.on == on),
          );
        }

        await toggle(on: !wasOn);
        // Leave the simulator as it was.
        await toggle(on: wasOn);

        await connection.useDemo();
      });
    },
  );
}
