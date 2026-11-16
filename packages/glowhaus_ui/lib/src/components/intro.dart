import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glowhaus_ui/src/components/pressable.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// The one photo of the intro screen. Swapping it means replacing
/// `assets/images/intro_home.jpg`; nothing else points at the file.
abstract final class GlowIntroPhoto {
  static const String asset = 'assets/images/intro_home.jpg';

  static const ImageProvider<Object> image = AssetImage(
    asset,
    package: 'glowhaus_ui',
  );
}

/// Proportions of the intro shape: a rounded rectangle on top, a narrow neck,
/// a stadium at the bottom, all one outline cut from one photo.
abstract final class GlowIntroShape {
  /// Share of the height taken by the rounded rectangle.
  static const double topShare = 0.58;

  /// Share of the height taken by the bottom stadium.
  static const double bottomShare = 0.17;

  /// Share of the width taken by the neck between them.
  static const double neckShare = 0.13;

  static const double topRadius = 32;

  /// Radius of the concave fillets where the neck meets top and bottom.
  static const double filletRadius = 36;

  /// How far the start button sits inside the bottom stadium, so the photo
  /// shows as a ring around it.
  static const double buttonInset = 14;

  /// The widest the shape gets; beyond that it is centred.
  static const double maxWidth = 440;
}

/// The first screen: one photo cut into a single shape, a headline over it,
/// the start button inside its foot, and a link under it.
///
/// Knows nothing about routing or storage: it takes strings and callbacks.
class GlowIntroPanel extends StatefulWidget {
  const new({
    required this.title,
    required this.titleRest,
    required this.startLabel,
    required this.onStart,
    required this.footerText,
    required this.linkLabel,
    required this.onLink,
    this.photo = GlowIntroPhoto.image,
    super.key,
  });

  /// First part of the headline, in white.
  final String title;

  /// Second part, at 70% white.
  final String titleRest;

  final String startLabel;
  final VoidCallback onStart;

  /// The muted line under the shape.
  final String footerText;
  final String linkLabel;
  final VoidCallback onLink;

  final ImageProvider<Object> photo;

  @override
  State<GlowIntroPanel> createState() => _GlowIntroPanelState();
}

class _GlowIntroPanelState extends State<GlowIntroPanel>
    with TickerProviderStateMixin {
  /// The slow push-in of the photo.
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  /// Headline first, then the button.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );

  late final Animation<double> _headline = CurvedAnimation(
    parent: _enter,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );

  late final Animation<double> _button = CurvedAnimation(
    parent: _enter,
    curve: const Interval(0.2, 1, curve: Curves.easeOut),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion.reduced) {
      _zoom.value = 1;
      _enter.value = 1;
    } else if (!_enter.isAnimating && _enter.value == 0) {
      _zoom.forward();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _zoom.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final bottom = height * GlowIntroShape.bottomShare;
              return Stack(
                children: [
                  Positioned.fill(child: _Photo(widget.photo, zoom: _zoom)),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height * GlowIntroShape.topShare,
                    child: _Headline(
                      title: widget.title,
                      titleRest: widget.titleRest,
                      animation: _headline,
                    ),
                  ),
                  PositionedDirectional(
                    bottom: GlowIntroShape.buttonInset,
                    start: GlowIntroShape.buttonInset,
                    end: GlowIntroShape.buttonInset,
                    height: math.max(
                      GlowSize.touch,
                      bottom - GlowIntroShape.buttonInset * 2,
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1).animate(_button),
                      child: FadeTransition(
                        opacity: _button,
                        child: _StartButton(
                          label: widget.startLabel,
                          onTap: widget.onStart,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: GlowSpace.x5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.footerText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: type.body.copyWith(color: colors.textMuted),
              ),
            ),
            const SizedBox(width: GlowSpace.x3),
            _LinkPill(label: widget.linkLabel, onTap: widget.onLink),
          ],
        ),
      ],
    );
  }
}

/// The photo, clipped to the intro outline and pushing in from 1.08 to 1.
class _Photo extends StatelessWidget {
  const new(this.image, {required this.zoom});

  final ImageProvider<Object> image;
  final Animation<double> zoom;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const IntroShapeClipper(),
      child: ColoredBox(
        color: context.colors.surfaceAlt,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1.08, end: 1).animate(
                CurvedAnimation(parent: zoom, curve: Curves.easeOutCubic),
              ),
              child: Image(
                image: image,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            // Keeps the white headline readable whatever photo is in place.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0x73000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top left in English and Turkish, top right in Persian.
class _Headline extends StatelessWidget {
  const new({
    required this.title,
    required this.titleRest,
    required this.animation,
  });

  final String title;
  final String titleRest;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final style = context.type.display
        .weight(300)
        .copyWith(fontSize: 44, height: 1.1, color: Colors.white);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          // 12 px up, as a share of the 44 px line.
          begin: const Offset(0, 12 / 44),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Semantics(
              header: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$title '),
                    TextSpan(
                      text: titleRest,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white pill inside the foot of the shape.
class _StartButton extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowPressable(
      onTap: onTap,
      pressedScale: 0.96,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: GlowRadius.pillAll,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GlowSpace.x4),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.heading
                  .weight(700)
                  .copyWith(fontSize: 20, color: const Color(0xFF111111)),
            ),
          ),
        ),
      ),
    );
  }
}

/// The accent pill under the shape.
class _LinkPill extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlowPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: GlowSize.touch),
        padding: const EdgeInsets.symmetric(
          horizontal: GlowSpace.x5,
          vertical: GlowSpace.x2,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.accentStrong,
          borderRadius: GlowRadius.pillAll,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.type.body.weight(700).copyWith(color: colors.onAccent),
        ),
      ),
    );
  }
}

/// The intro outline: a rounded rectangle, a neck and a stadium joined into
/// one path, with concave fillets at both junctions.
///
/// Every fillet is an `r × r` square in the corner with a circle of the same
/// radius cut out of it, so the straight neck runs into the wide parts in a
/// curve instead of a notch.
class IntroShapeClipper extends CustomClipper<Path> {
  const new();

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final topHeight = height * GlowIntroShape.topShare;
    final bottomHeight = height * GlowIntroShape.bottomShare;
    final bottomTop = height - bottomHeight;
    final neckWidth = width * GlowIntroShape.neckShare;
    final neckLeft = (width - neckWidth) / 2;
    final neckRight = neckLeft + neckWidth;

    final top = Path()
      ..addRRect(
        RRect.fromLTRBR(
          0,
          0,
          width,
          topHeight,
          const Radius.circular(GlowIntroShape.topRadius),
        ),
      );
    // Overlaps both ends by a hair so the union has no seam.
    final neck = Path()
      ..addRect(
        Rect.fromLTRB(neckLeft, topHeight - 1, neckRight, bottomTop + 1),
      );
    final bottom = Path()
      ..addRRect(
        RRect.fromLTRBR(
          0,
          bottomTop,
          width,
          height,
          Radius.circular(bottomHeight / 2),
        ),
      );

    var path = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, top, neck),
      bottom,
    );

    final radius = math.min(
      GlowIntroShape.filletRadius,
      math.min((width - neckWidth) / 2, (bottomTop - topHeight) / 2),
    );
    if (radius > 0) {
      // (corner of the junction, which way the fillet curves)
      for (final (corner, towards) in [
        (Offset(neckLeft, topHeight), const Offset(-1, 1)),
        (Offset(neckRight, topHeight), const Offset(1, 1)),
        (Offset(neckLeft, bottomTop), const Offset(-1, -1)),
        (Offset(neckRight, bottomTop), const Offset(1, -1)),
      ]) {
        final centre = corner + towards * radius;
        final square = Rect.fromPoints(corner, centre);
        final fillet = Path.combine(
          PathOperation.difference,
          Path()..addRect(square),
          Path()..addOval(Rect.fromCircle(center: centre, radius: radius)),
        );
        path = Path.combine(PathOperation.union, path, fillet);
      }
    }
    return path;
  }

  @override
  bool shouldReclip(IntroShapeClipper oldClipper) => false;
}
