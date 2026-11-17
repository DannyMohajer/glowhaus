@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

/// The phone's devices sheet: three columns of compact cards, the faces
/// scaled down, the plug a button in the corner.
typedef _Strings = ({
  String lamp,
  String on,
  String curtain,
  String open,
  String lock,
  String locked,
  String sensor,
  String dry,
  String camera,
  String standby,
  String outlet,
  String off,
  String offline,
  String unplug,
});

const _Strings _en = (
  lamp: 'Ceiling light',
  on: 'On · 70%',
  curtain: 'Curtain',
  open: 'Open 80%',
  lock: 'Front door',
  locked: 'Locked',
  sensor: 'Leak sensor',
  dry: 'Dry',
  camera: 'Doorbell',
  standby: 'Standby',
  outlet: 'Coffee machine',
  off: 'Off',
  offline: 'Offline',
  unplug: 'Unplug',
);

const _Strings _fa = (
  lamp: 'چراغ سقفی',
  on: 'روشن، ۷۰٪',
  curtain: 'پرده',
  open: 'باز ۸۰٪',
  lock: 'در ورودی',
  locked: 'قفل',
  sensor: 'حسگر نشتی',
  dry: 'خشک',
  camera: 'زنگ در',
  standby: 'آماده',
  outlet: 'قهوه‌ساز',
  off: 'خاموش',
  offline: 'آفلاین',
  unplug: 'کشیدن دوشاخه',
);

class _Sheet extends StatelessWidget {
  const new(this.s);

  final _Strings s;

  Widget _card({
    required String name,
    required String status,
    required Widget face,
    required bool online,
    required bool active,
  }) => GlowDeviceCard(
    name: name,
    status: online ? status : s.offline,
    face: face,
    online: online,
    active: active,
    compact: true,
    plugLabel: s.unplug,
    plugSemanticLabel: '${s.unplug} $name',
    onPlug: () {},
  );

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _card(
        name: s.lamp,
        status: s.on,
        face: GlowLightFace(on: true, onTap: () {}),
        online: true,
        active: true,
      ),
      _card(
        name: s.curtain,
        status: s.open,
        face: GlowCurtainFace(openPercent: 80, onTap: () {}),
        online: true,
        active: true,
      ),
      _card(
        name: s.lock,
        status: s.locked,
        face: GlowLockFace(locked: true, onTap: () {}),
        online: true,
        active: false,
      ),
      _card(
        name: s.sensor,
        status: s.dry,
        face: const GlowLeakFace(wet: false),
        online: true,
        active: false,
      ),
      _card(
        name: s.camera,
        status: s.standby,
        face: GlowCameraFace(ringTick: 0, onTap: () {}),
        online: true,
        active: false,
      ),
      _card(
        name: s.outlet,
        status: s.off,
        face: GlowPlugFace(on: false, onTap: () {}),
        online: false,
        active: false,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(GlowSpace.x3),
      child: Column(
        children: [
          for (var row = 0; row < cards.length; row += 3)
            Padding(
              padding: const EdgeInsets.only(bottom: GlowSpace.x2),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var column = 0; column < 3; column++) ...[
                      if (column > 0) const SizedBox(width: GlowSpace.x2),
                      Expanded(child: cards[row + column]),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(loadGlowFonts);

  for (final (name, brightness, direction, strings) in [
    ('light', Brightness.light, TextDirection.ltr, _en),
    ('dark', Brightness.dark, TextDirection.ltr, _en),
    ('light_fa_rtl', Brightness.light, TextDirection.rtl, _fa),
  ]) {
    testWidgets('compact device cards: $name', (tester) async {
      // An iPhone SE's width: the narrowest phone the app is built for.
      tester.useSurface(const Size(375, 300));
      await tester.pumpWidget(
        host(
          _Sheet(strings),
          brightness: brightness,
          direction: direction,
          reduceMotion: true,
          center: false,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/sheet_cards_$name.png'),
      );
    });
  }
}
