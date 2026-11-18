/// Route paths. The URL is the navigation state on every form factor.
abstract final class Routes {
  static const String intro = '/intro';
  static const String home = '/home';
  static const String rooms = '/rooms';
  static const String settings = '/settings';

  /// The app with the demo's devices panel open next to it.
  static const String demo = '/demo';

  /// The intro, with the location to continue to once it is done. A first
  /// visit to `#/demo` sees the intro and lands on `#/demo` after it.
  static String introTo(String next) =>
      Uri(path: intro, queryParameters: {'next': next}).toString();

  /// Where [introTo] said to go, or [home] when it said nothing this app
  /// can go to.
  static String nextAfterIntro(Uri intro) {
    final next = intro.queryParameters['next'];
    return next != null && next.startsWith('/') ? next : home;
  }

  static String room(String roomId) => '$rooms/$roomId';

  static String device(String roomId, String deviceId) =>
      '$rooms/$roomId/devices/$deviceId';
}
