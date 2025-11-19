// lib/src/widgets/grid_painter.dart

import 'package:flutter/material.dart';
import '../models/calendar_config.dart';
import '../models/calendar_theme.dart';

/// Paints the calendar grid background
class GridPainter extends CustomPainter {
  GridPainter({
    required this.config,
    required this.theme,
    required this.numberOfColumns,
    required this.columnWidth,
  });

  final CalendarConfig config;
  final CalendarTheme theme;
  final int numberOfColumns;
  final double columnWidth;

  @override
  void paint(Canvas canvas, Size size) {
    _drawZebraStripes(canvas, size);
    _drawVerticalLines(canvas, size);
    _drawHorizontalLines(canvas, size);
  }

  void _drawZebraStripes(Canvas canvas, Size size) {
    final hours = config.dayEndHour - config.dayStartHour;
    final hourHeight = config.hourHeight;

    for (int i = 0; i < hours; i++) {
      if (i % 2 == 0) {
        final rect = Rect.fromLTWH(0, i * hourHeight, size.width, hourHeight);
        final paint = Paint()
          ..color = theme.zebraStripeOdd
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawVerticalLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.gridLineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= numberOfColumns; i++) {
      final x = i * columnWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawHorizontalLines(Canvas canvas, Size size) {
    final hours = config.dayEndHour - config.dayStartHour;
    final hourHeight = config.hourHeight;
    final slotsPerHour = 60 ~/ config.timeSlotDuration.inMinutes;

    for (int i = 0; i <= hours * slotsPerHour; i++) {
      final y = (i / slotsPerHour) * hourHeight;
      final isHourMark = i % slotsPerHour == 0;

      final paint = Paint()
        ..color = isHourMark ? theme.hourLineColor : theme.gridLineColor
        ..strokeWidth = isHourMark ? 1.5 : 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.theme != theme ||
        oldDelegate.numberOfColumns != numberOfColumns ||
        oldDelegate.columnWidth != columnWidth;
  }
}
