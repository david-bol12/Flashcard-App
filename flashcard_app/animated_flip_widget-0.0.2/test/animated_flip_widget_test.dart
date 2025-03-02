import 'dart:math';

import 'package:animated_flip_widget/animated_flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedFlipWidget', () {
    testWidgets('front property', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
          ),
        ),
      );

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);
      // Check if the back widget is not displayed
      expect(find.text('Back'), findsNothing);

      // Simulate a flip
      controller.flip();
      await tester.pumpAndSettle(duration);

      // Check if the front widget is not displayed
      expect(find.text('Front'), findsNothing);
      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('back property', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
          ),
        ),
      );

      // Check if the back widget is not displayed
      expect(find.text('Back'), findsNothing);

      // Simulate a flip
      controller.flip();
      await tester.pumpAndSettle(duration);

      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('clickable property', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
            clickable: true,
          ),
        ),
      );

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);

      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Reset controller
      controller.flip();
      await tester.pump();
    });

    testWidgets('clickable property set to false', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
            clickable: false,
          ),
        ),
      );

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pump();

      // Check if the front widget is still displayed
      expect(find.text('Front'), findsOneWidget);
    });

    testWidgets('flipDuration property', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
          ),
        ),
      );
      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration + const Duration(milliseconds: 10));

      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration + const Duration(milliseconds: 10));

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);
    });

    testWidgets('flipDirection property - horizontal', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
            flipDirection: FlipDirection.horizontal,
          ),
        ),
      );

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);

      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);
      await tester.pumpAndSettle(duration);

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);
    });

    testWidgets('flipDirection property - vertical', (tester) async {
      const front = Text('Front');
      const back = Text('Back');
      final controller = FlipController();
      const duration = Duration(milliseconds: 800);
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedFlipWidget(
            front: front,
            back: back,
            controller: controller,
            flipDirection: FlipDirection.vertical,
          ),
        ),
      );

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);

      // Check if the back widget is displayed
      expect(find.text('Back'), findsOneWidget);

      // Simulate a tap
      await tester.tap(find.byType(AnimatedFlipWidget));
      await tester.pumpAndSettle(duration);

      // Check if the front widget is displayed
      expect(find.text('Front'), findsOneWidget);
    });
  });

  group('FlipController', () {
    test('initial angle', () {
      final controller = FlipController();
      expect(controller.angle, 0);
    });

    test('flip method', () {
      final controller = FlipController();
      controller.flip();
      expect(controller.angle, pi);
      controller.flip();
      expect(controller.angle, 0);
    });

    test('angleStream', () async {
      final controller = FlipController();
      controller.flip();
      double angle = -1;
      final subscription =
          controller.angleStream.listen((value) => angle = value);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(angle, pi);
      controller.flip();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(angle, 0);
      subscription.cancel();
    });
  });
}
