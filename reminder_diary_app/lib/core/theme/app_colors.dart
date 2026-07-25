import 'package:flutter/material.dart';

/// Warna dasar aplikasi. Reminder pakai palet biru-ungu yang energik,
/// Diary pakai palet warm neutral yang lebih tenang supaya kedua area
/// terasa punya "mood" berbeda meski dalam satu app.
class AppColors {
  AppColors._();

  // Brand / Reminder accent
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF8F87FF);
  static const Color secondary = Color(0xFF00C2A8);

  // Priority colors
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityHigh = Color(0xFFEF5350);

  // Diary accent (warm neutral)
  static const Color diaryAccent = Color(0xFFB08968);
  static const Color diaryAccentDark = Color(0xFFD8B08C);
  static const Color diaryBgLight = Color(0xFFF8F1E9);
  static const Color diaryBgDark = Color(0xFF221D19);

  // Neutrals
  static const Color bgLight = Color(0xFFF7F7FB);
  static const Color bgDark = Color(0xFF121016);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1C1A22);
}
