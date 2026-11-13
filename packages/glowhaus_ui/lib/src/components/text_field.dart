import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glowhaus_ui/src/theme/glowhaus_theme.dart';
import 'package:glowhaus_ui/src/tokens/dimens.dart';
import 'package:glowhaus_ui/src/tokens/typography.dart';

/// A labelled single- or multi-line text field.
///
/// The label sits above the field (never inside it), so it stays readable
/// while typing and in every language. [error] replaces [hint] below the
/// field and is announced to screen readers.
class GlowTextField extends StatelessWidget {
  const new({
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.placeholder,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;

  /// Help text under the field.
  final String? hint;

  /// Shown instead of [hint], in the error colour.
  final String? error;

  /// Example value shown while the field is empty.
  final String? placeholder;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;

  /// Host names, ports and certificates read left to right in every locale.
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final error = this.error;
    final hint = this.hint;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: GlowRadius.tileAll,
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: type.caption.weight(600).copyWith(color: colors.textMuted),
          ),
        ),
        const SizedBox(height: GlowSpace.x2),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            maxLines: obscure ? 1 : maxLines,
            minLines: 1,
            enabled: enabled,
            autocorrect: false,
            enableSuggestions: !obscure,
            textDirection: textDirection,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: type.body.copyWith(color: colors.text),
            cursorColor: colors.accent,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: type.body.copyWith(color: colors.textFaint),
              filled: true,
              fillColor: colors.surfaceAlt,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GlowSpace.x4,
                vertical: GlowSpace.x3,
              ),
              border: border(colors.border),
              enabledBorder: border(
                error == null ? colors.border : colors.error,
              ),
              focusedBorder: border(
                error == null ? colors.accent : colors.error,
                2,
              ),
              disabledBorder: border(colors.border),
            ),
          ),
        ),
        if (error != null || hint != null) ...[
          const SizedBox(height: GlowSpace.x1),
          Semantics(
            liveRegion: error != null,
            child: Text(
              error ?? hint!,
              style: type.caption.copyWith(
                color: error == null ? colors.textMuted : colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
