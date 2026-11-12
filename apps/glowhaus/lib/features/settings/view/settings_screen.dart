import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/features/settings/cubit/settings_state.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

class SettingsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SettingsCubit>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      bottom: false,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                GlowSpace.x5,
                GlowSpace.x5,
                GlowSpace.x5,
                GlowSpace.x5 + bottomInset,
              ),
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.settingsTitle, style: context.type.display),
                ),
                const SizedBox(height: GlowSpace.x6),
                _Section(
                  title: l10n.settingsAppearance,
                  children: [
                    _Labeled(
                      label: l10n.settingsTheme,
                      child: _Choices<ThemeMode>(
                        values: const [
                          ThemeMode.light,
                          ThemeMode.dark,
                          ThemeMode.system,
                        ],
                        selected: state.themeMode,
                        label: (mode) => switch (mode) {
                          ThemeMode.light => l10n.themeLight,
                          ThemeMode.dark => l10n.themeDark,
                          ThemeMode.system => l10n.themeSystem,
                        },
                        icon: (mode) => switch (mode) {
                          ThemeMode.light => GlowIcons.sun,
                          ThemeMode.dark => GlowIcons.moon,
                          ThemeMode.system => GlowIcons.monitor,
                        },
                        onSelected: cubit.setThemeMode,
                      ),
                    ),
                    _Labeled(
                      label: l10n.settingsAccent,
                      child: Wrap(
                        spacing: GlowSpace.x3,
                        runSpacing: GlowSpace.x2,
                        children: [
                          for (final accent in AccentChoice.values)
                            _AccentSwatch(
                              accent: accent,
                              label: switch (accent) {
                                AccentChoice.orange => l10n.accentOrange,
                                AccentChoice.blue => l10n.accentBlue,
                                AccentChoice.green => l10n.accentGreen,
                                AccentChoice.violet => l10n.accentViolet,
                                AccentChoice.rose => l10n.accentRose,
                              },
                              selected: accent == state.accent,
                              onTap: () => cubit.setAccent(accent),
                            ),
                        ],
                      ),
                    ),
                    _Labeled(
                      label: l10n.settingsLanguage,
                      child: _Choices<AppLanguage>(
                        values: AppLanguage.values,
                        selected: state.language,
                        label: (language) => switch (language) {
                          AppLanguage.en => l10n.languageEnglish,
                          AppLanguage.fa => l10n.languagePersian,
                          AppLanguage.tr => l10n.languageTurkish,
                        },
                        onSelected: cubit.setLanguage,
                      ),
                    ),
                    _SwitchRow(
                      title: l10n.settingsReduceMotion,
                      subtitle: l10n.settingsReduceMotionHint,
                      value: state.reduceMotion,
                      onChanged: (value) =>
                          cubit.setReduceMotion(enabled: value),
                    ),
                    if (cubit.welcomeToggleAvailable)
                      _SwitchRow(
                        title: l10n.settingsShowWelcome,
                        subtitle: l10n.settingsShowWelcomeHint,
                        value: state.showWelcome,
                        onChanged: (value) =>
                            cubit.setShowWelcome(enabled: value),
                      ),
                  ],
                ),
                if (cubit.simulationAvailable) ...[
                  const SizedBox(height: GlowSpace.x4),
                  _Section(
                    title: l10n.settingsSimulation,
                    subtitle: l10n.settingsSimulationHint,
                    children: [
                      _SliderRow(
                        label: l10n.settingsLatency,
                        valueLabel: l10n.settingsLatencyValue(state.latencyMs),
                        value: state.latencyMs.toDouble(),
                        max: SettingsState.maxLatencyMs.toDouble(),
                        divisions: SettingsState.maxLatencyMs ~/ 50,
                        onChanged: (value) => cubit.setLatency(value.round()),
                      ),
                      _SliderRow(
                        label: l10n.settingsFailureRate,
                        hint: l10n.settingsFailureRateHint,
                        valueLabel: l10n.percentValue(
                          (state.failureRate * 100).round(),
                        ),
                        value: state.failureRate,
                        max: SettingsState.maxFailureRate,
                        divisions: 10,
                        onChanged: cubit.setFailureRate,
                      ),
                    ],
                  ),
                ],
                // Room for the floating bottom navigation on phones.
                const SizedBox(height: GlowSpace.x10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.title, required this.children, this.subtitle});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.type.heading),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: GlowSpace.x1),
            Text(
              subtitle!,
              style: context.type.caption.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
          for (final child in children) ...[
            const SizedBox(height: GlowSpace.x5),
            child,
          ],
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const new({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.type.caption
              .weight(600)
              .copyWith(color: context.colors.textMuted),
        ),
        const SizedBox(height: GlowSpace.x2),
        child,
      ],
    );
  }
}

class _Choices<T> extends StatelessWidget {
  const new({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.icon,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final IconData Function(T value)? icon;
  final void Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: GlowSpace.x2,
      runSpacing: GlowSpace.x2,
      children: [
        for (final value in values)
          GlowChip(
            label: label(value),
            icon: icon?.call(value),
            selected: value == selected,
            onTap: () => onSelected(value),
          ),
      ],
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const new({
    required this.accent,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AccentChoice accent;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color =
        accent.color ??
        (colors.isDark
            ? GlowhausColors.defaultAccentDark
            : GlowhausColors.defaultAccentLight);
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: GlowPressable(
        onTap: onTap,
        selected: selected,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: context.motion.toggle,
          width: GlowSize.touch,
          height: GlowSize.touch,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.text : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: selected
                ? Icon(GlowIcons.check, size: 18, color: colors.onAccent)
                : null,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Text(title, style: context.type.body.weight(600)),
              ),
              Text(
                subtitle,
                style: context.type.caption.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: GlowSpace.x3),
        ToggleSwitch(value: value, onChanged: onChanged, semanticLabel: title),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const new({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final String valueLabel;
  final double value;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: type.body.weight(600))),
            Text(valueLabel, style: type.body.numeric.weight(700)),
          ],
        ),
        if (hint != null)
          Text(hint!, style: type.caption.copyWith(color: colors.textMuted)),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: colors.accent,
            inactiveTrackColor: colors.surfaceAlt,
            thumbColor: colors.accent,
            overlayColor: colors.accent.withValues(alpha: 0.12),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: GlowSpace.x3),
          ),
          child: Slider(
            value: value.clamp(0, max),
            max: max,
            divisions: divisions,
            semanticFormatterCallback: (_) => valueLabel,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
