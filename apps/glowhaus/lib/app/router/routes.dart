/// Route paths. The URL is the navigation state on every form factor.
abstract final class Routes {
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String rooms = '/rooms';
  static const String settings = '/settings';

  static String room(String roomId) => '$rooms/$roomId';

  static String device(String roomId, String deviceId) =>
      '$rooms/$roomId/devices/$deviceId';
}
