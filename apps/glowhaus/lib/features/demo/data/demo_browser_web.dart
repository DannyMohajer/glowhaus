import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:glowhaus/features/demo/data/demo_browser.dart';
import 'package:glowhaus_transport/glowhaus_transport.dart';
import 'package:web/web.dart' as web;

DemoBrowser createDemoBrowser() => const _WebBrowser();

class _WebBrowser implements DemoBrowser {
  const new();

  @override
  String? get initialRoute {
    final fragment = Uri.base.fragment;
    return fragment.isEmpty ? null : Uri.parse(fragment).path;
  }

  @override
  bool get supportsTabs => true;

  @override
  BridgePort? channel(String name) {
    try {
      return _ChannelPort(web.BroadcastChannel(name));
    } on Object {
      // Very old browsers, or a sandboxed frame without it.
      return null;
    }
  }

  @override
  void openTab(String route) {
    final here = Uri.base;
    web.window.open(here.replace(fragment: route).toString(), '_blank');
  }

  @override
  void showRoute(String route) => web.window.history.replaceState(
    web.window.history.state,
    '',
    Uri.base.replace(fragment: route).toString(),
  );

  @override
  void onPageHide(void Function() callback) {
    web.window.addEventListener('pagehide', ((web.Event _) => callback()).toJS);
  }

  @override
  TabLock? lock(String name) {
    // Missing in old browsers and on pages that are not a secure context.
    final navigator = web.window.navigator;
    if (!(navigator as JSObject).has('locks')) return null;
    return _WebLock(navigator.locks, name);
  }
}

/// A Web Lock held for as long as [_holding] is not complete: the callback
/// given to `request` returns that future as its promise.
class _WebLock implements TabLock {
  new(this._locks, this._name);

  final web.LockManager _locks;
  final String _name;
  final _lost = StreamController<void>.broadcast();
  Completer<void>? _holding;

  @override
  Stream<void> get lost => _lost.stream;

  @override
  Future<bool> acquire({bool steal = false}) {
    if (_holding != null) return Future.value(true);
    final granted = Completer<bool>();
    final holding = Completer<void>();
    final request = _locks.request(
      _name,
      steal ? web.LockOptions(steal: true) : web.LockOptions(ifAvailable: true),
      ((web.Lock? lock) {
        if (lock == null) {
          granted.complete(false);
          return null;
        }
        _holding = holding;
        granted.complete(true);
        return holding.future.toJS;
      }).toJS,
    );
    // The request's promise ends when the lock is released, or rejects
    // (AbortError) when another tab steals it.
    unawaited(
      request.toDart.then(
        (_) {},
        onError: (Object _) {
          if (!granted.isCompleted) granted.complete(false);
          if (identical(_holding, holding)) {
            _holding = null;
            _lost.add(null);
          }
        },
      ),
    );
    return granted.future;
  }

  @override
  void release() {
    _holding?.complete();
    _holding = null;
  }
}

/// Messages travel as JSON text: the shapes are plain maps and lists, and a
/// string is the cheapest thing to clone between tabs.
class _ChannelPort implements BridgePort {
  new(this._channel) {
    _channel.onmessage = ((web.MessageEvent event) {
      final data = event.data;
      if (data == null || !data.isA<JSString>()) return;
      try {
        final decoded = jsonDecode((data as JSString).toDart);
        if (decoded is Map<String, Object?>) _messages.add(decoded);
      } on FormatException {
        // Not ours.
      }
    }).toJS;
  }

  final web.BroadcastChannel _channel;
  final _messages = StreamController<Map<String, Object?>>.broadcast();

  @override
  Stream<Map<String, Object?>> get messages => _messages.stream;

  @override
  void post(Map<String, Object?> message) =>
      _channel.postMessage(jsonEncode(message).toJS);

  @override
  void close() {
    _channel.close();
    unawaited(_messages.close());
  }
}
