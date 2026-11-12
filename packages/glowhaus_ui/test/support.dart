import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Loads the real fonts so text and icons render in tests and goldens.
Future<void> loadGlowFonts() async {
  Future<ByteData> file(String path) async =>
      ByteData.sublistView(File(path).readAsBytesSync());

  await (FontLoader(
    'packages/glowhaus_ui/Manrope',
  )..addFont(file('assets/fonts/Manrope-Variable.ttf'))).load();
  await (FontLoader(
    'packages/glowhaus_ui/Vazirmatn',
  )..addFont(file('assets/fonts/Vazirmatn-Variable.ttf'))).load();
  await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      ))
      .load();
}

/// A themed host for one component.
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  Color? accent,
  bool reduceMotion = false,
  bool center = true,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: GlowhausTheme.build(
      brightness: brightness,
      accent: accent,
      persian: direction == TextDirection.rtl,
      reduceMotion: reduceMotion,
    ),
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: direction, child: app!),
    ),
    home: Scaffold(
      body: center
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(GlowSpace.x4),
                child: child,
              ),
            )
          : child,
    ),
  );
}

extension SurfaceSize on WidgetTester {
  /// Sets the logical window size for this test.
  void useSurface(Size size) {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
  }
}
