import 'package:flutter/material.dart';
import 'package:glowhaus/app/app_shell.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// First screen: one message, one button, straight into the demo home.
class WelcomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(GlowSpace.x6),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - GlowSpace.x6 * 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const GlowLogoMark(size: 56),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: GlowSpace.x10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _WelcomeArt(),
                            const SizedBox(height: GlowSpace.x10),
                            Semantics(
                              header: true,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: '${l10n.welcomeTitle}\n'),
                                    TextSpan(
                                      text: l10n.welcomeTitleAccent,
                                      style: TextStyle(color: colors.accent),
                                    ),
                                  ],
                                ),
                                style: type.display,
                              ),
                            ),
                            const SizedBox(height: GlowSpace.x4),
                            Text(
                              l10n.welcomeSubtitle,
                              style: type.body.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlowButton(
                        label: l10n.welcomeStart,
                        icon: rtl ? GlowIcons.arrowLeft : GlowIcons.arrowRight,
                        expand: true,
                        onTap: () => context.go(Routes.home),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small composition of device discs, purely decorative.
class _WelcomeArt extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget disc(IconData icon, Color background, {double size = 64}) =>
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: size * 0.4, color: glowOn(background)),
        );
    return ExcludeSemantics(
      child: Wrap(
        spacing: GlowSpace.x3,
        runSpacing: GlowSpace.x3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          disc(GlowIcons.lightbulb, colors.lamp, size: 88),
          disc(GlowIcons.thermometer, colors.surface),
          disc(GlowIcons.lock, colors.inverse, size: 72),
          disc(GlowIcons.blinds, colors.cool),
          disc(GlowIcons.plug, colors.power, size: 56),
        ],
      ),
    );
  }
}
