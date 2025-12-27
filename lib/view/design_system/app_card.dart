import 'package:flutter/material.dart';
import 'package:kids_space/view/design_system/app_theme_colors.dart';

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

  final VoidCallback? onTap;

  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 6.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      elevation: elevation,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
