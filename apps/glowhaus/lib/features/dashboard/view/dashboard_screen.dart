import 'package:flutter/material.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Placeholder until the dashboard is built on the repositories.
class DashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GlowSpace.x5),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            AppLocalizations.of(context).navHome,
            style: context.type.display,
          ),
        ),
      ),
    );
  }
}
