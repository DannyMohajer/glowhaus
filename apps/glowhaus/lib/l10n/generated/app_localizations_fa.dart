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

  @override
  String get settingsShowWelcome => 'نمایش صفحه خوش‌آمد';

  @override
  String get settingsShowWelcomeHint => 'دفعه بعد با صفحه خوش‌آمد باز شود';

  @override
  String greetingHi(String name) {
    return 'سلام $name،';
  }

  @override
  String get greetingWelcomeHome => 'به خانه خوش آمدی!';

  @override
  String activeDevices(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دستگاه فعال',
      zero: 'هیچ دستگاهی فعال نیست',
    );
    return '$_temp0';
  }

  @override
  String get connectionOnline => 'متصل';

  @override
  String get connectionConnecting => 'در حال اتصال…';

  @override
  String get connectionOffline => 'قطع';

  @override
  String get filterAll => 'همه';

  @override
  String roomDeviceCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دستگاه',
    );
    return '$_temp0';
  }

  @override
  String roomOnCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString روشن';
  }

  @override
  String get scenesTitle => 'صحنه‌ها';

  @override
  String get scenesSoon => 'کل خانه با یک لمس. به‌زودی.';

  @override
  String get emptyRoom => 'هنوز دستگاهی اینجا نیست';

  @override
  String get deviceNotFound => 'این دستگاه دیگر در دسترس نیست';

  @override
  String get roomNotFound => 'این اتاق دیگر وجود ندارد';

  @override
  String get loading => 'در حال بارگذاری خانه…';

  @override
  String get typeLights => 'روشنایی';

  @override
  String get typeSwitches => 'کلیدها';

  @override
  String get typeCurtains => 'پرده‌ها';

  @override
  String get typeClimate => 'تهویه';

  @override
  String get typeOutlets => 'پریزها';

  @override
  String get typeLocks => 'قفل‌ها';

  @override
  String get typeSensors => 'حسگرها';

  @override
  String get typeCameras => 'دوربین‌ها';

  @override
  String get typeOther => 'سایر';

  @override
  String get stateOn => 'روشن';

  @override
  String get stateOff => 'خاموش';

  @override
  String get stateOffline => 'آفلاین';

  @override
  String stateOnLevel(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'روشن · $percentString٪';
  }

  @override
  String get stateLocked => 'قفل';

  @override
  String get stateUnlocked => 'باز';

  @override
  String get stateJammed => 'گیر کرده';

  @override
  String stateOpenPercent(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$percentString٪ باز';
  }

  @override
  String get stateClosed => 'بسته';

  @override
  String get stateOpen => 'باز';

  @override
  String get stateOpening => 'در حال باز شدن…';

  @override
  String get stateClosing => 'در حال بسته شدن…';

  @override
  String get stateHeating => 'در حال گرمایش';

  @override
  String get stateCooling => 'در حال سرمایش';

  @override
  String get stateIdle => 'آماده';

  @override
  String get stateMotion => 'حرکت تشخیص داده شد';

  @override
  String get stateNoMotion => 'بدون حرکت';

  @override
  String stateChannelsOn(int on, int total) {
    final intl.NumberFormat onNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String onString = onNumberFormat.format(on);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$onString از $totalString روشن';
  }

  @override
  String get stateLive => 'زنده';

  @override
  String get stateUnknown => 'در انتظار دستگاه…';

  @override
  String temperatureValue(String value) {
    return '$value°';
  }

  @override
  String wattsValue(String value) {
    return '$value وات';
  }

  @override
  String kwhValue(String value) {
    return '$value کیلووات‌ساعت';
  }

  @override
  String get detailPower => 'برق';

  @override
  String get detailBrightness => 'روشنایی';

  @override
  String get detailColor => 'رنگ';

  @override
  String get detailColorTemperature => 'تن سفید';

  @override
  String get tempWarm => 'گرم';

  @override
  String get tempNeutral => 'خنثی';

  @override
  String get tempCool => 'سرد';

  @override
  String get tempDaylight => 'نور روز';

  @override
  String get detailPosition => 'موقعیت';

  @override
  String get actionOpen => 'باز کردن';

  @override
  String get actionClose => 'بستن';

  @override
  String get actionStop => 'توقف';

  @override
  String get detailSetpoint => 'دمای هدف';

  @override
  String get thermostatHeatingTo => 'گرمایش تا';

  @override
  String get thermostatCoolingTo => 'سرمایش تا';

  @override
  String get thermostatAutoTo => 'نگه‌داشتن روی';

  @override
  String get thermostatOff => 'خاموش';

  @override
  String get modeHeating => 'گرمایش';

  @override
  String get modeCooling => 'سرمایش';

  @override
  String currentTemperature(String value) {
    return 'اکنون $value';
  }

  @override
  String get detailFan => 'فن';

  @override
  String get fanAuto => 'خودکار';

  @override
  String get fanLow => 'کم';

  @override
  String get fanMedium => 'متوسط';

  @override
  String get fanHigh => 'زیاد';

  @override
  String get detailLivePower => 'مصرف لحظه‌ای';

  @override
  String get detailEnergy => 'انرژی کل';

  @override
  String get detailLock => 'قفل در';

  @override
  String get detailTemperature => 'دما';

  @override
  String get detailHumidity => 'رطوبت';

  @override
  String get detailMotion => 'حرکت';

  @override
  String get detailContact => 'در';

  @override
  String get detailCamera => 'دوربین';

  @override
  String get cameraSoon => 'نمایش زنده در نسخه‌های بعدی اضافه می‌شود';

  @override
  String get offlineBanner =>
      'آفلاین. آخرین وضعیت شناخته‌شده نمایش داده می‌شود.';

  @override
  String get pendingLabel => 'در حال ارسال…';

  @override
  String deviceInfo(String model, String firmware) {
    return '$model · نسخه $firmware';
  }

  @override
  String feedbackTimedOut(String device) {
    return '$device پاسخ نداد. تغییر شما برگردانده شد.';
  }

  @override
  String feedbackBusy(String device) {
    return '$device مشغول است و تغییر را نپذیرفت. تغییر برگردانده شد.';
  }

  @override
  String feedbackRejected(String device) {
    return '$device نتوانست تغییر را اعمال کند. تغییر برگردانده شد.';
  }

  @override
  String get demoRoomLivingRoom => 'اتاق نشیمن';

  @override
  String get demoRoomBedroom => 'اتاق خواب';

  @override
  String get demoRoomKitchen => 'آشپزخانه';

  @override
  String get demoRoomEntrance => 'ورودی';

  @override
  String get demoCeilingLight => 'چراغ سقفی';

  @override
  String get demoFloorLamp => 'آباژور';

  @override
  String get demoCurtain => 'پرده';

  @override
  String get demoThermostat => 'ترموستات';

  @override
  String get demoReadingLight => 'چراغ مطالعه';

  @override
  String get demoClimateSensor => 'حسگر دما و رطوبت';

  @override
  String get demoWallSwitch => 'کلید دیواری';

  @override
  String get demoCoffeeMachine => 'قهوه‌ساز';

  @override
  String get demoMotionSensor => 'حسگر حرکت';

  @override
  String get demoFrontDoorLock => 'قفل در ورودی';

  @override
  String get demoDoorSensor => 'حسگر در';

  @override
  String get demoDoorbellCamera => 'دوربین زنگ در';

  @override
  String get demoChannelCeiling => 'سقف';

  @override
  String get demoChannelCounter => 'کابینت';

  @override
  String get demoChannelHood => 'هود';

  @override
  String get demoSceneMovieNight => 'شب فیلم';

  @override
  String get demoSceneGoodMorning => 'صبح بخیر';

  @override
  String get demoSceneAway => 'بیرون از خانه';

  @override
  String get modeAuto => 'حالت خودکار';
}
