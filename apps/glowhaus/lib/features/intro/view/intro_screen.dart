import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/intro/data/link_opener.dart';
import 'package:glowhaus/features/settings/cubit/settings_cubit.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// First screen: one photo, one button, straight into the demo home.
///
/// Every first visit sees it, whatever address it came in at; "Let's start"
/// then goes on to that address ([Routes.nextAfterIntro]). It is shown once
/// — "Show intro again" in settings brings it back — and `#/demo?quiet`,
/// which records the demo, never sees it.
class IntroScreen extends StatelessWidget {
  const new({super.key});

  /// Where "View on GitHub" goes.
  static const String repositoryUrl =
      'https://github.com/DannyMohajer/glowhaus';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: GlowIntroShape.maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GlowSpace.x4,
                GlowSpace.x4,
                GlowSpace.x4,
                GlowSpace.x6,
              ),
              child: GlowIntroPanel(
                title: l10n.introTitle,
                titleRest: l10n.introTitleRest,
                startLabel: l10n.introStart,
                onStart: () {
                  final next = Routes.nextAfterIntro(
                    GoRouterState.of(context).uri,
                  );
                  context.read<SettingsCubit>().introSeen();
                  context.go(next);
                },
                footerText: l10n.introCurious,
                linkLabel: l10n.introGitHub,
                onLink: () => openExternalLink(repositoryUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
