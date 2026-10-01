import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/coin_model.dart';

class InteractivePriceChart extends StatefulWidget {
  final Map<String, List<PricePoint>> historicalData;
  final bool isBullish;
  final Function(PricePoint?)? onSelectedPointChanged;
  final ValueChanged<String>? onTimeframeChanged;
  final bool isLoading;

  const InteractivePriceChart({
    super.key,
    required this.historicalData,
    required this.isBullish,
    this.onSelectedPointChanged,
    this.onTimeframeChanged,
    this.isLoading = false,
  });

  @override
  State<InteractivePriceChart> createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  String _selectedRange = '7D';
  int? _hoverIndex;

  final List<String> _ranges = ['1D', '7D', '30D', '1Y'];

  @override
  Widget build(BuildContext context) {
    // Pick selected range or first available non-empty range
    List<PricePoint> points = widget.historicalData[_selectedRange] ?? [];
    if (points.isEmpty && widget.historicalData.isNotEmpty) {
      points = widget.historicalData.values.firstWhere((p) => p.isNotEmpty, orElse: () => []);
    }

    PricePoint? activePoint =
        (_hoverIndex != null && _hoverIndex! >= 0 && _hoverIndex! < points.length)
            ? points[_hoverIndex!]
            : null;

    final double? highPrice = points.isNotEmpty ? points.map((p) => p.price).reduce(max) : null;
    final double? lowPrice = points.isNotEmpty ? points.map((p) => p.price).reduce(min) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeframe selector bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: _ranges.map((range) {
              final isSelected = range == _selectedRange;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_selectedRange != range) {
                      setState(() {
                        _selectedRange = range;
                        _hoverIndex = null;
                      });
                      widget.onSelectedPointChanged?.call(null);
                      widget.onTimeframeChanged?.call(range);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cardHighlight : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      range,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // High / Low Indicators Bar
        if (highPrice != null && lowPrice != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.bearish,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Low: ${Formatters.formatCurrency(lowPrice)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.bullish,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'High: ${Formatters.formatCurrency(highPrice)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Interactive Canvas Container
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth;
            const chartHeight = 220.0;

            if (points.isEmpty) {
              return Container(
                width: chartWidth,
                height: chartHeight,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading $_selectedRange chart data from API...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return GestureDetector(
              onHorizontalDragStart: (details) =>
                  _handleTouch(details.localPosition.dx, chartWidth, points),
              onHorizontalDragUpdate: (details) =>
                  _handleTouch(details.localPosition.dx, chartWidth, points),
              onHorizontalDragEnd: (_) => _handleTouchEnd(),
              onTapDown: (details) =>
                  _handleTouch(details.localPosition.dx, chartWidth, points),
              onTapUp: (_) => _handleTouchEnd(),
              onTapCancel: () => _handleTouchEnd(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: chartWidth,
                    height: chartHeight,
                    child: CustomPaint(
                      painter: _ChartPainter(
                        points: points,
                        lineColor: widget.isBullish ? AppColors.bullish : AppColors.bearish,
                        selectedIndex: _hoverIndex,
                      ),
                    ),
                  ),

                  // Floating Tooltip Badge when scrubbing
                  if (activePoint != null && _hoverIndex != null && points.isNotEmpty)
                    Positioned(
                      top: 4,
                      left: _clampTooltipPosition(
                        (_hoverIndex! / (points.length - 1)) * chartWidth,
                        chartWidth,
                        130,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.isBullish ? AppColors.bullish : AppColors.bearish,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.formatCurrency(activePoint.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(activePoint.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleTouch(double dx, double width, List<PricePoint> points) {
    if (points.isEmpty) return;
    final clampedX = dx.clamp(0.0, width);
    final index = ((clampedX / width) * (points.length - 1)).round();
    setState(() {
      _hoverIndex = index.clamp(0, points.length - 1);
    });
    widget.onSelectedPointChanged?.call(points[_hoverIndex!]);
  }

  void _handleTouchEnd() {
    setState(() {
      _hoverIndex = null;
    });
    widget.onSelectedPointChanged?.call(null);
  }

  double _clampTooltipPosition(double touchX, double totalWidth, double tooltipWidth) {
    double centered = touchX - (tooltipWidth / 2);
    return centered.clamp(8.0, totalWidth - tooltipWidth - 8.0);
  }

  String _formatTime(DateTime dt) {
    if (_selectedRange == '1D') {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}

class _ChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final Color lineColor;
  final int? selectedIndex;

  _ChartPainter({
    required this.points,
    required this.lineColor,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Draw horizontal grid lines
    final Paint gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final prices = points.map((p) => p.price).toList();
    double minVal = prices.reduce((a, b) => a < b ? a : b);
    double maxVal = prices.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    final double stepX = size.width / (points.length - 1);
    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final double normalized = (points[i].price - minVal) / range;
      // Leave padding at top and bottom
      final double y = size.height - (normalized * (size.height - 40)) - 20;
      final double x = i * stepX;
      offsets.add(Offset(x, y));
    }

    // Bezier path
    final Path path = Path()..moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Area fill with gradient
    final Path fillPath = Path.from(path);
    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.lineTo(offsets.first.dx, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Main line stroke
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Touch Indicator (Crosshair and Glow Dot)
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < offsets.length) {
      final selectedOffset = offsets[selectedIndex!];

      // Vertical line
      final Paint crosshairPaint = Paint()
        ..color = AppColors.textMuted.withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(selectedOffset.dx, 0),
        Offset(selectedOffset.dx, size.height),
        crosshairPaint,
      );

      // Glowing outer ring
      final Paint glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedOffset, 9, glowPaint);

      // Inner solid dot
      final Paint dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedOffset, 4.5, dotPaint);

      final Paint whiteDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedOffset, 2, whiteDot);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
