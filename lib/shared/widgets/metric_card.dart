import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 메트릭 카드 (2x2 그리드용).
/// 예: 스코어, 핸디캡, 드라이빙 거리, GIR%
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.status,
    this.statusColor,
    this.icon,
    this.trailingChart,
  });

  final String label;
  final String value;
  final String? unit;
  final String? status;
  final Color? statusColor;
  final IconData? icon;
  final Widget? trailingChart;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, size: 16, color: AppColors.dim),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (status != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    status!,
                    style: TextStyle(
                      color: statusColor ?? AppColors.good,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (trailingChart != null)
            SizedBox(height: 40, child: trailingChart!),
        ],
      ),
    );
  }
}
