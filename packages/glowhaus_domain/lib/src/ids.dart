/// Validation of the identifiers defined in `docs/protocol.md`, section 2.
abstract final class Ids {
  static final RegExp _slug = RegExp(r'^[a-z0-9][a-z0-9_-]{0,31}$');
  static final RegExp _capability = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{0,31}$');
  static final RegExp _command = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  /// Device id reserved by the discovery topic.
  static const String reservedDeviceId = 'discovery';

  static bool isValidHomeId(String value) => _slug.hasMatch(value);

  static bool isValidDeviceId(String value) =>
      _slug.hasMatch(value) && value != reservedDeviceId;

  static bool isValidCapabilityId(String value) => _capability.hasMatch(value);

  static bool isValidCommandId(String value) => _command.hasMatch(value);
}
