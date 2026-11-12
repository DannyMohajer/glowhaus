@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

import 'support.dart';

typedef _Strings = ({
  String hi,
  String welcome,
  List<String> chips,
  String lamp,
  String lampOn,
  String off,
  String offline,
  String lock,
  String locked,
  String heating,
  String cooling,
  List<String> modes,
  String heatingTo,
  String closed,
  String open,
  List<String> nav,
  String room,
  String roomSummary,
  String connected,
});

const _Strings _en = (
  hi: 'Hi Daniel,',
  welcome: 'Welcome home!',
  chips: ['All', 'Lights', 'Climate'],
  lamp: 'Floor lamp',
  lampOn: 'On · 55%',
  off: 'Off',
  offline: 'Offline',
  lock: 'Front door',
  locked: 'Locking…',
  heating: 'Heating',
  cooling: 'Cooling',
  modes: ['Off', 'Heat', 'Cool', 'Auto'],
  heatingTo: 'Heating to',
  closed: 'Closed',
  open: 'Open',
  nav: ['Home', 'Rooms', 'Settings'],
  room: 'Living Room',
  roomSummary: '4 devices · 2 on',
  connected: 'Connected',
);

const _Strings _fa = (
  hi: 'سلام دانیال،',
  welcome: 'به خانه خوش آمدی!',
  chips: ['همه', 'روشنایی', 'تهویه'],
  lamp: 'آباژور',
  lampOn: 'روشن، ۵۵٪',
  off: 'خاموش',
  offline: 'آفلاین',
  lock: 'در ورودی',
  locked: 'در حال قفل شدن…',
  heating: 'گرمایش',
  cooling: 'سرمایش',
  modes: ['خاموش', 'گرمایش', 'سرمایش', 'خودکار'],
  heatingTo: 'گرمایش تا',
  closed: 'بسته',
  open: 'باز',
  nav: ['خانه', 'اتاق‌ها', 'تنظیمات'],
  room: 'اتاق نشیمن',
  roomSummary: '۴ دستگاه، ۲ روشن',
  connected: 'متصل',
);

class _Gallery extends StatelessWidget {
  const new(this.s);

  final _Strings s;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const gap = SizedBox(height: GlowSpace.x4);
    Widget tile({
      required String title,
      required String subtitle,
      required IconData icon,
      required bool on,
      bool offline = false,
      bool pending = false,
      DeviceTone? tone,
    }) => Expanded(
      child: DeviceTile(
        title: title,
        subtitle: subtitle,
        icon: icon,
        on: on,
        offline: offline,
        pending: pending,
        tone: tone,
        onToggle: (_) {},
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GlowSpace.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingHeader(
            line1: s.hi,
            line2: s.welcome,
            trailing: IconButtonRound(
              icon: GlowIcons.bell,
              semanticLabel: 'bell',
              onTap: () {},
            ),
          ),
          gap,
          Row(
            children: [
              ConnectionBadge(
                state: ConnectionBadgeState.online,
                label: s.connected,
              ),
            ],
          ),
          gap,
          Wrap(
            spacing: GlowSpace.x2,
            children: [
              for (final (i, label) in s.chips.indexed)
                GlowChip(label: label, selected: i == 0, onTap: () {}),
            ],
          ),
          gap,
          RoomCard(
            title: s.room,
            subtitle: s.roomSummary,
            icon: GlowIcons.sofa,
            meta: '20.8°',
            onTap: () {},
            controls: [
              RoomQuickControl(
                icon: GlowIcons.lamp,
                label: s.lamp,
                on: true,
                onTap: () {},
              ),
              RoomQuickControl(
                icon: GlowIcons.lockOpen,
                label: s.lock,
                on: false,
                tone: DeviceTone.attention,
                onTap: () {},
              ),
            ],
          ),
          gap,
          Row(
            children: [
              tile(
                title: s.lamp,
                subtitle: s.lampOn,
                icon: GlowIcons.lamp,
                on: true,
              ),
              const SizedBox(width: GlowSpace.x3),
              tile(
                title: s.lamp,
                subtitle: s.off,
                icon: GlowIcons.lamp,
                on: false,
              ),
            ],
          ),
          const SizedBox(height: GlowSpace.x3),
          Row(
            children: [
              tile(
                title: s.lock,
                subtitle: s.locked,
                icon: GlowIcons.lock,
                on: true,
                pending: true,
                tone: DeviceTone.neutral,
              ),
              const SizedBox(width: GlowSpace.x3),
              tile(
                title: s.lamp,
                subtitle: s.offline,
                icon: GlowIcons.lamp,
                on: true,
                offline: true,
              ),
            ],
          ),
          gap,
          Center(
            child: TickDial(
              value: 22.5,
              min: 16,
              max: 30,
              valueLabel: '22.5°',
              caption: s.heatingTo,
              minLabel: '16°',
              maxLabel: '30°',
              semanticLabel: 'dial',
              size: 240,
              onChanged: (_) {},
            ),
          ),
          gap,
          ModeRow(
            icon: GlowIcons.flame,
            title: s.heating,
            value: true,
            color: colors.heat,
            onChanged: (_) {},
          ),
          const SizedBox(height: GlowSpace.x2),
          GlowSegmented<int>(
            selected: 1,
            onChanged: (_) {},
            segments: [
              GlowSegment(value: 0, label: s.modes[0], icon: GlowIcons.power),
              GlowSegment(
                value: 1,
                label: s.modes[1],
                icon: GlowIcons.flame,
                color: colors.heat,
              ),
              GlowSegment(
                value: 2,
                label: s.modes[2],
                icon: GlowIcons.snowflake,
                color: colors.cool,
              ),
              GlowSegment(value: 3, label: s.modes[3], icon: GlowIcons.sunMoon),
            ],
          ),
          gap,
          PositionSlider(
            value: 60,
            reportedValue: 35,
            startLabel: s.closed,
            endLabel: s.open,
            semanticLabel: 'curtain',
            onChanged: (_) {},
          ),
          gap,
          Row(
            children: [
              Expanded(
                child: GlowBottomNav(
                  items: [
                    GlowNavItem(icon: GlowIcons.house, label: s.nav[0]),
                    GlowNavItem(icon: GlowIcons.layoutGrid, label: s.nav[1]),
                    GlowNavItem(icon: GlowIcons.settings, label: s.nav[2]),
                  ],
                  currentIndex: 0,
                  onTap: (_) {},
                ),
              ),
              GlowFab(icon: GlowIcons.plus, semanticLabel: 'add', onTap: () {}),
            ],
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
    ('dark_fa_rtl', Brightness.dark, TextDirection.rtl, _fa),
  ]) {
    testWidgets('component gallery: $name', (tester) async {
      tester.useSurface(const Size(420, 1420));
      await tester.pumpWidget(
        host(
          _Gallery(strings),
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
        matchesGoldenFile('goldens/gallery_$name.png'),
      );
    });
  }
}
