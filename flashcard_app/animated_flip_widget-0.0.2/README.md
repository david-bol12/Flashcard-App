⭐ A flutter package I made a copy of as I needed to edit the 'FlipController' class to include a reset method
 ```dart
void reset() {
    duration = const Duration(seconds: 0);
    _angle = 0;
    _angleController.sink.add(_angle);
  }
```

# Animated Flip Card
A Flutter package that creates an animation of a flipping card.


<img src="https://raw.githubusercontent.com/tajaouart/animated_flip_widget/main/animated_flip_widget.gif" height="600"/>



## Features
- Creates an animation of a flipping card
- Allows you to display different widgets on the front and back of the card
- Includes a `FlipController` class to control the animation of the flip
- Allows you to specify whether the card should be clickable or not
- Allows you to specify the duration of the flipping animation
- Allows you to specify the direction of the flipping animation (horizontal or vertical)

## Getting started
To use this package, add `animated_flip_card` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
animated_flip_card: <latest version>
```

## Usage
To use the `AnimatedFlipWidget`, you must pass in three required parameters: `front`, `back`, and `controller`.

```dart
AnimatedFlipWidget(
  front: Text('Front'),
  back: Text('Back'),
  controller: _controller,
)
```


## Usage
To use the `AnimatedFlipWidget`, you must pass in three required parameters: `front`, `back`, and `controller`.

```dart
AnimatedFlipWidget(
  front: Text('Front'),
  back: Text('Back'),
  controller: _controller,
)
```

You can also specify the optional parameters:

```dart
AnimatedFlipWidget(
  front: Text('Front'),
  back: Text('Back'),
  controller: _controller,
  clickable: true,
  flipDuration: Duration(milliseconds: 600),
  flipDirection: FlipDirection.Horizontal,
)
```

You can control the animation of the flip by calling the flip() method on the FlipController instance.

```dart
_controller.flip();
```

## Additional information

- This package uses the `TweenAnimationBuilder` widget to build a tween animation that rotates the card based on the angle of the `controller`.
- It also has an `enum` class `FlipDirection` that allows you to define the direction of flipping horizontally or vertically.
- A sample project demonstrating how to use the package is available in the `example` directory of this package



