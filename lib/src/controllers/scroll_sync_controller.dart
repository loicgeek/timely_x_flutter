// lib/src/controllers/scroll_sync_controller.dart

import 'package:flutter/material.dart';

import '../utils/date_time_utils.dart';

/// Controller for synchronizing scroll positions
class ScrollSyncController {
  ScrollSyncController() {
    horizontalScrollController = ScrollController()
      ..addListener(_onHorizontalScroll);
    verticalScrollController = ScrollController()
      ..addListener(_onVerticalScroll);
  }

  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  final List<ScrollController> _linkedHorizontalControllers = [];
  final List<ScrollController> _linkedVerticalControllers = [];

  bool _isUpdating = false;

  /// Link a horizontal scroll controller
  void linkHorizontal(ScrollController controller) {
    _linkedHorizontalControllers.add(controller);
  }

  /// Link a vertical scroll controller
  void linkVertical(ScrollController controller) {
    _linkedVerticalControllers.add(controller);
  }

  /// Unlink a horizontal scroll controller
  void unlinkHorizontal(ScrollController controller) {
    _linkedHorizontalControllers.remove(controller);
  }

  /// Unlink a vertical scroll controller
  void unlinkVertical(ScrollController controller) {
    _linkedVerticalControllers.remove(controller);
  }

  void _onHorizontalScroll() {
    if (_isUpdating) return;
    _isUpdating = true;

    final offset = horizontalScrollController.offset;
    for (final controller in _linkedHorizontalControllers) {
      if (controller.hasClients) {
        controller.jumpTo(offset);
      }
    }

    _isUpdating = false;
  }

  void _onVerticalScroll() {
    if (_isUpdating) return;
    _isUpdating = true;

    final offset = verticalScrollController.offset;
    for (final controller in _linkedVerticalControllers) {
      if (controller.hasClients) {
        controller.jumpTo(offset);
      }
    }

    _isUpdating = false;
  }

  /// Scroll to a specific time
  void scrollToTime(DateTime time, {required double hourHeight}) {
    final dayStart = DateTime(time.year, time.month, time.day);
    final offset = DateTimeUtils.calculateVerticalOffset(
      time: time,
      dayStart: dayStart,
      hourHeight: hourHeight,
    );

    if (verticalScrollController.hasClients) {
      verticalScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Scroll to current time
  void scrollToNow({required double hourHeight}) {
    scrollToTime(DateTime.now(), hourHeight: hourHeight);
  }

  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    _linkedHorizontalControllers.clear();
    _linkedVerticalControllers.clear();
  }
}
