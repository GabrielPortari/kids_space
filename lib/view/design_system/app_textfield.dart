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
    final fill = widget.fillColor ?? theme.colorScheme.surface;
    final borderClr = widget.borderColor ?? AppColors.outline;
    final focusedClr = widget.focusedBorderColor ?? theme.colorScheme.primary;

    final border = OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: BorderSide(color: borderClr),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius,
      borderSide: BorderSide(color: focusedClr, width: 2),
    );

    final field = TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: fill,
        contentPadding: widget.contentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
      ),
    );

    final effectiveDecoration = widget.decoration ?? BoxDecoration(
      color: Colors.transparent,
      borderRadius: widget.borderRadius,
      boxShadow: widget.elevationShadow > 0
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: widget.elevationShadow * 2,
                offset: Offset(0, widget.elevationShadow / 2),
              )
            ]
          : null,
    );

    return Container(
      decoration: effectiveDecoration,
      child: field,
    );
  }
}