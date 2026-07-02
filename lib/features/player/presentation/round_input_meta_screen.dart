import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/round_input_controller.dart';
import '../domain/golf_constants.dart';

/// 라운드 입력 — 1단계: 라운드 정보.
///
/// 웹 `player-input.html`의 상단 top-inputs 섹션에 해당.
/// 완료 후 `/player/input/holes` 로 이동.
class RoundInputMetaScreen extends ConsumerStatefulWidget {
  const RoundInputMetaScreen({super.key});

  @override
  ConsumerState<RoundInputMetaScreen> createState() =>
      _RoundInputMetaScreenState();
}

class _RoundInputMetaScreenState extends ConsumerState<RoundInputMetaScreen> {
  late final TextEditingController _tournamentCtrl;
  late final TextEditingController _courseCtrl;
  late final TextEditingController _windLowCtrl;
  late final TextEditingController _windHighCtrl;
  bool _grassExpanded = false;

  @override
  void initState() {
    super.initState();
    final meta = ref.read(roundInputProvider).meta;
    _tournamentCtrl = TextEditingController(text: meta.tournamentName);
    _courseCtrl = TextEditingController(text: meta.courseName);
    _windLowCtrl = TextEditingController(
      text: meta.windSpeedLow == null
          ? ''
          : meta.windSpeedLow!.toStringAsFixed(0),
    );
    _windHighCtrl = TextEditingController(
      text: meta.windSpeedHigh == null
          ? ''
          : meta.windSpeedHigh!.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _tournamentCtrl.dispose();
    _courseCtrl.dispose();
    _windLowCtrl.dispose();
    _windHighCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(roundInputProvider.select((d) => d.meta));
    final ctrl = ref.read(roundInputProvider.notifier);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('Play Information'),
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          children: [
                            _segmented<RoundMode>(
                              label: 'Mode',
                              value: meta.mode,
                              options: RoundMode.values,
                              labelOf: (m) => m.label,
                              onChanged: (v) =>
                                  ctrl.setMeta(meta.copyWith(mode: v)),
                            ),
                            if (meta.mode == RoundMode.tournament)
                              _labeledField(
                                label: 'Tournament Name',
                                child: TextField(
                                  controller: _tournamentCtrl,
                                  decoration: _decoration(hint: 'e.g. US Open'),
                                  onChanged: (v) => ctrl.setMeta(
                                    meta.copyWith(tournamentName: v),
                                  ),
                                ),
                              )
                            else
                              _labeledField(
                                label: 'Practice Name (optional)',
                                child: TextField(
                                  controller: _tournamentCtrl,
                                  decoration: _decoration(
                                    hint: 'e.g. Jeju CC 연습라운드',
                                  ),
                                  onChanged: (v) => ctrl.setMeta(
                                    meta.copyWith(tournamentName: v),
                                  ),
                                ),
                              ),
                            _labeledField(
                              label: 'Date',
                              child: _DatePickerField(
                                value: meta.date,
                                onChanged: (d) =>
                                    ctrl.setMeta(meta.copyWith(date: d)),
                              ),
                            ),
                            _labeledField(
                              label: 'Course Name',
                              child: TextField(
                                controller: _courseCtrl,
                                decoration: _decoration(hint: '안양CC East'),
                                onChanged: (v) =>
                                    ctrl.setMeta(meta.copyWith(courseName: v)),
                              ),
                            ),
                            _segmented<TeeTime>(
                              label: 'Tee Time',
                              value: meta.teeTime,
                              options: TeeTime.values,
                              labelOf: (m) => m.label,
                              onChanged: (v) =>
                                  ctrl.setMeta(meta.copyWith(teeTime: v)),
                            ),
                            _segmented<HoleCount>(
                              label: 'Holes',
                              value: meta.holeCount,
                              options: HoleCount.values,
                              labelOf: (m) => m.label,
                              onChanged: (v) =>
                                  ctrl.setMeta(meta.copyWith(holeCount: v)),
                            ),
                            _segmented<PlayOrder>(
                              label: 'Play Order',
                              value: meta.playOrder,
                              options: PlayOrder.values,
                              labelOf: (m) => m.label,
                              onChanged: (v) =>
                                  ctrl.setMeta(meta.copyWith(playOrder: v)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _SectionTitle('Weather Info'),
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          children: [
                            _segmented<Weather>(
                              label: 'Weather',
                              value: meta.weather,
                              options: Weather.values,
                              labelOf: (m) => '${m.emoji} ${m.label}',
                              onChanged: (v) =>
                                  ctrl.setMeta(meta.copyWith(weather: v)),
                            ),
                            _segmented<TempUnit>(
                              label: 'Temp Unit',
                              value: meta.tempUnit,
                              options: TempUnit.values,
                              labelOf: (m) => m.label,
                              onChanged: (v) => ctrl.setMeta(
                                meta.copyWith(
                                  tempUnit: v,
                                  clearTempRange: true,
                                ),
                              ),
                            ),
                            _labeledField(
                              label: 'Temp Range',
                              child: _DropdownField<String>(
                                value: meta.tempRange,
                                items: [
                                  for (final o in TempRangeOptions.forUnit(
                                    meta.tempUnit,
                                  ))
                                    (value: o.code, label: o.label),
                                ],
                                onChanged: (v) =>
                                    ctrl.setMeta(meta.copyWith(tempRange: v)),
                                hint: 'Select temperature range',
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _labeledField(
                                    label: 'Wind Low (mph)',
                                    child: TextField(
                                      controller: _windLowCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: _decoration(hint: 'mph'),
                                      onChanged: (v) => ctrl.setMeta(
                                        meta.copyWith(
                                          windSpeedLow: double.tryParse(v),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _labeledField(
                                    label: 'Wind High (mph)',
                                    child: TextField(
                                      controller: _windHighCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: _decoration(hint: 'mph'),
                                      onChanged: (v) => ctrl.setMeta(
                                        meta.copyWith(
                                          windSpeedHigh: double.tryParse(v),
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

                      const SizedBox(height: 24),
                      _SectionTitle('Grass Info (선택)'),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () =>
                            setState(() => _grassExpanded = !_grassExpanded),
                        borderRadius: BorderRadius.circular(14),
                        child: _card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.grass_rounded,
                                    color: AppColors.muted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _grassExpanded ? '접기' : '잔디 정보 추가하기 (탭)',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    _grassExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: AppColors.muted,
                                  ),
                                ],
                              ),
                              if (_grassExpanded) ...[
                                const SizedBox(height: 12),
                                _grassPicker(
                                  label: 'Fairway',
                                  value: meta.fairwayGrass,
                                  mix1: meta.fairwayMix1,
                                  mix2: meta.fairwayMix2,
                                  onChanged: (g) => ctrl.setMeta(
                                    g == null
                                        ? meta.copyWith(clearFairwayGrass: true)
                                        : meta.copyWith(fairwayGrass: g),
                                  ),
                                  onMix1: (g) => ctrl.setMeta(
                                    meta.copyWith(fairwayMix1: g),
                                  ),
                                  onMix2: (g) => ctrl.setMeta(
                                    meta.copyWith(fairwayMix2: g),
                                  ),
                                ),
                                _grassPicker(
                                  label: 'Rough',
                                  value: meta.roughGrass,
                                  mix1: meta.roughMix1,
                                  mix2: meta.roughMix2,
                                  onChanged: (g) => ctrl.setMeta(
                                    g == null
                                        ? meta.copyWith(clearRoughGrass: true)
                                        : meta.copyWith(roughGrass: g),
                                  ),
                                  onMix1: (g) =>
                                      ctrl.setMeta(meta.copyWith(roughMix1: g)),
                                  onMix2: (g) =>
                                      ctrl.setMeta(meta.copyWith(roughMix2: g)),
                                ),
                                _grassPicker(
                                  label: 'Green',
                                  value: meta.greenGrass,
                                  mix1: meta.greenMix1,
                                  mix2: meta.greenMix2,
                                  onChanged: (g) => ctrl.setMeta(
                                    g == null
                                        ? meta.copyWith(clearGreenGrass: true)
                                        : meta.copyWith(greenGrass: g),
                                  ),
                                  onMix1: (g) =>
                                      ctrl.setMeta(meta.copyWith(greenMix1: g)),
                                  onMix2: (g) =>
                                      ctrl.setMeta(meta.copyWith(greenMix2: g)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _NextBar(
        onNext: () => context.push('/player/input/holes'),
      ),
    );
  }

  // ---------- helpers ----------

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardFill,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardStroke),
    ),
    child: child,
  );

  Widget _labeledField({required String label, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            child,
          ],
        ),
      );

  Widget _segmented<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) => _labeledField(
    label: label,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Row(
        children: [
          for (final opt in options)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(opt),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: opt == value
                        ? AppColors.rose1.withValues(alpha: 0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labelOf(opt),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: opt == value ? AppColors.midnight : AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _grassPicker({
    required String label,
    required Grass? value,
    required Grass? mix1,
    required Grass? mix2,
    required ValueChanged<Grass?> onChanged,
    required ValueChanged<Grass?> onMix1,
    required ValueChanged<Grass?> onMix2,
  }) => _labeledField(
    label: label,
    child: Column(
      children: [
        _DropdownField<Grass>(
          value: value,
          items: [for (final g in Grass.values) (value: g, label: g.label)],
          onChanged: onChanged,
          hint: 'Select',
        ),
        if (value == Grass.mix)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: _DropdownField<Grass>(
                    value: mix1,
                    items: [
                      for (final g in Grass.values.where((g) => g != Grass.mix))
                        (value: g, label: g.label),
                    ],
                    onChanged: onMix1,
                    hint: 'Grass 1',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('+', style: TextStyle(color: AppColors.muted)),
                ),
                Expanded(
                  child: _DropdownField<Grass>(
                    value: mix2,
                    items: [
                      for (final g in Grass.values.where((g) => g != Grass.mix))
                        (value: g, label: g.label),
                    ],
                    onChanged: onMix2,
                    hint: 'Grass 2',
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  InputDecoration _decoration({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.glassFill,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.glassStroke),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.glassStroke),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.rose1, width: 1.4),
    ),
  );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                Text('새 라운드 입력', style: AppTextStyles.sectionTitle(size: 18)),
                const Text(
                  '1 / 3 · 라운드 정보',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? '날짜 선택'
        : DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(value!);
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 1),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.rose1,
                surface: AppColors.gun1,
                onSurface: AppColors.text,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: AppColors.gun1,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassStroke),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value == null ? AppColors.muted : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final T? value;
  final List<({T value, String label})> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.gun2,
          iconEnabledColor: AppColors.muted,
          hint: Text(
            hint ?? 'Select',
            style: const TextStyle(color: AppColors.muted),
          ),
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(
                '- ${hint ?? "Select"} -',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            for (final it in items)
              DropdownMenuItem<T?>(value: it.value, child: Text(it.label)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NextBar extends StatelessWidget {
  const _NextBar({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.bg0,
        border: const Border(
          top: BorderSide(color: AppColors.glassStroke, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onNext,
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('홀별 입력으로'),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
