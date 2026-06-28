import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_providers.dart';

/// 앱 진입 시 보여주는 스플래시.
/// - 배경: 진한 남색 단색
/// - 중앙: SYADOW 워드마크 SVG (assets/icon/source_wordmark.svg)
/// - 골드 빛이 좌→우로 1회 가로지르며 글자가 차례로 켜짐 (shimmer reveal)
/// - shimmer 종료 후 hold 구간 동안 베이스 골드로 유지
/// - 노출 시간 [_splashDuration] 후 auth 상태에 따라 /home 또는 /login 으로 분기
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // 조정 가능한 상수 (보면서 미세조정)
  static const Duration _splashDuration = Duration(milliseconds: 2200);
  static const Duration _shimmerDuration = Duration(milliseconds: 1500);
  static const double _wordmarkWidth = 260; // SVG 가로 폭(px)

  // 색 토큰 (모두 한 곳에 모음)
  static const Color _bg = Color(0xFF050813); // 배경 = 빛 닿기 전 (안 보임)
  static const Color _gold = Color(0xFFD4A373); // 베이스 골드 (빛 지나간 후)
  static const Color _highlight = Color(0xFFFFE9C8); // 빛 정점 하이라이트

  late final AnimationController _shimmer;
  late final Animation<double> _shimmerCurve;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: _shimmerDuration);
    _shimmerCurve = CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut);
    _shimmer.forward(); // 1회만 진행 (반복 안 함)
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 최소 노출 시간 + auth 상태 결정 둘 다 기다림.
    await Future.wait<void>([
      Future<void>.delayed(_splashDuration),
      ref.read(authStateProvider.future),
    ]);
    if (!mounted) return;
    final user = ref.read(authStateProvider).value;
    context.go(user != null ? '/home' : '/login');
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _shimmerCurve,
          builder: (context, child) {
            final t = _shimmerCurve.value; // 0..1 (eased)
            // 그라데이션: 왼쪽은 이미 지나간 영역(베이스 골드), 오른쪽은 아직 안 닿은 영역(배경).
            // 빛 위치 t를 기준으로 highlight 포인트를 좌→우로 이동시킴.
            const halfBand = 0.08; // 빛의 좌우 폭(좁을수록 날카로움)
            final s1 = (t - halfBand).clamp(0.0, 1.0);
            final s2 = t.clamp(0.0, 1.0);
            final s3 = (t + halfBand).clamp(0.0, 1.0);
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: const Alignment(-1, 0),
                end: const Alignment(1, 0),
                colors: const [
                  _gold, // 이미 빛이 지나간 부분 (베이스 골드)
                  _gold,
                  _highlight, // 빛 정점
                  _bg, // 아직 안 닿은 부분 (배경에 묻힘)
                  _bg,
                ],
                stops: [0.0, s1, s2, s3, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: child,
            );
          },
          child: SvgPicture.asset(
            'assets/icon/source_wordmark.svg',
            width: _wordmarkWidth,
            // ShaderMask가 색을 srcIn으로 덮어쓰므로 SVG의 원본 fill은 흰색으로 강제.
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
