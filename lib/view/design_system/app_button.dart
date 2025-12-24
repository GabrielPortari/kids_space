import 'package:flutter/material.dart';

/// AppButton: botão padronizável e focado em aparência.
/// Visuals configuráveis: `padding`, `borderRadius`, `elevation`,
/// `backgroundColor`, `gradient`, `border`, `shadowColor`, `minWidth`, `height`.
class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double elevation;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final Color? shadowColor;
  final double? minWidth;
  final double? height;
  final bool isLoading;
  final Color? splashColor;
  final AlignmentGeometry alignment;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.elevation = 2.0,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.shadowColor,
    this.minWidth,
    this.height,
    this.isLoading = false,
    this.splashColor,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !isLoading;
    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final content = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
            ),
          )
        : child;

    final boxDecoration = BoxDecoration(
      color: gradient == null ? bgColor : null,
      gradient: gradient,
      border: border,
      borderRadius: borderRadius,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: shadowColor ?? Colors.black.withOpacity(0.12),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation / 2),
              )
            ]
          : null,
    );

    Widget button = Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 0, minHeight: height ?? 0),
      decoration: boxDecoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: splashColor ?? (theme.colorScheme.onPrimary.withOpacity(0.08)),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: padding,
            child: SizedBox(
              height: height,
              child: Align(alignment: alignment, child: DefaultTextStyle.merge(style: TextStyle(color: gradient == null ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary), child: content)),
            ),
          ),
        ),
      ),
    );

    if (!enabled) {
      button = Opacity(opacity: 0.6, child: button);
    }

    return button;
  }
}

/// Usage examples:
/// AppButton(child: Text('Salvar'), onPressed: () {})
/// AppButton(gradient: LinearGradient(...), borderRadius: BorderRadius.circular(12), child: Text('Ação'))
