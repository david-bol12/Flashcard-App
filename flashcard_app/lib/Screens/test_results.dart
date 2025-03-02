import 'dart:math';
import 'package:flashcard_app/Screens/basic_test.dart';
import 'flashcard_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/Widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({
    super.key,
    required this.correctFlashcards,
    required this.incorrectFlashcards,
    required this.reversedReview,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> correctFlashcards;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> incorrectFlashcards;
  final bool reversedReview;

  static const double iconSize = 80;

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {

  final ConfettiController _confettiController = ConfettiController(
    duration: Duration(seconds: 1),
  );

  String feedback (progress) {
    Map<double, String> feedbackResponses = {
      0.25 : 'Keep Practicing!',
      0.5 : 'Getting There!',
      0.75 : 'Great Work!',
      1.0 : 'Fantastic!'
    };
    for (double score in feedbackResponses.keys) {
      if (progress <= score) {
        if(score >= 0.75) {
          Future.delayed(
              Duration(milliseconds: 500),
                  () {
                _confettiController.play();
              }
          );
        }
        return feedbackResponses[score] ?? 'Good Job';
      }
    }
    return 'Good Job!';
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = widget.correctFlashcards.length;
    int incorrectCount = widget.incorrectFlashcards.length;
    double progress = (correctCount + incorrectCount) == 0
        ? 0
        : correctCount / (correctCount + incorrectCount);

    return Scaffold(
      appBar: AppBar(

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Stack(
              children: [
                Center(
                  child: Text(
                    'Test Complete!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Center(
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: -pi/2,
                    numberOfParticles: 10,
                    minBlastForce: 10,
                    maxBlastForce: 20,
                    colors: [
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.purple
                    ],
                  ),
                ),
              ]
            ),
            const SizedBox(height: 16),

            // Feedback
            Text(
              feedback(progress),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Correct and Incorrect Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatContainer(
                  label: 'Correct',
                  count: correctCount,
                  color: Colors.greenAccent,
                  icon: Icons.check,
                  flashcards: widget.correctFlashcards,
                ),
                _buildStatContainer(
                  label: 'Incorrect',
                  count: incorrectCount,
                  color: Colors.redAccent,
                  icon: Icons.close,
                  flashcards: widget.incorrectFlashcards,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Progress Bar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Progress: ${(value * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: progress < 1 ?
      FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context,
            createRoute(
              BasicTestScreen(
                flashcards: widget.incorrectFlashcards,
                reversedReview: widget.reversedReview,
              )
            )
          );
        },
        label: const Text('Retry'),
        icon: const Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ) : null,
    );
  }

// Simplified Stat Container
  Widget _buildStatContainer({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> flashcards,
  }) {
    return GestureDetector(
      onTap: () {
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 120,
        decoration: BoxDecoration(
          color: color.withAlpha(35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
