import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:meta/meta.dart';

/// Connection state of a [Transport] (not of an individual device).
enum TransportStatus { disconnected, connecting, connected, reconnecting }

/// Something a transport learned about a device.
@immutable
sealed class DeviceEvent {
  const new({required this.homeId, required this.deviceId});

  final String homeId;
  final String deviceId;
}

/// A device announced itself (or re-announced with a changed descriptor).
final class DeviceAnnounced extends DeviceEvent {
  new({required super.homeId, required this.descriptor})
    : super(deviceId: descriptor.id);

  final DeviceDescriptor descriptor;
}

/// A device reported a full state snapshot, keyed by capability id.
final class DeviceStateChanged extends DeviceEvent {
  const new({
    required super.homeId,
    required super.deviceId,
    required this.state,
    required this.at,
  });

  final Map<String, CapabilityState> state;
  final DateTime at;
}

final class DeviceAvailabilityChanged extends DeviceEvent {
  const new({
    required super.homeId,
    required super.deviceId,
    required this.availability,
  });

  final DeviceAvailability availability;
}

/// A device left the home.
final class DeviceRemoved extends DeviceEvent {
  const new({required super.homeId, required super.deviceId});
}

/// How commands reach devices and how their state comes back.
///
/// The interface speaks domain objects only, so a simulation, an MQTT broker
/// or a local connection are interchangeable above it.
abstract interface class Transport {
  /// The latest value of [status].
  TransportStatus get currentStatus;

  /// Broadcast stream of connection state changes.
  Stream<TransportStatus> get status;

  /// Broadcast stream of device events. Subscribe before [connect] to receive
  /// the initial announcements.
  Stream<DeviceEvent> get events;

  Future<void> connect();

  Future<void> disconnect();

  /// Sends [command] and completes with its final outcome: acked, failed or
  /// timed out. Device-level failures never throw.
  Future<CommandResult> send(
    DeviceCommand command, {
    Duration timeout = Protocol.commandTimeout,
  });

  /// Releases all resources. The transport cannot be used afterwards.
  Future<void> dispose();
}
