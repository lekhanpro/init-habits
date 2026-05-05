import 'package:flutter/material.dart';

class ScoreSparkline extends StatelessWidget {
  final List<double> scores;
  final Color color;
  final double width;
  final double height;

  const ScoreSparkline({
    super.key,
    required this.scores,
    required this.color,
    this.width = 56,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return SizedBox(width: width, height: height);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparklinePainter(scores, color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> scores;
  final Color color;

  _SparklinePainter(this.scores, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;
    final maxV = scores.reduce((a, b) => a > b ? a : b).clamp(0.01, 1.0);
    final stepX = size.width / (scores.length - 1);
    final path = Path();
    for (int i = 0; i < scores.length; i++) {
      final x = i * stepX;
      final y = size.height - (scores[i] / maxV) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final stroke = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.scores != scores || old.color != color;
}
