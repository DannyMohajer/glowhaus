import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/devices_tab_app.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

class _NoChannel implements DemoBrowser {
  final shown = <String>[];

  @override
  String? get initialRoute => '/devices';

  @override
  bool get supportsTabs => true;

  @override
  BridgePort? channel(String name) => null;

  @override
  void openTab(String route) {}

  @override
  void showRoute(String route) => shown.add(route);

  @override
  void onPageHide(void Function() callback) {}
}

void main() {
  testWidgets('without a demo to join, the devices tab says so and keeps '
      'its route', (tester) async {
    final browser = _NoChannel();
    await tester.pumpWidget(
      DevicesTabApp(browser: browser, channelName: 'test'),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('No Glowhaus demo is open'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(browser.shown, contains('/devices'));
  });
}
