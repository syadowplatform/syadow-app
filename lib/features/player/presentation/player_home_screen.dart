import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/sparkline.dart';
import '../../auth/application/auth_providers.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _tab = 0;

  static const _navItems = [
    BottomNavItem(icon: Icons.home_rounded, label: '오늘'),
    BottomNavItem(icon: Icons.show_chart_rounded, label: 'Stats'),
    BottomNavItem(icon: Icons.add_circle_outline_rounded, label: '입력'),
    BottomNavItem(icon: Icons.chat_bubble_outline_rounded, label: '연결'),
    BottomNavItem(icon: Icons.settings_outlined, label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('M월 d일, EEE', 'ko_KR').format(DateTime.now());

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.bgGradient),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                _Header(today: today),
                const SizedBox(height: 16),
                _SuggestionCard(),
                const SizedBox(height: 16),
                _MetricsGrid(),
                const SizedBox(height: 16),
                _SectionHeader(title: '라운드', proBadge: true),
                const SizedBox(height: 12),
                _RoundCard(),
                const SizedBox(height: 12),
                _SectionHeader(title: '코치 코멘트'),
                const SizedBox(height: 12),
                _CoachCommentCard(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SyadowBottomNav(
              items: _navItems,
              currentIndex: _tab,
              onTap: (i) {
                if (i == 2) {
                  context.push('/player/input/new');
                  return;
                }
                setState(() => _tab = i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                today,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.expand_more_rounded,
                color: AppColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          color: AppColors.bg1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.glassStroke),
          ),
          onSelected: (v) async {
            if (v == 'signout') {
              await ref.read(authServiceProvider).signOut();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.text,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.signOut,
                    style: const TextStyle(color: AppColors.text),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardStroke, width: 1.5),
              gradient: LinearGradient(
                colors: [
                  AppColors.rose1.withValues(alpha: 0.6),
                  AppColors.rose2.withValues(alpha: 0.6),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: AppColors.text, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (rect) =>
                    AppColors.neonGradient.createShader(rect),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text('오늘의 제안', style: AppTextStyles.sectionTitle(size: 14)),
              const Spacer(),
              const Icon(
                Icons.expand_more_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '드라이빙 평균이 지난주 대비 8y 줄었습니다. 백스윙 템포를 천천히 가져가는 연습을 추천드려요. 페어웨이 안착률은 양호합니다.',
            style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: [
        MetricCard(
          label: '최근 스코어',
          value: '-2',
          status: '좋음',
          statusColor: AppColors.good,
          icon: Icons.flag_outlined,
          trailingChart: const Sparkline(
            values: [4, 2, 5, 3, 1, -1, -2],
            color: AppColors.good,
            fillOpacity: 0.15,
          ),
        ),
        MetricCard(
          label: '핸디캡',
          value: '12.4',
          status: '하락 추세',
          statusColor: AppColors.info,
          icon: Icons.trending_down_rounded,
          trailingChart: const Sparkline(
            values: [14.2, 13.8, 13.5, 13.0, 12.8, 12.6, 12.4],
            color: AppColors.info,
            fillOpacity: 0.15,
          ),
        ),
        MetricCard(
          label: '드라이빙',
          value: '245',
          unit: 'y',
          status: '평균',
          statusColor: AppColors.warn,
          icon: Icons.sports_golf_outlined,
          trailingChart: const Sparkline(
            values: [253, 250, 248, 247, 246, 244, 245],
            color: AppColors.warn,
            fillOpacity: 0.15,
          ),
        ),
        MetricCard(
          label: 'GIR',
          value: '64',
          unit: '%',
          status: '양호',
          statusColor: AppColors.good,
          icon: Icons.gps_fixed_rounded,
          trailingChart: const Sparkline(
            values: [55, 58, 60, 62, 61, 63, 64],
            color: AppColors.good,
            fillOpacity: 0.15,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.proBadge = false});
  final String title;
  final bool proBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        if (proBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.roleTrainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.roleTrainer.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'Pro',
              style: TextStyle(
                color: AppColors.roleTrainer,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (rect) =>
                    AppColors.sleepGradient.createShader(rect),
                child: const Text(
                  '최근 라운드',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '더 보기',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          const GradientProgressBar(
            value: 0.78,
            height: 8,
            gradient: AppColors.sleepGradient,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoundStat(label: '총 타수', value: '74', icon: Icons.flag),
              _RoundStat(label: '페어웨이', value: '71%', icon: Icons.gps_fixed),
              _RoundStat(label: '퍼팅', value: '30', icon: Icons.adjust),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundStat extends StatelessWidget {
  const _RoundStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: AppColors.dim),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCommentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.roleCoach.withValues(alpha: 0.8),
                  AppColors.roleCoach.withValues(alpha: 0.4),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.sports, color: AppColors.text, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '김민수 코치',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '백스윙 영상 보내주세요. 어드레스 자세 점검 필요해 보입니다.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
