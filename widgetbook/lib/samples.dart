import 'package:flutter/widgets.dart';

/// Sample copy for the catalog in the three app languages.
class Samples {
  const new _(this._code);

  factory of(BuildContext context) =>
      Samples._(Localizations.localeOf(context).languageCode);

  final String _code;

  String _pick(String en, String fa, String tr) => switch (_code) {
    'fa' => fa,
    'tr' => tr,
    _ => en,
  };

  String get hi => _pick('Hi Daniel,', 'سلام دانیال،', 'Merhaba Daniel,');
  String get welcome =>
      _pick('Welcome home!', 'به خانه خوش آمدی!', 'Evine hoş geldin!');
  String get all => _pick('All', 'همه', 'Tümü');
  String get lights => _pick('Lights', 'روشنایی', 'Işıklar');
  String get climate => _pick('Climate', 'تهویه', 'İklim');
  String get security => _pick('Security', 'امنیت', 'Güvenlik');
  String get start => _pick("Let's start", 'شروع کنیم', 'Başlayalım');
  String get addDevice => _pick('Add device', 'افزودن دستگاه', 'Cihaz ekle');
  String get notifications => _pick('Notifications', 'اعلان‌ها', 'Bildirimler');
  String get lamp => _pick('Floor lamp', 'آباژور', 'Lambader');
  String get ceiling => _pick('Ceiling light', 'چراغ سقفی', 'Tavan lambası');
  String get lock => _pick('Front door', 'در ورودی', 'Ön kapı');
  String get on => _pick('On', 'روشن', 'Açık');
  String get off => _pick('Off', 'خاموش', 'Kapalı');
  String get offline => _pick('Offline', 'آفلاین', 'Çevrimdışı');
  String get livingRoom => _pick('Living Room', 'اتاق نشیمن', 'Oturma Odası');
  String get roomSummary =>
      _pick('4 devices · 2 on', '۴ دستگاه · ۲ روشن', '4 cihaz · 2 açık');
  String get connected => _pick('Connected', 'متصل', 'Bağlı');
  String get connecting => _pick('Connecting…', 'در حال اتصال…', 'Bağlanıyor…');
  String get disconnected => _pick('Offline', 'قطع', 'Bağlantı yok');
  String get heating => _pick('Heating', 'گرمایش', 'Isıtma');
  String get cooling => _pick('Cooling', 'سرمایش', 'Soğutma');
  String get heatingTo => _pick('Heating to', 'گرمایش تا', 'Isıtma hedefi');
  String get coolingTo => _pick('Cooling to', 'سرمایش تا', 'Soğutma hedefi');
  String get temperature => _pick('Temperature', 'دما', 'Sıcaklık');
  String get curtain => _pick('Curtain', 'پرده', 'Perde');
  String get closed => _pick('Closed', 'بسته', 'Kapalı');
  String get open => _pick('Open', 'باز', 'Açık');
  String get home => _pick('Home', 'خانه', 'Ana sayfa');
  String get rooms => _pick('Rooms', 'اتاق‌ها', 'Odalar');
  String get settings => _pick('Settings', 'تنظیمات', 'Ayarlar');
  String get device => _pick('Device', 'دستگاه', 'Cihaz');
  String get cardBody => _pick(
    'A plain surface with a 28 px radius.',
    'یک سطح ساده با گوشه‌های ۲۸ پیکسلی.',
    '28 px köşeli sade bir yüzey.',
  );
}
