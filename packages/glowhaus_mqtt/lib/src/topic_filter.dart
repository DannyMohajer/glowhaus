/// Topic names and filters as MQTT 3.1.1 section 4.7 defines them.
abstract final class MqttTopics {
  /// Longest topic a broker must accept.
  static const int maxLength = 65535;

  /// True if [topic] is a valid name to publish to: non-empty, no wildcards,
  /// no NUL characters.
  static bool isValidName(String topic) =>
      topic.isNotEmpty &&
      topic.length <= maxLength &&
      !topic.contains('+') &&
      !topic.contains('#') &&
      !topic.contains('\u0000');

  /// True if [filter] is a valid subscription filter: non-empty, no NUL,
  /// `+` only as a whole level, `#` only as the whole last level.
  static bool isValidFilter(String filter) {
    if (filter.isEmpty ||
        filter.length > maxLength ||
        filter.contains('\u0000')) {
      return false;
    }
    final levels = filter.split('/');
    for (final (index, level) in levels.indexed) {
      if (level == '+') continue;
      if (level == '#') {
        if (index != levels.length - 1) return false;
        continue;
      }
      if (level.contains('+') || level.contains('#')) return false;
    }
    return true;
  }

  /// Whether [filter] matches the concrete [topic].
  ///
  /// Levels compare exactly (case-sensitive); `+` matches one level, `#`
  /// matches the rest including zero levels (`a/#` matches `a`). A filter
  /// whose first level is a wildcard never matches a topic starting with
  /// `$` (broker-internal topics).
  static bool matches(String filter, String topic) {
    if (topic.startsWith(r'$') &&
        (filter.startsWith('+') || filter.startsWith('#'))) {
      return false;
    }
    final want = filter.split('/');
    final have = topic.split('/');
    for (var i = 0; i < want.length; i++) {
      final level = want[i];
      if (level == '#') return true;
      if (i >= have.length) return false;
      if (level != '+' && level != have[i]) return false;
    }
    return want.length == have.length;
  }
}
