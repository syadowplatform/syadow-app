import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 작은 라인 차트 (메트릭 카드용 sparkline).
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color = AppColors.good,
    this.fillOpacity = 0.0,
  });

  final List<double> values;
  final Color color;
  final double fillOpacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        values: values,
        color: color,
        fillOpacity: fillOpacity,
      ),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.fillOpacity,
  });

  final List<double> values;
  final Color color;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);
    final stepX = size.width / (values.length - 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (fillOpacity > 0) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..color = color.withValues(alpha: fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // end dot
    final lastX = (values.length - 1) * stepX;
    final lastY = size.height - ((values.last - minV) / range) * size.height;
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

/// 가로 프로그레스 바 (그라데이션).
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.value, // 0.0 ~ 1.0
    this.height = 6,
    this.gradient = AppColors.neonGradient,
    this.backgroundColor = AppColors.cardStroke,
  });

  final double value;
  final double height;
  final Gradient gradient;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: backgroundColor),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),
        ],
      ),
    );
  }
}
