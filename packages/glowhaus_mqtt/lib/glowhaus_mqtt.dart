/// MQTT 3.1.1 as Glowhaus uses it: a small connection interface, the
/// `mqtt_client` adapter for real brokers (TCP with TLS on native, WSS in
/// the browser), an in-memory broker, and topic matching.
///
/// Nothing here knows about Glowhaus payloads or topics; those live in
/// `glowhaus_domain`. Nothing here imports Flutter.
library;

export 'src/connection.dart';
export 'src/in_memory_broker.dart';
export 'src/mqtt_client_connection.dart';
export 'src/mqtt_endpoint.dart';
export 'src/topic_filter.dart';
