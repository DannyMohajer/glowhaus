import 'package:flutter/material.dart' hide LockState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/data/home_repository.dart';
import 'package:glowhaus/features/device/cubit/device_cubit.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/features/shared/device_presentation.dart';
import 'package:glowhaus/features/shared/pane.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Device detail, composed from the device's capabilities: one section per
/// capability, never a screen per device type.
class DevicePane extends StatelessWidget {
  const new({required this.deviceId, this.backTo, super.key});

  final String deviceId;
  final String? backTo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceCubit(
        context.read<HomeRepository>(),
        context.read<DeviceRepository>(),
        deviceId,
      ),
      child: _DeviceView(backTo: backTo),
    );
  }
}

class _DeviceView extends StatelessWidget {
  const new({this.backTo});

  final String? backTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final colors = context.colors;
    final type = context.type;

    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        final view = state.view;
        if (view == null) {
          return Column(
            children: [
              if (backTo != null)
                Padding(
                  padding: const EdgeInsets.all(GlowSpace.x5),
                  child: PaneHeader(title: '', backTo: backTo),
                ),
              Expanded(
                child: state.resolved
                    ? PaneMessage(
                        icon: GlowIcons.circleHelp,
                        message: l10n.deviceNotFound,
                      )
                    : const Center(
                        child: GlowSpinner(size: 28, strokeWidth: 3),
                      ),
              ),
            ],
          );
        }

        final device = view.device;
        final room = state.room;
        final model = device.model;
        final firmware = device.firmware;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            GlowSpace.x5,
            GlowSpace.x5,
            GlowSpace.x5,
            scrollBottomPadding(context),
          ),
          children: [
            PaneHeader(
              title: device.displayName(l10n),
              subtitle: [
                if (room != null) room.displayName(l10n),
                deviceStatus(readings, device),
              ].join(' · '),
              backTo: backTo,
              trailing: view.pending ? const _PendingBadge() : null,
            ),
            const SizedBox(height: GlowSpace.x4),
            if (device.isOffline) ...[
              _Banner(icon: GlowIcons.wifiOff, message: l10n.offlineBanner),
              const SizedBox(height: GlowSpace.x3),
            ],
            for (final section in _sections(context, view)) ...[
              section,
              const SizedBox(height: GlowSpace.x3),
            ],
            if (model != null && firmware != null)
              Padding(
                padding: const EdgeInsets.only(top: GlowSpace.x2),
                child: Text(
                  l10n.deviceInfo(model, firmware),
                  textAlign: TextAlign.center,
                  style: type.caption.copyWith(color: colors.textMuted),
                ),
              ),
          ],
        );
      },
    );
  }

  /// One block per capability, in descriptor order.
  List<Widget> _sections(BuildContext context, DeviceView view) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final colors = context.colors;
    final cubit = context.read<DeviceCubit>();
    final device = view.device;
    final enabled = !device.isOffline;
    final switches = device.capabilitiesOf(CapabilityKind.onOff).length;
    final hasThermostat = device.has(CapabilityKind.thermostat);
    final sensorTiles = <Widget>[];
    final sections = <Widget>[];

    for (final capability in device.capabilities) {
      final id = capability.id;
      final pending = view.isPending(id);
      switch (device.state[id]) {
        case OnOffState(:final on):
          final label = capability.displayLabel(l10n);
          sections.add(
            ModeRow(
              key: ValueKey('switch-$id'),
              icon: GlowIcons.power,
              title: switches > 1 && label != null ? label : l10n.detailPower,
              subtitle: on ? l10n.stateOn : l10n.stateOff,
              value: on,
              pending: pending,
              color: deviceActiveColor(colors, device),
              onChanged: enabled
                  ? (value) => cubit.set(id, CapabilityPatch.onOff(on: value))
                  : null,
            ),
          );
        case BrightnessState(:final level):
          sections.add(
            _Draft<int>(
              value: level,
              onCommit: (value) =>
                  cubit.set(id, CapabilityPatch.brightness(level: value)),
              builder: (value, onChanged, onChangeEnd) => _Section(
                title: l10n.detailBrightness,
                value: readings.percent(value),
                pending: pending,
                child: PositionSlider(
                  value: value,
                  step: 1,
                  startLabel: readings.percent(0),
                  endLabel: readings.percent(100),
                  semanticLabel: l10n.detailBrightness,
                  onChanged: enabled ? onChanged : null,
                  onChangeEnd: onChangeEnd,
                ),
              ),
            ),
          );
        case ColorState(:final hue):
          sections.add(
            _Section(
              title: l10n.detailColor,
              pending: pending,
              child: _HueSwatches(
                hue: hue,
                label: l10n.detailColor,
                onSelected: enabled
                    ? (value) => cubit.set(
                        id,
                        CapabilityPatch.color(hue: value, saturation: 85),
                      )
                    : null,
              ),
            ),
          );
        case ColorTemperatureState(:final kelvin):
          final config = capability.colorTemperatureConfig;
          final presets =
              [
                (2700, l10n.tempWarm),
                (4000, l10n.tempNeutral),
                (5500, l10n.tempCool),
                (6500, l10n.tempDaylight),
              ].where(
                (preset) =>
                    config == null ||
                    (preset.$1 >= config.minKelvin &&
                        preset.$1 <= config.maxKelvin),
              );
          sections.add(
            _Section(
              title: l10n.detailColorTemperature,
              pending: pending,
              child: Wrap(
                spacing: GlowSpace.x2,
                runSpacing: GlowSpace.x2,
                children: [
                  for (final (value, label) in presets)
                    GlowChip(
                      label: label,
                      selected: kelvin == value,
                      onTap: enabled
                          ? () => cubit.set(
                              id,
                              CapabilityPatch.colorTemperature(kelvin: value),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          );
        case final PositionState position:
          sections.add(
            _PositionSection(
              capabilityId: id,
              position: position,
              pending: pending,
              enabled: enabled,
            ),
          );
        case final ThermostatState thermostat:
          sections.add(
            _ThermostatSection(
              capability: capability,
              thermostat: thermostat,
              celsius: device.firstState<TemperatureSensorState>()?.celsius,
              pending: pending,
              enabled: enabled,
            ),
          );
        case PowerMeterState(:final watts, :final energyKwh):
          sensorTiles
            ..add(
              _ReadingTile(
                icon: GlowIcons.zap,
                color: colors.power,
                label: l10n.detailLivePower,
                value: readings.watts(watts),
              ),
            )
            ..addAll([
              if (energyKwh != null)
                _ReadingTile(
                  icon: GlowIcons.gauge,
                  label: l10n.detailEnergy,
                  value: readings.energy(energyKwh),
                ),
            ]);
        case LockState(:final locked, :final jammed):
          sections.add(
            ModeRow(
              key: ValueKey('lock-$id'),
              icon: locked ? GlowIcons.lock : GlowIcons.lockOpen,
              title: l10n.detailLock,
              subtitle: jammed
                  ? l10n.stateJammed
                  : (locked ? l10n.stateLocked : l10n.stateUnlocked),
              value: locked,
              pending: pending,
              onChanged: enabled
                  ? (value) =>
                        cubit.set(id, CapabilityPatch.lock(locked: value))
                  : null,
            ),
          );
        case TemperatureSensorState(:final celsius):
          // A thermostat shows the room temperature next to its dial.
          if (!hasThermostat) {
            sensorTiles.add(
              _ReadingTile(
                icon: GlowIcons.thermometer,
                color: colors.heat,
                label: l10n.detailTemperature,
                value: readings.temperature(celsius),
              ),
            );
          }
        case HumiditySensorState(:final percent):
          sensorTiles.add(
            _ReadingTile(
              icon: GlowIcons.droplets,
              color: colors.cool,
              label: l10n.detailHumidity,
              value: readings.percent(percent),
            ),
          );
        case MotionSensorState(:final motion):
          sensorTiles.add(
            _ReadingTile(
              icon: GlowIcons.radar,
              color: motion ? colors.accent : null,
              label: l10n.detailMotion,
              value: motion ? l10n.stateMotion : l10n.stateNoMotion,
            ),
          );
        case ContactSensorState(:final open):
          sensorTiles.add(
            _ReadingTile(
              icon: open ? GlowIcons.doorOpen : GlowIcons.doorClosed,
              color: open ? colors.warning : null,
              label: l10n.detailContact,
              value: open ? l10n.stateOpen : l10n.stateClosed,
            ),
          );
        case CameraState():
          sections.add(const _CameraPlaceholder());
        case null:
          // No state reported yet (or an unknown capability): nothing to show.
          break;
      }
    }

    if (sensorTiles.isNotEmpty) {
      sections.add(
        EqualColumns(
          columns: sensorTiles.length == 1 ? 1 : 2,
          children: sensorTiles,
        ),
      );
    }
    return sections;
  }
}

/// Holds the value being dragged, so a slider follows the finger while only
/// the final value is sent. Falls back to the upstream value as soon as that
/// changes (the optimistic value, a rollback, or a report from the device).
class _Draft<T> extends StatefulWidget {
  const new({
    required this.value,
    required this.onCommit,
    required this.builder,
    super.key,
  });

  final T value;
  final ValueChanged<T> onCommit;
  final Widget Function(
    T value,
    ValueChanged<T> onChanged,
    ValueChanged<T> onChangeEnd,
  )
  builder;

  @override
  State<_Draft<T>> createState() => _DraftState<T>();
}

class _DraftState<T> extends State<_Draft<T>> {
  T? _draft;

  @override
  void didUpdateWidget(_Draft<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _draft = null;
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    _draft ?? widget.value,
    (value) => setState(() => _draft = value),
    (value) {
      setState(() => _draft = value);
      widget.onCommit(value);
    },
  );
}

class _PendingBadge extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x3,
          vertical: GlowSpace.x2,
        ),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: GlowRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowSpinner(size: 12, color: colors.text),
            const SizedBox(width: GlowSpace.x2),
            Text(
              AppLocalizations.of(context).pendingLabel,
              style: context.type.caption.weight(700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const new({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(GlowSpace.x4),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: GlowRadius.tileAll,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: GlowSize.icon, color: colors.textMuted),
          const SizedBox(width: GlowSpace.x3),
          Expanded(child: Text(message, style: context.type.body)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.value,
    this.pending = false,
  });

  final String title;
  final String? value;
  final bool pending;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return GlowCard(
      radius: GlowRadius.tile,
      padding: const EdgeInsets.all(GlowSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: type.body.weight(700))),
              if (pending) ...[
                const GlowSpinner(size: 14),
                const SizedBox(width: GlowSpace.x2),
              ],
              if (value != null)
                Text(value!, style: type.body.numeric.weight(700)),
            ],
          ),
          const SizedBox(height: GlowSpace.x3),
          child,
        ],
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final background = color ?? colors.surfaceAlt;
    return MergeSemantics(
      child: GlowCard(
        radius: GlowRadius.tile,
        padding: const EdgeInsets.all(GlowSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: GlowSize.touch,
              height: GlowSize.touch,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: GlowSize.icon,
                color: color == null ? colors.text : glowOn(background),
              ),
            ),
            const SizedBox(height: GlowSpace.x4),
            Text(label, style: type.caption.copyWith(color: colors.textMuted)),
            const SizedBox(height: GlowSpace.x1),
            Text(value, style: type.heading.numeric),
          ],
        ),
      ),
    );
  }
}

class _HueSwatches extends StatelessWidget {
  const new({required this.hue, required this.label, required this.onSelected});

  final int hue;
  final String label;
  final ValueChanged<int>? onSelected;

  static const List<int> _hues = [0, 28, 50, 120, 180, 210, 270, 320];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: onSelected == null ? 0.5 : 1,
      child: Wrap(
        spacing: GlowSpace.x2,
        runSpacing: GlowSpace.x2,
        children: [
          for (final (index, value) in _hues.indexed)
            GlowPressable(
              onTap: onSelected == null ? null : () => onSelected!(value),
              selected: value == hue,
              semanticLabel: '$label ${index + 1}',
              child: Container(
                width: GlowSize.touch,
                height: GlowSize.touch,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value == hue ? colors.text : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HSVColor.fromAHSV(
                      1,
                      value.toDouble(),
                      0.85,
                      1,
                    ).toColor(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PositionSection extends StatelessWidget {
  const new({
    required this.capabilityId,
    required this.position,
    required this.pending,
    required this.enabled,
  });

  final String capabilityId;
  final PositionState position;
  final bool pending;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final cubit = context.read<DeviceCubit>();
    void moveTo(int target) =>
        cubit.set(capabilityId, CapabilityPatch.position(target: target));

    return _Draft<int>(
      value: position.target,
      onCommit: moveTo,
      builder: (value, onChanged, onChangeEnd) => _Section(
        title: l10n.detailPosition,
        value: readings.percent(position.moving ? position.position : value),
        pending: pending,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PositionSlider(
              value: value,
              // While it travels, show where the curtain really is.
              reportedValue: position.moving ? position.position : null,
              startLabel: l10n.stateClosed,
              endLabel: l10n.stateOpen,
              semanticLabel: l10n.detailPosition,
              onChanged: enabled ? onChanged : null,
              onChangeEnd: onChangeEnd,
            ),
            const SizedBox(height: GlowSpace.x3),
            Wrap(
              spacing: GlowSpace.x2,
              runSpacing: GlowSpace.x2,
              children: [
                GlowChip(
                  label: l10n.actionOpen,
                  onTap: enabled ? () => moveTo(100) : null,
                ),
                GlowChip(
                  label: l10n.actionStop,
                  selected: position.moving,
                  onTap: enabled && position.moving
                      ? () => cubit.set(
                          capabilityId,
                          const CapabilityPatch.position(stop: true),
                        )
                      : null,
                ),
                GlowChip(
                  label: l10n.actionClose,
                  onTap: enabled ? () => moveTo(0) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThermostatSection extends StatelessWidget {
  const new({
    required this.capability,
    required this.thermostat,
    required this.celsius,
    required this.pending,
    required this.enabled,
  });

  final Capability capability;
  final ThermostatState thermostat;
  final double? celsius;
  final bool pending;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readings = Readings(l10n);
    final colors = context.colors;
    final type = context.type;
    final cubit = context.read<DeviceCubit>();
    final config = capability.thermostatConfig;
    final modes = config?.modes ?? ThermostatMode.values;
    final mode = thermostat.mode;
    final running = mode != ThermostatMode.off;
    final celsius = this.celsius;
    final fan = thermostat.fan;

    void setMode(ThermostatMode next) =>
        cubit.set(capability.id, CapabilityPatch.thermostat(mode: next));

    return Column(
      children: [
        GlowCard(
          child: Column(
            children: [
              _Draft<double>(
                value: thermostat.setpoint,
                onCommit: (value) => cubit.set(
                  capability.id,
                  CapabilityPatch.thermostat(setpoint: value),
                ),
                builder: (value, onChanged, onChangeEnd) => TickDial(
                  value: value,
                  min: config?.minSetpoint ?? 16,
                  max: config?.maxSetpoint ?? 30,
                  step: config?.step ?? 0.5,
                  valueLabel: readings.temperature(value),
                  formatValue: readings.temperature,
                  caption: switch (mode) {
                    ThermostatMode.heat => l10n.thermostatHeatingTo,
                    ThermostatMode.cool => l10n.thermostatCoolingTo,
                    ThermostatMode.auto => l10n.thermostatAutoTo,
                    ThermostatMode.off => l10n.thermostatOff,
                  },
                  minLabel: readings.temperature(config?.minSetpoint ?? 16),
                  maxLabel: readings.temperature(config?.maxSetpoint ?? 30),
                  semanticLabel: l10n.detailSetpoint,
                  tone: switch (mode) {
                    ThermostatMode.cool => TickDialTone.cool,
                    ThermostatMode.off => TickDialTone.neutral,
                    _ => TickDialTone.heat,
                  },
                  onChanged: enabled && running ? onChanged : null,
                  onChangeEnd: onChangeEnd,
                ),
              ),
              const SizedBox(height: GlowSpace.x3),
              Wrap(
                spacing: GlowSpace.x2,
                runSpacing: GlowSpace.x2,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (celsius != null)
                    Text(
                      l10n.currentTemperature(readings.temperature(celsius)),
                      style: type.body.numeric.weight(700),
                    ),
                  if (pending) const GlowSpinner(size: 14),
                  if (modes.contains(ThermostatMode.auto))
                    GlowChip(
                      label: l10n.modeAuto,
                      selected: mode == ThermostatMode.auto,
                      onTap: enabled
                          ? () => setMode(
                              mode == ThermostatMode.auto
                                  ? ThermostatMode.heat
                                  : ThermostatMode.auto,
                            )
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: GlowSpace.x3),
        if (modes.contains(ThermostatMode.heat)) ...[
          ModeRow(
            key: const ValueKey('mode-heat'),
            icon: GlowIcons.flame,
            title: l10n.modeHeating,
            value: mode == ThermostatMode.heat,
            pending: pending && mode == ThermostatMode.heat,
            color: colors.heat,
            onChanged: enabled
                ? (on) => setMode(on ? ThermostatMode.heat : ThermostatMode.off)
                : null,
          ),
          const SizedBox(height: GlowSpace.x2),
        ],
        if (modes.contains(ThermostatMode.cool))
          ModeRow(
            key: const ValueKey('mode-cool'),
            icon: GlowIcons.snowflake,
            title: l10n.modeCooling,
            value: mode == ThermostatMode.cool,
            pending: pending && mode == ThermostatMode.cool,
            color: colors.cool,
            onChanged: enabled
                ? (on) => setMode(on ? ThermostatMode.cool : ThermostatMode.off)
                : null,
          ),
        if (fan != null && (config?.fanModes.isNotEmpty ?? false)) ...[
          const SizedBox(height: GlowSpace.x3),
          _Section(
            title: l10n.detailFan,
            child: Wrap(
              spacing: GlowSpace.x2,
              runSpacing: GlowSpace.x2,
              children: [
                for (final option in config!.fanModes)
                  GlowChip(
                    label: switch (option) {
                      FanMode.auto => l10n.fanAuto,
                      FanMode.low => l10n.fanLow,
                      FanMode.medium => l10n.fanMedium,
                      FanMode.high => l10n.fanHigh,
                    },
                    icon: option == fan ? GlowIcons.fan : null,
                    selected: option == fan,
                    onTap: enabled
                        ? () => cubit.set(
                            capability.id,
                            CapabilityPatch.thermostat(fan: option),
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Live view arrives with the camera milestone.
class _CameraPlaceholder extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: colors.inverse,
          borderRadius: GlowRadius.cardAll,
        ),
        padding: const EdgeInsets.all(GlowSpace.x5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(GlowIcons.video, size: 32, color: colors.onInverse),
            const SizedBox(height: GlowSpace.x3),
            Text(
              l10n.cameraSoon,
              textAlign: TextAlign.center,
              style: context.type.body.copyWith(color: colors.onInverse),
            ),
          ],
        ),
      ),
    );
  }
}
