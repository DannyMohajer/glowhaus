import 'package:flutter/widgets.dart';

void main() {
  runApp(const WidgetbookPlaceholder());
}

/// Placeholder. Replaced by the Widgetbook catalog with the design system.
class WidgetbookPlaceholder extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('Glowhaus Widgetbook')),
    );
  }
}
