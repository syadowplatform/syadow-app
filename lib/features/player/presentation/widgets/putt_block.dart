import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/round_input_controller.dart';
import '../../domain/hole_data.dart';

/// 퍼트 하나 (웹 .putt-block 대응). 필드는 Step 하나만.
class PuttBlock extends ConsumerStatefulWidget {
  const PuttBlock({super.key, required this.holeId, required this.puttIndex});

  final String holeId;
  final int puttIndex;

  @override
  ConsumerState<PuttBlock> createState() => _PuttBlockState();
}

class _PuttBlockState extends ConsumerState<PuttBlock> {
  late final TextEditingController _stepCtrl;

  @override
  void initState() {
    super.initState();
    final p = _readPutt();
    _stepCtrl = TextEditingController(
      text: p.step == null ? '' : p.step!.toStringAsFixed(0),
    );
  }

  Putt _readPutt() {
    final list = ref.read(roundInputProvider).holes[widget.holeId]?.putts;
    if (list == null || widget.puttIndex >= list.length) {
      return Putt(index: widget.puttIndex + 1);
    }
    return list[widget.puttIndex];
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(roundInputProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gun1.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Row(
        children: [
          const Text(
            'Putt',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.rose1,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Step',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _stepCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
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
                  borderSide: const BorderSide(
                    color: AppColors.rose1,
                    width: 1.4,
                  ),
                ),
              ),
              onChanged: (v) {
                final n = double.tryParse(v);
                ctrl.updatePutt(
                  widget.holeId,
                  widget.puttIndex,
                  (p) => n == null
                      ? p.copyWith(clearStep: true)
                      : p.copyWith(step: n),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => ctrl.removePutt(widget.holeId, widget.puttIndex),
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
    );
  }
}
