
import 'package:flutter/material.dart';

// NOTE: this file centralizes theme creation using a seed color.
// The application uses ColorScheme.fromSeed(seedColor: seedColor).
const Color danger = Colors.red;
const Color success = Colors.green;
Color dangerBg = Colors.red.shade100;
Color successBg = Colors.green.shade100;

const Color seedColor = Colors.blue;

class AppTheme {
  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light);
    final base = ThemeData.from(colorScheme: scheme);

    final textTheme = base.textTheme.copyWith(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: scheme.primary, width: 2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: scheme.error)),
    );

    return base.copyWith(
      textTheme: textTheme,
      inputDecorationTheme: inputDecoration,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary)),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
    final base = ThemeData.from(colorScheme: scheme);

    final textTheme = base.textTheme.copyWith(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF111219),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade800)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade800)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: scheme.primary, width: 2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: scheme.error)),
    );

    return base.copyWith(
      textTheme: textTheme,
      inputDecorationTheme: inputDecoration,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary)),
    );
  }
}