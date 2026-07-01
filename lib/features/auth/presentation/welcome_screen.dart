import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 4분할 풀블리드 배경 (플레이스홀더, 나중에 사진 4장으로 교체)
          const _FullBleedRoleGrid(),

          // 2. 전체 화면 어두운 vignette — 로고/버튼 가독성 확보
          const _Vignette(),

          // 3. 중앙 SYADOW 로고
          const Center(child: _CenterLogo()),

          // 4. 하단 버튼 영역 (하단 그림자 → 완전 검정 그라데이션)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActions(t: t),
          ),
        ],
      ),
    );
  }
}

class _FullBleedRoleGrid extends StatelessWidget {
  const _FullBleedRoleGrid();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileGolf,
                  icon: Icons.sports_golf,
                  color: AppColors.rolePlayer,
                  labelAlign: Alignment.topLeft,
                ),
              ),
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileCoach,
                  icon: Icons.psychology_alt_outlined,
                  color: AppColors.roleCoach,
                  labelAlign: Alignment.topRight,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileFitter,
                  icon: Icons.tune_rounded,
                  color: AppColors.roleFitter,
                  labelAlign: Alignment.bottomLeft,
                ),
              ),
              Expanded(
                child: _RoleQuadrant(
                  label: t.welcomeTileTrainer,
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.roleTrainer,
                  labelAlign: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 플레이스홀더 quadrant. 나중에 `Image.asset(fit: BoxFit.cover)`로 교체.
class _RoleQuadrant extends StatelessWidget {
  const _RoleQuadrant({
    required this.label,
    required this.icon,
    required this.color,
    required this.labelAlign,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Alignment labelAlign;

  @override
  Widget build(BuildContext context) {
    // 배경 아이콘을 라벨 반대편 코너 쪽으로 밀어 사진 느낌 흉내
    final iconAlign = Alignment(-labelAlign.x * 0.7, -labelAlign.y * 0.7);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.gun1, color, 0.35)!,
            AppColors.gun1,
            const Color(0xFF0A0A0D),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: iconAlign,
              child: Icon(
                icon,
                size: 140,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: labelAlign,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.65),
            ],
            stops: const [0.35, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _CenterLogo extends StatelessWidget {
  const _CenterLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.bg0.withValues(alpha: 0.9),
            AppColors.bg0.withValues(alpha: 0.6),
            AppColors.bg0.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF8B6B4A), AppColors.rose1, Color(0xFFF4D29F)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: SvgPicture.asset(
            'assets/icon/source_wordmark.svg',
            width: 170,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.t});
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bg0.withValues(alpha: 0.0),
            AppColors.bg0.withValues(alpha: 0.75),
            AppColors.bg0.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrimaryButton(
                label: t.createAccount,
                onPressed: () => context.push('/signup'),
              ),
              const SizedBox(height: 12),
              _SecondaryButton(
                label: t.welcomeIHaveAccount,
                onPressed: () => context.push('/login/email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A373), Color(0xFFF4D29F)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose1.withValues(alpha: 0.4),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.midnight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
