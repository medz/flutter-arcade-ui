import 'package:flutter/material.dart';

abstract final class ArcadeColors {
  static const canvas = Color(0xFF08090D);
  static const surface = Color(0xFF0E1016);
  static const surfaceRaised = Color(0xFF141720);
  static const border = Color(0xFF2A2E39);
  static const text = Color(0xFFF5F4F8);
  static const muted = Color(0xFFA6A7B0);
  static const violet = Color(0xFF9B7BFF);
  static const aqua = Color(0xFF62E7E0);
}

ThemeData createArcadeTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: ArcadeColors.violet,
        brightness: Brightness.dark,
      ).copyWith(
        primary: ArcadeColors.violet,
        secondary: ArcadeColors.aqua,
        surface: ArcadeColors.surface,
        onSurface: ArcadeColors.text,
        outline: ArcadeColors.border,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ArcadeColors.canvas,
    canvasColor: ArcadeColors.canvas,
    dividerColor: ArcadeColors.border,
    splashFactory: InkSparkle.splashFactory,
    textTheme: Typography.material2021().white.apply(
      bodyColor: ArcadeColors.text,
      displayColor: ArcadeColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ArcadeColors.canvas,
      foregroundColor: ArcadeColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ArcadeColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ArcadeColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ArcadeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ArcadeColors.violet, width: 1.5),
      ),
    ),
  );
}
