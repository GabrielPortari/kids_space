import 'dart:ui';

import 'package:flutter/material.dart';

/// Lightweight AppCard focused on theming and visual effects.
///
/// This simplified version exposes: `decoration`, `gradient`, `color`,
/// `elevation`/`shadowColor`, and an optional `glass` backdrop blur.
class AppCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double elevation;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final BoxDecoration? decoration; // overrides other decoration props
  final Color? shadowColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 6.0,
    this.color,
    this.gradient,
    this.border,
    this.decoration,
    this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius;

    final effectiveElevation = elevation;

    final _decoration = decoration ?? BoxDecoration(
      color: color ?? theme.colorScheme.surface,
      gradient: gradient,
      border: border,
      borderRadius: radius,
      boxShadow: (effectiveElevation) > 0
          ? [
              BoxShadow(
                color: shadowColor ?? theme.colorScheme.shadow.withOpacity(0.25),
                blurRadius: (effectiveElevation) * 1.5,
                spreadRadius: (effectiveElevation) > 0 ? 0.5 : 0,
                offset: Offset(0, (effectiveElevation) / 2),
              )
            ]
          : null,
    );

    Widget card = Container(
      margin: margin,
      decoration: _decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
