import 'package:flutter/widgets.dart';

/// Spacing on a 4-pt grid.
abstract final class GlowSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
}

abstract final class GlowRadius {
  static const double card = 28;
  static const double tile = 20;
  static const double pill = 999;

  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius tileAll = BorderRadius.all(Radius.circular(tile));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class GlowSize {
  /// Minimum touch target and the diameter of round icon buttons.
  static const double touch = 44;
  static const double icon = 20;
  static const double iconLarge = 24;
}

/// Window width classes used by adaptive layouts.
enum GlowWindowSize {
  /// Phones: bottom navigation, one pane.
  compact,

  /// Small tablets, split windows: side rail, two panes.
  medium,

  /// Tablets in landscape, desktop: side rail, three panes.
  expanded;

  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 1000;

  static GlowWindowSize fromWidth(double width) => width >= expandedMinWidth
      ? expanded
      : width >= mediumMinWidth
      ? medium
      : compact;

  static GlowWindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  int get maxPanes => index + 1;
}
