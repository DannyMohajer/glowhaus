import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

enum TickDialTone { heat, cool, neutral }

/// A thermostat dial made of tick marks. Drag or tap along the arc to set the
/// value; low values sit at the start side, so the dial mirrors in RTL.
class TickDial extends StatelessWidget {
  const new({
    required this.value,
    required this.min,
    required this.max,
    required this.valueLabel,
    required this.minLabel,
    required this.maxLabel,
    required this.semanticLabel,
    this.step = 0.5,
    this.caption,
    this.formatValue,
    this.tone = TickDialTone.heat,
    this.onChanged,
    this.onChangeEnd,
    this.size = 280,
    super.key,
  }) : assert(max > min, 'max must be greater than min'),
       assert(step > 0, 'step must be positive');

  final double value;
  final double min;
  final double max;
  final double step;

  /// The big text in the centre, e.g. "22.5°".
  final String valueLabel;

  /// Small text under the value, e.g. "Heating to".
  final String? caption;
  final String minLabel;
  final String maxLabel;
  final String semanticLabel;

  /// Formats a value for assistive tech ("what would one step up be").
  /// Defaults to one decimal place.
  final String Function(double value)? formatValue;
  final TickDialTone tone;

  /// Called continuously while dragging. Null disables the dial.
  final ValueChanged<double>? onChanged;

  /// Called once when the drag or tap ends: the moment to send a command.
  final ValueChanged<double>? onChangeEnd;
  final double size;

  static const int tickCount = 55;
  static const double _startDegrees = 135;
  static const double _sweepDegrees = 270;

  double get _fraction => ((value - min) / (max - min)).clamp(0, 1);

  double _snap(double raw) {
    final stepped = ((raw - min) / step).round() * step + min;
    return stepped.clamp(min, max);
  }

  double _valueAt(Offset local, double extent, TextDirection direction) {
    var dx = local.dx - extent / 2;
    final dy = local.dy - extent / 2;
    if (direction == TextDirection.rtl) dx = -dx;
    final degrees = (math.atan2(dy, dx) * 180 / math.pi + 360) % 360;
    final relative = (degrees - _startDegrees + 360) % 360;
    final fraction = relative <= _sweepDegrees
        ? relative / _sweepDegrees
        // In the gap at the bottom: stick to the nearer end.
        : (relative - _sweepDegrees < (360 - _sweepDegrees) / 2 ? 1.0 : 0.0);
    return _snap(min + fraction * (max - min));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final direction = Directionality.of(context);
    final enabled = onChanged != null;
    final (Color from, Color to) = switch (tone) {
      TickDialTone.heat => (colors.lamp, colors.heat),
      TickDialTone.cool => (
        Color.lerp(colors.cool, colors.surface, 0.55)!,
        colors.cool,
      ),
      TickDialTone.neutral => (colors.textFaint, colors.textMuted),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = math.min(size, constraints.biggest.shortestSide);
        void update(Offset local) =>
            onChanged?.call(_valueAt(local, extent, direction));
        void end() => onChangeEnd?.call(value);
        String format(double v) => formatValue?.call(v) ?? v.toStringAsFixed(1);

        return Semantics(
          container: true,
          slider: true,
          enabled: enabled,
          label: semanticLabel,
          value: valueLabel,
          increasedValue: format(_snap(value + step)),
          decreasedValue: format(_snap(value - step)),
          onIncrease: enabled && value < max
              ? () {
                  final next = _snap(value + step);
                  onChanged?.call(next);
                  onChangeEnd?.call(next);
                }
              : null,
          onDecrease: enabled && value > min
              ? () {
                  final next = _snap(value - step);
                  onChanged?.call(next);
                  onChangeEnd?.call(next);
                }
              : null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Both axes are claimed so the dial wins over a scroll view.
              onVerticalDragStart: enabled
                  ? (d) => update(d.localPosition)
                  : null,
              onVerticalDragUpdate: enabled
                  ? (d) => update(d.localPosition)
                  : null,
              onVerticalDragEnd: enabled ? (_) => end() : null,
              onHorizontalDragStart: enabled
                  ? (d) => update(d.localPosition)
                  : null,
              onHorizontalDragUpdate: enabled
                  ? (d) => update(d.localPosition)
                  : null,
              onHorizontalDragEnd: enabled ? (_) => end() : null,
              onTapUp: enabled
                  ? (d) {
                      final next = _valueAt(d.localPosition, extent, direction);
                      onChanged?.call(next);
                      onChangeEnd?.call(next);
                    }
                  : null,
              child: SizedBox.square(
                dimension: extent,
                child: CustomPaint(
                  painter: _TickDialPainter(
                    fraction: _fraction,
                    from: from,
                    to: to,
                    idle: colors.border,
                    knob: colors.surface,
                    knobBorder: to,
                    rtl: direction == TextDirection.rtl,
                    enabled: enabled,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            child: Text(
                              valueLabel,
                              textScaler: TextScaler.noScaling,
                              style: type.display.numeric.copyWith(
                                fontSize: extent * 0.2,
                                height: 1.1,
                                color: enabled ? colors.text : colors.textMuted,
                              ),
                            ),
                          ),
                          if (caption != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: extent * 0.5,
                              ),
                              child: Text(
                                caption!,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: type.caption.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      PositionedDirectional(
                        start: extent * 0.14,
                        end: extent * 0.14,
                        bottom: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final label in [minLabel, maxLabel])
                              Text(
                                label,
                                style: type.caption.numeric.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TickDialPainter extends CustomPainter {
  const new({
    required this.fraction,
    required this.from,
    required this.to,
    required this.idle,
    required this.knob,
    required this.knobBorder,
    required this.rtl,
    required this.enabled,
  });

  final double fraction;
  final Color from;
  final Color to;
  final Color idle;
  final Color knob;
  final Color knobBorder;
  final bool rtl;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2 - 2;
    final tickLength = size.shortestSide * 0.06;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2, size.shortestSide * 0.011);

    Offset point(double t, double radius) {
      final degrees = TickDial._startDegrees + TickDial._sweepDegrees * t;
      final radians = degrees * math.pi / 180;
      final dx = math.cos(radians) * radius;
      return center + Offset(rtl ? -dx : dx, math.sin(radians) * radius);
    }

    const last = TickDial.tickCount - 1;
    final activeIndex = (fraction * last).round();
    for (var i = 0; i <= last; i++) {
      final t = i / last;
      final active = enabled && i <= activeIndex;
      final current = enabled && i == activeIndex;
      paint.color = active ? Color.lerp(from, to, t)! : idle;
      canvas.drawLine(
        point(t, outer),
        point(t, outer - tickLength * (current ? 1.6 : 1)),
        paint,
      );
    }

    final knobCenter = point(
      activeIndex / last,
      outer - tickLength * 1.6 - size.shortestSide * 0.055,
    );
    final knobRadius = size.shortestSide * 0.032;
    canvas
      ..drawCircle(knobCenter, knobRadius, Paint()..color = knob)
      ..drawCircle(
        knobCenter,
        knobRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = enabled ? knobBorder : idle,
      );
  }

  @override
  bool shouldRepaint(_TickDialPainter old) =>
      old.fraction != fraction ||
      old.from != from ||
      old.to != to ||
      old.idle != idle ||
      old.knob != knob ||
      old.rtl != rtl ||
      old.enabled != enabled;
}
