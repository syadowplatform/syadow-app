import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/round_input_controller.dart';
import '../domain/golf_constants.dart';
import '../domain/hole_data.dart';
import '../domain/player_round.dart';

/// 라운드 입력 — 3단계: 요약 + 노트 + 저장.
class RoundInputSummaryScreen extends ConsumerStatefulWidget {
  const RoundInputSummaryScreen({super.key});

  @override
  ConsumerState<RoundInputSummaryScreen> createState() =>
      _RoundInputSummaryScreenState();
}

class _RoundInputSummaryScreenState
    extends ConsumerState<RoundInputSummaryScreen> {
  late final TextEditingController _swingCtrl;
  late final TextEditingController _shortCtrl;
  late final TextEditingController _puttCtrl;
  late final TextEditingController _mindCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final n = ref.read(roundInputProvider).notes;
    _swingCtrl = TextEditingController(text: n.swing);
    _shortCtrl = TextEditingController(text: n.shortGame);
    _puttCtrl = TextEditingController(text: n.putting);
    _mindCtrl = TextEditingController(text: n.mind);
  }

  @override
  void dispose() {
    _swingCtrl.dispose();
    _shortCtrl.dispose();
    _puttCtrl.dispose();
    _mindCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(playerRoundRepositoryProvider);
      await ref.read(roundInputProvider.notifier).save(uid: uid, repo: repo);
      if (!mounted) return;
      ref.read(roundInputProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장되었습니다. (mock)'),
          backgroundColor: AppColors.good,
        ),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e'), backgroundColor: AppColors.bad),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(roundInputProvider);
    final summary = draft.scoreSummary;
    final meta = draft.meta;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Score summary
                      _ScoreCard(summary: summary),

                      const SizedBox(height: 16),

                      // Meta preview
                      _MetaSummary(draft: draft),

                      const SizedBox(height: 16),

                      // Hole quick grid
                      _HolesQuickGrid(),

                      const SizedBox(height: 24),
                      _SectionTitle('Round Notes'),
                      const SizedBox(height: 12),
                      _noteField(
                        label: 'Swing',
                        placeholder: 'Swing thoughts, tempo, alignment...',
                        controller: _swingCtrl,
                        onChanged: (v) =>
                            _updateNotes(draft.notes.copyWith(swing: v)),
                      ),
                      _noteField(
                        label: 'Short Game',
                        placeholder: 'Chip, pitch, bunker...',
                        controller: _shortCtrl,
                        onChanged: (v) =>
                            _updateNotes(draft.notes.copyWith(shortGame: v)),
                      ),
                      _noteField(
                        label: 'Putting',
                        placeholder: 'Speed, read, stroke...',
                        controller: _puttCtrl,
                        onChanged: (v) =>
                            _updateNotes(draft.notes.copyWith(putting: v)),
                      ),
                      _noteField(
                        label: 'Mind',
                        placeholder: 'Focus, emotions, pressure...',
                        controller: _mindCtrl,
                        onChanged: (v) =>
                            _updateNotes(draft.notes.copyWith(mind: v)),
                      ),

                      const SizedBox(height: 16),
                      _SectionTitle('스코어카드 사진 (선택)'),
                      const SizedBox(height: 12),
                      _PhotoPlaceholder(),

                      const SizedBox(height: 16),
                      Text(
                        '코스: ${meta.courseName.isEmpty ? "(미입력)" : meta.courseName}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _saveBar(),
    );
  }

  void _updateNotes(RoundNotes n) =>
      ref.read(roundInputProvider.notifier).setNotes(n);

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
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
                Text('저장', style: AppTextStyles.sectionTitle(size: 18)),
                const Text(
                  '3 / 3 · 요약 + 노트',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.rose1,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 6,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.glassFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.glassStroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.glassStroke),
                ),
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg0,
        border: Border(
          top: BorderSide(color: AppColors.glassStroke, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _save,
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
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.midnight,
                  ),
                )
              : const Icon(Icons.save_rounded, size: 18),
          label: Text(_saving ? '저장 중…' : '라운드 저장'),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.rose1,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.summary});
  final ScoreSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.rose1.withValues(alpha: 0.18),
            AppColors.gun1.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.rose1.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          _box('Front 9', summary.front9),
          _divider(),
          _box('Back 9', summary.back9),
          _divider(),
          _box('Total', summary.total, big: true),
        ],
      ),
    );
  }

  Widget _box(String label, int value, {bool big = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value == 0 ? '–' : '$value',
            style: AppTextStyles.brand(
              size: big ? 40 : 30,
              color: big ? AppColors.rose1 : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 44,
    color: AppColors.glassStroke,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

class _MetaSummary extends StatelessWidget {
  const _MetaSummary({required this.draft});
  final RoundDraft draft;

  @override
  Widget build(BuildContext context) {
    final m = draft.meta;
    final dateStr = m.date == null
        ? '-'
        : '${m.date!.year}.${m.date!.month.toString().padLeft(2, "0")}.${m.date!.day.toString().padLeft(2, "0")}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        children: [
          _row('날짜', dateStr),
          _row('코스', m.courseName.isEmpty ? '-' : m.courseName),
          _row(
            '모드',
            '${m.mode.label} · ${m.teeTime.label} · ${m.holeCount.label}',
          ),
          _row('날씨', '${m.weather.emoji} ${m.weather.label}'),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            k,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HolesQuickGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(roundInputProvider);
    final holeIds = HoleIds.ordered(
      holeCount: draft.meta.holeCount,
      playOrder: draft.meta.playOrder,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              '홀별 점수',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.rose1,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final id in holeIds)
                _hoteBox(id, draft.holes[id] ?? HoleEntry.empty(id)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hoteBox(String id, HoleEntry h) {
    final s = h.autoScore;
    final d = s == 0 ? 0 : s - h.par;
    Color bg;
    if (s == 0) {
      bg = AppColors.gun2;
    } else if (d < 0) {
      bg = AppColors.good.withValues(alpha: 0.25);
    } else if (d == 0) {
      bg = AppColors.rose1.withValues(alpha: 0.25);
    } else if (d == 1) {
      bg = AppColors.warn.withValues(alpha: 0.25);
    } else {
      bg = AppColors.bad.withValues(alpha: 0.25);
    }
    return Container(
      width: 46,
      height: 54,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            id,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            s == 0 ? '–' : '$s',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.gun1.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassStroke,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.muted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            const Text(
              '스코어카드 사진 추가 (준비 중)',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
