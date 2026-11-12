/// MQTT 3.1.1 as Glowhaus uses it: a small connection interface that a real
/// client and an in-memory broker both implement, plus topic matching.
///
/// Nothing here knows about Glowhaus payloads or topics; those live in
/// `glowhaus_domain`. Nothing here imports Flutter.
library;

export 'src/connection.dart';
export 'src/in_memory_broker.dart';
export 'src/topic_filter.dart';
