
import 'package:flutter/material.dart';

const background = Color(0xFFFEF6E4);      // #fef6e4
const headline = Color(0xFF001858);        // #001858
const paragraph = Color(0xFF172C66);       // #172c66
const buttonColor = Color(0xFFF582AE);     // #f582ae
const buttonText = Color(0xFF001858);      // #001858

const illStroke = Color(0xFF001858);       // #001858
const illMain = Color(0xFFF3D2C1);         // #f3d2c1
const illHighlight = Color(0xFFFEF6E4);    // #fef6e4
const illSecondary = Color(0xFF8BD3DD);    // #8bd3dd
const illTertiary = Color(0xFFF582AE);     // #f582ae

// Semantic status colors
const success = Color(0xFF2E7D32); // green 800
const danger = Color(0xFFD32F2F);  // red 700

final successBg = success.withOpacity(0.12);
final dangerBg = danger.withOpacity(0.12);

final colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: buttonColor,            // cor principal (botões / acentos)
  onPrimary: buttonText,
  secondary: illSecondary,
  onSecondary: headline,
  background: background,
  onBackground: paragraph,
  surface: illMain,
  onSurface: paragraph,
  error: Color(0xFFB00020), 
  onError: Colors.white,
);

final theme = ThemeData.from(colorScheme: colorScheme).copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: background,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: headline,
    elevation: 0,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: headline),
    displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: headline),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: headline),
    bodyLarge: TextStyle(fontSize: 16, color: paragraph, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, color: paragraph, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, color: paragraph.withOpacity(0.9)),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: buttonText),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFFCED4DA))),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: buttonColor,
    foregroundColor: buttonText,
  ),
);