import 'package:flutter/material.dart';

/// AppText: Design system de tipografia com variações prontas.
/// Use `AppText.headerLarge(context)` ou `AppText.bodyMedium()` para obter estilos.
class AppText {
  static Color _color(BuildContext? context) =>
      context != null ? Theme.of(context).colorScheme.onSurface : Colors.black;

  // Headers
  static TextStyle headerLarge([BuildContext? context]) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _color(context),
        height: 1.2,
      );

  static TextStyle headerMedium([BuildContext? context]) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _color(context),
        height: 1.25,
      );

  static TextStyle headerSmall([BuildContext? context]) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _color(context),
        height: 1.3,
      );

  // Titles / subtitles
  static TextStyle title([BuildContext? context]) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _color(context),
      );

  static TextStyle subtitle([BuildContext? context]) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _color(context).withOpacity(0.85),
      );

  // Body
  static TextStyle bodyLarge([BuildContext? context]) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _color(context),
        height: 1.4,
      );

  static TextStyle bodyMedium([BuildContext? context]) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _color(context),
        height: 1.4,
      );

  static TextStyle bodySmall([BuildContext? context]) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _color(context).withOpacity(0.9),
        height: 1.3,
      );

  // Caption / helper
  static TextStyle caption([BuildContext? context]) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: _color(context).withOpacity(0.7),
      );

  // Button text
  static TextStyle button([BuildContext? context]) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
      );
}

/// Usage examples:
/// Text('Título', style: AppText.headerLarge(context))
/// Text('Corpo', style: AppText.bodyMedium())
