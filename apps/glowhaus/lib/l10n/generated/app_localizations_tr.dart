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

  @override
  String get settingsShowWelcome => 'Karşılama ekranını göster';

  @override
  String get settingsShowWelcomeHint =>
      'Bir sonraki açılışta karşılama ekranıyla başla';

  @override
  String greetingHi(String name) {
    return 'Merhaba $name,';
  }

  @override
  String get greetingWelcomeHome => 'Evine hoş geldin!';

  @override
  String activeDevices(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString cihaz etkin',
      zero: 'Etkin cihaz yok',
    );
    return '$_temp0';
  }

  @override
  String get connectionOnline => 'Bağlı';

  @override
  String get connectionConnecting => 'Bağlanıyor…';

  @override
  String get connectionOffline => 'Çevrimdışı';

  @override
  String get filterAll => 'Tümü';

  @override
  String roomDeviceCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString cihaz',
    );
    return '$_temp0';
  }

  @override
  String roomOnCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString açık';
  }

  @override
  String get scenesTitle => 'Sahneler';

  @override
  String get scenesSoon => 'Tek dokunuşla tüm ev. Yakında.';

  @override
  String get emptyRoom => 'Burada henüz cihaz yok';

  @override
  String get deviceNotFound => 'Bu cihaz artık kullanılamıyor';

  @override
  String get roomNotFound => 'Bu oda artık yok';

  @override
  String get loading => 'Evin yükleniyor…';

  @override
  String get typeLights => 'Işıklar';

  @override
  String get typeSwitches => 'Anahtarlar';

  @override
  String get typeCurtains => 'Perdeler';

  @override
  String get typeClimate => 'İklim';

  @override
  String get typeOutlets => 'Prizler';

  @override
  String get typeLocks => 'Kilitler';

  @override
  String get typeSensors => 'Sensörler';

  @override
  String get typeCameras => 'Kameralar';

  @override
  String get typeOther => 'Diğer';

  @override
  String get stateOn => 'Açık';

  @override
  String get stateOff => 'Kapalı';

  @override
  String get stateOffline => 'Çevrimdışı';

  @override
  String stateOnLevel(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Açık · %$percentString';
  }

  @override
  String get stateLocked => 'Kilitli';

  @override
  String get stateUnlocked => 'Kilit açık';

  @override
  String get stateJammed => 'Sıkıştı';

  @override
  String stateOpenPercent(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '%$percentString açık';
  }

  @override
  String get stateClosed => 'Kapalı';

  @override
  String get stateOpen => 'Açık';

  @override
  String get stateOpening => 'Açılıyor…';

  @override
  String get stateClosing => 'Kapanıyor…';

  @override
  String get stateHeating => 'Isıtıyor';

  @override
  String get stateCooling => 'Soğutuyor';

  @override
  String get stateIdle => 'Beklemede';

  @override
  String get stateMotion => 'Hareket algılandı';

  @override
  String get stateNoMotion => 'Hareket yok';

  @override
  String stateChannelsOn(int on, int total) {
    final intl.NumberFormat onNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String onString = onNumberFormat.format(on);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString kanaldan $onString açık';
  }

  @override
  String get stateLive => 'Canlı';

  @override
  String get stateUnknown => 'Cihaz bekleniyor…';

  @override
  String temperatureValue(String value) {
    return '$value°';
  }

  @override
  String wattsValue(String value) {
    return '$value W';
  }

  @override
  String kwhValue(String value) {
    return '$value kWh';
  }

  @override
  String get detailPower => 'Güç';

  @override
  String get detailBrightness => 'Parlaklık';

  @override
  String get detailColor => 'Renk';

  @override
  String get detailColorTemperature => 'Beyaz tonu';

  @override
  String get tempWarm => 'Sıcak';

  @override
  String get tempNeutral => 'Nötr';

  @override
  String get tempCool => 'Soğuk';

  @override
  String get tempDaylight => 'Gün ışığı';

  @override
  String get detailPosition => 'Konum';

  @override
  String get actionOpen => 'Aç';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionStop => 'Durdur';

  @override
  String get detailSetpoint => 'Hedef sıcaklık';

  @override
  String get thermostatHeatingTo => 'Isıtma hedefi';

  @override
  String get thermostatCoolingTo => 'Soğutma hedefi';

  @override
  String get thermostatAutoTo => 'Sabit tutuluyor';

  @override
  String get thermostatOff => 'Kapalı';

  @override
  String get detailMode => 'Mod';

  @override
  String get modeOff => 'Kapalı';

  @override
  String get modeHeat => 'Isıtma';

  @override
  String get modeCool => 'Soğutma';

  @override
  String currentTemperature(String value) {
    return 'Şu an $value';
  }

  @override
  String get detailFan => 'Fan';

  @override
  String get fanAuto => 'Otomatik';

  @override
  String get fanLow => 'Düşük';

  @override
  String get fanMedium => 'Orta';

  @override
  String get fanHigh => 'Yüksek';

  @override
  String get detailLivePower => 'Anlık tüketim';

  @override
  String get detailEnergy => 'Toplam enerji';

  @override
  String get detailLock => 'Kapı kilidi';

  @override
  String get detailTemperature => 'Sıcaklık';

  @override
  String get detailHumidity => 'Nem';

  @override
  String get detailMotion => 'Hareket';

  @override
  String get detailContact => 'Kapı';

  @override
  String get detailCamera => 'Kamera';

  @override
  String get cameraSoon => 'Canlı görüntü sonraki bir sürümde gelecek';

  @override
  String get offlineBanner => 'Çevrimdışı. Bilinen son durum gösteriliyor.';

  @override
  String get pendingLabel => 'Gönderiliyor…';

  @override
  String deviceInfo(String model, String firmware) {
    return '$model · yazılım $firmware';
  }

  @override
  String feedbackUnreachable(String device) {
    return 'Bağlantı yok. $device için yapılan değişiklik geri alındı.';
  }

  @override
  String feedbackTimedOut(String device) {
    return '$device yanıt vermedi. Değişikliğin geri alındı.';
  }

  @override
  String feedbackBusy(String device) {
    return '$device meşgul ve değişikliği reddetti. Değişiklik geri alındı.';
  }

  @override
  String feedbackRejected(String device) {
    return '$device değişikliği uygulayamadı. Değişiklik geri alındı.';
  }

  @override
  String feedbackAppliedLate(String device) {
    return '$device sonunda değişti.';
  }

  @override
  String get demoRoomLivingRoom => 'Oturma Odası';

  @override
  String get demoRoomBedroom => 'Yatak Odası';

  @override
  String get demoRoomKitchen => 'Mutfak';

  @override
  String get demoRoomEntrance => 'Giriş';

  @override
  String get demoCeilingLight => 'Tavan lambası';

  @override
  String get demoFloorLamp => 'Lambader';

  @override
  String get demoCurtain => 'Perde';

  @override
  String get demoThermostat => 'Termostat';

  @override
  String get demoReadingLight => 'Okuma lambası';

  @override
  String get demoClimateSensor => 'İklim sensörü';

  @override
  String get demoWallSwitch => 'Duvar anahtarı';

  @override
  String get demoCoffeeMachine => 'Kahve makinesi';

  @override
  String get demoMotionSensor => 'Hareket sensörü';

  @override
  String get demoFrontDoorLock => 'Ön kapı kilidi';

  @override
  String get demoDoorSensor => 'Kapı sensörü';

  @override
  String get demoDoorbellCamera => 'Kapı zili kamerası';

  @override
  String get demoChannelCeiling => 'Tavan';

  @override
  String get demoChannelCounter => 'Tezgâh';

  @override
  String get demoChannelHood => 'Davlumbaz';

  @override
  String get demoSceneMovieNight => 'Film gecesi';

  @override
  String get demoSceneGoodMorning => 'Günaydın';

  @override
  String get demoSceneAway => 'Dışarıda';

  @override
  String get modeAuto => 'Otomatik';

  @override
  String get listSeparator => ' · ';

  @override
  String get connectionReconnecting => 'Yeniden bağlanıyor…';

  @override
  String get connectionDemo => 'Demo ev';

  @override
  String get settingsConnection => 'Bağlantı';

  @override
  String get settingsConnectionHint => 'Cihazların nereden geldiği.';

  @override
  String get connectionModeDemo => 'Demo';

  @override
  String get connectionModeBroker => 'Kendi broker\'ım';

  @override
  String get connectionDemoHint =>
      'Uygulamanın içinde on iki simüle cihaz. Ağ gerekmez.';

  @override
  String get connectionBrokerHint =>
      'Glowhaus protokolünü konuşan bir MQTT broker\'ı, örneğin infra/ içindeki.';

  @override
  String get connectionWebNote =>
      'Tarayıcıda uygulama güvenli WebSocket (wss://) ile bağlanır ve bu tarayıcı broker\'ın sertifikasına güvenmelidir.';

  @override
  String get connectionHost => 'Sunucu';

  @override
  String get connectionHostHint =>
      'Ad veya IP adresi, mqtts:// ve port olmadan';

  @override
  String get connectionPort => 'Port';

  @override
  String connectionPortHint(int port) {
    return 'Varsayılan için boş bırak: $port';
  }

  @override
  String get connectionTls => 'Şifreli (TLS)';

  @override
  String get connectionTlsHint =>
      'Yalnızca bu bilgisayardaki bir broker veya bir emülatör için kapat.';

  @override
  String get connectionWebSocket => 'WebSocket üzerinden';

  @override
  String get connectionWebSocketHint =>
      'Yalnızca WebSocket istemcilerini dinleyen bir broker için.';

  @override
  String get connectionPath => 'WebSocket yolu';

  @override
  String get connectionHome => 'Ev kimliği';

  @override
  String get connectionUsername => 'Kullanıcı adı';

  @override
  String get connectionPassword => 'Parola';

  @override
  String get connectionPasswordHint =>
      'Yalnızca bellekte tutulur, asla kaydedilmez.';

  @override
  String get connectionCa => 'Ek CA sertifikası (PEM)';

  @override
  String get connectionCaHint =>
      'İsteğe bağlı. Bu cihazın geliştirme broker\'ına güvenmesi için infra/certs/ca.crt dosyasını yapıştır.';

  @override
  String get connectionConnect => 'Bağlan';

  @override
  String connectionStatusConnected(String broker) {
    return '$broker adresine bağlı.';
  }

  @override
  String connectionStatusConnecting(String broker) {
    return '$broker adresine bağlanıyor…';
  }

  @override
  String connectionStatusNeedsPassword(String broker) {
    return '$broker üzerinde en son görülen cihazlar gösteriliyor. Bağlanmak için parolayı gir.';
  }

  @override
  String get connectionProblemUnreachable =>
      'Orada yanıt veren bir broker yok. Sunucuyu, portu ve broker\'ın çalıştığını kontrol et.';

  @override
  String get connectionProblemUnreachableWeb =>
      'Orada yanıt veren bir broker yok ya da bu tarayıcı sertifikasına güvenmiyor.';

  @override
  String get connectionProblemUntrusted =>
      'Broker\'ın sertifikasına burada güvenilmiyor ya da bu sunucu adını kapsamıyor.';

  @override
  String get connectionProblemUnauthorized =>
      'Kullanıcı adı veya parola yanlış.';

  @override
  String get connectionProblemRefused => 'Broker bağlantıyı reddetti.';

  @override
  String get connectionInvalidHost =>
      'Şema veya port olmadan bir sunucu adı ya da IP adresi gir.';

  @override
  String get connectionInvalidPort => 'Port 1 ile 65535 arasında bir sayıdır.';

  @override
  String get connectionInvalidPath => 'Yol / ile başlar.';

  @override
  String get connectionInvalidHome => 'Küçük harf, rakam, - ve _, en fazla 32.';

  @override
  String get connectionInvalidUsername => 'Bir kullanıcı adı gir.';

  @override
  String get panelTitle => 'Cihazlar';

  @override
  String get panelSubtitle =>
      'Protokolün öbür ucu: bu sayfanın içindeki bir MQTT broker\'ına bağlı on iki sanal cihaz.';

  @override
  String get panelOpen => 'Cihazlar';

  @override
  String get panelClose => 'Cihaz panelini kapat';

  @override
  String get panelOpenTab => 'Yeni sekmede aç';

  @override
  String get panelPlugged => 'Prize takılı';

  @override
  String panelPlugDevice(String device) {
    return '$device prize takılı';
  }

  @override
  String panelPress(String device) {
    return '$device üzerindeki düğmeye bas';
  }

  @override
  String get panelTraffic => 'MQTT trafiği';

  @override
  String get panelTrafficEmpty =>
      'Henüz bir şey yok. Uygulamada bir şeye dokun.';

  @override
  String panelTrafficSent(String device) {
    return '$device gönderdi';
  }

  @override
  String panelTrafficReceived(String device) {
    return '$device aldı';
  }

  @override
  String get panelAway =>
      'Cihazlar başka bir sekmede çalışıyor. Buraya dönmeleri için o sekmeyi kapat.';

  @override
  String get devicesTabJoining => 'Demoya bağlanıyor…';

  @override
  String get devicesTabNoHost =>
      'Bu tarayıcıda açık bir Glowhaus demosu yok. Başka bir sekmede aç ve tekrar dene.';

  @override
  String get devicesTabRetry => 'Tekrar dene';

  @override
  String get devicesTabElsewhere =>
      'Cihazlar zaten başka bir sekmede çalışıyor.';

  @override
  String get devicesTabTakeOver => 'Devral';

  @override
  String get devicesTabHint =>
      'Bu cihazlar diğer sekmendeki uygulamayla MQTT üzerinden konuşur. Bu sekmeyi kapatırsan geri dönerler.';
}
