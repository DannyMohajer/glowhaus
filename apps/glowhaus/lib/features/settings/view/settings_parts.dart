import 'package:flutter/material.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

// Building blocks shared by the sections of the settings screen.

class SettingsSection extends StatelessWidget {
  const new({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

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

class SettingsLabeled extends StatelessWidget {
  const new({required this.label, required this.child, super.key});

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

class SettingsChoices<T> extends StatelessWidget {
  const new({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.icon,
    super.key,
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

class SettingsSwitchRow extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
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
