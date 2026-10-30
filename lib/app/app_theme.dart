import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    background: Colors.white,
    surface: const Color(0xFFF4F4F5),
    foreground: const Color(0xFF0B0B0C),
    secondary: const Color(0xFF6B6B72),
    border: const Color(0xFFE4E4E7),
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    background: const Color(0xFF0B0B0C),
    surface: const Color(0xFF1C1C1E),
    foreground: Colors.white,
    secondary: const Color(0xFF9A9AA0),
    border: const Color(0xFF2C2C2E),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color foreground,
    required Color secondary,
    required Color border,
  }) {
    final colors =
        ColorScheme.fromSeed(
          seedColor: foreground,
          brightness: brightness,
        ).copyWith(
          primary: foreground,
          onPrimary: background,
          surface: background,
          onSurface: foreground,
          surfaceContainerLow: surface,
          surfaceContainerHighest: surface,
          outline: border,
          onSurfaceVariant: secondary,
          secondary: brightness == Brightness.light
              ? const Color(0xFF2F7BF5)
              : const Color(0xFF4C8DFF),
          tertiary: const Color(0xFFF5B301),
        );

    final textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 1.23,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.27,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.38,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.43, color: foreground),
      bodySmall: TextStyle(fontSize: 12, height: 1.33, color: secondary),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: colors,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: background,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: foreground,
        labelStyle: textTheme.bodySmall?.copyWith(color: foreground),
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(color: background),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: Colors.transparent,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? foreground
                : secondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? foreground
                : secondary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brightness == Brightness.light
            ? background
            : const Color(0xFF242426),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerColor: border,
    );
  }
}
