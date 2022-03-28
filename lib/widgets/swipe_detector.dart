import 'dart:math';

import 'package:flutter/widgets.dart';

class SwipeDetector extends StatelessWidget {
  final Function() onSwipeLeft;
  final Function() onSwipeRight;
  final Function() onSwipeUp;
  final Function() onSwipeDown;
  final Function() onSwipeUpLeft;
  final Function() onSwipeDownLeft;
  final Function() onSwipeUpRight;
  final Function() onSwipeDownRight;
  final Function() onEnd;
  final Widget child;

  const SwipeDetector({
    Key key,
    @required this.child,
    @required this.onSwipeLeft,
    @required this.onSwipeRight,
    @required this.onSwipeUp,
    @required this.onSwipeDown,
    @required this.onSwipeUpLeft,
    @required this.onSwipeDownLeft,
    @required this.onSwipeUpRight,
    @required this.onSwipeDownRight,
    @required this.onEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset p1;
    double angle = 0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: child,
      onPanStart: (details) {
        angle = null;
        p1 = details.localPosition;
      },
      onPanUpdate: (p2) {
        angle = _calculateAngle(
            p1.dx, p1.dy, p2.localPosition.dx, p2.localPosition.dy);
        if (angle == null) return;
        if (angle < 22.5 || angle >= 337.5) return onSwipeUp();
        if (angle >= 22.5 && angle < 67.5) return onSwipeUpRight();
        if (angle >= 67.5 && angle < 112.5) return onSwipeRight();
        if (angle >= 112.5 && angle < 157.5) return onSwipeDownRight();
        if (angle >= 157.5 && angle < 202.5) return onSwipeDown();
        if (angle >= 202.5 && angle < 247.5) return onSwipeDownLeft();
        if (angle >= 247.5 && angle < 292.5) return onSwipeLeft();
        return onSwipeUpLeft();
      },
      onPanEnd: (details) {
        return onEnd();
      },
    );
  }

  double _calculateAngle(double p1x, double p1y, double p2x, double p2y) {
    if (p1x == p2x && p1y == p2y) return null;
    double a = p1y - p2y;
    double b = p2x - p1x;
    if (a * a + b * b < 30) return null;
    double angle = 0;
    double angleRad = atan2(a, b);
    angle = (angleRad * 180) / pi;
    if (angle < 0) angle = 180 + angle;

    // print("($p1x , $p1y)");
    // print("($p2x , $p2y)");

    if (p1x < p2x && -p1y < -p2y) {
      // print("điểm bắt đầu ở bên trái và thấp hơn điểm kết thúc");
      return 90 - angle;
    }
    if (p1x < p2x && -p1y >= -p2y) {
      // print("điểm bắt đầu ở bên trái và cao hơn điểm kết thúc");
      return 270 - angle;
    }
    if (p1x >= p2x && -p1y >= -p2y) {
      // print("điểm bắt đầu ở bên phải và cao hơn điểm kết thúc");
      return 270 - angle;
    }
    // print("điểm bắt đầu ở bên phải và thấp hơn điểm kết thúc");
    return 450 - angle;
  }
}
