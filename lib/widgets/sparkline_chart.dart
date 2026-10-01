import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SparklineChart extends StatelessWidget {
  final List<double> data;
  final bool isBullish;
  final double width;
  final double height;
  final bool showFill;

  const SparklineChart({
    super.key,
    required this.data,
    required this.isBullish,
    this.width = 68,
    this.height = 32,
    this.showFill = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          lineColor: isBullish ? AppColors.bullish : AppColors.bearish,
          showFill: showFill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showFill;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.showFill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    final double stepX = size.width / (data.length - 1);

    final Path path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double normalized = (data[i] - minVal) / range;
      // Invert Y so highest value is at top
      final double y = size.height - (normalized * (size.height - 4)) - 2;
      final double x = i * stepX;
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill underneath the line
    if (showFill) {
      final Path fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.35),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Stroke line
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.showFill != showFill;
  }
}
