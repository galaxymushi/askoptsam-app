import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF0A5FF2);
  static const primaryDeep = Color(0xFF0747C4);
  static const navy = Color(0xFF0B1229);
  static const ink = Color(0xFF111A33);
  static const muted = Color(0xFF6E7B93);
  static const hint = Color(0xFF8A96AD);
  static const page = Color(0xFFFFFFFF);
  static const splash = Color(0xFFE8F0FF);
  static const soft = Color(0xFFEDF3FE);
  static const chip = Color(0xFFF3F7FF);
  static const border = Color(0xFFDDE8FB);
  static const fieldFill = Color(0xFFFFFFFF);
  static const navBorder = Color(0xFFE9EEF9);
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF1F9D61);

  static const darkPage = Color(0xFF08102F);
  static const darkSurface = Color(0xFF101F4E);
  static const darkSurfaceAlt = Color(0xFF102050);
  static const darkBorder = Color(0xFF1E2C55);
  static const darkSoft = Color(0xFF16234C);
  static const darkMuted = Color(0xFF9AA9C8);
  static const darkText = Color(0xFFF4F7FF);
}

class AppTheme {
  AppTheme._();

  static const _font = 'Inter';

  static ThemeData light() => _build(
        brightness: Brightness.light,
        page: AppColors.page,
        text: AppColors.navy,
        muted: AppColors.muted,
        border: AppColors.border,
        fieldFill: AppColors.fieldFill,
        chip: AppColors.chip,
        navBorder: AppColors.navBorder,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        page: AppColors.darkPage,
        text: AppColors.darkText,
        muted: AppColors.darkMuted,
        border: AppColors.darkBorder,
        fieldFill: AppColors.darkSurface,
        chip: AppColors.darkSurface,
        navBorder: AppColors.darkBorder,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color page,
    required Color text,
    required Color muted,
    required Color border,
    required Color fieldFill,
    required Color chip,
    required Color navBorder,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? const Color(0xFF2E6BFF) : AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: page,
      onSurface: text,
      surfaceContainerHighest: chip,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _font,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      splashFactory: InkSparkle.splashFactory,
    );

    TextStyle style(double size, FontWeight weight, Color color,
            {double height = 1.3, double spacing = 0}) =>
        TextStyle(
          fontFamily: _font,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: spacing,
        );

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: style(32, FontWeight.w800, text, height: 1.15, spacing: -0.7),
        headlineLarge: style(32, FontWeight.w800, text, height: 1.15, spacing: -0.6),
        headlineMedium: style(26, FontWeight.w700, text, height: 1.2, spacing: -0.4),
        titleLarge: style(20, FontWeight.w700, text, height: 1.25),
        titleMedium: style(17, FontWeight.w600, text, height: 1.3),
        bodyLarge: style(16, FontWeight.w400, text, height: 1.45),
        bodyMedium: style(15, FontWeight.w400, text, height: 1.45),
        bodySmall: style(13.5, FontWeight.w400, muted, height: 1.4),
        labelLarge: style(16, FontWeight.w600, text),
        labelMedium: style(13, FontWeight.w600, muted, spacing: 0.6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: text,
        titleTextStyle: style(19, FontWeight.w700, text),
      ),
      iconTheme: IconThemeData(color: text, size: 24),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: style(16, FontWeight.w400, AppColors.hint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2E6BFF) : AppColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.navy,
        contentTextStyle: style(14.5, FontWeight.w500, Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? const Color(0xFF2E6BFF) : AppColors.primary,
      ),
    );
  }
}
