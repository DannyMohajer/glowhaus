import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

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
