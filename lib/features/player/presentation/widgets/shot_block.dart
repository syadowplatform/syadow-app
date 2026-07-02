import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/round_input_controller.dart';
import '../../domain/golf_constants.dart';
import '../../domain/hole_data.dart';
import 'round_input_pickers.dart';

/// 샷 하나를 표시/편집하는 블럭 (웹 .shot-block 대응).
///
/// 웹 순서와 동일:
///   1. Distance (yd)
///   2. Wind (clock)
///   3. Club (autocomplete)
///   4. Position (dropdown)
///   5. Direction (button — 모드는 par/position/shotIndex에 따라 결정)
class ShotBlock extends ConsumerStatefulWidget {
  const ShotBlock({
    super.key,
    required this.holeId,
    required this.shotIndex, // 0-based index in list
    required this.par,
  });

  final String holeId;
  final int shotIndex;
  final int par;

  @override
  ConsumerState<ShotBlock> createState() => _ShotBlockState();
}

class _ShotBlockState extends ConsumerState<ShotBlock> {
  late final TextEditingController _distCtrl;
  late final TextEditingController _clubCtrl;

  @override
  void initState() {
    super.initState();
    final shot = _readShot();
    _distCtrl = TextEditingController(
      text: shot.distance == null ? '' : shot.distance!.toStringAsFixed(0),
    );
    _clubCtrl = TextEditingController(text: shot.club);
  }

  Shot _readShot() {
    final h = ref.read(roundInputProvider).holes[widget.holeId];
    return h?.shots[widget.shotIndex] ?? Shot(index: widget.shotIndex + 1);
  }

  @override
  void dispose() {
    _distCtrl.dispose();
    _clubCtrl.dispose();
    super.dispose();
  }

  static String _ordinal(int n) {
    final v = n % 100;
    final suffixes = ['th', 'st', 'nd', 'rd'];
    final i = (v >= 11 && v <= 13)
        ? 0
        : (v % 10 >= 1 && v % 10 <= 3)
        ? v % 10
        : 0;
    return '$n${suffixes[i]}';
  }

  DirectionMode _dirModeFor(Shot s) {
    if (s.position == ShotPosition.og) return DirectionMode.grid;
    if (widget.shotIndex == 0 && (widget.par == 4 || widget.par == 5)) {
      return DirectionMode.three;
    }
    return DirectionMode.nine;
  }

  @override
  Widget build(BuildContext context) {
    final shot = ref.watch(
      roundInputProvider.select((d) {
        final list = d.holes[widget.holeId]?.shots ?? const <Shot>[];
        return widget.shotIndex < list.length
            ? list[widget.shotIndex]
            : Shot(index: widget.shotIndex + 1);
      }),
    );
    final ctrl = ref.read(roundInputProvider.notifier);
    final labelText = '${_ordinal(widget.shotIndex + 1)} Shot';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gun1.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.rose1,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => ctrl.removeShot(widget.holeId, widget.shotIndex),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Distance
          _Row(
            label: 'To Hole (yd)',
            child: SizedBox(
              width: 90,
              child: TextField(
                controller: _distCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textAlign: TextAlign.right,
                decoration: _fieldDeco(hint: '0'),
                onChanged: (v) {
                  final n = double.tryParse(v);
                  ctrl.updateShot(
                    widget.holeId,
                    widget.shotIndex,
                    (s) => n == null
                        ? s.copyWith(clearDistance: true)
                        : s.copyWith(distance: n),
                  );
                },
              ),
            ),
          ),

          // 2. Wind
          _Row(
            label: 'Wind',
            child: SizedBox(
              width: 110,
              child: PickerChip(
                label: 'Wind',
                value: shot.wind,
                onTap: () async {
                  final v = await showWindClockPicker(
                    context,
                    current: shot.wind,
                  );
                  if (v != null) {
                    ctrl.updateShot(
                      widget.holeId,
                      widget.shotIndex,
                      (s) => s.copyWith(wind: v),
                    );
                  }
                },
              ),
            ),
          ),

          // 3. Club (autocomplete)
          _Row(
            label: 'Club',
            child: SizedBox(
              width: 130,
              child: RawAutocomplete<String>(
                textEditingController: _clubCtrl,
                focusNode: FocusNode(),
                optionsBuilder: (v) {
                  final t = v.text.toUpperCase();
                  if (t.isEmpty) return Clubs.all;
                  return Clubs.all.where((c) => c.startsWith(t));
                },
                onSelected: (v) {
                  _clubCtrl.text = v;
                  ctrl.updateShot(
                    widget.holeId,
                    widget.shotIndex,
                    (s) => s.copyWith(club: v),
                  );
                },
                fieldViewBuilder: (ctx, fCtrl, focus, submit) {
                  return TextField(
                    controller: fCtrl,
                    focusNode: focus,
                    textAlign: TextAlign.right,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _fieldDeco(hint: 'DR / 7I / PUTT'),
                    onChanged: (v) {
                      ctrl.updateShot(
                        widget.holeId,
                        widget.shotIndex,
                        (s) => s.copyWith(club: v.toUpperCase()),
                      );
                    },
                    onSubmitted: (v) {
                      final n = Clubs.normalize(v);
                      fCtrl.text = n;
                      ctrl.updateShot(
                        widget.holeId,
                        widget.shotIndex,
                        (s) => s.copyWith(club: n),
                      );
                      submit();
                    },
                    onEditingComplete: () {
                      final n = Clubs.normalize(fCtrl.text);
                      fCtrl.text = n;
                      ctrl.updateShot(
                        widget.holeId,
                        widget.shotIndex,
                        (s) => s.copyWith(club: n),
                      );
                    },
                  );
                },
                optionsViewBuilder: (ctx, onSelected, options) {
                  return Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      elevation: 4,
                      color: AppColors.gun2,
                      borderRadius: BorderRadius.circular(10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 220,
                          maxWidth: 180,
                        ),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            for (final o in options)
                              InkWell(
                                onTap: () => onSelected(o),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    o,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Position
          _Row(
            label: 'Position',
            child: SizedBox(
              width: 130,
              child: _PositionDropdown(
                value: shot.position,
                onChanged: (v) {
                  ctrl.updateShot(
                    widget.holeId,
                    widget.shotIndex,
                    (s) => v == null
                        ? s.copyWith(clearPosition: true)
                        : s.copyWith(position: v),
                  );
                },
              ),
            ),
          ),

          // 5. Direction
          _Row(
            label: 'Direction',
            child: SizedBox(
              width: 110,
              child: PickerChip(
                label: 'Direction',
                value: shot.direction,
                onTap: () async {
                  final mode = _dirModeFor(shot);
                  final v = await showDirectionPicker(
                    context,
                    mode: mode,
                    current: shot.direction,
                  );
                  if (v != null) {
                    ctrl.updateShot(
                      widget.holeId,
                      widget.shotIndex,
                      (s) => s.copyWith(direction: v),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco({String? hint}) => InputDecoration(
    isDense: true,
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    filled: true,
    fillColor: AppColors.glassFill,
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PositionDropdown extends StatelessWidget {
  const _PositionDropdown({required this.value, required this.onChanged});
  final ShotPosition? value;
  final ValueChanged<ShotPosition?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ShotPosition?>(
          value: value,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.gun2,
          iconEnabledColor: AppColors.muted,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hint: const Text(
            '-',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          items: [
            const DropdownMenuItem<ShotPosition?>(
              value: null,
              child: Text('-'),
            ),
            for (final p in ShotPosition.values)
              DropdownMenuItem<ShotPosition?>(
                value: p,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.code),
                    const SizedBox(width: 6),
                    Text(
                      p.label,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
