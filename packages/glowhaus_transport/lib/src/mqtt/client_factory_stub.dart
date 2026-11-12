import 'package:glowhaus_transport/src/mqtt/mqtt_endpoint.dart';
import 'package:mqtt_client/mqtt_client.dart';

/// Replaced by the io or web implementation at compile time.
MqttClient createClient(MqttEndpoint endpoint, String clientId) =>
    throw UnsupportedError('No MQTT client for this platform');
