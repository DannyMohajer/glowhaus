import 'dart:ui';

import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:injectable/injectable.dart';

/// Loads whatever a language needs before the UI switches to it.
abstract interface class LanguagePreparer {
  /// The supported language closest to the device's language.
  AppLanguage get systemLanguage;

  Future<void> prepare(AppLanguage language);
}

/// Persian uses a font that is not loaded at startup, to keep the first
/// load of the web build small.
@LazySingleton(as: LanguagePreparer)
class FontLanguagePreparer implements LanguagePreparer {
  @override
  AppLanguage get systemLanguage =>
      AppLanguage.fromLocale(PlatformDispatcher.instance.locale);

  @override
  Future<void> prepare(AppLanguage language) async {
    if (language == AppLanguage.fa) await GlowFontLoader.ensurePersian();
  }
}
