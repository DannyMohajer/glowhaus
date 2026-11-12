import 'package:flutter/material.dart';

/// Motion tokens. With [reduced] every duration collapses to zero.
@immutable
class GlowhausMotion extends ThemeExtension<GlowhausMotion> {
  const new({this.reduced = false});

  final bool reduced;

  /// Press feedback.
  Duration get tap => _of(150);

  /// Switches, selection changes.
  Duration get toggle => _of(250);

  /// Pages and panels.
  Duration get page => _of(400);

  Curve get curve => Curves.easeOutCubic;

  Duration _of(int milliseconds) =>
      reduced ? Duration.zero : Duration(milliseconds: milliseconds);

  @override
  GlowhausMotion copyWith({bool? reduced}) =>
      GlowhausMotion(reduced: reduced ?? this.reduced);

  @override
  GlowhausMotion lerp(GlowhausMotion? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
