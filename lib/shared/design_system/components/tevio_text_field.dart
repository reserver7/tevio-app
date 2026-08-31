import 'package:flutter/material.dart';

import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_spacing.dart';

class TevioTextField extends StatelessWidget {
  const TevioTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: TevioSpacing.xs),
          ],
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            focusNode: focusNode,
            readOnly: readOnly,
            enabled: enabled,
            onTap: onTap,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            minLines: obscureText ? 1 : minLines,
            maxLength: maxLength,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              helperText: helperText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              constraints: const BoxConstraints(
                minHeight: TevioDimensions.inputHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
