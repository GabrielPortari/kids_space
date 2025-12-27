import 'package:flutter/material.dart';
import 'package:kids_space/view/design_system/app_theme_colors.dart';

/// AppTextField: campo de texto padronizável e visualmente customizável.
///
/// Principais props visuais: `padding`, `borderRadius`, `fillColor`,
/// `borderColor`, `elevationShadow` e `decoration` (override).
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int? maxLines;

  // Visual customization
  final EdgeInsetsGeometry contentPadding;
  final BorderRadius borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double elevationShadow;
  final BoxDecoration? decoration; // overrides the container decoration

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.elevationShadow = 1.0,
    this.decoration,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = widget.fillColor ?? theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;

    final enabledBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: BorderSide(color: widget.focusedBorderColor ?? theme.colorScheme.primary, width: 2),
    );

    final inputDecoration = InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      contentPadding: widget.contentPadding,
      filled: true,
      fillColor: fill,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
    );

    final TextField field = TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      decoration: inputDecoration.copyWith(
        suffixIcon: widget.suffixIcon ?? (widget.obscureText
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null),
      ),
    );

    if (widget.decoration != null) {
      return Container(decoration: widget.decoration, child: field);
    }

    return Material(
      color: Colors.transparent,
      elevation: widget.elevationShadow,
      shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
      child: field,
    );
  }
}