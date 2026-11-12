import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// What the app needs to know about where it runs.
@lazySingleton
class AppPlatform {
  const new({@ignoreParam this.isWeb = kIsWeb});

  final bool isWeb;
}
