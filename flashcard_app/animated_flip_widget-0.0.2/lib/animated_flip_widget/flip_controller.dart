import 'dart:async';
import 'dart:math';

enum FlipDirection { vertical, horizontal }

/// `FlipController` class is used to control the animation of the flip.
class FlipController {

  final Duration flipDuration; // Replaces flipDuration originally in flip_widget

  FlipController({
    /// Inputted/desired flip animation duration
    this.flipDuration = const Duration(milliseconds: 400)
    });

  /// Actual flip duration which can change to 0 to allow widget to be reset without animation
  late Duration duration = flipDuration;

  /// Controller that emit the angle value of the animation
  final _angleController = StreamController<double>();

  /// The current angle of the flip animation
  /// This value can be accessed via the `angle` getter method
  double _angle = 0;

  double get angle => _angle;

  /// A Stream that emits the angle of the flip animation
  Stream<double> get angleStream => _angleController.stream;

  /// Triggers the flip animation by toggling between 0 and pi
  void flip() {
    duration = flipDuration;
    _angle = _angle == 0 ? pi : 0;
    _angleController.sink.add(_angle);
  }

  /// Returns widget to face up without flip animation
  void reset() {
    duration = const Duration(seconds: 0);
    _angle = 0;
    _angleController.sink.add(_angle);
  }

  /// Release resources when you are done with the controller
  void dispose() {
    _angleController.close();
  }
}
