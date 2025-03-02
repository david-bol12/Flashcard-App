import 'dart:math';
import 'package:flutter/material.dart';

import 'flip_controller.dart';

/// This widget creates an animation of a flipping card.
///
/// It takes three required parameters: `front`, `back`, and `controller`.
/// `front` and `back` are the `Widget`s that will be displayed on the front and back of the card, respectively.
/// `controller` is an instance of the `FlipController` class, which is responsible for controlling the animation of the flip.
///
/// The widget also takes two optional parameters: `clickable` and `flipDuration`.
/// `clickable` is a boolean that indicates whether the card should be clickable or not.
/// If `clickable` is true, then the card will flip when it is tapped. If `clickable` is false, then the card will not respond to taps.
/// The default value is true.
///
/// `flipDuration` is a `Duration` type that specifies how long the flipping animation should take. The default value is 400 milliseconds.
///
/// `flipDirection` is an enumeration that indicates the direction of flipping, either horizontally or vertically. The default value is vertical.
///
/// Usage:
///
/// ```dart
/// FlipController controller = FlipController();
///
/// ...
///
/// AnimatedFlipWidget(
///   front: MyFrontWidget(),
///   back: MyBackWidget(),
///   controller: controller,
///   flipDuration: Duration(milliseconds: 800),
///   flipDirection: FlipDirection.Horizontal,
/// ),
///
/// ...
///
///  controller.flip();
///
/// ```
class AnimatedFlipWidget extends StatelessWidget {
  const AnimatedFlipWidget({
    required this.front,
    required this.back,
    required this.controller,
    this.clickable = true,
    this.flipDirection = FlipDirection.vertical,
    super.key,
  });

  /// Widget that will be displayed on the front of the card
  final Widget front;

  /// Widget that will be displayed on the back of the card
  final Widget back;

  /// `FlipController` class is used to control the animation of the flip.
  final FlipController controller;

  /// indicates whether the card should be clickable or not.
  final bool clickable;

  /// Indicates the direction of flipping, either horizontally or vertically
  final FlipDirection flipDirection;

  @override
  Widget build(BuildContext context) {
    bool isFront = true;
    return GestureDetector(
      onTap: clickable
          ? () {
              controller.flip();
            }
          : null,
      child: StreamBuilder<double>(
        stream: controller.angleStream,
        builder: (context, angle) {
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: angle.data ?? 0),
            duration: controller.duration,
            builder: (_, value, __) {
              if (value >= (pi / 2)) {
                isFront = false;
              } else {
                isFront = true;
              }

              final transform = Matrix4.identity()..setEntry(3, 2, 0.001);

              switch (flipDirection) {
                case FlipDirection.vertical:
                  transform.rotateX(value);
                  break;
                case FlipDirection.horizontal:
                  transform.rotateY(value);
              }

              return Transform(
                alignment: Alignment.center,
                transform: transform,
                child: isFront
                    ? front
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateX(
                              flipDirection == FlipDirection.vertical ? pi : 0)
                          ..rotateY(flipDirection == FlipDirection.horizontal
                              ? pi
                              : 0),
                        child: back,
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
