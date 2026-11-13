import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

DemoBrowser createDemoBrowser() => const _NoBrowser();

class _NoBrowser implements DemoBrowser {
  const new();

  @override
  String? get initialRoute => null;

  @override
  bool get supportsTabs => false;

  @override
  BridgePort? channel(String name) => null;

  @override
  void openTab(String route) {}

  @override
  void showRoute(String route) {}

  @override
  void onPageHide(void Function() callback) {}
}
