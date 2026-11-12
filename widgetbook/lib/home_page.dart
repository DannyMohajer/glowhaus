import 'package:flutter/material.dart';

/// Start page of the catalog. Replaces Widgetbook's default page, which uses
/// emoji (no emoji font is bundled) and promotes Widgetbook's hosted services.
class CatalogHomePage extends StatelessWidget {
  const new({super.key});

  static const List<(IconData, String, String)> _hints = [
    (
      Icons.view_list_outlined,
      'Components',
      'Pick a component from the navigation. Every component has at least '
          'one use case.',
    ),
    (
      Icons.tune,
      'Addons',
      'Switch light and dark theme, English, Persian (right to left) and '
          'Turkish, and text scale.',
    ),
    (
      Icons.toggle_on_outlined,
      'Knobs',
      'Change the inputs of the selected use case: states, labels, accent '
          'colour, reduced motion.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Glowhaus design system',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tokens, themes and components of the Glowhaus smart home '
                'app. Components know nothing about devices: they take '
                'strings, icons and callbacks.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              for (final (icon, title, body) in _hints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.titleSmall),
                            const SizedBox(height: 2),
                            Text(body, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
