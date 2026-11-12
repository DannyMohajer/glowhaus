import 'package:glowhaus_domain/src/ids.dart';
import 'package:meta/meta.dart';

/// The per-device topics.
enum DeviceChannel { set, state, ack, availability }

/// A parsed Glowhaus topic.
@immutable
sealed class GlowhausTopic {
  const new(this.homeId);

  final String homeId;
}

/// `glowhaus/{homeId}/discovery`
final class DiscoveryTopic extends GlowhausTopic {
  const new(super.homeId);

  @override
  bool operator ==(Object other) =>
      other is DiscoveryTopic && other.homeId == homeId;

  @override
  int get hashCode => Object.hash(DiscoveryTopic, homeId);

  @override
  String toString() => 'DiscoveryTopic($homeId)';
}

/// `glowhaus/{homeId}/{deviceId}/{channel}`
final class DeviceTopic extends GlowhausTopic {
  const new(super.homeId, this.deviceId, this.channel);

  final String deviceId;
  final DeviceChannel channel;

  @override
  bool operator ==(Object other) =>
      other is DeviceTopic &&
      other.homeId == homeId &&
      other.deviceId == deviceId &&
      other.channel == channel;

  @override
  int get hashCode => Object.hash(homeId, deviceId, channel);

  @override
  String toString() => 'DeviceTopic($homeId, $deviceId, ${channel.name})';
}

/// The only place that builds or parses topic strings.
///
/// See `docs/protocol.md`, section 3.
class TopicCodec {
  const new();

  static const String root = 'glowhaus';
  static const String _discovery = Ids.reservedDeviceId;

  /// The topic string for [topic]. Throws [ArgumentError] on invalid ids.
  String build(GlowhausTopic topic) {
    _checkHome(topic.homeId);
    switch (topic) {
      case DiscoveryTopic():
        return '$root/${topic.homeId}/$_discovery';
      case DeviceTopic(:final deviceId, :final channel):
        if (!Ids.isValidDeviceId(deviceId)) {
          throw ArgumentError.value(deviceId, 'deviceId', 'Invalid device id');
        }
        return '$root/${topic.homeId}/$deviceId/${channel.name}';
    }
  }

  String discovery(String homeId) => build(DiscoveryTopic(homeId));

  String device(String homeId, String deviceId, DeviceChannel channel) =>
      build(DeviceTopic(homeId, deviceId, channel));

  /// Subscription filter for one channel of every device in a home,
  /// e.g. `glowhaus/demo-home/+/state`.
  String allDevicesFilter(String homeId, DeviceChannel channel) {
    _checkHome(homeId);
    return '$root/$homeId/+/${channel.name}';
  }

  /// Parses a concrete topic (no wildcards). Returns null for anything that
  /// is not a valid Glowhaus topic.
  GlowhausTopic? parse(String topic) {
    final parts = topic.split('/');
    if (parts.length < 3 || parts.first != root) return null;
    final homeId = parts[1];
    if (!Ids.isValidHomeId(homeId)) return null;
    if (parts.length == 3) {
      return parts[2] == _discovery ? DiscoveryTopic(homeId) : null;
    }
    if (parts.length != 4 || !Ids.isValidDeviceId(parts[2])) return null;
    for (final channel in DeviceChannel.values) {
      if (channel.name == parts[3]) {
        return DeviceTopic(homeId, parts[2], channel);
      }
    }
    return null;
  }

  static void _checkHome(String homeId) {
    if (!Ids.isValidHomeId(homeId)) {
      throw ArgumentError.value(homeId, 'homeId', 'Invalid home id');
    }
  }
}
