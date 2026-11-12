import 'package:json_annotation/json_annotation.dart';

/// `error.code` values of an ack. See `docs/protocol.md`, section 8.2.
@JsonEnum(fieldRename: FieldRename.snake)
enum ProtocolErrorCode {
  invalidPayload,
  unsupportedVersion,
  unsupportedCapability,
  readOnly,
  outOfRange,
  busy,
  hardwareFault,
  notAllowed,
  expired,

  /// A code this version of the app does not know. Treated as a generic
  /// failure.
  unknown,
}
