import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/Widgets/screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_app/Widgets/flashcard.dart';
import 'package:animated_flip_widget/animated_flip_widget.dart';
import 'test_results.dart';

const double padding = 20;

class BasicTestScreen extends StatefulWidget {
  const BasicTestScreen({
    super.key,
    required this.flashcards,
    required this.reversedReview,
    required this.collectionPath,
    required this.setName
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> flashcards;
  final bool reversedReview;
  final String collectionPath;
  final String setName;

  @override
  State<BasicTestScreen> createState() => _BasicTestScreenState();
}

class _BasicTestScreenState extends State<BasicTestScreen> {

  List<QueryDocumentSnapshot<Map<String, dynamic>>> incorrectFlashcards = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> correctFlashcards = [];

  void forward () {
    setState(() {
      if(flashcardIndex >= widget.flashcards.length - 1) {
        Navigator.pop(context);
        Navigator.push(context, createRoute(
          TestResultsScreen(
            correctFlashcards: correctFlashcards,
            incorrectFlashcards: incorrectFlashcards,
            reversedReview: widget.reversedReview,
            collectionPath: widget.collectionPath,
            setName: widget.setName,
        )));
      }
      else {
        flashcardIndex++;
      }
      flipController.reset();
    });
  }

  int flashcardIndex = 0;
  FlipController flipController = FlipController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text((flashcardIndex + 1).toString()),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlashcardWidget(
              front: widget.reversedReview ? widget.flashcards[flashcardIndex].data()['Back'] : widget.flashcards[flashcardIndex].data()['Front'],
              back: widget.reversedReview ? widget.flashcards[flashcardIndex].data()['Front'] : widget.flashcards[flashcardIndex].data()['Back'],
              flipController: flipController,
              frontImage: widget.flashcards[flashcardIndex].data()['Front Image'],
              backImage: widget.flashcards[flashcardIndex].data()['Back Image'],
            ),
          ),
          FlashcardNavigator(
            onForward: () {
                forward();
            },
            onBack: () {
              setState(() {
                flashcardIndex -= flashcardIndex == 0 ?  0 : 1;
                flipController.reset();
              });
            },
            onRight: () {
                // db.collection(widget.collectionPath).doc(widget.flashcards[flashcardIndex].id)
                //     .update({'Status' : widget.flashcards[flashcardIndex].data()['Status'] + 1});
                correctFlashcards.add(widget.flashcards[flashcardIndex]);
                forward();
            },
            onWrong: () {
                // db.collection(widget.collectionPath).doc(widget.flashcards[flashcardIndex].id)
                //     .update({'Status' : widget.flashcards[flashcardIndex].data()['Status'] - 1});
                incorrectFlashcards.add(widget.flashcards[flashcardIndex]);
                forward();
            },
          ),
        ],
      )
    );
  }
}

class FlashcardNavigator extends StatelessWidget {

  final Function onForward;
  final Function onBack;
  final Function onRight;
  final Function onWrong;

  const FlashcardNavigator({
    super.key,
    required this.onForward,
    required this.onBack,
    required this.onRight,
    required this.onWrong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6.0,
                offset: const Offset(0, 5)
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {onBack();},
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {onWrong();},
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: const BoxDecoration(
                    color: Colors.redAccent
                ),
                child: const Center(
                  child: Icon(
                    Icons.close_rounded,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {onRight();},
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: const BoxDecoration(
                    color: Colors.greenAccent
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {onForward();},
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(100), bottomRight: Radius.circular(100)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
