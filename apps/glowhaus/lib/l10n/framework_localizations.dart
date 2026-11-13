import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:intl/intl.dart' as intl;

/// Flutter's own strings (text field menus, tooltips, reading direction) for
/// the three app languages only.
///
/// `GlobalMaterialLocalizations.delegate` and friends can build any of about
/// 80 locales, so every one of them stays in the web build, and with them
/// every string a text field might show. Listing only English, Persian and
/// Turkish lets the compiler drop the rest. Date formats use the default
/// pattern: the app shows no Material date or time pickers.
abstract final class FrameworkLocalizations {
  static const List<LocalizationsDelegate<Object>> delegates = [
    _MaterialDelegate(),
    _CupertinoDelegate(),
    _WidgetsDelegate(),
  ];

  static bool _supports(Locale locale) =>
      AppLanguage.values.any((l) => l.name == locale.languageCode);
}

class _MaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) => FrameworkLocalizations._supports(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final code = locale.languageCode;
    final y = intl.DateFormat.y();
    final yMd = intl.DateFormat.yMd();
    final yMMMd = intl.DateFormat.yMMMd();
    final mmmEd = intl.DateFormat.MMMEd();
    final long = intl.DateFormat.yMMMMEEEEd();
    final yearMonth = intl.DateFormat.yMMMM();
    final mmmd = intl.DateFormat.MMMd();
    final decimal = intl.NumberFormat.decimalPattern(code);
    final twoDigits = intl.NumberFormat('00', code);
    return SynchronousFuture(switch (code) {
      'fa' => MaterialLocalizationFa(
        fullYearFormat: y,
        compactDateFormat: yMd,
        shortDateFormat: yMMMd,
        mediumDateFormat: mmmEd,
        longDateFormat: long,
        yearMonthFormat: yearMonth,
        shortMonthDayFormat: mmmd,
        decimalFormat: decimal,
        twoDigitZeroPaddedFormat: twoDigits,
      ),
      'tr' => MaterialLocalizationTr(
        fullYearFormat: y,
        compactDateFormat: yMd,
        shortDateFormat: yMMMd,
        mediumDateFormat: mmmEd,
        longDateFormat: long,
        yearMonthFormat: yearMonth,
        shortMonthDayFormat: mmmd,
        decimalFormat: decimal,
        twoDigitZeroPaddedFormat: twoDigits,
      ),
      _ => MaterialLocalizationEn(
        fullYearFormat: y,
        compactDateFormat: yMd,
        shortDateFormat: yMMMd,
        mediumDateFormat: mmmEd,
        longDateFormat: long,
        yearMonthFormat: yearMonth,
        shortMonthDayFormat: mmmd,
        decimalFormat: decimal,
        twoDigitZeroPaddedFormat: twoDigits,
      ),
    });
  }

  @override
  bool shouldReload(_MaterialDelegate old) => false;
}

class _CupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) => FrameworkLocalizations._supports(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final code = locale.languageCode;
    final y = intl.DateFormat.y();
    final d = intl.DateFormat.d();
    final e = intl.DateFormat.E();
    final mmmd = intl.DateFormat.MMMd();
    final h = intl.DateFormat('h');
    final m = intl.DateFormat('m');
    final mm = intl.DateFormat('mm');
    final s = intl.DateFormat('s');
    final decimal = intl.NumberFormat.decimalPattern(code);
    return SynchronousFuture(switch (code) {
      'fa' => CupertinoLocalizationFa(
        fullYearFormat: y,
        dayFormat: d,
        weekdayFormat: e,
        mediumDateFormat: mmmd,
        singleDigitHourFormat: h,
        singleDigitMinuteFormat: m,
        doubleDigitMinuteFormat: mm,
        singleDigitSecondFormat: s,
        decimalFormat: decimal,
      ),
      'tr' => CupertinoLocalizationTr(
        fullYearFormat: y,
        dayFormat: d,
        weekdayFormat: e,
        mediumDateFormat: mmmd,
        singleDigitHourFormat: h,
        singleDigitMinuteFormat: m,
        doubleDigitMinuteFormat: mm,
        singleDigitSecondFormat: s,
        decimalFormat: decimal,
      ),
      _ => CupertinoLocalizationEn(
        fullYearFormat: y,
        dayFormat: d,
        weekdayFormat: e,
        mediumDateFormat: mmmd,
        singleDigitHourFormat: h,
        singleDigitMinuteFormat: m,
        doubleDigitMinuteFormat: mm,
        singleDigitSecondFormat: s,
        decimalFormat: decimal,
      ),
    });
  }

  @override
  bool shouldReload(_CupertinoDelegate old) => false;
}

class _WidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) => FrameworkLocalizations._supports(locale);

  /// Persian reads right to left; this is where the app learns it.
  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      SynchronousFuture(switch (locale.languageCode) {
        'fa' => const WidgetsLocalizationFa(),
        'tr' => const WidgetsLocalizationTr(),
        _ => const WidgetsLocalizationEn(),
      });

  @override
  bool shouldReload(_WidgetsDelegate old) => false;
}
