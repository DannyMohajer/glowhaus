// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'گلوهاوس';

  @override
  String get navHome => 'خانه';

  @override
  String get navRooms => 'اتاق‌ها';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get welcomeTitle => 'به خانه هوشمندت';

  @override
  String get welcomeTitleAccent => 'خوش آمدی';

  @override
  String get welcomeSubtitle =>
      'روشنایی، تهویه و امنیت در یک جا. این یک نسخه نمایشی زنده با دستگاه‌های شبیه‌سازی‌شده است؛ هر چیزی را لمس کن.';

  @override
  String get welcomeStart => 'شروع کنیم';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsAppearance => 'ظاهر';

  @override
  String get settingsTheme => 'پوسته';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تیره';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get settingsAccent => 'رنگ تأکیدی';

  @override
  String get accentOrange => 'نارنجی';

  @override
  String get accentBlue => 'آبی';

  @override
  String get accentGreen => 'سبز';

  @override
  String get accentViolet => 'بنفش';

  @override
  String get accentRose => 'سرخابی';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get settingsReduceMotion => 'کاهش حرکت';

  @override
  String get settingsReduceMotionHint =>
      'خاموش کردن پویانمایی‌ها و جابه‌جایی‌ها';

  @override
  String get settingsSimulation => 'شبیه‌سازی';

  @override
  String get settingsSimulationHint =>
      'دستگاه‌های این نسخه نمایشی شبیه‌سازی شده‌اند. شبکه را بدتر کن تا ببینی برنامه چطور رفتار می‌کند.';

  @override
  String get settingsLatency => 'تأخیر شبکه';

  @override
  String settingsLatencyValue(int ms) {
    final intl.NumberFormat msNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String msString = msNumberFormat.format(ms);

    return '$msString میلی‌ثانیه';
  }

  @override
  String get settingsFailureRate => 'نرخ خطا';

  @override
  String get settingsFailureRateHint =>
      'سهم فرمان‌هایی که ناموفق می‌شوند یا بی‌پاسخ می‌مانند';

  @override
  String percentValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString٪';
  }

  @override
  String get roomsTitle => 'اتاق‌ها';

  @override
  String get selectRoom => 'یک اتاق را انتخاب کن';

  @override
  String get selectDevice => 'یک دستگاه را انتخاب کن';

  @override
  String get back => 'بازگشت';
}
