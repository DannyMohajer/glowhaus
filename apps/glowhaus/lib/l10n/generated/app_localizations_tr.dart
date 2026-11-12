// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Glowhaus';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navRooms => 'Odalar';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get welcomeTitle => 'Akıllı evine';

  @override
  String get welcomeTitleAccent => 'hoş geldin';

  @override
  String get welcomeSubtitle =>
      'Aydınlatma, iklim ve güvenlik tek bir yerde. Bu, simüle cihazlarla çalışan canlı bir demo; istediğine dokun.';

  @override
  String get welcomeStart => 'Başlayalım';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get settingsAccent => 'Vurgu rengi';

  @override
  String get accentOrange => 'Turuncu';

  @override
  String get accentBlue => 'Mavi';

  @override
  String get accentGreen => 'Yeşil';

  @override
  String get accentViolet => 'Mor';

  @override
  String get accentRose => 'Gül';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get settingsReduceMotion => 'Hareketi azalt';

  @override
  String get settingsReduceMotionHint => 'Animasyonları ve geçişleri kapat';

  @override
  String get settingsSimulation => 'Simülasyon';

  @override
  String get settingsSimulationHint =>
      'Bu demodaki cihazlar simüle edilir. Uygulamanın nasıl başa çıktığını görmek için ağı kötüleştir.';

  @override
  String get settingsLatency => 'Ağ gecikmesi';

  @override
  String settingsLatencyValue(int ms) {
    final intl.NumberFormat msNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String msString = msNumberFormat.format(ms);

    return '$msString ms';
  }

  @override
  String get settingsFailureRate => 'Hata oranı';

  @override
  String get settingsFailureRateHint =>
      'Başarısız olan veya zaman aşımına uğrayan komutların oranı';

  @override
  String percentValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '%$valueString';
  }

  @override
  String get roomsTitle => 'Odalar';

  @override
  String get selectRoom => 'Bir oda seç';

  @override
  String get selectDevice => 'Bir cihaz seç';

  @override
  String get back => 'Geri';
}
