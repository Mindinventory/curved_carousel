import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'common/swipe_detector.dart';


// Curved Carousel widget class.

class CurvedCarousel extends StatefulWidget {
  const CurvedCarousel(
      {Key? key,
      required this.itemBuilder,
      required this.itemCount,
      this.viewPortSize = 0.20,
      this.curveScale = 8,
      this.scaleMiddleItem = true,
      this.middleItemScaleRatio = 1.2,
      this.disableInfiniteScrolling = false,
      this.tiltItemWithcurve = true,
      this.horizontalPadding = 0,
      this.animationDuration = 300,
      this.onChangeEnd, 
      this.onChangeStart, 
      this.moveAutomatically = false, 
      this.automaticMoveDelay = 5000, 
      this.reverseAutomaticMovement = false
      })
      : super(key: key);

  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  /// to enable/disable infinite scrolling
  final bool disableInfiniteScrolling;

  /// scale middle item or not
  final bool scaleMiddleItem;

  /// provide viewport size
  final double viewPortSize;

  /// set curviness factor
  final double curveScale;

  /// selected middle item scale ratio
  final double middleItemScaleRatio;

  /// Does the items angle need to be follow to curve.
  /// If [true] the item angle will match the curve, if [false] the item will stay aligned with the screen
  final bool tiltItemWithcurve;

  /// The function to trigger when the item change animation is done
  final void Function(int index, bool automatic)? onChangeEnd;

  /// The function to trigger when the item change animation is start
  final void Function(int index, bool automatic)? onChangeStart;

  /// The padding to apply horizontally to the carousel
  final double horizontalPadding;

  /// The duration of the item change animation in milliseconds
  final int animationDuration;

  /// Does the change of item need to be automatic.
  /// If [true] use the [automaticMoveDelay] and [reverseAutomaticMovement] to  trigger automatically
  /// the change of item every [automaticMoveDelay] secondes.
  /// If [false] the only way to change item is to swipe left or right on the carousel
  final bool moveAutomatically;

  /// The delay between to automatic movement.
  /// If the [moveAutomatically] attribut is [true] then this variable control how often does the automatic
  /// change of item need to happend in milliseconds.
  final int automaticMoveDelay;

  /// The direction of the automatic movement
  /// If the [moveAutomatically] attribut is [true] then this controls the direction of the automatic change of item
  /// If this attribut is [true] then the movement will move the items backward. 
  final bool reverseAutomaticMovement;

  @override
  _CurvedCarouselState createState() => _CurvedCarouselState();
}

class _CurvedCarouselState extends State<CurvedCarousel>
    with SingleTickerProviderStateMixin {
   late int _selectedItemIndex;
  late int _visibleItemsCount;
  bool? _forward;
  bool _currentMovementIsAuto = false;
  int _viewPortIndex = 0;
  int _currentItemIndex = 0;
  int _lastViewPortIndex = -1;
  late double _itemWidth;
  late int _itemsCount;

  @override
  void initState() {
    super.initState();

    if(widget.moveAutomatically)
    {
    // set up the automatic movement of the caroussel
    Timer.periodic(
      Duration(milliseconds: widget.automaticMoveDelay), 
    (timer) {
      // do not execute the movement if the moveAutomaticly is false
      if(!widget.moveAutomatically) return;

      movement(true, widget.reverseAutomaticMovement);
    });
    }
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemsCount = 1 ~/ widget.viewPortSize;
    _itemWidth = (MediaQuery.of(context).size.width / _itemsCount);
    _visibleItemsCount = MediaQuery.of(context).size.width ~/ _itemWidth;
    if (_visibleItemsCount % 2 == 0) {
      if (_itemWidth * (_visibleItemsCount + 0.5) <=
          MediaQuery.of(context).size.width) {
        _visibleItemsCount++;
      } else {
        _visibleItemsCount--;
      }
    }
    _selectedItemIndex = (_visibleItemsCount - 1) ~/ 2;
    // update the first item index based on the visible item count
    _currentItemIndex = _visibleItemsCount~/2;
  }

  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      threshold: 1,
      onSwipe: (bool b) {
        if (!b) {
          // if user swipes right to left side
          if (_viewPortIndex + _visibleItemsCount < widget.itemCount ||
              !widget.disableInfiniteScrolling) {
            movement(false, false);
          }
        } else {
          // if user swipes left to right side
          if (_viewPortIndex > 0 || !widget.disableInfiniteScrolling) {
            movement(false, true);
          }
        }
      },
      child: FractionallySizedBox(
        widthFactor: 1,
        child: TweenAnimationBuilder(
          key: ValueKey(_viewPortIndex),
          curve: Curves.easeInOut,
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: widget.animationDuration),
          onEnd: () {
            // when the animation end trigger the on changed end function if set
            if(widget.onChangeEnd != null) {
              widget.onChangeEnd!.call(_currentItemIndex, _currentMovementIsAuto);
            }
          },
          builder: (context, double value, child) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // All visible items in viewport
                for (int i = 0; i < _visibleItemsCount; i++)
                  AnimatedItem(
                    offset: Offset(
                      getCurveX(i, _itemWidth, _visibleItemsCount, value),
                      getCurveY(i, _itemWidth, value),
                    ),
                    angle: widget.tiltItemWithcurve ? getAngle(i, _itemWidth, value) : 0,
                    scale: getItemScale(i, value),
                    child: widget.itemBuilder(
                        context, (i + _viewPortIndex) % widget.itemCount),
                  ),
                if (_forward != null && _forward! && value < 0.9)
                  AnimatedItem(
                    offset: Offset(
                      getCurveX(-1, _itemWidth,_visibleItemsCount, value),
                      getCurveY(-1, _itemWidth, value),
                    ),
                    angle: widget.tiltItemWithcurve ? getAngle(-1, _itemWidth, value) : 0,
                    scale: getItemScale(-1, value),
                    child: widget.itemBuilder(
                        context, (_viewPortIndex - 1) % widget.itemCount),
                  ),
                if (_forward != null && !_forward! && value < 0.9)
                  AnimatedItem(
                    offset: Offset(
                      getCurveX(_visibleItemsCount, _itemWidth,_visibleItemsCount, value),
                      getCurveY(_visibleItemsCount, _itemWidth, value),
                    ),
                    angle: widget.tiltItemWithcurve ? getAngle(_visibleItemsCount, _itemWidth, value) : 0,
                    scale: getItemScale(_visibleItemsCount, value),
                    child: widget.itemBuilder(
                        context,
                        (_viewPortIndex + _visibleItemsCount) %
                            widget.itemCount),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  /// calculate the current index of item to update it
  void updateCurrentIndex()
  {
    if(_forward != null)
    {
      _currentItemIndex = _forward! == true ? _currentItemIndex+1 : _currentItemIndex-1;
      _currentItemIndex = _currentItemIndex < 0 ? widget.itemCount-1 : _currentItemIndex == widget.itemCount ? 0 : _currentItemIndex;
    }
  }

  double interpolate(double prev, double current, double progress) {
    //progress will be between 0 and 1 !!
    return (prev + (progress * (current - prev)));
  }

  double getCurvePoint(int i) {
    if (_selectedItemIndex == i) {
      return 0;
    }
    return -((i - _selectedItemIndex).abs() *
            (i - _selectedItemIndex).abs() *
            widget.curveScale)
        .toDouble();
  }

  double getCurveX(int i, double itemWidth, int visibleItemCount, double value) {
    // calculate the correct padding to space element correctly when curved
    int middleItemIndex = visibleItemCount~/2;
    double centerPaddingCorrection = (i < middleItemIndex ? -i : i == middleItemIndex ? 0 : -(i-middleItemIndex)+middleItemIndex) * widget.curveScale;
    double horizontalPadding = i < middleItemIndex ? widget.horizontalPadding : i == middleItemIndex ? -widget.horizontalPadding/4 : -widget.horizontalPadding;
    double finalPadding = centerPaddingCorrection + horizontalPadding/2;

    // calculate the correct padding for the previous position in the interpolate during an animation
    int direction = _forward != null && _forward! == false ? 1 : -1;
    int transitionMiddleItemIndex = visibleItemCount~/2 + direction;
    double transitionCenterPaddingCorrection = (i < transitionMiddleItemIndex ? -i+direction : i == transitionMiddleItemIndex ? 0 : -(i+direction-transitionMiddleItemIndex)+transitionMiddleItemIndex) * widget.curveScale;
    double transitionHorizontalPadding = i < transitionMiddleItemIndex ? widget.horizontalPadding : i == transitionMiddleItemIndex ? -widget.horizontalPadding/4 : -widget.horizontalPadding;
    double finalTransitionPadding = transitionCenterPaddingCorrection + transitionHorizontalPadding/2;

    // add a padding to element added for animation purposes
    if(i == -1 || i == visibleItemCount)
    {
      centerPaddingCorrection = (visibleItemCount== i ? -1 : 1) * widget.curveScale/2 - horizontalPadding;
    }

    if (_forward != null) {
      double interpolatedValue = interpolate(
        -(_selectedItemIndex - i - (_forward! ? 1 : -1)) * itemWidth + finalTransitionPadding,
        -(_selectedItemIndex - i) * itemWidth + finalPadding,
        value);
      return interpolatedValue;
      
    }
    return -(_selectedItemIndex - i) * itemWidth + finalPadding ;
  }

  double getCurveY(int i, double itemWidth, double value) {
    if (_forward != null) {
      return interpolate(
          getCurvePoint(i + (_forward! ? 1 : -1)), getCurvePoint(i), value);
    }
    return getCurvePoint(i);
  }

  double getAngleValue(int i) {
    if (_selectedItemIndex == i) {
      return 0;
    }
    return -((i - _selectedItemIndex) * pi / (widget.curveScale + 5))
        .toDouble();
  }

  double getAngle(int i, double itemWidth, double value) {
    if (_lastViewPortIndex != -1) {
      return interpolate(
          getAngleValue(i + (_forward! ? 1 : -1)), getAngleValue(i), value);
    }
    return getAngleValue(i);
  }

  double getItemScale(int i, double value) {
    if (!widget.scaleMiddleItem) {
      return 1;
    }
    if (_lastViewPortIndex != -1) {
      if (_selectedItemIndex == i) {
        return interpolate(1, widget.middleItemScaleRatio, value);
      } else if (i + (_forward! ? 1 : -1) == _selectedItemIndex) {
        return interpolate(widget.middleItemScaleRatio, 1, value);
      }
    }
    if (_selectedItemIndex == i) {
      return widget.middleItemScaleRatio;
    } else {
      return 1;
    }
  }

  /// trigger a movement
  /// automaticMovement: if true set the current movement is auto variable to true
  /// reverse : if false move to the left if true move to right
  void movement(bool automaticMovement, bool reverse)
  {
    _currentMovementIsAuto = automaticMovement;
    if(reverse) moveLeft();
    else moveRight();
  }

  void moveRight() {
    _lastViewPortIndex = _viewPortIndex;
    _viewPortIndex = (_viewPortIndex + 1) % widget.itemCount;
    setState(() {});
    _forward = true;
    updateCurrentIndex();
    // call the on change started function if set
    if(widget.onChangeStart != null) widget.onChangeStart!.call(_currentItemIndex, _currentMovementIsAuto);
  }

  void moveLeft() {
    _lastViewPortIndex = _viewPortIndex;
    _viewPortIndex = _viewPortIndex - 1;
    if (_viewPortIndex < 0) {
      _viewPortIndex = widget.itemCount - 1;
    }
    setState(() {});
    _forward = false;
    updateCurrentIndex();
    // call the on change started function if set
    if(widget.onChangeStart != null) widget.onChangeStart!.call(_currentItemIndex, _currentMovementIsAuto);
  }
}

class AnimatedItem extends StatelessWidget {
  final Offset offset;
  final double angle;
  final double scale;
  final Widget child;

  const AnimatedItem(
      {Key? key,
      required this.offset,
      required this.angle,
      required this.scale,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}
