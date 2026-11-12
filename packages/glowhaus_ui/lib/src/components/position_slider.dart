import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';

/// A wide slider for curtains and blinds, 0 to 100. Mirrors in RTL.
class PositionSlider extends StatelessWidget {
  const new({
    required this.value,
    required this.startLabel,
    required this.endLabel,
    required this.semanticLabel,
    this.reportedValue,
    this.onChanged,
    this.onChangeEnd,
    this.step = 5,
    super.key,
  });

  /// The target, 0 (closed) to 100 (open).
  final int value;

  /// Where the device actually is, shown as a marker while it travels.
  final int? reportedValue;

  /// e.g. "Closed".
  final String startLabel;

  /// e.g. "Open".
  final String endLabel;
  final String semanticLabel;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onChangeEnd;
  final int step;

  static const double _height = 64;

  int _valueAt(double dx, double width, TextDirection direction) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    final raw =
        (direction == TextDirection.rtl ? 1 - fraction : fraction) * 100;
    return ((raw / step).round() * step).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final motion = context.motion;
    final direction = Directionality.of(context);
    final enabled = onChanged != null;
    final reported = reportedValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          slider: true,
          enabled: enabled,
          label: semanticLabel,
          value: '$value%',
          increasedValue: '${(value + step).clamp(0, 100)}%',
          decreasedValue: '${(value - step).clamp(0, 100)}%',
          onIncrease: enabled && value < 100
              ? () {
                  final next = (value + step).clamp(0, 100);
                  onChanged?.call(next);
                  onChangeEnd?.call(next);
                }
              : null,
          onDecrease: enabled && value > 0
              ? () {
                  final next = (value - step).clamp(0, 100);
                  onChanged?.call(next);
                  onChangeEnd?.call(next);
                }
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: enabled
                    ? (d) => onChanged?.call(
                        _valueAt(d.localPosition.dx, width, direction),
                      )
                    : null,
                onHorizontalDragUpdate: enabled
                    ? (d) => onChanged?.call(
                        _valueAt(d.localPosition.dx, width, direction),
                      )
                    : null,
                onHorizontalDragEnd: enabled
                    ? (_) => onChangeEnd?.call(value)
                    : null,
                onTapUp: enabled
                    ? (d) {
                        final next = _valueAt(
                          d.localPosition.dx,
                          width,
                          direction,
                        );
                        onChanged?.call(next);
                        onChangeEnd?.call(next);
                      }
                    : null,
                child: Opacity(
                  opacity: enabled ? 1 : 0.5,
                  child: ClipRRect(
                    borderRadius: GlowRadius.tileAll,
                    child: SizedBox(
                      height: _height,
                      width: width,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(color: colors.surfaceAlt),
                          ),
                          AnimatedPositionedDirectional(
                            duration: motion.tap,
                            curve: motion.curve,
                            start: 0,
                            top: 0,
                            bottom: 0,
                            width: width * value / 100,
                            child: ColoredBox(color: colors.accent),
                          ),
                          // Handle at the edge of the fill.
                          AnimatedPositionedDirectional(
                            duration: motion.tap,
                            curve: motion.curve,
                            start: (width * value / 100 - 14).clamp(
                              8,
                              width - 12,
                            ),
                            top: 18,
                            bottom: 18,
                            width: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: value > 8
                                    ? colors.onAccent
                                    : colors.textMuted,
                                borderRadius: GlowRadius.pillAll,
                              ),
                            ),
                          ),
                          if (reported != null && reported != value)
                            AnimatedPositionedDirectional(
                              duration: motion.toggle,
                              start: (width * reported / 100 - 1).clamp(
                                0,
                                width - 2,
                              ),
                              top: 0,
                              bottom: 0,
                              width: 2,
                              child: ColoredBox(color: colors.text),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: GlowSpace.x2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in [startLabel, endLabel])
              Text(
                label,
                style: type.caption.copyWith(color: colors.textMuted),
              ),
          ],
        ),
      ],
    );
  }
}
