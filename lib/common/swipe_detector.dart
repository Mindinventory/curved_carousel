import 'package:flutter/material.dart';

class SwipeDetector extends StatefulWidget {
  const SwipeDetector(
      {Key? key,
      required this.child,
      required this.onSwipe,
      this.threshold = 10.0})
      : super(key: key);
  final Widget child;
  // minimum finger displacement to count as a swipe
  final double threshold;
  final void Function(bool) onSwipe;

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  double? _offsetX;

  bool? leftToRightSwipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: dragStart,
      onVerticalDragStart: dragStart,
      onHorizontalDragDown: dragStart,
      onVerticalDragDown: dragStart,
      onHorizontalDragEnd: dragEnd,
      onVerticalDragEnd: dragEnd,
      child: widget.child,
    );
  }

  void dragStart(event) {
    if (_offsetX != null) {
      if ((_offsetX! - event.globalPosition.dx).abs() > widget.threshold) {
        leftToRightSwipe = _offsetX! < event.globalPosition.dx;
      }
    }
    _offsetX = event.globalPosition.dx;
  }

  void dragEnd(event) {
    if (leftToRightSwipe != null) {
      widget.onSwipe(leftToRightSwipe!);
    }
    _offsetX = null;
  }
}
