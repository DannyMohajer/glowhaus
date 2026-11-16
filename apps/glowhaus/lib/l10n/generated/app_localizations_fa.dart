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
  String get introTitle => 'به گلوهاوس';

  @override
  String get introTitleRest => 'خوش آمدی';

  @override
  String get introStart => 'شروع کنیم';

  @override
  String get introCurious => 'کنجکاوی که چطور کار می‌کند؟';

  @override
  String get introGitHub => 'دیدن در گیت‌هاب';

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
  String get settingsShowIntro => 'نمایش دوبارهٔ صفحهٔ معرفی';

  @override
  String get settingsShowIntroHint => 'دفعهٔ بعد با صفحهٔ معرفی باز شود';

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

    return 'روشن، $percentString٪';
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
  String get stateDry => 'خشک';

  @override
  String get stateLeak => 'نشتی تشخیص داده شد';

  @override
  String get stateStandby => 'آماده‌به‌کار';

  @override
  String get stateUnknown => 'در انتظار دستگاه…';

  @override
  String temperatureValue(String value) {
    return '‎$value°‎';
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
  String get detailMode => 'حالت';

  @override
  String get modeOff => 'خاموش';

  @override
  String get modeHeat => 'گرمایش';

  @override
  String get modeCool => 'سرمایش';

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
  String get detailLeak => 'آب';

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
    return '$model، نسخه $firmware';
  }

  @override
  String feedbackUnreachable(String device) {
    return 'اتصال برقرار نیست. تغییر $device لغو شد.';
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
  String feedbackAppliedLate(String device) {
    return '$device در نهایت تغییر کرد.';
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
  String get demoLeakSensor => 'حسگر نشتی';

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
  String get modeAuto => 'خودکار';

  @override
  String get listSeparator => '، ';

  @override
  String get connectionReconnecting => 'اتصال دوباره…';

  @override
  String get connectionDemo => 'خانه‌ی نمایشی';

  @override
  String get settingsConnection => 'اتصال';

  @override
  String get settingsConnectionHint => 'دستگاه‌ها از کجا می‌آیند.';

  @override
  String get connectionModeDemo => 'نمایشی';

  @override
  String get connectionModeBroker => 'بروکر من';

  @override
  String get connectionDemoHint =>
      'دوازده دستگاه شبیه‌سازی‌شده، همین‌جا در برنامه. شبکه لازم نیست.';

  @override
  String get connectionBrokerHint =>
      'یک بروکر MQTT که پروتکل Glowhaus را می‌فهمد، مثل نمونه‌ی پوشه‌ی infra/.';

  @override
  String get connectionWebNote =>
      'در مرورگر، برنامه از راه WebSocket امن (wss://) وصل می‌شود و این مرورگر باید گواهی بروکر را معتبر بداند.';

  @override
  String get connectionHost => 'میزبان';

  @override
  String get connectionHostHint => 'نام یا نشانی IP، بدون mqtts:// و بدون پورت';

  @override
  String get connectionPort => 'پورت';

  @override
  String connectionPortHint(int port) {
    return 'خالی برای پیش‌فرض، $port';
  }

  @override
  String get connectionTls => 'رمزگذاری‌شده (TLS)';

  @override
  String get connectionTlsHint =>
      'فقط برای بروکری روی همین رایانه یا یک شبیه‌ساز خاموش کن.';

  @override
  String get connectionWebSocket => 'از راه WebSocket';

  @override
  String get connectionWebSocketHint =>
      'برای بروکری که فقط به کلاینت‌های WebSocket گوش می‌دهد.';

  @override
  String get connectionPath => 'مسیر WebSocket';

  @override
  String get connectionHome => 'شناسه‌ی خانه';

  @override
  String get connectionUsername => 'نام کاربری';

  @override
  String get connectionPassword => 'گذرواژه';

  @override
  String get connectionPasswordHint =>
      'فقط در حافظه می‌ماند و هرگز ذخیره نمی‌شود.';

  @override
  String get connectionCa => 'گواهی CA اضافه (PEM)';

  @override
  String get connectionCaHint =>
      'اختیاری. infra/certs/ca.crt را اینجا بچسبان تا این دستگاه به بروکر توسعه اعتماد کند.';

  @override
  String get connectionConnect => 'وصل شو';

  @override
  String connectionStatusConnected(String broker) {
    return 'به $broker وصل است.';
  }

  @override
  String connectionStatusConnecting(String broker) {
    return 'در حال اتصال به $broker…';
  }

  @override
  String connectionStatusNeedsPassword(String broker) {
    return 'دستگاه‌هایی که آخرین بار روی $broker دیده شدند نمایش داده می‌شوند. برای اتصال گذرواژه را وارد کن.';
  }

  @override
  String get connectionProblemUnreachable =>
      'آنجا هیچ بروکری پاسخ نمی‌دهد. میزبان و پورت را بررسی کن و مطمئن شو بروکر در حال اجراست.';

  @override
  String get connectionProblemUnreachableWeb =>
      'آنجا هیچ بروکری پاسخ نمی‌دهد، یا این مرورگر گواهی آن را معتبر نمی‌داند.';

  @override
  String get connectionProblemUntrusted =>
      'گواهی بروکر اینجا معتبر نیست یا این نام میزبان را پوشش نمی‌دهد.';

  @override
  String get connectionProblemUnauthorized =>
      'نام کاربری یا گذرواژه نادرست است.';

  @override
  String get connectionProblemRefused => 'بروکر اتصال را نپذیرفت.';

  @override
  String get connectionInvalidHost =>
      'یک نام میزبان یا نشانی IP وارد کن، بدون پیشوند و پورت.';

  @override
  String get connectionInvalidPort => 'پورت عددی از ۱ تا ۶۵۵۳۵ است.';

  @override
  String get connectionInvalidPath => 'مسیر با / شروع می‌شود.';

  @override
  String get connectionInvalidHome =>
      'حروف کوچک لاتین، رقم، - و _، حداکثر ۳۲ نویسه.';

  @override
  String get connectionInvalidUsername => 'یک نام کاربری وارد کن.';

  @override
  String get panelTitle => 'دستگاه‌ها';

  @override
  String get panelSubtitle =>
      'آن سوی پروتکل: سیزده دستگاه مجازی روی یک بروکر MQTT درون همین صفحه.';

  @override
  String get panelOpen => 'دستگاه‌ها';

  @override
  String get panelClose => 'بستن پنل دستگاه‌ها';

  @override
  String get panelOpenTab => 'باز کردن در زبانه‌ی جدید';

  @override
  String get panelHint =>
      'دستگاه را همان‌طور که در خانه فشار می‌دهی لمس کن. برای آفلاین کردن، دوشاخه‌اش را بکش.';

  @override
  String panelHandOn(String device, String action) {
    return '$device: $action';
  }

  @override
  String get panelHandButton => 'دکمه‌اش را بزن';

  @override
  String get panelHandLock => 'صفحه‌کلید: قفل کن';

  @override
  String get panelHandUnlock => 'صفحه‌کلید: باز کن';

  @override
  String get panelHandMotion => 'از جلویش رد شو';

  @override
  String get panelHandOpenDoor => 'باز کردن در';

  @override
  String get panelHandCloseDoor => 'بستن در';

  @override
  String get panelHandLeak => 'ریختن کمی آب';

  @override
  String get panelHandDry => 'خشک کردن';

  @override
  String get panelPlugged => 'به برق وصل';

  @override
  String get panelUnplugged => 'دوشاخه کشیده';

  @override
  String panelPlugOut(String device) {
    return 'کشیدن دوشاخهٔ $device';
  }

  @override
  String panelPlugIn(String device) {
    return 'زدن دوبارهٔ دوشاخهٔ $device';
  }

  @override
  String get panelHandOpenCurtain => 'باز کردن پرده';

  @override
  String get panelHandCloseCurtain => 'بستن پرده';

  @override
  String get panelHandDoorbell => 'زدن زنگ در';

  @override
  String get panelTrafficShow => 'نمایش ترافیک MQTT';

  @override
  String get panelTrafficHide => 'پنهان کردن ترافیک MQTT';

  @override
  String get panelTraffic => 'ترافیک MQTT';

  @override
  String get panelTrafficEmpty => 'هنوز چیزی نیست. در برنامه روی چیزی بزن.';

  @override
  String panelTrafficSent(String device) {
    return '$device فرستاد';
  }

  @override
  String panelTrafficReceived(String device) {
    return '$device دریافت کرد';
  }

  @override
  String get panelAway =>
      'دستگاه‌ها در زبانه‌ی دیگری اجرا می‌شوند. آن را ببند تا به اینجا برگردند.';

  @override
  String get devicesTabJoining => 'در حال اتصال به نسخه‌ی نمایشی…';

  @override
  String get devicesTabNoHost =>
      'هیچ نسخه‌ی نمایشی Glowhaus در این مرورگر باز نیست. آن را در زبانه‌ی دیگری باز کن و دوباره امتحان کن.';

  @override
  String get devicesTabRetry => 'دوباره امتحان کن';

  @override
  String get devicesTabElsewhere =>
      'دستگاه‌ها همین حالا در زبانه‌ی دیگری اجرا می‌شوند.';

  @override
  String get devicesTabTakeOver => 'در اختیار گرفتن';

  @override
  String get devicesTabHint =>
      'این دستگاه‌ها با برنامه در زبانه‌ی دیگرت از راه MQTT حرف می‌زنند. این زبانه را ببندی، به خانه برمی‌گردند.';
}
