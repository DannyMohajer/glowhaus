import 'package:glowhaus/features/demo/data/demo_browser_stub.dart'
    if (dart.library.js_interop) 'package:glowhaus/features/demo/data/demo_browser_web.dart'
    as platform;
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// What the demo needs from the browser, and nothing else: a channel to the
/// other tabs of this site, opening a tab, and noticing that this page is
/// going away. Off the web there is none of it.
abstract interface class DemoBrowser {
  /// The location in the URL fragment the page was opened at, with its
  /// query: `/devices`, `/demo?quiet`. Null off the web, or when the
  /// address carries no fragment.
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

  /// A lock that one tab of this site holds at a time (the Web Locks API),
  /// or null where there is none.
  TabLock? lock(String name);
}

/// A lock shared by the tabs of this site: at most one holds it.
abstract interface class TabLock {
  /// Takes the lock if no tab holds it, or with [steal] from the tab that
  /// does. Completes with whether this tab holds it now.
  Future<bool> acquire({bool steal = false});

  /// Fires when another tab took the lock away (see [acquire]'s `steal`).
  Stream<void> get lost;

  /// Gives the lock up.
  void release();
}

DemoBrowser createDemoBrowser() => platform.createDemoBrowser();
