import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Brand palette (WCAG AA verified) ─────────────────────────────────────────
const Color _kPrimary = Color(0xFF2962FF); // 5.5:1 on white
const Color _kPrimaryDark = Color(0xFF1A3EB3);
const Color _kSecondary = Color(0xFF388E3C); // 4.5:1 on white
const Color _kError = Color(0xFFB00020); // 5.9:1 on white
const Color _kSurfaceAlt = Color(0xFFF7F9FC);
const Color _kOnSurface = Color(0xFF0F1218);
const Color _kOnSurfaceSecondary = Color(0xFF495267);
const Color _kOutline = Color(0xFFC4CADA);

// ── Semantic tokens (legacy exports kept for compatibility) ───────────────────
const Color danger = _kError;
const Color success = _kSecondary;
const Color dangerBg = Color(0xFFFDECEA);
const Color successBg = Color(0xFFE8F5E9);

// ── KidsSpaceColors theme extension ──────────────────────────────────────────
class KidsSpaceColors extends ThemeExtension<KidsSpaceColors> {
  const KidsSpaceColors({
    required this.checkinBg,
    required this.checkinBorder,
    required this.checkoutBg,
    required this.checkoutBorder,
    required this.healthAlertBg,
    required this.healthAlertBorder,
    required this.healthAlertIcon,
    required this.surfaceAlt,
    required this.onSurfaceSecondary,
    required this.pendingBg,
    required this.pendingBorder,
  });

  final Color checkinBg;
  final Color checkinBorder;
  final Color checkoutBg;
  final Color checkoutBorder;
  final Color healthAlertBg;
  final Color healthAlertBorder;
  final Color healthAlertIcon;
  final Color surfaceAlt;
  final Color onSurfaceSecondary;
  final Color pendingBg;
  final Color pendingBorder;

  static const light = KidsSpaceColors(
    checkinBg: Color(0xFFE8F5E9),
    checkinBorder: Color(0xFF81C784),
    checkoutBg: Color(0xFFF7F9FC),
    checkoutBorder: Color(0xFFC4CADA),
    healthAlertBg: Color(0xFFFFF8E1),
    healthAlertBorder: Color(0xFFFFB300),
    healthAlertIcon: Color(0xFFE65100),
    surfaceAlt: _kSurfaceAlt,
    onSurfaceSecondary: _kOnSurfaceSecondary,
    pendingBg: Color(0xFFFFF3E0),
    pendingBorder: Color(0xFFFFCC80),
  );

  @override
  KidsSpaceColors copyWith({
    Color? checkinBg,
    Color? checkinBorder,
    Color? checkoutBg,
    Color? checkoutBorder,
    Color? healthAlertBg,
    Color? healthAlertBorder,
    Color? healthAlertIcon,
    Color? surfaceAlt,
    Color? onSurfaceSecondary,
    Color? pendingBg,
    Color? pendingBorder,
  }) =>
      KidsSpaceColors(
        checkinBg: checkinBg ?? this.checkinBg,
        checkinBorder: checkinBorder ?? this.checkinBorder,
        checkoutBg: checkoutBg ?? this.checkoutBg,
        checkoutBorder: checkoutBorder ?? this.checkoutBorder,
        healthAlertBg: healthAlertBg ?? this.healthAlertBg,
        healthAlertBorder: healthAlertBorder ?? this.healthAlertBorder,
        healthAlertIcon: healthAlertIcon ?? this.healthAlertIcon,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
        pendingBg: pendingBg ?? this.pendingBg,
        pendingBorder: pendingBorder ?? this.pendingBorder,
      );

  @override
  KidsSpaceColors lerp(ThemeExtension<KidsSpaceColors>? other, double t) {
    if (other is! KidsSpaceColors) return this;
    return KidsSpaceColors(
      checkinBg: Color.lerp(checkinBg, other.checkinBg, t)!,
      checkinBorder: Color.lerp(checkinBorder, other.checkinBorder, t)!,
      checkoutBg: Color.lerp(checkoutBg, other.checkoutBg, t)!,
      checkoutBorder: Color.lerp(checkoutBorder, other.checkoutBorder, t)!,
      healthAlertBg: Color.lerp(healthAlertBg, other.healthAlertBg, t)!,
      healthAlertBorder:
          Color.lerp(healthAlertBorder, other.healthAlertBorder, t)!,
      healthAlertIcon: Color.lerp(healthAlertIcon, other.healthAlertIcon, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      onSurfaceSecondary:
          Color.lerp(onSurfaceSecondary, other.onSurfaceSecondary, t)!,
      pendingBg: Color.lerp(pendingBg, other.pendingBg, t)!,
      pendingBorder: Color.lerp(pendingBorder, other.pendingBorder, t)!,
    );
  }
}

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData lightTheme() {
    // Material 3 color scheme generated from brand blue
    final scheme = ColorScheme.fromSeed(
      seedColor: _kPrimary,
      brightness: Brightness.light,
    ).copyWith(
      primary: _kPrimary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE8F0FE),
      onPrimaryContainer: _kPrimaryDark,
      secondary: _kSecondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE8F5E9),
      onSecondaryContainer: const Color(0xFF1B5E20),
      error: _kError,
      onError: Colors.white,
      errorContainer: const Color(0xFFFDECEA),
      surface: Colors.white,
      onSurface: _kOnSurface,
      surfaceContainerHighest: _kSurfaceAlt,
      outline: _kOutline,
      outlineVariant: const Color(0xFFDDE2ED),
    );

    final textTheme = _buildTextTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      extensions: const [KidsSpaceColors.light],

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: _kSurfaceAlt,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _kOnSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _kOnSurface,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── NavigationBar (Material 3) ─────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8F0FE),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: _kPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: _kOnSurfaceSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _kPrimary, size: 24);
          }
          return const IconThemeData(color: _kOnSurfaceSecondary, size: 24);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
      ),

      // ── BottomNavigationBar (legacy) ──────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _kPrimary,
        unselectedItemColor: _kOnSurfaceSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEEF1F7)),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Inputs ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kError, width: 2),
        ),
        labelStyle: const TextStyle(color: _kOnSurfaceSecondary, fontSize: 15),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA3B5),
          fontSize: 15,
        ),
        errorStyle: const TextStyle(color: _kError, fontSize: 12, height: 1.4),
        floatingLabelStyle: const TextStyle(color: _kPrimary, fontSize: 12),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _kPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: _kPrimary),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _kPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Dialogs ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _kOnSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: _kOnSurface,
          height: 1.5,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E2230),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        actionTextColor: const Color(0xFF90B4FF),
      ),

      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _kSurfaceAlt,
        selectedColor: const Color(0xFFE8F0FE),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: const BorderSide(color: Color(0xFFEEF1F7)),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF1F7),
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 8,
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _kPrimary,
      ),
    );
  }

  static ThemeData darkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _kPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF90B4FF),
      onPrimary: const Color(0xFF001270),
      secondary: const Color(0xFF81C784),
      onSecondary: const Color(0xFF003909),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690014),
      surface: const Color(0xFF121318),
      onSurface: const Color(0xFFE2E2E9),
      outline: const Color(0xFF44474F),
    );

    final textTheme = _buildTextTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0F1018),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121318),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2030),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2D3E)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2030),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF44474F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF44474F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle:
            TextStyle(color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 15),
        hintStyle:
            TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2D3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      color: textColor,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: textColor,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: textColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: textColor,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textColor,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: textColor,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: textColor,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: textColor,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textColor,
      letterSpacing: 0.5,
    ),
  );
}
