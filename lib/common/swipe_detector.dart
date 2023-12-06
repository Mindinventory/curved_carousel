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
  final void Function(bool, bool upToDownSwiped) onSwipe;

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  double? _offsetX;
  double? _offsetY;

  bool? leftToRightSwipe;
  bool? upToDownSwipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: dragStart,
      onVerticalDragStart: dragStartVertical,
      onVerticalDragUpdate: dragStartVertical,
      onHorizontalDragDown: dragStart,
      onVerticalDragDown: dragStartVertical,
      onHorizontalDragEnd: dragEnd,
      onVerticalDragEnd: dragEndVertical,
      child: widget.child,
    );
  }

  void dragStart(event) {
    if (_offsetX != null) {
      if ((_offsetX! - event.globalPosition.dx).abs() > widget.threshold) {
        leftToRightSwipe = _offsetX! < event.globalPosition.dx;
      }
    }
    debugPrint(leftToRightSwipe.toString());
    _offsetX = event.globalPosition.dx;
  }

  void dragEnd(event) {
    if (leftToRightSwipe != null) {
      widget.onSwipe(leftToRightSwipe!, false);
    }
    _offsetX = null;
  }

  void dragStartVertical(event) {
    if (_offsetY != null) {
      if ((_offsetY! - event.globalPosition.dy).abs() > widget.threshold) {
        upToDownSwipe = _offsetY! < event.globalPosition.dy;
      }
    }
    debugPrint(upToDownSwipe.toString());
    _offsetY = event.globalPosition.dy;
  }

  void dragEndVertical(event) {
    if (upToDownSwipe != null) {
      widget.onSwipe(upToDownSwipe!, true);
    }
    _offsetY = null;
  }
}
