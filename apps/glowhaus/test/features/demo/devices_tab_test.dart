import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus/features/demo/view/devices_tab_app.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';

/// An in-process BroadcastChannel: what one port posts reaches every other
/// port, asynchronously.
class _Hub {
  final _ports = <_Port>[];

  _Port port() {
    final port = _Port(this);
    _ports.add(port);
    return port;
  }
}

class _Port implements BridgePort {
  new(this._hub);

  final _Hub _hub;
  final _messages = StreamController<Map<String, Object?>>.broadcast();
  bool closed = false;

  @override
  Stream<Map<String, Object?>> get messages => _messages.stream;

  @override
  void post(Map<String, Object?> message) {
    if (closed) return;
    for (final other in _hub._ports) {
      if (identical(other, this) || other.closed) continue;
      final copy = Map<String, Object?>.of(message);
      scheduleMicrotask(() {
        if (!other.closed) other._messages.add(copy);
      });
    }
  }

  @override
  void close() => closed = true;
}

/// One Web Lock shared by the "tabs" of a test.
class _Locks {
  _FakeLock? holder;
}

class _FakeLock implements TabLock {
  new(this._locks);

  final _Locks _locks;
  final requests = <bool>[];
  final _lost = StreamController<void>.broadcast();

  bool get held => identical(_locks.holder, this);

  @override
  Future<bool> acquire({bool steal = false}) async {
    requests.add(steal);
    final holder = _locks.holder;
    if (holder != null && !identical(holder, this)) {
      if (!steal) return false;
      _locks.holder = null;
      holder._lost.add(null);
    }
    _locks.holder = this;
    return true;
  }

  @override
  Stream<void> get lost => _lost.stream;

  @override
  void release() {
    if (held) _locks.holder = null;
  }
}

class _Browser implements DemoBrowser {
  new({required this.locks, this.hub});

  final _Locks locks;
  final _Hub? hub;
  late final lockHere = _FakeLock(locks);
  final shown = <String>[];

  @override
  String? get initialRoute => '/devices';

  @override
  bool get supportsTabs => true;

  @override
  BridgePort? channel(String name) => hub?.port();

  @override
  void openTab(String route) {}

  @override
  void showRoute(String route) => shown.add(route);

  @override
  void onPageHide(void Function() callback) {}

  @override
  TabLock? lock(String name) => lockHere;
}

/// The app tab's side: the demo and its bridge host.
class _AppTab {
  new(this.hub) {
    demo = SimulatedTransport(
      homeId: DemoHome.homeId,
      devices: DemoHome.devices(),
      connectDelay: Duration.zero,
      ambientInterval: null,
    );
    host = DemoBridgeHost(demo, hub.port(), hostId: 'app-tab');
    host.devicesAway.listen(away.add);
    unawaited(demo.connect());
  }

  final _Hub hub;
  late final SimulatedTransport demo;
  late final DemoBridgeHost host;
  final away = <bool>[];

  Future<void> close() async {
    await host.close();
    await demo.dispose();
  }
}

void main() {
  testWidgets('without a demo to join, the devices tab says so and keeps '
      'its route', (tester) async {
    final browser = _Browser(locks: _Locks());
    await tester.pumpWidget(
      DevicesTabApp(browser: browser, channelName: 'test'),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('No Glowhaus demo is open'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(browser.shown, contains('/devices'));
    expect(browser.lockHere.held, isFalse, reason: 'nothing to hold it for');
  });

  testWidgets('while another tab holds the lock, this one offers to take '
      'over, and taking over steals it', (tester) async {
    final locks = _Locks();
    final elsewhere = _FakeLock(locks);
    await elsewhere.acquire();
    var lostElsewhere = false;
    elsewhere.lost.listen((_) => lostElsewhere = true);

    final browser = _Browser(locks: locks);
    await tester.pumpWidget(
      DevicesTabApp(browser: browser, channelName: 'test'),
    );
    await tester.pump();
    expect(
      find.text('Devices are already running in another tab.'),
      findsOneWidget,
    );
    expect(browser.lockHere.requests, [false]);

    await tester.tap(find.text('Take over'));
    await tester.pump();
    expect(browser.lockHere.requests, [false, true]);
    expect(lostElsewhere, isTrue);
    // No app tab in this test: joining then times out.
    await tester.pump(const Duration(seconds: 4));
    expect(find.textContaining('No Glowhaus demo is open'), findsOneWidget);
  });

  testWidgets('the devices run here until another tab takes over; then this '
      'tab stops them and says so', (tester) async {
    final hub = _Hub();
    final app = _AppTab(hub);
    final locks = _Locks();
    final browser = _Browser(locks: locks, hub: hub);
    await tester.pumpWidget(
      DevicesTabApp(browser: browser, channelName: 'test'),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ceiling light'), findsOneWidget, reason: 'running');
    expect(app.away, [true]);

    // Another devices tab steals the lock: this one leaves at once.
    await _FakeLock(locks).acquire(steal: true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('Devices are already running in another tab.'),
      findsOneWidget,
    );
    expect(find.text('Ceiling light'), findsNothing);
    expect(app.away.last, isFalse, reason: 'the goodbye reached the app tab');
    expect(app.demo.devicesAway, isFalse);

    await tester.pumpWidget(const SizedBox());
    // Fake time moves only on pump: start the close, then let it run.
    unawaited(app.close());
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('a newer devices tab that joins the app tab sends this one '
      'away, even without a lock', (tester) async {
    final hub = _Hub();
    final app = _AppTab(hub);
    final browser = _Browser(locks: _Locks(), hub: hub);
    await tester.pumpWidget(
      DevicesTabApp(browser: browser, channelName: 'test'),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Ceiling light'), findsOneWidget);

    RemoteDemoHome? newer;
    unawaited(
      RemoteDemoHome.join(
        hub.port(),
        guestId: 'newer',
        ambientInterval: null,
      ).then((r) => newer = r),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(newer, isNotNull);
    expect(
      find.text('Devices are already running in another tab.'),
      findsOneWidget,
    );
    expect(newer!.home.device('lr-ceiling')!.online, isTrue);
    expect(
      app.away,
      isNot(contains(false)),
      reason: 'the devices never came home between',
    );

    unawaited(newer!.leave());
    await tester.pumpWidget(const SizedBox());
    // Fake time moves only on pump: start the close, then let it run.
    unawaited(app.close());
    await tester.pump(const Duration(seconds: 30));
  });
}
