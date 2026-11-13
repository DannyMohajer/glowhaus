import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glowhaus/data/device_repository.dart';
import 'package:glowhaus/features/feedback/app_cubits.dart';
import 'package:glowhaus/features/shared/demo_names.dart';
import 'package:glowhaus/l10n/generated/app_localizations.dart';
import 'package:glowhaus_domain/glowhaus_domain.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';

/// Explains a rolled-back command in plain words.
String feedbackMessage(AppLocalizations l10n, CommandFailure failure) {
  final device = failure.device.displayName(l10n);
  if (failure.unreachable) return l10n.feedbackUnreachable(device);
  if (failure.timedOut) return l10n.feedbackTimedOut(device);
  return failure.code == ProtocolErrorCode.busy
      ? l10n.feedbackBusy(device)
      : l10n.feedbackRejected(device);
}

/// Shows a message whenever a command was rolled back, and a quieter one
/// when a timed-out command turns out to have been applied, on any screen.
class FeedbackListener extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackCubit, FeedbackState>(
      listenWhen: (previous, current) => previous.sequence != current.sequence,
      listener: (context, state) {
        final failure = state.failure;
        final lateApply = state.lateApply;
        if (failure == null && lateApply == null) return;
        final colors = context.colors;
        final l10n = AppLocalizations.of(context);
        final wide = GlowWindowSize.of(context) != GlowWindowSize.compact;
        final (IconData icon, Color iconColor, String message) = failure != null
            ? (
                failure.timedOut || failure.unreachable
                    ? GlowIcons.wifiOff
                    : GlowIcons.triangleAlert,
                colors.warning,
                feedbackMessage(l10n, failure),
              )
            : (
                GlowIcons.check,
                colors.onInverse,
                l10n.feedbackAppliedLate(lateApply!.device.displayName(l10n)),
              );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.inverse,
              elevation: 0,
              width: wide ? 440 : null,
              margin: wide
                  ? null
                  : const EdgeInsets.fromLTRB(
                      GlowSpace.x4,
                      0,
                      GlowSpace.x4,
                      GlowSpace.x2,
                    ),
              shape: const RoundedRectangleBorder(
                borderRadius: GlowRadius.tileAll,
              ),
              duration: Duration(seconds: failure != null ? 5 : 3),
              content: Row(
                children: [
                  Icon(icon, size: GlowSize.icon, color: iconColor),
                  const SizedBox(width: GlowSpace.x3),
                  Expanded(
                    child: Text(
                      message,
                      style: context.type.body.copyWith(
                        color: colors.onInverse,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      },
      child: child,
    );
  }
}
