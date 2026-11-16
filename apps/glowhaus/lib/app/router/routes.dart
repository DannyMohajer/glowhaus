/// Route paths. The URL is the navigation state on every form factor.
abstract final class Routes {
  static const String intro = '/intro';
  static const String home = '/home';
  static const String rooms = '/rooms';
  static const String settings = '/settings';

  /// The app with the demo's devices panel open next to it.
  static const String demo = '/demo';

  static String room(String roomId) => '$rooms/$roomId';

  static String device(String roomId, String deviceId) =>
      '$rooms/$roomId/devices/$deviceId';
}
