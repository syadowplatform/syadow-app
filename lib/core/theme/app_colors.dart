import 'package:flutter/material.dart';

/// 웹 syadow-ui.css의 색 토큰을 Dart 상수로 포팅.
/// 색을 직접 수정하지 말고 항상 이 클래스를 참조할 것.
class AppColors {
  AppColors._();

  // Base — black + gold 톤 (2026-07-01 남색→검정 전환)
  static const Color midnight = Color(0xFF0D0D10);
  static const Color bg0 = Color(0xFF050505); // 거의 순검정, 약간의 뉘앙스
  static const Color bg1 = Color(0xFF101014); // 카드 베이스

  // Surfaces (gunmetal → 뉴트럴 다크)
  static const Color gun1 = Color(0xFF16161A);
  static const Color gun2 = Color(0xFF22222A);

  // Accents (rose gold)
  static const Color rose1 = Color(0xFFD4A373);
  static const Color rose2 = Color(0xFFE4B48E);

  // Text
  static const Color text = Color(0xFFEAF0FA);
  static const Color muted = Color(0xFF93A6BD);
  static const Color dim = Color(0xFF5C6B82);

  // Glassmorphism overlays
  static const Color glassFill = Color(0x1AFFFFFF); // white @ 10%
  static const Color glassStroke = Color(0x33FFFFFF); // white @ 20%
  static const Color cardFill = Color(0xCC101014); // bg1 @ 80%
  static const Color cardStroke = Color(0x1FFFFFFF); // white @ 12%

  // Status
  static const Color good = Color(0xFF4ADE80); // green
  static const Color warn = Color(0xFFFFB84D); // amber
  static const Color bad = Color(0xFFFF6B6B); // red
  static const Color info = Color(0xFF6C8DFF); // blue

  // Neon accents (그라데이션용)
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color neonPurple = Color(0xFFA78BFA);
  static const Color neonPink = Color(0xFFF472B6);

  // Role accents (캘린더 다트 등)
  static const Color rolePlayer = rose1;
  static const Color roleCoach = Color(0xFF6C8DFF);
  static const Color roleFitter = Color(0xFF4ECDC4);
  static const Color roleTrainer = Color(0xFFFF9F43); // 🆕 워킹노트: 4번째 다트 orange

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [midnight, bg0],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [neonCyan, neonPurple, neonPink],
  );

  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
}
