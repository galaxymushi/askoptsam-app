import 'package:flutter/material.dart';

enum AppThemeMode { daylight, midnight, amber }

/// Eye identity tokens, taken from the Eye app mockup: deep blue and white.
class EyeColors {
  static const blue = Color(0xFF0B3C91);
  static const blueDeep = Color(0xFF0B2D74);
  static const blueBright = Color(0xFF1A5FD6);
  static const sky = Color(0xFF1F9BE2);
  static const ice = Color(0xFFC9DBFF);
  static const ink = Color(0xFF0A1B3D);
  static const muted = Color(0xFF4A5B7A);
  static const white = Color(0xFFFFFFFF);
  static const error = Color(0xFFB3261E);
  static const navy = Color(0xFF061532);
}

class AppTheme {
  static const sans = 'Poppins';

  static ThemeData build(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.daylight:
        return _base(
          brightness: Brightness.light,
          background: EyeColors.white,
          surface: EyeColors.white,
          primary: EyeColors.blue,
          onPrimary: EyeColors.white,
          text: EyeColors.ink,
          muted: EyeColors.muted,
          outline: EyeColors.blue,
          error: EyeColors.error,
          onError: EyeColors.white,
          appBarBackground: EyeColors.blue,
          appBarForeground: EyeColors.white,
          hintOnBlue: EyeColors.ice,
        );
      case AppThemeMode.midnight:
        return _base(
          brightness: Brightness.dark,
          background: EyeColors.navy,
          surface: const Color(0xFF0C2452),
          primary: const Color(0xFF8FBAFF),
          onPrimary: EyeColors.ink,
          text: EyeColors.white,
          muted: const Color(0xFFC0D0EC),
          outline: const Color(0xFF6E9CE6),
          error: const Color(0xFFFFB4AB),
          onError: const Color(0xFF460A04),
          appBarBackground: const Color(0xFF0C2452),
          appBarForeground: EyeColors.white,
          hintOnBlue: const Color(0xFFD5E3FF),
        );
      case AppThemeMode.amber:
        return _base(
          brightness: Brightness.dark,
          background: const Color(0xFF000000),
          surface: const Color(0xFF121200),
          primary: const Color(0xFFFFE000),
          onPrimary: const Color(0xFF000000),
          text: const Color(0xFFFFFFFF),
          muted: const Color(0xFFE8E8C8),
          outline: const Color(0xFFFFE000),
          error: const Color(0xFFFF8A80),
          onError: const Color(0xFF000000),
          appBarBackground: const Color(0xFF000000),
          appBarForeground: const Color(0xFFFFE000),
          hintOnBlue: const Color(0xFFFFF3A8),
        );
    }
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color text,
    required Color muted,
    required Color outline,
    required Color error,
    required Color onError,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color hintOnBlue,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: const Color(0xFF1F9BE2),
      onSecondary: EyeColors.white,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest:
          brightness == Brightness.light ? const Color(0xFFEAF1FF) : const Color(0xFF123064),
      onSurfaceVariant: muted,
      outline: outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: sans,
    );

    TextStyle textStyle(double size, FontWeight weight,
            {double? height, double? letterSpacing, Color? color}) =>
        TextStyle(
          fontFamily: AppTheme.sans,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? text,
        );

    final textTheme = base.textTheme.copyWith(
      displayLarge: textStyle(60, FontWeight.w800,
          height: 1.0, letterSpacing: -1.2),
      displayMedium: textStyle(48, FontWeight.w800,
          height: 1.04, letterSpacing: -0.8),
      headlineLarge: textStyle(38, FontWeight.w800,
          height: 1.1, letterSpacing: -0.5),
      headlineMedium: textStyle(30, FontWeight.w800, height: 1.15),
      titleLarge: textStyle(26, FontWeight.w700, height: 1.2),
      titleMedium: textStyle(22, FontWeight.w700, height: 1.3),
      bodyLarge: textStyle(22, FontWeight.w500, height: 1.45),
      bodyMedium: textStyle(19, FontWeight.w500, height: 1.5),
      bodySmall: textStyle(16, FontWeight.w500, height: 1.5, color: muted),
      labelLarge: textStyle(20, FontWeight.w700),
      labelMedium: textStyle(15, FontWeight.w600, letterSpacing: 0.4),
    );

    final radius = BorderRadius.circular(18);
    final borderColor = outline.withValues(alpha: 0.85);

    return base.copyWith(
      textTheme: textTheme,
      iconTheme: IconThemeData(color: text, size: 30),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 92,
        leadingWidth: 132,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: appBarForeground,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: appBarForeground, size: 32),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(64, 68),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 3),
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: primary,
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? EyeColors.white
            : const Color(0xFF0C2452),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        labelStyle: TextStyle(
          fontFamily: sans,
          fontSize: 17,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        hintStyle: TextStyle(
          fontFamily: sans,
          fontSize: 18,
          height: 1.2,
          color: muted,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primary, width: 3),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: outline.withValues(alpha: 0.3),
        trackHeight: 10,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
        trackOutlineColor: WidgetStateProperty.all(primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor, width: 3),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.light
            ? EyeColors.blue
            : primary,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: brightness == Brightness.light ? EyeColors.white : onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: borderColor,
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      extensions: <ThemeExtension<dynamic>>[
        EyeSurface(
          onBlue: appBarForeground,
          mutedOnBlue: hintOnBlue,
        ),
      ],
    );
  }
}

/// Colours used on top of the blue cards and headers.
class EyeSurface extends ThemeExtension<EyeSurface> {
  const EyeSurface({required this.onBlue, required this.mutedOnBlue});

  final Color onBlue;
  final Color mutedOnBlue;

  @override
  EyeSurface copyWith({Color? onBlue, Color? mutedOnBlue}) {
    return EyeSurface(
      onBlue: onBlue ?? this.onBlue,
      mutedOnBlue: mutedOnBlue ?? this.mutedOnBlue,
    );
  }

  @override
  EyeSurface lerp(EyeSurface? other, double t) {
    if (other == null) return this;
    return EyeSurface(
      onBlue: Color.lerp(onBlue, other.onBlue, t)!,
      mutedOnBlue: Color.lerp(mutedOnBlue, other.mutedOnBlue, t)!,
    );
  }
}
