import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String language) =>
    jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _arb('en');

  for (final language in ['fa', 'tr']) {
    final arb = _arb(language);

    test('$language has exactly the keys of the English template', () {
      expect(_messageKeys(arb), _messageKeys(en));
    });

    test('$language keeps every placeholder', () {
      for (final key in _messageKeys(en)) {
        expect(
          _placeholders(arb[key] as String),
          _placeholders(en[key] as String),
          reason: key,
        );
      }
    });

    test('$language has no empty messages', () {
      for (final key in _messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    });
  }

  test('no hard-coded user-facing strings in the app source', () {
    // Text widgets must take their strings from AppLocalizations. A quoted
    // literal passed straight to Text(...) is almost certainly a miss.
    final offenders = <String>[];
    final literalText = RegExp(r'''\bText\(\s*['"]''');
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.contains('/l10n/generated/'))) {
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (literalText.hasMatch(line)) {
          offenders.add('${file.path}:${index + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
