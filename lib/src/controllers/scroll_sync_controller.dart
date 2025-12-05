// lib/src/controllers/scroll_sync_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/date_time_utils.dart';

/// Controller for synchronizing scroll positions with smooth physics
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

  // Track if we're actively scrolling to avoid interrupting momentum

  int? _frameCallbackId;

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
    _scheduleSync(() => _syncHorizontal());
  }

  void _onVerticalScroll() {
    if (_isUpdating) return;
    _scheduleSync(() => _syncVertical());
  }

  /// Schedule sync on next frame to batch updates and maintain smooth scrolling
  void _scheduleSync(VoidCallback syncCallback) {
    if (_frameCallbackId != null) return; // Already scheduled

    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback((_) {
      _frameCallbackId = null;
      if (!_isUpdating) {
        syncCallback();
      }
    });
  }

  void _syncHorizontal() {
    if (!horizontalScrollController.hasClients) return;

    _isUpdating = true;
    final position = horizontalScrollController.position;
    final offset = position.pixels;

    for (final controller in _linkedHorizontalControllers) {
      if (controller.hasClients) {
        _syncController(controller, offset, position);
      }
    }

    _isUpdating = false;
  }

  void _syncVertical() {
    if (!verticalScrollController.hasClients) return;

    _isUpdating = true;
    final position = verticalScrollController.position;
    final offset = position.pixels;

    for (final controller in _linkedVerticalControllers) {
      if (controller.hasClients) {
        _syncController(controller, offset, position);
      }
    }

    _isUpdating = false;
  }

  /// Sync a controller while respecting physics and momentum
  void _syncController(
    ScrollController target,
    double offset,
    ScrollPosition sourcePosition,
  ) {
    final targetPosition = target.position;

    // If the target is close enough, don't update to avoid jitter
    if ((targetPosition.pixels - offset).abs() < 0.5) {
      return;
    }

    // Check if source is actively being dragged or has momentum
    // ignore: invalid_use_of_protected_member
    final isDragging =
        sourcePosition is ScrollPositionWithSingleContext &&
        sourcePosition.activity?.isScrolling == true;

    if (isDragging) {
      // During active scrolling, use jumpTo for immediate response
      // but only if the difference is significant
      if ((targetPosition.pixels - offset).abs() > 1.0) {
        target.jumpTo(offset);
      }
    } else {
      // When not actively scrolling, use physics-based correction
      // This prevents interrupting momentum
      targetPosition.correctPixels(offset);
    }
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
    // Cancel any pending frame callbacks
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
      _frameCallbackId = null;
    }

    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    _linkedHorizontalControllers.clear();
    _linkedVerticalControllers.clear();
  }
}
