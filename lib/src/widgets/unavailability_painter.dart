// lib/src/widgets/unavailability_painter.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/business_hours.dart';

/// Paints unavailability patterns on the calendar grid
class UnavailabilityPainter extends CustomPainter {
  UnavailabilityPainter({
    required this.unavailabilityPeriods,
    required this.hourHeight,
    required this.dayStartHour,
    required this.cellWidth,
    required this.cellLeft,
    this.defaultStyle = const UnavailabilityStyle(),
  });

  final List<({TimePeriod period, UnavailabilityStyle style})>
  unavailabilityPeriods;
  final double hourHeight;
  final int dayStartHour;
  final double cellWidth;
  final double cellLeft;
  final UnavailabilityStyle defaultStyle;

  @override
  void paint(Canvas canvas, Size size) {
    for (final unavailability in unavailabilityPeriods) {
      _paintUnavailability(canvas, unavailability.period, unavailability.style);
    }
  }

  void _paintUnavailability(
    Canvas canvas,
    TimePeriod period,
    UnavailabilityStyle style,
  ) {
    final startY = (period.startTime - dayStartHour) * hourHeight;
    final endY = (period.endTime - dayStartHour) * hourHeight;
    final height = endY - startY;

    if (height <= 0) return;

    // Background paint
    final bgPaint = Paint()
      ..color = style.backgroundColor.withValues(alpha: style.opacity)
      ..style = PaintingStyle.fill;

    // Compute which hour rows this unavailability covers
    final startHour = period.startTime.floor();
    final endHour = period.endTime.ceil();

    for (int h = startHour; h < endHour; h++) {
      // Each cell's Y boundaries
      final cellStartY = (h - dayStartHour) * hourHeight;
      final cellEndY = ((h + 1) - dayStartHour) * hourHeight;

      // Clip the unavailability to this cell
      final top = math.max(startY, cellStartY);
      final bottom = math.min(endY, cellEndY);
      final cellHeight = bottom - top;

      if (cellHeight <= 0) continue;

      final rect = Rect.fromLTWH(0, top, cellWidth, cellHeight);

      // Draw background
      canvas.drawRect(rect, bgPaint);

      // Draw pattern
      switch (style.pattern) {
        case UnavailabilityPattern.solid:
          break;
        case UnavailabilityPattern.diagonalLines:
          _paintDiagonalLines(canvas, rect, style, reverse: false);
          break;
        case UnavailabilityPattern.diagonalLinesReverse:
          _paintDiagonalLines(canvas, rect, style, reverse: true);
          break;
        case UnavailabilityPattern.crossHatch:
          _paintDiagonalLines(canvas, rect, style, reverse: false);
          _paintDiagonalLines(canvas, rect, style, reverse: true);
          break;
        case UnavailabilityPattern.horizontalLines:
          _paintHorizontalLines(canvas, rect, style);
          break;
        case UnavailabilityPattern.verticalLines:
          _paintVerticalLines(canvas, rect, style);
          break;
        case UnavailabilityPattern.dots:
          _paintDots(canvas, rect, style);
          break;
        case UnavailabilityPattern.grid:
          _paintHorizontalLines(canvas, rect, style);
          _paintVerticalLines(canvas, rect, style);
          break;
        case UnavailabilityPattern.custom:
          break;
      }

      // Draw border
      if (style.showBorder) {
        final borderPaint = Paint()
          ..color = style.borderColor.withValues(alpha: style.opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.borderWidth;
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  void _paintDiagonalLines(
    Canvas canvas,
    Rect rect,
    UnavailabilityStyle style, {
    bool reverse = false,
  }) {
    canvas.save(); // Save current canvas state
    canvas.clipRect(rect); // Clip to this cell rect

    final paint = Paint()
      ..color = style.patternColor.withValues(alpha: style.opacity)
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke;

    final spacing = style.lineSpacing;

    for (double x = -rect.height; x <= rect.width; x += spacing) {
      if (reverse) {
        final start = Offset(rect.right - x, rect.top);
        final end = Offset(rect.right - x - rect.height, rect.bottom);
        canvas.drawLine(start, end, paint);
      } else {
        final start = Offset(rect.left + x, rect.top);
        final end = Offset(rect.left + x + rect.height, rect.bottom);
        canvas.drawLine(start, end, paint);
      }
    }

    canvas.restore(); // Restore canvas to remove clipping
  }

  void _paintHorizontalLines(
    Canvas canvas,
    Rect rect,
    UnavailabilityStyle style,
  ) {
    final paint = Paint()
      ..color = style.patternColor.withValues(alpha: style.opacity)
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke;

    final spacing = style.lineSpacing;
    final lines = (rect.height / spacing).ceil();

    for (int i = 0; i <= lines; i++) {
      final y = rect.top + (i * spacing);
      if (y <= rect.bottom) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
      }
    }
  }

  void _paintVerticalLines(
    Canvas canvas,
    Rect rect,
    UnavailabilityStyle style,
  ) {
    final paint = Paint()
      ..color = style.patternColor.withOpacity(style.opacity)
      ..strokeWidth = style.lineWidth
      ..style = PaintingStyle.stroke;

    final spacing = style.lineSpacing;
    final lines = (rect.width / spacing).ceil();

    for (int i = 0; i <= lines; i++) {
      final x = rect.left + (i * spacing);
      if (x <= rect.right) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
      }
    }
  }

  void _paintDots(Canvas canvas, Rect rect, UnavailabilityStyle style) {
    final paint = Paint()
      ..color = style.patternColor.withOpacity(style.opacity)
      ..style = PaintingStyle.fill;

    final spacing = style.lineSpacing;
    final radius = style.lineWidth;

    final cols = (rect.width / spacing).ceil();
    final rows = (rect.height / spacing).ceil();

    for (int row = 0; row <= rows; row++) {
      for (int col = 0; col <= cols; col++) {
        final x = rect.left + (col * spacing);
        final y = rect.top + (row * spacing);

        if (x <= rect.right && y <= rect.bottom) {
          canvas.drawCircle(Offset(x, y), radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(UnavailabilityPainter oldDelegate) {
    return unavailabilityPeriods != oldDelegate.unavailabilityPeriods ||
        hourHeight != oldDelegate.hourHeight ||
        dayStartHour != oldDelegate.dayStartHour ||
        cellWidth != oldDelegate.cellWidth ||
        cellLeft != oldDelegate.cellLeft ||
        defaultStyle != oldDelegate.defaultStyle;
  }
}
