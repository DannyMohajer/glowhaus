// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Glowhaus';

  @override
  String get navHome => 'Home';

  @override
  String get navRooms => 'Rooms';

  @override
  String get navSettings => 'Settings';

  @override
  String get welcomeTitle => 'Welcome to your';

  @override
  String get welcomeTitleAccent => 'smart home';

  @override
  String get welcomeSubtitle =>
      'Lights, climate and security in one place. This is a live demo with simulated devices, so tap anything.';

  @override
  String get welcomeStart => 'Let\'s start';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentRose => 'Rose';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Turn off animations and transitions';

  @override
  String get settingsSimulation => 'Simulation';

  @override
  String get settingsSimulationHint =>
      'The devices in this demo are simulated. Make the network worse to see how the app copes.';

  @override
  String get settingsLatency => 'Network delay';

  @override
  String settingsLatencyValue(int ms) {
    final intl.NumberFormat msNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String msString = msNumberFormat.format(ms);

    return '$msString ms';
  }

  @override
  String get settingsFailureRate => 'Failure rate';

  @override
  String get settingsFailureRateHint =>
      'Share of commands that fail or time out';

  @override
  String percentValue(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString%';
  }

  @override
  String get roomsTitle => 'Rooms';

  @override
  String get selectRoom => 'Select a room';

  @override
  String get selectDevice => 'Select a device';

  @override
  String get back => 'Back';
}
