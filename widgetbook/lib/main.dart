import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:glowhaus_widgetbook/home_page.dart';
import 'package:glowhaus_widgetbook/samples.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const GlowhausWidgetbook());
}

const _accents = <String, Color?>{
  'Orange (default)': null,
  'Blue': Color(0xFF2F6BFF),
  'Green': Color(0xFF1F9D6B),
  'Violet': Color(0xFF7A4DFF),
  'Rose': Color(0xFFE5387B),
};

class GlowhausWidgetbook extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      home: const CatalogHomePage(),
      addons: [
        ThemeAddon<Brightness>(
          themes: const [
            WidgetbookTheme(name: 'Light', data: Brightness.light),
            WidgetbookTheme(name: 'Dark', data: Brightness.dark),
          ],
          themeBuilder: (context, brightness, child) => Theme(
            data: GlowhausTheme.build(brightness: brightness),
            child: child,
          ),
        ),
        LocalizationAddon(
          locales: const [Locale('en'), Locale('fa'), Locale('tr')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
        TextScaleAddon(min: 0.8, initialScale: 1),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Basics',
          children: [
            _component('GreetingHeader', _greeting),
            _component('GlowChip', _chips),
            _component('IconButtonRound', _iconButtons),
            _component('GlowButton', _buttons),
            _component('GlowFab', _fab),
            _component('GlowCard', _card),
            _component('ToggleSwitch', _toggle),
            _component('StatusDot', _statusDots),
            _component('GlowPulseRing', _pulseRing),
            _component('ConnectionBadge', _connection),
            _component('GlowTextField', (_) => const _TextFields()),
            _component('GlowIntroPanel', _intro, padded: false),
          ],
        ),
        WidgetbookFolder(
          name: 'Devices',
          children: [
            _faceComponent(),
            _component('DeviceTile', _deviceTile),
            _component('RoomCard', _roomCard),
            _component('TickDial', _tickDial),
            _component('PositionSlider', _positionSlider),
            _component('ModeRow', _modeRows),
            _component('GlowSegmented', _segmented),
          ],
        ),
        WidgetbookFolder(
          name: 'Navigation',
          children: [
            _component('GlowBottomNav', _bottomNav),
            _component('AdaptiveScaffold', _adaptiveScaffold, padded: false),
          ],
        ),
      ],
    );
  }
}

WidgetbookComponent _component(
  String name,
  WidgetBuilder builder, {
  bool padded = true,
}) => WidgetbookComponent(
  name: name,
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) => _Frame(padded: padded, builder: builder),
    ),
  ],
);

/// Applies the Glowhaus theme for the selected brightness, locale and accent,
/// and loads the Persian font when it is needed.
class _Frame extends StatelessWidget {
  const new({required this.builder, required this.padded});

  final WidgetBuilder builder;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final persian = Localizations.localeOf(context).languageCode == 'fa';
    final accent = context.knobs.object.dropdown<String>(
      label: 'Accent',
      options: _accents.keys.toList(),
    );
    final reduceMotion = context.knobs.boolean(label: 'Reduce motion');
    final theme = GlowhausTheme.build(
      brightness: Theme.of(context).brightness,
      accent: _accents[accent],
      persian: persian,
      reduceMotion: reduceMotion,
    );
    return FutureBuilder<void>(
      future: persian ? GlowFontLoader.ensurePersian() : null,
      // Wait for the Persian font so no fallback glyphs flash (or are fetched).
      builder: (context, snapshot) =>
          persian && snapshot.connectionState != ConnectionState.done
          ? const SizedBox.shrink()
          : Theme(
              data: theme,
              child: Builder(
                builder: (context) => ColoredBox(
                  color: context.colors.bg,
                  child: DefaultTextStyle(
                    style: context.type.body,
                    child: padded
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(GlowSpace.x5),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: builder(context),
                              ),
                            ),
                          )
                        : builder(context),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Keeps a value so interactive components respond in the catalog.
class _Stateful<T> extends StatefulWidget {
  const new({required this.initial, required this.builder});

  final T initial;
  final Widget Function(BuildContext context, T value, ValueChanged<T> set)
  builder;

  @override
  State<_Stateful<T>> createState() => _StatefulState<T>();
}

class _StatefulState<T> extends State<_Stateful<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _value,
    (value) => setState(() => _value = value),
  );
}

Widget _greeting(BuildContext context) {
  final s = Samples.of(context);
  return GreetingHeader(
    line1: context.knobs.string(label: 'Line 1', initialValue: s.hi),
    line2: context.knobs.string(label: 'Line 2', initialValue: s.welcome),
    trailing: IconButtonRound(
      icon: GlowIcons.bell,
      semanticLabel: s.notifications,
      onTap: () {},
    ),
  );
}

Widget _chips(BuildContext context) {
  final s = Samples.of(context);
  final labels = [s.all, s.lights, s.climate, s.security];
  return _Stateful<int>(
    initial: 0,
    builder: (context, selected, set) => Wrap(
      spacing: GlowSpace.x2,
      runSpacing: GlowSpace.x2,
      children: [
        for (final (index, label) in labels.indexed)
          GlowChip(
            label: label,
            icon: index == 1 ? GlowIcons.lightbulb : null,
            selected: index == selected,
            onTap: () => set(index),
          ),
      ],
    ),
  );
}

Widget _iconButtons(BuildContext context) {
  final s = Samples.of(context);
  return Wrap(
    spacing: GlowSpace.x3,
    children: [
      for (final tone in GlowTone.values)
        IconButtonRound(
          icon: GlowIcons.bell,
          semanticLabel: '${s.notifications} (${tone.name})',
          tone: tone,
          onTap: () {},
        ),
    ],
  );
}

Widget _buttons(BuildContext context) {
  final s = Samples.of(context);
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final tone in [GlowTone.accent, GlowTone.inverse, GlowTone.surface])
        Padding(
          padding: const EdgeInsets.only(bottom: GlowSpace.x3),
          child: GlowButton(
            label: s.start,
            tone: tone,
            expand: true,
            icon: Directionality.of(context) == TextDirection.rtl
                ? GlowIcons.arrowLeft
                : GlowIcons.arrowRight,
            onTap: enabled ? () {} : null,
          ),
        ),
    ],
  );
}

Widget _fab(BuildContext context) {
  final s = Samples.of(context);
  final extended = context.knobs.boolean(label: 'With label');
  return Center(
    child: GlowFab(
      icon: GlowIcons.plus,
      semanticLabel: s.addDevice,
      label: extended ? s.addDevice : null,
      onTap: () {},
    ),
  );
}

Widget _card(BuildContext context) {
  final s = Samples.of(context);
  return GlowCard(
    onTap: context.knobs.boolean(label: 'Tappable') ? () {} : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.livingRoom, style: context.type.title),
        const SizedBox(height: GlowSpace.x2),
        Text(
          s.cardBody,
          style: context.type.body.copyWith(color: context.colors.textMuted),
        ),
      ],
    ),
  );
}

Widget _toggle(BuildContext context) {
  final s = Samples.of(context);
  final pending = context.knobs.boolean(label: 'Pending');
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return Center(
    child: _Stateful<bool>(
      initial: true,
      builder: (context, value, set) => ToggleSwitch(
        value: value,
        pending: pending,
        semanticLabel: s.lamp,
        onChanged: enabled ? set : null,
      ),
    ),
  );
}

Widget _statusDots(BuildContext context) => Wrap(
  spacing: GlowSpace.x5,
  runSpacing: GlowSpace.x3,
  children: [
    for (final tone in StatusTone.values)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(tone: tone),
          const SizedBox(width: GlowSpace.x2),
          Text(tone.name, style: context.type.caption),
        ],
      ),
  ],
);

Widget _connection(BuildContext context) {
  final s = Samples.of(context);
  return Wrap(
    spacing: GlowSpace.x2,
    runSpacing: GlowSpace.x2,
    children: [
      ConnectionBadge(state: ConnectionBadgeState.online, label: s.connected),
      ConnectionBadge(
        state: ConnectionBadgeState.connecting,
        label: s.connecting,
      ),
      ConnectionBadge(
        state: ConnectionBadgeState.offline,
        label: s.disconnected,
      ),
    ],
  );
}

class _TextFields extends StatefulWidget {
  const new();

  @override
  State<_TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<_TextFields> {
  final _host = TextEditingController(text: 'localhost');
  final _password = TextEditingController(text: 'not-the-password');

  @override
  void dispose() {
    _host.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Samples.of(context);
    final showError = context.knobs.boolean(label: 'Error');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowTextField(
          label: s.host,
          hint: s.hostHint,
          controller: _host,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: GlowSpace.x4),
        GlowTextField(
          label: s.password,
          error: showError ? s.wrongPassword : null,
          controller: _password,
          obscure: true,
        ),
      ],
    );
  }
}

/// The intro screen's one shape, headline, button and link. Light, dark and
/// Persian (right to left) come from the catalog's addons.
Widget _intro(BuildContext context) {
  final s = Samples.of(context);
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: GlowIntroShape.maxWidth,
        maxHeight: 760,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GlowSpace.x4,
          GlowSpace.x4,
          GlowSpace.x4,
          GlowSpace.x6,
        ),
        child: GlowIntroPanel(
          title: s.introTitle,
          titleRest: s.introTitleRest,
          startLabel: s.start,
          onStart: () {},
          footerText: s.introCurious,
          linkLabel: s.introGitHub,
          onLink: () {},
        ),
      ),
    ),
  );
}

/// Every device face, in the three states a card can be in: doing
/// something, idle, and unplugged (greyed out, "Offline").
WidgetbookComponent _faceComponent() => WidgetbookComponent(
  name: 'GlowDeviceCard',
  useCases: [
    for (final face in _faces)
      WidgetbookUseCase(
        name: face.name,
        builder: (context) => _Frame(
          padded: true,
          builder: (context) => _faceStates(context, face),
        ),
      ),
  ],
);

/// One face: its name, and how it looks when it is on and when it is off.
typedef _Face = ({
  String name,
  String Function(Samples s) label,
  String Function(Samples s, {required bool on}) status,
  Widget Function(Samples s, {required bool on, required bool online}) build,
});

final List<_Face> _faces = [
  (
    name: 'Light',
    label: (s) => s.lamp,
    status: (s, {required on}) => on ? s.on : s.off,
    build: (s, {required on, required online}) => GlowLightFace(
      on: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.lamp}: ${s.press}',
    ),
  ),
  (
    name: 'Curtain',
    label: (s) => s.curtain,
    status: (s, {required on}) => on ? s.open : s.closed,
    build: (s, {required on, required online}) => GlowCurtainFace(
      openPercent: on ? 80 : 0,
      onTap: online ? () {} : null,
      semanticLabel: '${s.curtain}: ${s.press}',
    ),
  ),
  (
    name: 'Thermostat',
    label: (s) => s.thermostat,
    status: (s, {required on}) => on ? s.heating : s.off,
    build: (s, {required on, required online}) => GlowThermostatFace(
      reading: '22.5°',
      running: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.thermostat}: ${s.press}',
    ),
  ),
  (
    name: 'Wall switch',
    label: (s) => s.wallSwitch,
    status: (s, {required on}) => on ? s.on : s.off,
    build: (s, {required on, required online}) => GlowSwitchFace(
      gangs: [on, false, on],
      labelOf: (index) => '${s.wallSwitch} ${index + 1}',
      onPress: online ? (_) {} : null,
    ),
  ),
  (
    name: 'Lock',
    label: (s) => s.lock,
    status: (s, {required on}) => on ? s.locked : s.unlocked,
    build: (s, {required on, required online}) => GlowLockFace(
      locked: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.lock}: ${s.press}',
    ),
  ),
  (
    name: 'Doorbell camera',
    label: (s) => s.doorbell,
    status: (s, {required on}) => on ? s.on : s.off,
    build: (s, {required on, required online}) => GlowCameraFace(
      ringTick: on ? 1 : 0,
      onTap: online ? () {} : null,
      semanticLabel: '${s.doorbell}: ${s.press}',
    ),
  ),
  (
    name: 'Smart plug',
    label: (s) => s.plug,
    status: (s, {required on}) => on ? s.on : s.off,
    build: (s, {required on, required online}) => GlowPlugFace(
      on: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.plug}: ${s.press}',
    ),
  ),
  (
    name: 'Door sensor',
    label: (s) => s.doorSensor,
    status: (s, {required on}) => on ? s.open : s.closed,
    build: (s, {required on, required online}) => GlowDoorFace(
      open: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.doorSensor}: ${s.press}',
    ),
  ),
  (
    name: 'Climate sensor',
    label: (s) => s.climateSensor,
    status: (s, {required on}) => '21.4°',
    build: (s, {required on, required online}) =>
        const GlowClimateFace(temperature: '21.4°', humidity: '47%'),
  ),
  (
    name: 'Leak sensor',
    label: (s) => s.leakSensor,
    status: (s, {required on}) => on ? s.leak : s.dry,
    build: (s, {required on, required online}) => GlowLeakFace(
      wet: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.leakSensor}: ${s.press}',
    ),
  ),
  (
    name: 'Motion sensor',
    label: (s) => s.motionSensor,
    status: (s, {required on}) => on ? s.on : s.noMotion,
    build: (s, {required on, required online}) => GlowMotionFace(
      motion: on,
      onTap: online ? () {} : null,
      semanticLabel: '${s.motionSensor}: ${s.press}',
    ),
  ),
];

Widget _faceStates(BuildContext context, _Face face) {
  final s = Samples.of(context);
  Widget card({required bool on, required bool online}) => GlowDeviceCard(
    name: face.label(s),
    status: online ? face.status(s, on: on) : s.offline,
    face: face.build(s, on: on, online: online),
    online: online,
    active: on && online,
    plugLabel: online ? s.plugged : s.unplugged,
    plugSemanticLabel: '${face.label(s)}: ${online ? s.plugged : s.unplugged}',
    onPlug: () {},
  );
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: card(on: true, online: true)),
        const SizedBox(width: GlowSpace.x3),
        Expanded(child: card(on: false, online: true)),
        const SizedBox(width: GlowSpace.x3),
        Expanded(child: card(on: false, online: false)),
      ],
    ),
  );
}

/// The ring the app's device chips show when that device publishes.
Widget _pulseRing(BuildContext context) {
  final s = Samples.of(context);
  return _Stateful<int>(
    initial: 0,
    builder: (context, tick, set) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlowPulseRing(
          tick: tick,
          child: RoomQuickControl(
            icon: GlowIcons.lamp,
            label: s.lamp,
            on: true,
            onTap: () => set(tick + 1),
          ),
        ),
      ],
    ),
  );
}

Widget _deviceTile(BuildContext context) {
  final s = Samples.of(context);
  final offline = context.knobs.boolean(label: 'Offline');
  final pending = context.knobs.boolean(label: 'Pending');
  final withSwitch = context.knobs.boolean(label: 'Switch', initialValue: true);
  return _Stateful<bool>(
    initial: true,
    builder: (context, on, set) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DeviceTile(
            title: s.lamp,
            subtitle: offline
                ? s.offline
                : (on ? '${s.on}${s.separator}55%' : s.off),
            icon: GlowIcons.lamp,
            on: on,
            offline: offline,
            pending: pending,
            onTap: () {},
            onToggle: withSwitch ? set : null,
          ),
        ),
        const SizedBox(width: GlowSpace.x3),
        Expanded(child: _LockTile(s: s)),
      ],
    ),
  );
}

/// Locked is calm although its switch is on; unlocked asks for attention.
class _LockTile extends StatelessWidget {
  const new({required this.s});

  final Samples s;

  @override
  Widget build(BuildContext context) => _Stateful<bool>(
    initial: true,
    builder: (context, locked, set) => DeviceTile(
      title: s.lock,
      subtitle: locked ? s.locked : s.unlocked,
      icon: locked ? GlowIcons.lock : GlowIcons.lockOpen,
      on: locked,
      tone: locked ? DeviceTone.neutral : DeviceTone.attention,
      onTap: () {},
      onToggle: set,
    ),
  );
}

Widget _roomCard(BuildContext context) {
  final s = Samples.of(context);
  final selected = context.knobs.boolean(label: 'Selected');
  return _Stateful<bool>(
    initial: true,
    builder: (context, lampOn, set) => RoomCard(
      title: s.livingRoom,
      subtitle: s.roomSummary,
      icon: GlowIcons.sofa,
      meta: '20.8°',
      selected: selected,
      onTap: () {},
      controls: [
        RoomQuickControl(
          icon: GlowIcons.lamp,
          label: s.lamp,
          on: lampOn,
          onTap: () => set(!lampOn),
        ),
        RoomQuickControl(
          icon: GlowIcons.lightbulb,
          label: s.ceiling,
          on: false,
          pending: true,
          onTap: () {},
        ),
        RoomQuickControl(
          icon: GlowIcons.lockOpen,
          label: s.lock,
          on: false,
          tone: DeviceTone.attention,
        ),
      ],
    ),
  );
}

Widget _tickDial(BuildContext context) {
  final s = Samples.of(context);
  final tone = context.knobs.object.dropdown<TickDialTone>(
    label: 'Tone',
    options: TickDialTone.values,
    labelBuilder: (tone) => tone.name,
  );
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return Center(
    child: _Stateful<double>(
      initial: 22.5,
      builder: (context, value, set) => TickDial(
        value: value,
        min: 16,
        max: 30,
        valueLabel: '${value.toStringAsFixed(1)}°',
        caption: tone == TickDialTone.cool ? s.coolingTo : s.heatingTo,
        minLabel: '16°',
        maxLabel: '30°',
        semanticLabel: s.temperature,
        tone: tone,
        onChanged: enabled ? set : null,
      ),
    ),
  );
}

Widget _positionSlider(BuildContext context) {
  final s = Samples.of(context);
  final travelling = context.knobs.boolean(label: 'Show reported position');
  return _Stateful<int>(
    initial: 60,
    builder: (context, value, set) => PositionSlider(
      value: value,
      reportedValue: travelling ? 30 : null,
      startLabel: s.closed,
      endLabel: s.open,
      semanticLabel: s.curtain,
      onChanged: set,
    ),
  );
}

Widget _modeRows(BuildContext context) {
  final s = Samples.of(context);
  final pending = context.knobs.boolean(label: 'Pending');
  return _Stateful<bool>(
    initial: true,
    builder: (context, heating, set) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ModeRow(
          icon: GlowIcons.flame,
          title: s.heating,
          value: heating,
          pending: pending && heating,
          color: context.colors.heat,
          onChanged: (_) => set(true),
        ),
        const SizedBox(height: GlowSpace.x2),
        ModeRow(
          icon: GlowIcons.snowflake,
          title: s.cooling,
          value: !heating,
          pending: pending && !heating,
          color: context.colors.cool,
          onChanged: (_) => set(false),
        ),
      ],
    ),
  );
}

Widget _segmented(BuildContext context) {
  final s = Samples.of(context);
  final colors = context.colors;
  final pending = context.knobs.boolean(label: 'Pending');
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  return _Stateful<int>(
    initial: 1,
    builder: (context, mode, set) => GlowSegmented<int>(
      selected: mode,
      pending: pending,
      semanticLabel: s.mode,
      onChanged: enabled ? set : null,
      segments: [
        GlowSegment(value: 0, label: s.modeOff, icon: GlowIcons.power),
        GlowSegment(
          value: 1,
          label: s.modeHeat,
          icon: GlowIcons.flame,
          color: colors.heat,
        ),
        GlowSegment(
          value: 2,
          label: s.modeCool,
          icon: GlowIcons.snowflake,
          color: colors.cool,
        ),
        GlowSegment(
          value: 3,
          label: s.modeAuto,
          icon: GlowIcons.sunMoon,
          color: colors.accentStrong,
        ),
      ],
    ),
  );
}

List<GlowNavItem> _navItems(Samples s) => [
  GlowNavItem(icon: GlowIcons.house, label: s.home),
  GlowNavItem(icon: GlowIcons.layoutGrid, label: s.rooms),
  GlowNavItem(icon: GlowIcons.settings, label: s.settings),
];

Widget _bottomNav(BuildContext context) {
  final s = Samples.of(context);
  return _Stateful<int>(
    initial: 0,
    builder: (context, index, set) =>
        GlowBottomNav(items: _navItems(s), currentIndex: index, onTap: set),
  );
}

Widget _adaptiveScaffold(BuildContext context) {
  final s = Samples.of(context);
  Widget pane(String label) => Padding(
    padding: const EdgeInsets.all(GlowSpace.x3),
    child: GlowCard(
      child: Center(child: Text(label, style: context.type.heading)),
    ),
  );
  return _Stateful<int>(
    initial: 1,
    builder: (context, index, set) => AdaptiveScaffold(
      destinations: _navItems(s),
      currentIndex: index,
      onDestinationSelected: set,
      body: SafeArea(
        child: AdaptivePanes(
          panes: [pane(s.rooms), pane(s.livingRoom), pane(s.device)],
        ),
      ),
    ),
  );
}
