// lib/src/widgets/slot_highlight_painter.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/available_slots.dart';

/// Paints available slot highlights on the calendar grid
class SlotHighlightPainter extends CustomPainter {
  SlotHighlightPainter({
    required this.slots,
    required this.config,
    required this.hourHeight,
    required this.dayStartHour,
    required this.cellWidth,
    required this.cellLeft,
    this.onSlotTap,
  });

  final List<AvailableSlot> slots;
  final SlotHighlightConfig config;
  final double hourHeight;
  final int dayStartHour;
  final double cellWidth;
  final double cellLeft;
  final void Function(AvailableSlot)? onSlotTap;

  @override
  void paint(Canvas canvas, Size size) {
    for (final slot in slots) {
      _paintSlot(canvas, slot);
    }
  }

  void _paintSlot(Canvas canvas, AvailableSlot slot) {
    final rect = _calculateSlotRect(slot);
    if (rect.height <= 0) return;

    final color = _getColorForSlot(slot);

    switch (config.style) {
      case SlotHighlightStyle.none:
        // No highlighting
        break;

      case SlotHighlightStyle.subtle:
        _paintSubtle(canvas, rect, color);
        break;

      case SlotHighlightStyle.border:
        _paintBorder(canvas, rect);
        break;

      case SlotHighlightStyle.emphasized:
        _paintEmphasized(canvas, rect, color);
        break;

      case SlotHighlightStyle.gradient:
        _paintGradient(canvas, rect, color);
        break;

      case SlotHighlightStyle.custom:
        // Custom style handled by builder
        break;
    }

    // Draw slot info if configured
    if (config.showCapacity || config.showPrice) {
      _paintSlotInfo(canvas, rect, slot);
    }
  }

  Rect _calculateSlotRect(AvailableSlot slot) {
    final startHour = slot.startTime.hour + (slot.startTime.minute / 60.0);
    final endHour = slot.endTime.hour + (slot.endTime.minute / 60.0);

    final top = (startHour - dayStartHour) * hourHeight;
    final bottom = (endHour - dayStartHour) * hourHeight;
    final height = bottom - top;

    return Rect.fromLTWH(cellLeft, top, cellWidth, height);
  }

  Color _getColorForSlot(AvailableSlot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return config.availableColor;
      case SlotStatus.tentative:
        return config.tentativeColor;
      case SlotStatus.blocked:
      case SlotStatus.past:
        return config.blockedColor;
    }
  }

  void _paintSubtle(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(config.opacity)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _paintBorder(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = config.borderColor
      ..strokeWidth = config.borderWidth
      ..style = PaintingStyle.stroke;

    // Add slight inset to prevent overlap with grid lines
    final insetRect = Rect.fromLTRB(
      rect.left + 1,
      rect.top + 1,
      rect.right - 1,
      rect.bottom - 1,
    );

    canvas.drawRect(insetRect, paint);
  }

  void _paintEmphasized(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(config.opacity)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    // Add subtle border
    final borderPaint = Paint()
      ..color = color.withOpacity(config.opacity * 2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, borderPaint);
  }

  void _paintGradient(Canvas canvas, Rect rect, Color color) {
    final gradient = ui.Gradient.linear(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.bottom),
      [
        color.withOpacity(config.opacity * 0.5),
        color.withOpacity(config.opacity),
        color.withOpacity(config.opacity * 0.5),
      ],
      [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _paintSlotInfo(Canvas canvas, Rect rect, AvailableSlot slot) {
    // Only show info if slot is tall enough
    if (rect.height < 30) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final infoLines = <String>[];

    if (config.showCapacity && slot.capacity > 1) {
      infoLines.add('${slot.remainingCapacity}/${slot.capacity}');
    }

    if (config.showPrice && slot.price != null) {
      infoLines.add('\$${slot.price!.toStringAsFixed(2)}');
    }

    if (infoLines.isEmpty) return;

    final infoText = infoLines.join('\n');

    textPainter.text = TextSpan(
      text: infoText,
      style: TextStyle(
        fontSize: 10,
        color: Colors.black.withOpacity(0.6),
        fontWeight: FontWeight.w500,
      ),
    );

    textPainter.layout(maxWidth: rect.width - 8);

    // Center the text in the slot
    final textOffset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(SlotHighlightPainter oldDelegate) {
    return slots != oldDelegate.slots ||
        config != oldDelegate.config ||
        hourHeight != oldDelegate.hourHeight ||
        dayStartHour != oldDelegate.dayStartHour ||
        cellWidth != oldDelegate.cellWidth ||
        cellLeft != oldDelegate.cellLeft;
  }
}
