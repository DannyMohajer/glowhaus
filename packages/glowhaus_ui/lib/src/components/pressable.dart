import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';

/// Tap target with press feedback, keyboard activation, a focus ring and
/// button semantics. The building block of every interactive component.
class GlowPressable extends StatefulWidget {
  const new({
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.borderRadius = GlowRadius.pillAll,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;
  final BorderRadius borderRadius;

  @override
  State<GlowPressable> createState() => _GlowPressableState();
}

class _GlowPressableState extends State<GlowPressable> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final motion = context.motion;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      selected: widget.selected,
      toggled: widget.toggled,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onTap?.call(),
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: motion.tap,
            curve: motion.curve,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: _focused
                    ? Border.all(color: context.colors.accent, width: 2)
                    : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A small indeterminate progress ring. Static when motion is reduced.
class GlowSpinner extends StatefulWidget {
  const new({this.size = 16, this.color, this.strokeWidth = 2, super.key});

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  State<GlowSpinner> createState() => _GlowSpinnerState();
}

class _GlowSpinnerState extends State<GlowSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion.reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          painter: _SpinnerPainter(
            color: widget.color ?? context.colors.textMuted,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const new({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      (Offset.zero & size).deflate(strokeWidth / 2),
      0,
      4.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// The one soft shadow, for floating elements in the light theme only.
List<BoxShadow> glowFloatingShadow(BuildContext context) =>
    context.colors.isDark
    ? const []
    : const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

/// Black on light colours, white on dark ones.
Color glowOn(Color background) => background.computeLuminance() > 0.55
    ? const Color(0xFF111111)
    : const Color(0xFFFFFFFF);
