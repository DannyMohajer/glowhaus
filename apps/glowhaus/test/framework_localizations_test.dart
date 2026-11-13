import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus/l10n/framework_localizations.dart';

Future<T> _load<T>(String code) {
  final delegate = FrameworkLocalizations.delegates.firstWhere(
    (d) => d.type == T,
  ) as LocalizationsDelegate<T>;
  return delegate.load(Locale(code));
}

void main() {
  test('only the three app languages are offered', () {
    for (final delegate in FrameworkLocalizations.delegates) {
      for (final code in ['en', 'fa', 'tr']) {
        expect(delegate.isSupported(Locale(code)), isTrue);
      }
      expect(delegate.isSupported(const Locale('de')), isFalse);
    }
  });

  test('Persian reads right to left, the others left to right', () async {
    expect(
      (await _load<WidgetsLocalizations>('fa')).textDirection,
      TextDirection.rtl,
    );
    expect(
      (await _load<WidgetsLocalizations>('tr')).textDirection,
      TextDirection.ltr,
    );
  });

  test('text field menus are translated', () async {
    expect((await _load<MaterialLocalizations>('en')).copyButtonLabel, 'Copy');
    expect(
      (await _load<MaterialLocalizations>('tr')).copyButtonLabel,
      isNot('Copy'),
    );
    expect(
      (await _load<MaterialLocalizations>('fa')).pasteButtonLabel,
      isNot('Paste'),
    );
  });
}
