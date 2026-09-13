import 'package:flutter/material.dart';

abstract final class ShutterColors {
  static const background = Color(0xFFF3EFE7);
  static const surface = Color(0xFFEAE5DB);
  static const surfaceLight = Color(0xFFF7F4EE);
  static const cavity = Color(0xFF24231F);
  static const cavityLight = Color(0xFF30302B);
  static const text = Color(0xFF34312C);
  static const muted = Color(0xFF8C867C);
  static const hairline = Color(0xFFCFC8BC);
  static const brass = Color(0xFFB18A52);
  static const brassLight = Color(0xFFD0AE73);
  static const brassDark = Color(0xFF755A35);
  static const lightOff = Color(0xFF605C52);
  static const lightOn = Color(0xFFFFD27A);
  static const lightCore = Color(0xFFFFF4D0);
}

abstract final class ShutterTheme {
  static ThemeData get data => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ShutterColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ShutterColors.brass,
          surface: ShutterColors.background,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            color: ShutterColors.text,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}

