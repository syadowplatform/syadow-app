import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// SYADOW 텍스트 스타일.
/// - 브랜드/타이틀: Orbitron (google_fonts에서 런타임 로딩)
/// - 본문: 시스템 폰트 (iOS=SF Pro, Android=Roboto) — Flutter 기본값
class AppTextStyles {
  AppTextStyles._();

  /// 브랜드 워드마크 ("SYADOW" 로고) — Orbitron 900
  static TextStyle brand({double size = 28, Color? color}) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: color ?? AppColors.text,
      );

  /// 섹션 타이틀 — Orbitron 700
  static TextStyle sectionTitle({double size = 20, Color? color}) =>
      GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? AppColors.text,
      );

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.text,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.text,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.muted,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.muted,
    ),
  );
}
