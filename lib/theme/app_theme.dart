import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Offline-safe theme (no runtime Google Fonts download).
class AppTheme {
  static TextTheme _textTheme(TextTheme base, Color ink) {
    return base.apply(bodyColor: ink, displayColor: ink).copyWith(
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: ink,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: ink,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ink,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        brightness: Brightness.light,
      ),
    );

    return _applyCommon(
      base.copyWith(
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: _textTheme(base.textTheme, AppColors.ink),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: _input(AppColors.surfaceElevated, AppColors.border),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inkMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerColor: AppColors.border,
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const surface = Color(0xFF121A22);
    const elevated = Color(0xFF1B2530);
    const border = Color(0xFF2E3A48);
    const ink = Color(0xFFE8EEF4);
    const muted = Color(0xFF9AA8B5);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: surface,
        error: AppColors.danger,
        brightness: Brightness.dark,
        onSurface: ink,
      ),
    );

    return _applyCommon(
      base.copyWith(
        scaffoldBackgroundColor: surface,
        textTheme: _textTheme(base.textTheme, ink),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: surface,
          foregroundColor: ink,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: elevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: _input(elevated, border, hint: muted),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: elevated,
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: elevated,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: muted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerColor: border,
        dialogTheme: DialogThemeData(
          backgroundColor: elevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

  static InputDecorationTheme _input(Color fill, Color border, {Color? hint}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      hintStyle: TextStyle(color: hint ?? AppColors.inkMuted),
    );
  }

  static ThemeData _applyCommon(ThemeData base) {
    return base.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: base.cardTheme.color,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        side: BorderSide(color: base.dividerColor),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
