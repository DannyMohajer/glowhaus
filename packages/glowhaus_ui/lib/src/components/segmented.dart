import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// One option of a [GlowSegmented].
@immutable
class GlowSegment<T> {
  const new({required this.value, required this.label, this.icon, this.color});

  final T value;
  final String label;
  final IconData? icon;

  /// Fill while selected, e.g. heat or cool. Defaults to the inverse colour.
  final Color? color;
}

/// Pick exactly one of a few options, all visible at once: equal-width
/// segments in a pill track, each with an optional icon above its label.
///
/// [pending] shows a spinner in the selected segment while a change is in
/// flight. A null [onChanged] disables the control.
class GlowSegmented<T> extends StatelessWidget {
  const new({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.pending = false,
    this.semanticLabel,
    super.key,
  });

  final List<GlowSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool pending;

  /// Names the group for screen readers, e.g. "Mode".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Opacity(
        opacity: onChanged == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.all(GlowSpace.x1),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: GlowRadius.tileAll,
            border: Border.all(color: colors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, segment) in segments.indexed) ...[
                  if (index > 0) const SizedBox(width: GlowSpace.x1),
                  Expanded(
                    child: _Segment(
                      segment: segment,
                      selected: segment.value == selected,
                      pending: pending && segment.value == selected,
                      onTap: onChanged == null
                          ? null
                          : () {
                              if (segment.value != selected) {
                                onChanged(segment.value);
                              }
                            },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const new({
    required this.segment,
    required this.selected,
    required this.pending,
    required this.onTap,
  });

  final GlowSegment<T> segment;
  final bool selected;
  final bool pending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = selected ? segment.color ?? colors.inverse : null;
    final foreground = fill == null
        ? colors.textMuted
        : fill == colors.inverse
        ? colors.onInverse
        : _readableOn(fill);
    final icon = segment.icon;
    return GlowPressable(
      onTap: onTap,
      selected: selected,
      semanticLabel: segment.label,
      borderRadius: const BorderRadius.all(
        Radius.circular(GlowRadius.tile - GlowSpace.x1),
      ),
      child: AnimatedContainer(
        duration: context.motion.toggle,
        curve: context.motion.curve,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x1,
          vertical: GlowSpace.x2,
        ),
        decoration: BoxDecoration(
          color: fill ?? Colors.transparent,
          borderRadius: const BorderRadius.all(
            Radius.circular(GlowRadius.tile - GlowSpace.x1),
          ),
        ),
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (pending)
                SizedBox.square(
                  dimension: GlowSize.icon,
                  child: Center(child: GlowSpinner(color: foreground)),
                )
              else if (icon != null)
                Icon(icon, size: GlowSize.icon, color: foreground),
              if (icon != null || pending) const SizedBox(height: GlowSpace.x1),
              Text(
                segment.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.type.caption
                    .weight(selected ? 700 : 600)
                    .copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Black or white, whichever contrasts more with [fill] (small text sits
/// on it).
Color _readableOn(Color fill) {
  final luminance = fill.computeLuminance();
  final onBlack = (luminance + 0.05) / 0.05;
  final onWhite = 1.05 / (luminance + 0.05);
  return onBlack > onWhite ? const Color(0xFF111111) : const Color(0xFFFFFFFF);
}
