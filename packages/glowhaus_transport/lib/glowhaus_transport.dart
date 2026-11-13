/// Glowhaus transport: how commands reach devices and state comes back.
///
/// Pure Dart. See `docs/architecture.md`.
library;

// The demo seed and the knobs of the simulated link live with the device
// engine; the app reaches them through this package.
export 'package:glowhaus_device/glowhaus_device.dart'
    show DemoHome, DemoNames, DeviceSpec, SimulationConfig;

// What an app needs to point an MqttTransport at a real broker.
export 'package:glowhaus_mqtt/glowhaus_mqtt.dart'
    show
        MqttClientConnection,
        MqttConnectFailure,
        MqttConnectionException,
        MqttEndpoint,
        MqttLogin;

export 'src/mqtt/mqtt_transport.dart';
export 'src/mqtt/reconnect_policy.dart';
export 'src/simulated/simulated_transport.dart';
export 'src/transport.dart';
