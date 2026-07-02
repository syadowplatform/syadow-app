import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/round_input_controller.dart';
import '../domain/golf_constants.dart';
import '../domain/hole_data.dart';
import 'widgets/putt_block.dart';
import 'widgets/round_input_pickers.dart';
import 'widgets/shot_block.dart';

/// 라운드 입력 — 2단계: 홀별 스와이프 입력.
///
/// PageView로 홀 1개당 화면 1개. 좌우 스와이프로 이동.
class RoundInputHolesScreen extends ConsumerStatefulWidget {
  const RoundInputHolesScreen({super.key});

  @override
  ConsumerState<RoundInputHolesScreen> createState() =>
      _RoundInputHolesScreenState();
}

class _RoundInputHolesScreenState extends ConsumerState<RoundInputHolesScreen> {
  late final PageController _pageCtrl;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(roundInputProvider.select((d) => d.meta));
    final holeIds = HoleIds.ordered(
      holeCount: meta.holeCount,
      playOrder: meta.playOrder,
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                currentPage: _pageIndex,
                totalPages: holeIds.length,
                holeIds: holeIds,
                onJump: (i) => _pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  itemCount: holeIds.length,
                  itemBuilder: (ctx, i) => _HolePage(holeId: holeIds[i]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        currentPage: _pageIndex,
        totalPages: holeIds.length,
        onPrev: () {
          if (_pageIndex > 0) {
            _pageCtrl.previousPage(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
            );
          }
        },
        onNext: () {
          if (_pageIndex < holeIds.length - 1) {
            _pageCtrl.nextPage(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
            );
          }
        },
        onComplete: () => context.push('/player/input/summary'),
      ),
    );
  }
}

// ---------------------------------------------------------------
// Header (progress dots + back)
// ---------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.currentPage,
    required this.totalPages,
    required this.holeIds,
    required this.onJump,
  });

  final int currentPage;
  final int totalPages;
  final List<String> holeIds;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.text,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('홀별 입력', style: AppTextStyles.sectionTitle(size: 18)),
                    Text(
                      '2 / 3 · ${holeIds[currentPage]} · $currentPage 완료 / ${totalPages - 1}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/player/input/summary'),
                child: const Text(
                  '요약',
                  style: TextStyle(
                    color: AppColors.rose1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ProgressDots(
            totalPages: totalPages,
            currentPage: currentPage,
            onTap: onJump,
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.totalPages,
    required this.currentPage,
    required this.onTap,
  });
  final int totalPages;
  final int currentPage;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < totalPages; i++)
            GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: i == currentPage ? 22 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == currentPage ? AppColors.rose1 : AppColors.gun2,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// One-hole page
// ---------------------------------------------------------------

class _HolePage extends ConsumerWidget {
  const _HolePage({required this.holeId});
  final String holeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hole = ref.watch(
      roundInputProvider.select(
        (d) => d.holes[holeId] ?? HoleEntry.empty(holeId),
      ),
    );
    final ctrl = ref.read(roundInputProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 홀 번호 + Par
          _HoleHeaderCard(
            holeId: holeId,
            par: hole.par,
            autoScore: hole.autoScore,
            onParChanged: (v) => ctrl.setPar(holeId, v),
          ),

          const SizedBox(height: 16),

          // Pin location
          _SectionCard(
            title: 'Pin (9-Grid)',
            trailing: hole.pin == null
                ? null
                : InkWell(
                    onTap: () => ctrl.setPin(holeId, null),
                    child: const Text(
                      '해제',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
            child: SizedBox(
              width: 200,
              child: PickerChip(
                label: 'Pin',
                value: hole.pin,
                placeholder: '핀 위치 선택',
                onTap: () async {
                  final v = await showPinPicker(context, current: hole.pin);
                  if (v != null) ctrl.setPin(holeId, v);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Shots
          _SectionCard(
            title: 'Shots',
            trailing: Text(
              '${hole.shots.length}개',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < hole.shots.length; i++)
                  ShotBlock(
                    key: ValueKey('${holeId}_shot_$i'),
                    holeId: holeId,
                    shotIndex: i,
                    par: hole.par,
                  ),
                OutlinedButton.icon(
                  onPressed: () => ctrl.addShot(holeId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose1,
                    side: const BorderSide(color: AppColors.rose1, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    '샷 추가',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Putts
          _SectionCard(
            title: 'Putter Steps',
            trailing: Text(
              '${hole.putts.length}개',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < hole.putts.length; i++)
                  PuttBlock(
                    key: ValueKey('${holeId}_putt_$i'),
                    holeId: holeId,
                    puttIndex: i,
                  ),
                OutlinedButton.icon(
                  onPressed: () => ctrl.addPutt(holeId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose1,
                    side: const BorderSide(color: AppColors.rose1, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    '퍼트 추가',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tap-in + Penalty
          _SectionCard(
            title: '기타',
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tap-In',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: hole.tapIn,
                      activeThumbColor: AppColors.rose1,
                      onChanged: (v) => ctrl.setTapIn(holeId, v),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Penalty',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.right,
                        controller: TextEditingController(
                          text: hole.penalty == 0 ? '' : '${hole.penalty}',
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: AppColors.glassFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.glassStroke,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.glassStroke,
                            ),
                          ),
                        ),
                        onChanged: (v) =>
                            ctrl.setPenalty(holeId, int.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// Hole header (large hole number + Par + auto score)
// ---------------------------------------------------------------

class _HoleHeaderCard extends StatelessWidget {
  const _HoleHeaderCard({
    required this.holeId,
    required this.par,
    required this.autoScore,
    required this.onParChanged,
  });

  final String holeId;
  final int par;
  final int autoScore;
  final ValueChanged<int> onParChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rose1.withValues(alpha: 0.15),
            AppColors.gun1.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rose1.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.midnight.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.rose1, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  holeId,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${HoleIds.numberOf(holeId)}',
                  style: AppTextStyles.brand(size: 32, color: AppColors.rose1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAR',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final p in [3, 4, 5])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => onParChanged(p),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: p == par
                                  ? AppColors.rose1
                                  : AppColors.gun2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: p == par
                                    ? AppColors.rose1
                                    : AppColors.glassStroke,
                              ),
                            ),
                            child: Text(
                              '$p',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: p == par
                                    ? AppColors.midnight
                                    : AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                autoScore == 0 ? '–' : '$autoScore',
                style: AppTextStyles.brand(size: 30),
              ),
              if (autoScore > 0)
                Text(
                  _scoreLabel(autoScore, par),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(autoScore, par),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _scoreLabel(int score, int par) {
    final d = score - par;
    if (score == 1) return 'HOLE-IN-ONE';
    return switch (d) {
      < -2 => 'ALBATROSS+',
      -2 => 'EAGLE',
      -1 => 'BIRDIE',
      0 => 'PAR',
      1 => 'BOGEY',
      2 => 'DOUBLE',
      _ => '+$d',
    };
  }

  static Color _scoreColor(int score, int par) {
    final d = score - par;
    if (d < 0) return AppColors.good;
    if (d == 0) return AppColors.rose1;
    if (d == 1) return AppColors.warn;
    return AppColors.bad;
  }
}

// ---------------------------------------------------------------
// Common section card
// ---------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.rose1,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// Bottom nav (prev / next / complete)
// ---------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    required this.onComplete,
  });
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage >= totalPages - 1;
    final isFirst = currentPage == 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg0,
        border: Border(
          top: BorderSide(color: AppColors.glassStroke, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _navButton(
            onTap: isFirst ? null : onPrev,
            icon: Icons.chevron_left_rounded,
            label: '이전 홀',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLast ? onComplete : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose1,
                  foregroundColor: AppColors.midnight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(isLast ? '요약으로' : '다음 홀'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      height: 52,
      width: 64,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          disabledForegroundColor: AppColors.dim,
          side: const BorderSide(color: AppColors.glassStroke),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}
