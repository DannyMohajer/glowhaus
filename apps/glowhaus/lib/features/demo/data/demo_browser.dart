import 'package:glowhaus/features/demo/data/demo_browser_stub.dart'
    if (dart.library.js_interop) 'package:glowhaus/features/demo/data/demo_browser_web.dart'
    as platform;
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// What the demo needs from the browser, and nothing else: a channel to the
/// other tabs of this site, opening a tab, and noticing that this page is
/// going away. Off the web there is none of it.
abstract interface class DemoBrowser {
  /// The current route in the URL fragment, e.g. `/devices`; null off the
  /// web or when there is none.
  String? get initialRoute;

  /// Whether [openTab] and [channel] do anything here.
  bool get supportsTabs;

  /// A BroadcastChannel to every other tab of this site, or null.
  BridgePort? channel(String name);

  /// Opens this site at [route] (a fragment route such as `/devices`) in a
  /// new tab.
  void openTab(String route);

  /// Puts [route] back into the address bar without a navigation, so a
  /// reload returns to it.
  void showRoute(String route);

  /// Calls [callback] when the page is being hidden for good (closed,
  /// reloaded, navigated away).
  void onPageHide(void Function() callback);
}

DemoBrowser createDemoBrowser() => platform.createDemoBrowser();
