import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/basics.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/icons.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// Device faces: a small drawing of the hardware that a person presses the
/// way they would at home, instead of a row of labelled controls.
///
/// Every face takes plain values (on, open, locked) and callbacks. Which
/// face a device gets is decided by the app, from its capabilities.

/// Height of a face drawing inside a card, at its natural size.
const double _faceHeight = 96;

/// Height of a face in a compact card (a phone's devices sheet).
const double glowFaceHeightCompact = 56;

/// How dim an unplugged device's card goes.
const double _offlineOpacity = 0.35;

/// How tall the faces below are drawn.
///
/// The drawings are not redrawn smaller: the same widgets are scaled, so a
/// lamp in a phone's devices sheet is the lamp from the side panel at a
/// different size.
class GlowFaceScale extends InheritedWidget {
  const new({required this.height, required super.child, super.key});

  final double height;

  /// The height faces are drawn at here; [_faceHeight] by default.
  static double heightOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlowFaceScale>()?.height ??
      _faceHeight;

  @override
  bool updateShouldNotify(GlowFaceScale old) => old.height != height;
}

/// One device in the devices panel: its name and a status LED, the drawing
/// of the device (pressed directly), its status line, and the plug button
/// across the bottom edge.
class GlowDeviceCard extends StatelessWidget {
  const new({
    required this.name,
    required this.status,
    required this.face,
    required this.plugLabel,
    required this.plugSemanticLabel,
    required this.onPlug,
    this.online = true,
    this.active = false,
    this.publishTick = 0,
    this.compact = false,
    super.key,
  });

  final String name;
  final String status;

  /// The drawing, usually one of the `Glow…Face` widgets.
  final Widget face;

  /// "Plugged in" or "Unplugged".
  final String plugLabel;
  final String plugSemanticLabel;
  final VoidCallback onPlug;

  /// False while the plug is out: the whole card greys out.
  final bool online;

  /// The device is doing something (a light on, a thermostat heating).
  final bool active;

  /// Any change sends a dot flying off the card: the device published.
  final int publishTick;

  /// The phone card: a smaller face, tighter type, and the plug as an icon
  /// button in the corner instead of a bar across the bottom.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) return _compact(context);
    final colors = context.colors;
    final motion = context.motion;
    final dim = AnimatedOpacity(
      duration: motion.toggle,
      opacity: online ? 1 : _offlineOpacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The card's own name and status are the group's label (below);
          // the drawing and the plug stay buttons of their own.
          ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.body.weight(600),
                  ),
                ),
                const SizedBox(width: GlowSpace.x2),
                StatusDot(
                  tone: online ? StatusTone.success : StatusTone.offline,
                ),
              ],
            ),
          ),
          const SizedBox(height: GlowSpace.x2),
          _Greyed(greyed: !online, child: face),
          const SizedBox(height: GlowSpace.x2),
          ExcludeSemantics(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.caption.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '$name\n$status',
      child: AnimatedContainer(
        duration: motion.toggle,
        curve: motion.curve,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: GlowRadius.tileAll,
          border: Border.all(
            color: active && online ? colors.accent : colors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: GlowRadius.tileAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      GlowSpace.x3,
                      GlowSpace.x3,
                      GlowSpace.x3,
                      GlowSpace.x2,
                    ),
                    child: dim,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(child: _PublishDot(tick: publishTick)),
                  ),
                ],
              ),
              _PlugButton(
                label: plugLabel,
                semanticLabel: plugSemanticLabel,
                pluggedIn: online,
                onTap: onPlug,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The same card on a phone: the face scaled down, the name and status
  /// under it, and the plug as a small button in the card's corner.
  Widget _compact(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '$name\n$status',
      child: AnimatedContainer(
        duration: motion.toggle,
        curve: motion.curve,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: GlowRadius.tileAll,
          border: Border.all(
            color: active && online ? colors.accent : colors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: GlowRadius.tileAll,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(GlowSpace.x2),
                child: AnimatedOpacity(
                  duration: motion.toggle,
                  opacity: online ? 1 : _offlineOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Greyed(
                        greyed: !online,
                        child: GlowFaceScale(
                          height: glowFaceHeightCompact,
                          child: face,
                        ),
                      ),
                      const SizedBox(height: GlowSpace.x2),
                      ExcludeSemantics(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.caption.weight(700),
                        ),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.caption.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(child: _PublishDot(tick: publishTick)),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: _PlugIconButton(
                  semanticLabel: plugSemanticLabel,
                  pluggedIn: online,
                  onTap: onPlug,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The plug on a compact card: a small button in the corner. Out, the plug
/// tilts and goes accent, as it does on the full card's plug bar.
class _PlugIconButton extends StatelessWidget {
  const new({
    required this.semanticLabel,
    required this.pluggedIn,
    required this.onTap,
  });

  final String semanticLabel;
  final bool pluggedIn;
  final VoidCallback onTap;

  /// The disc; the button around it keeps a full touch target.
  static const double _disc = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return Tooltip(
      message: semanticLabel,
      excludeFromSemantics: true,
      child: GlowPressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: SizedBox(
          width: GlowSize.touch,
          height: GlowSize.touch,
          child: Center(
            child: AnimatedContainer(
              duration: motion.toggle,
              curve: motion.curve,
              width: _disc,
              height: _disc,
              decoration: BoxDecoration(
                color: pluggedIn ? colors.surfaceAlt : colors.accentSoft,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: AnimatedRotation(
                duration: motion.toggle,
                curve: motion.curve,
                turns: pluggedIn ? 0 : 0.07,
                child: Icon(
                  GlowIcons.plug,
                  size: 14,
                  color: pluggedIn ? colors.textMuted : colors.accentStrong,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unplugged devices lose their colour as well as their brightness.
class _Greyed extends StatelessWidget {
  const new({required this.greyed, required this.child});

  final bool greyed;
  final Widget child;

  @override
  Widget build(BuildContext context) => greyed
      ? ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0.2126, 0.7152, 0.0722, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          child: child,
        )
      : child;
}

/// The plug across the card's bottom edge: out takes the device off the
/// network, in brings it back.
class _PlugButton extends StatelessWidget {
  const new({
    required this.label,
    required this.semanticLabel,
    required this.pluggedIn,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool pluggedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return GlowPressable(
      onTap: onTap,
      // A button, not a switch: its label says what pressing it does
      // ("Unplug the ceiling light", "Plug it back in").
      semanticLabel: semanticLabel,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(GlowRadius.tile),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x2,
          vertical: GlowSpace.x2,
        ),
        decoration: BoxDecoration(
          color: pluggedIn ? colors.surfaceAlt : colors.accentSoft,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulled out: the plug hangs down and tilts.
              AnimatedSlide(
                duration: motion.toggle,
                curve: motion.curve,
                offset: pluggedIn ? Offset.zero : const Offset(0, 0.2),
                child: AnimatedRotation(
                  duration: motion.toggle,
                  curve: motion.curve,
                  turns: pluggedIn ? 0 : 0.07,
                  child: Icon(
                    GlowIcons.plug,
                    size: 15,
                    color: pluggedIn ? colors.textMuted : colors.accentStrong,
                  ),
                ),
              ),
              const SizedBox(width: GlowSpace.x2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.caption
                      .weight(600)
                      .copyWith(
                        color: pluggedIn
                            ? colors.textMuted
                            : colors.accentStrong,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dot that leaves the card every time the device publishes.
class _PublishDot extends StatefulWidget {
  const new({required this.tick});

  final int tick;

  @override
  State<_PublishDot> createState() => _PublishDotState();
}

class _PublishDotState extends State<_PublishDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didUpdateWidget(_PublishDot old) {
    super.didUpdateWidget(old);
    if (old.tick != widget.tick &&
        widget.tick != 0 &&
        !context.motion.reduced) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        if (t == 0 || t == 1) return const SizedBox.shrink();
        return Align(
          alignment: Alignment(0, 1 - 2.4 * t),
          child: Opacity(
            opacity: 1 - t,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The frame every face is drawn in. Pressable faces take [onTap]; sensors
/// leave it null and are read-only.
class GlowFaceFrame extends StatelessWidget {
  const new({
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.decorative = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// False when the drawing holds its own controls (a plate of rockers):
  /// the frame itself is then not a button, but what is inside it still is.
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      height: _faceHeight,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
    final face = onTap == null && semanticLabel == null
        ? (decorative ? ExcludeSemantics(child: body) : body)
        : GlowPressable(
            onTap: onTap,
            semanticLabel: semanticLabel,
            pressedScale: 0.96,
            borderRadius: BorderRadius.circular(14),
            child: body,
          );
    return _Scaled(child: face);
  }
}

/// Draws its child at the height [GlowFaceScale] asks for: the drawing is
/// laid out at its natural size and scaled, so nothing inside has to know.
class _Scaled extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = GlowFaceScale.heightOf(context);
    if (height == _faceHeight) return child;
    final scale = height / _faceHeight;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The drawing is laid out at its full size — an OverflowBox, so
          // the smaller box it goes in does not squeeze it — and scaled
          // from the corner it starts in, which is the end in Persian.
          final corner = AlignmentDirectional.topStart.resolve(
            Directionality.of(context),
          );
          final width = constraints.maxWidth / scale;
          return ClipRect(
            child: OverflowBox(
              alignment: corner,
              minWidth: width,
              maxWidth: width,
              minHeight: _faceHeight,
              maxHeight: _faceHeight,
              child: Transform.scale(
                scale: scale,
                alignment: corner,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A lamp: the bulb lights up and a cone of light fades in.
class GlowLightFace extends StatelessWidget {
  const new({required this.on, this.onTap, this.semanticLabel, super.key});

  final bool on;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 22,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: on ? 0.3 : 0,
              child: SizedBox(
                width: 150,
                height: 74,
                child: CustomPaint(painter: _ConePainter(colors.lamp)),
              ),
            ),
          ),
          Container(width: 2, height: 14, color: colors.border),
          Positioned(
            top: 12,
            child: AnimatedContainer(
              duration: motion.toggle,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: on ? colors.lamp : colors.border,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConePainter extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.43, 0)
      ..lineTo(size.width * 0.57, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ConePainter old) => old.color != color;
}

/// Two curtain panels over a window, sliding open and closed.
class GlowCurtainFace extends StatelessWidget {
  const new({
    required this.openPercent,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// 0 closed, 100 fully open.
  final int openPercent;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Fully open leaves a hand's width of fabric at each side.
    final share = 0.42 - 0.3 * (openPercent.clamp(0, 100) / 100);
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              Positioned(
                left: width * 0.2,
                right: width * 0.2,
                top: 16,
                bottom: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.cool.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: width * 0.08,
                right: width * 0.08,
                top: 10,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              for (final left in [true, false])
                Positioned(
                  left: left ? width * 0.08 : null,
                  right: left ? null : width * 0.08,
                  top: 14,
                  bottom: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                    width: width * share,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.border),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A thermostat dial. The ring breathes while the device is heating or
/// cooling, and rests when it is idle or off.
class GlowThermostatFace extends StatefulWidget {
  const new({
    required this.reading,
    required this.running,
    this.cooling = false,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// What the dial shows, e.g. "22.5°".
  final String reading;

  /// Heating or cooling right now.
  final bool running;
  final bool cooling;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<GlowThermostatFace> createState() => _GlowThermostatFaceState();
}

class _GlowThermostatFaceState extends State<GlowThermostatFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(GlowThermostatFace old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.running && !context.motion.reduced) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final running = widget.running;
    final hot = widget.cooling ? colors.cool : colors.heat;
    return GlowFaceFrame(
      onTap: widget.onTap,
      semanticLabel: widget.semanticLabel,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: running
                    ? Color.lerp(
                        hot,
                        hot.withValues(alpha: 0.35),
                        _pulse.value,
                      )!
                    : colors.border,
                width: 4,
              ),
            ),
            child: child,
          ),
          child: Text(
            widget.reading,
            maxLines: 1,
            style: context.type.heading.numeric.weight(600),
          ),
        ),
      ),
    );
  }
}

/// A wall plate with rockers; each one is pressed on its own.
class GlowSwitchFace extends StatelessWidget {
  const new({
    required this.gangs,
    required this.labelOf,
    this.onPress,
    super.key,
  });

  /// One entry per channel: on or off.
  final List<bool> gangs;

  /// The accessible label of the rocker at that index.
  final String Function(int index) labelOf;

  /// Null while the device has no power.
  final void Function(int index)? onPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return GlowFaceFrame(
      decorative: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(GlowSpace.x2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, on) in gangs.indexed) ...[
                if (index > 0) const SizedBox(width: GlowSpace.x2),
                GlowPressable(
                  onTap: onPress == null ? null : () => onPress!(index),
                  semanticLabel: labelOf(index),
                  toggled: on,
                  pressedScale: 0.96,
                  borderRadius: BorderRadius.circular(7),
                  child: AnimatedContainer(
                    duration: motion.toggle,
                    curve: motion.curve,
                    width: 22,
                    height: 56,
                    transform: Matrix4.identity()
                      ..setEntry(3, 1, on ? 0.004 : -0.004)
                      ..rotateX(on ? 0.26 : -0.26),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? colors.accent : colors.surfaceAlt,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: colors.border),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A door lock: the bolt slides out when it is locked.
class GlowLockFace extends StatelessWidget {
  const new({required this.locked, this.onTap, this.semanticLabel, super.key});

  final bool locked;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centre = constraints.maxWidth / 2;
          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: centre + (locked ? 24 : 8),
                child: Container(
                  width: 32,
                  height: 12,
                  decoration: BoxDecoration(
                    color: locked ? colors.accent : colors.offline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors.text,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A doorbell camera: a lens, a blinking recording dot, and a ripple every
/// time the bell is pressed.
class GlowCameraFace extends StatefulWidget {
  const new({
    required this.ringTick,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// Any change rings the bell: one ripple.
  final int ringTick;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<GlowCameraFace> createState() => _GlowCameraFaceState();
}

class _GlowCameraFaceState extends State<GlowCameraFace>
    with TickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _rec = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion.reduced) {
      _rec
        ..stop()
        ..value = 1;
    } else if (!_rec.isAnimating) {
      _rec.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowCameraFace old) {
    super.didUpdateWidget(old);
    if (old.ringTick != widget.ringTick && !context.motion.reduced) {
      _ripple.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    _rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowFaceFrame(
      onTap: widget.onTap,
      semanticLabel: widget.semanticLabel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ripple,
            builder: (context, _) {
              final t = _ripple.value;
              if (t == 0 || t == 1) return const SizedBox.shrink();
              return Container(
                width: 56 + 90 * t,
                height: 56 + 90 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 1 - t),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border, width: 7),
            ),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors.cool,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.2).animate(_rec),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A smart plug: a socket with an LED under it.
class GlowPlugFace extends StatelessWidget {
  const new({required this.on, this.onTap, this.semanticLabel, super.key});

  final bool on;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: GlowSpace.x3),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.text,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: GlowSpace.x2),
          AnimatedContainer(
            duration: motion.toggle,
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: on ? colors.power : colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A contact sensor on a door: the two halves part when the door opens.
class GlowDoorFace extends StatelessWidget {
  const new({required this.open, this.onTap, this.semanticLabel, super.key});

  final bool open;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          width: open ? 70 : 50,
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 2; i++)
                Container(
                  width: 20,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: open ? colors.warning : colors.border,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A climate sensor: a small LCD with its two readings.
class GlowClimateFace extends StatelessWidget {
  const new({required this.temperature, required this.humidity, super.key});

  final String temperature;
  final String humidity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lcd = colors.isDark
        ? const Color(0xFF0B120C)
        : const Color(0xFF12201A);
    const reading = Color(0xFF7BD88F);
    return GlowFaceFrame(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GlowSpace.x4,
            vertical: GlowSpace.x2,
          ),
          decoration: BoxDecoration(
            color: lcd,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                temperature,
                maxLines: 1,
                style: context.type.title.numeric.copyWith(color: reading),
              ),
              Text(
                humidity,
                maxLines: 1,
                style: context.type.caption.numeric.copyWith(
                  color: reading.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A leak sensor: a droplet, blue while it is dry, red when it is not.
class GlowLeakFace extends StatelessWidget {
  const new({required this.wet, this.onTap, this.semanticLabel, super.key});

  final bool wet;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Center(
        child: AnimatedScale(
          duration: context.motion.toggle,
          scale: wet ? 1.15 : 1,
          child: Icon(
            GlowIcons.droplets,
            size: 40,
            // Wet reads as the accent, the colour the panel gives to a
            // device that wants a look.
            color: wet ? colors.accent : colors.cool,
          ),
        ),
      ),
    );
  }
}

/// A motion sensor: arcs that light up when it sees someone.
class GlowMotionFace extends StatelessWidget {
  const new({required this.motion, this.onTap, this.semanticLabel, super.key});

  final bool motion;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowFaceFrame(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Center(
        child: AnimatedContainer(
          duration: context.motion.toggle,
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: motion
                ? colors.accent.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          child: Icon(
            GlowIcons.radar,
            size: 36,
            color: motion ? colors.accent : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
