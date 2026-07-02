import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/golf_constants.dart';

/// 웹의 팝업(Pin/Direction/Wind)을 모바일 bottom sheet로 대체.
///
/// 사용법: 각 필드는 [PickerChip]으로 현재 값 노출 → 탭 시 각 헬퍼(show*)로
/// 바텀시트 오픈 → 선택값 리턴.

/// 라벨 + 현재값 + 화살표를 표시하는 공통 버튼.
class PickerChip extends StatelessWidget {
  const PickerChip({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder = 'Select',
    this.width,
  });

  final String label;
  final String? value;
  final String placeholder;
  final double? width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value != null && value!.isNotEmpty && value != 'Select';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.rose1 : AppColors.glassStroke,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected ? value! : placeholder,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.text : AppColors.muted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// Pin 9-grid selector
// -----------------------------

Future<String?> showPinPicker(BuildContext context, {String? current}) {
  return _showSheet<String>(
    context,
    title: '핀 위치 선택 (9-Grid)',
    subtitle: '그린의 3×3 격자에서 핀 위치를 골라주세요.',
    builder: (ctx) => _GridPicker(
      rows: PinGridCodes.rows,
      currentValue: current,
      onSelect: (v) => Navigator.of(ctx).pop(v),
    ),
  );
}

// -----------------------------
// Direction picker (9/3/grid)
// -----------------------------

Future<String?> showDirectionPicker(
  BuildContext context, {
  required DirectionMode mode,
  String? current,
}) {
  final rows = switch (mode) {
    DirectionMode.nine => DirectionArrows.nine,
    DirectionMode.three => DirectionArrows.three,
    DirectionMode.grid => PinGridCodes.rows,
  };
  return _showSheet<String>(
    context,
    title: '샷 방향 선택',
    subtitle: switch (mode) {
      DirectionMode.nine => '샷이 향한 방향을 골라주세요.',
      DirectionMode.three => '좌 / 중 / 우 중 선택.',
      DirectionMode.grid => '그린 위 볼 위치를 골라주세요.',
    },
    builder: (ctx) => _GridPicker(
      rows: rows,
      currentValue: current,
      onSelect: (v) => Navigator.of(ctx).pop(v),
    ),
  );
}

// -----------------------------
// Wind clock picker
// -----------------------------

Future<String?> showWindClockPicker(BuildContext context, {String? current}) {
  return _showSheet<String>(
    context,
    title: '바람 방향 선택 (시계)',
    subtitle: '바람이 불어오는 시계 방향을 골라주세요.',
    builder: (ctx) => _ClockPicker(
      currentValue: current,
      onSelect: (v) => Navigator.of(ctx).pop(v),
    ),
  );
}

// =========================================================
// Internal helpers
// =========================================================

Future<T?> _showSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.bg1,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.dim,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 20),
            builder(ctx),
          ],
        ),
      ),
    ),
  );
}

class _GridPicker extends StatelessWidget {
  const _GridPicker({
    required this.rows,
    required this.onSelect,
    this.currentValue,
  });

  final List<List<String>> rows;
  final String? currentValue;
  final void Function(String value) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final val in row)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _GridCell(
                      value: val,
                      selected: val == currentValue,
                      onTap: () => onSelect(val),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(color: AppColors.muted)),
        ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.rose1.withValues(alpha: 0.2)
              : AppColors.gun1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.rose1 : AppColors.glassStroke,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.rose1 : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class _ClockPicker extends StatelessWidget {
  const _ClockPicker({required this.onSelect, this.currentValue});

  final String? currentValue;
  final void Function(String value) onSelect;

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    const radius = 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 원 배경
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.gun1,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassStroke),
                ),
              ),
              // 시계 숫자 12개
              for (var i = 0; i < 12; i++)
                _positionedClockCell(
                  size: size,
                  radius: radius,
                  index: i,
                  child: _ClockCell(
                    value: WindClock.hours[i],
                    selected: WindClock.hours[i] == currentValue,
                    onTap: () => onSelect(WindClock.hours[i]),
                  ),
                ),
              // 중앙 X (무풍)
              _ClockCell(
                value: WindClock.noWind,
                label: '무풍',
                selected: currentValue == WindClock.noWind,
                onTap: () => onSelect(WindClock.noWind),
                large: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(color: AppColors.muted)),
        ),
      ],
    );
  }

  Widget _positionedClockCell({
    required double size,
    required double radius,
    required int index,
    required Widget child,
  }) {
    // 12시(index 0) = 위, 시계방향
    final angle = (index * 30 - 90) * math.pi / 180.0;
    final dx = size / 2 + radius * math.cos(angle);
    final dy = size / 2 + radius * math.sin(angle);
    return Positioned(left: dx - 22, top: dy - 22, child: child);
  }
}

class _ClockCell extends StatelessWidget {
  const _ClockCell({
    required this.value,
    required this.selected,
    required this.onTap,
    this.label,
    this.large = false,
  });
  final String value;
  final String? label;
  final bool selected;
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sz = large ? 56.0 : 44.0;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: sz,
        height: sz,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.rose1.withValues(alpha: 0.25)
              : AppColors.gun2,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.rose1 : AppColors.glassStroke,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: large ? 20 : 15,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.rose1 : AppColors.text,
              ),
            ),
            if (label != null)
              Text(
                label!,
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}
