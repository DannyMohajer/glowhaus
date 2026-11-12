import 'package:flutter/widgets.dart';

void main() {
  runApp(const GlowhausApp());
}

/// Placeholder root widget. Replaced when the app shell is built.
class GlowhausApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('Glowhaus')),
    );
  }
}
