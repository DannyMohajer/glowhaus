import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glowhaus_domain/src/capability/capability.dart';
import 'package:glowhaus_domain/src/capability/capability_patch.dart';
import 'package:glowhaus_domain/src/capability/capability_state.dart';
import 'package:glowhaus_domain/src/command/device_command.dart';
import 'package:glowhaus_domain/src/device/device.dart';
import 'package:glowhaus_domain/src/protocol/protocol_error.dart';

part 'payloads.freezed.dart';
part 'payloads.g.dart';

/// Constants of protocol version 1. See `docs/protocol.md`.
abstract final class Protocol {
  /// Value of the `v` field.
  static const int version = 1;

  /// Revision of the document within [version]. Revisions only add what
  /// older receivers can ignore (section 4), so `v` stays the same.
  static const String revision = '1.1';

  /// Devices reject commands whose `ts` is older than this (`expired`).
  static const Duration commandMaxAge = Duration(seconds: 10);

  /// Devices must ack within this time.
  static const Duration ackDeadline = Duration(seconds: 2);

  /// How long an app waits for an ack before `timedOut`.
  static const Duration commandTimeout = Duration(seconds: 5);

  /// How long an app keeps an optimistic value after an ack while waiting
  /// for a matching state.
  static const Duration stateSettleTimeout = Duration(seconds: 10);

  /// Maximum random delay before answering a discovery query.
  static const Duration announceJitter = Duration(milliseconds: 500);
}

/// The `device` object of a discovery announce.
@freezed
abstract class DeviceDescriptor with _$DeviceDescriptor {
  const factory({
    required String id,
    @JsonKey(unknownEnumValue: DeviceType.unknown) required DeviceType type,
    required String name,
    required List<Capability> capabilities,
    String? manufacturer,
    String? model,
    String? firmware,
    String? roomHint,

    /// Optional translation key for the factory default [name].
    String? nameKey,
  }) = _DeviceDescriptor;

  factory fromJson(Map<String, dynamic> json) =>
      _$DeviceDescriptorFromJson(json);
}

/// A message on `glowhaus/{homeId}/discovery`.
@Freezed(unionKey: 'type')
sealed class DiscoveryMessage with _$DiscoveryMessage {
  const factory announce({
    required int ts,
    required DeviceDescriptor device,
    @Default(Protocol.version) int v,
  }) = DiscoveryAnnounce;

  const factory query({required int ts, @Default(Protocol.version) int v}) =
      DiscoveryQuery;

  const factory bye({
    required int ts,
    required String deviceId,
    @Default(Protocol.version) int v,
  }) = DiscoveryBye;

  factory fromJson(Map<String, dynamic> json) =>
      _$DiscoveryMessageFromJson(json);
}

/// Payload of the retained `info` topic (revision 1.1): what the device is,
/// kept by the broker so an app learns about every device as soon as it
/// subscribes, online or not. The same descriptor an announce carries.
@freezed
abstract class InfoPayload with _$InfoPayload {
  const factory({
    required int ts,
    required DeviceDescriptor device,
    @Default(Protocol.version) int v,
  }) = _InfoPayload;

  factory fromJson(Map<String, dynamic> json) => _$InfoPayloadFromJson(json);
}

enum AvailabilityStatus { online, offline }

/// Payload of the retained `availability` topic.
@freezed
abstract class AvailabilityPayload with _$AvailabilityPayload {
  const factory({
    required AvailabilityStatus status,
    int? ts,
    @Default(Protocol.version) int v,
  }) = _AvailabilityPayload;

  factory fromJson(Map<String, dynamic> json) =>
      _$AvailabilityPayloadFromJson(json);

  const new _();

  DeviceAvailability get availability => switch (status) {
    AvailabilityStatus.online => DeviceAvailability.online,
    AvailabilityStatus.offline => DeviceAvailability.offline,
  };
}

/// Payload of the retained `state` topic: a full snapshot.
@freezed
abstract class StatePayload with _$StatePayload {
  const factory({
    required int ts,
    required Map<String, Map<String, dynamic>> state,
    @Default(Protocol.version) int v,
  }) = _StatePayload;

  /// Encodes typed capability states, keyed by capability id.
  factory encode(Map<String, CapabilityState> state, {required int ts}) =>
      StatePayload(
        ts: ts,
        state: <String, Map<String, dynamic>>{
          for (final MapEntry(:key, :value) in state.entries)
            key: value.toWire(),
        },
      );

  factory fromJson(Map<String, dynamic> json) => _$StatePayloadFromJson(json);

  const new _();

  /// Decodes against the device's [capabilities]. Entries with an unknown
  /// capability id, an unknown kind or a malformed object are dropped.
  Map<String, CapabilityState> decode(List<Capability> capabilities) {
    final result = <String, CapabilityState>{};
    for (final capability in capabilities) {
      final raw = state[capability.id];
      if (raw == null) continue;
      final parsed = CapabilityState.fromWire(capability.kind, raw);
      if (parsed != null) result[capability.id] = parsed;
    }
    return result;
  }
}

/// Payload of the `set` topic: one atomic command.
@freezed
abstract class SetPayload with _$SetPayload {
  const factory({
    required String commandId,
    required int ts,
    required Map<String, Map<String, dynamic>> set,
    @Default(Protocol.version) int v,
  }) = _SetPayload;

  factory fromJson(Map<String, dynamic> json) => _$SetPayloadFromJson(json);

  const new _();

  /// Whether a device whose clock reads [now] must reject this as `expired`.
  bool isExpired(DateTime now) =>
      now.millisecondsSinceEpoch - ts > Protocol.commandMaxAge.inMilliseconds;

  /// Device side: resolves `set` against the device's [capabilities].
  ///
  /// Returns the typed patches, or the error to ack with. Atomic: the first
  /// problem rejects the whole command.
  ({Map<String, CapabilityPatch> patches, ProtocolErrorCode? error}) decode(
    List<Capability> capabilities,
  ) {
    const none = <String, CapabilityPatch>{};
    if (v > Protocol.version) {
      return (patches: none, error: ProtocolErrorCode.unsupportedVersion);
    }
    if (set.isEmpty) {
      return (patches: none, error: ProtocolErrorCode.invalidPayload);
    }
    final byId = {for (final c in capabilities) c.id: c};
    final patches = <String, CapabilityPatch>{};
    for (final MapEntry(key: id, value: raw) in set.entries) {
      final capability = byId[id];
      if (capability == null) {
        return (patches: none, error: ProtocolErrorCode.unsupportedCapability);
      }
      if (!capability.kind.isWritable) {
        return (patches: none, error: ProtocolErrorCode.readOnly);
      }
      final patch = CapabilityPatch.fromWire(capability.kind, raw);
      if (patch == null) {
        return (patches: none, error: ProtocolErrorCode.invalidPayload);
      }
      final error = patch.validate(capability);
      if (error != null) return (patches: none, error: error);
      patches[id] = patch;
    }
    return (patches: patches, error: null);
  }
}

@freezed
abstract class AckError with _$AckError {
  const factory({
    @JsonKey(unknownEnumValue: ProtocolErrorCode.unknown)
    required ProtocolErrorCode code,
    String? message,
  }) = _AckError;

  factory fromJson(Map<String, dynamic> json) => _$AckErrorFromJson(json);
}

/// Payload of the `ack` topic.
@freezed
abstract class AckPayload with _$AckPayload {
  const factory({
    required String commandId,
    required bool ok,
    int? ts,
    AckError? error,
    @Default(Protocol.version) int v,
  }) = _AckPayload;

  factory fromJson(Map<String, dynamic> json) => _$AckPayloadFromJson(json);

  const new _();

  CommandResult toResult() => ok
      ? CommandResult.acked(commandId: commandId)
      : CommandResult.failed(
          commandId: commandId,
          code: error?.code ?? ProtocolErrorCode.unknown,
          message: error?.message,
        );
}
