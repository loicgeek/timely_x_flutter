// lib/src/widgets/scroll_navigation_wrapper.dart

import 'package:flutter/material.dart';

/// Wraps horizontal scrolling to prevent conflicts with system back navigation gestures
///
/// This widget prevents the system's edge-swipe back gesture from interfering
/// with horizontal scrolling in the calendar. It does this by claiming the
/// horizontal drag gesture before the navigation system can intercept it.
class ScrollNavigationWrapper extends StatelessWidget {
  const ScrollNavigationWrapper({
    Key? key,
    required this.child,
    this.axis = Axis.horizontal,
  }) : super(key: key);

  final Widget child;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    // Only wrap if we're dealing with horizontal scrolling
    if (axis != Axis.horizontal) {
      return child;
    }

    return GestureDetector(
      // Claim horizontal drag gestures to prevent navigation
      onHorizontalDragStart: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragEnd: (_) {},
      // Use opaque to ensure we capture all gestures in this area
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
