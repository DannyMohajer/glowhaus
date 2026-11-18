import 'package:glowhaus/app/router/routes.dart';

/// Where the app opens: the address the page was opened at, with its
/// query, or the home when there is none.
///
/// Whether the intro comes first is not decided here — the address of a web
/// page wins over this, so the router decides it with a redirect (see
/// `createRouter`).
String startLocation(String? entry) => entry ?? Routes.home;

/// `#/demo?quiet`: the demo's devices do not change by themselves (no power
/// or temperature updates every 2 s), so a screen recording shows only what
/// is pressed. Presses and commands work as ever, and the intro stays out
/// of the way. For recording only; nothing in the app mentions it.
bool quietDemo(Uri page) =>
    page.queryParameters.containsKey('quiet') ||
    Uri.parse(page.fragment).queryParameters.containsKey('quiet');
