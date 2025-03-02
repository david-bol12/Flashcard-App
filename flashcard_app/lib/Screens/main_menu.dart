import 'package:flutter/material.dart';
import 'package:flashcard_app/Widgets/topic.dart';
import 'package:flashcard_app/Widgets/speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/Widgets/set.dart';
import '../notifications.dart';
import 'flashcard_menu.dart';
import 'package:flashcard_app/Widgets/screen_widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({
    super.key,
    required this.collectionPath,
    required this.topicName
  });

  final String collectionPath;
  final String topicName;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

final db = FirebaseFirestore.instance;

class _MainMenuScreenState extends State<MainMenuScreen> {

  final TextEditingController searchBar = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    listenToNotification();
    super.initState();
  }

  listenToNotification() {
    NotificationService.onClickNotification.stream.listen(
      (event) {
        if(event != null) {
          final String collectionPath = event;
          Navigator.push(context, createRoute(FlashcardMenuScreen(collectionPath: collectionPath, setName: 'Flashcard App',)));
          showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                child: TestOptionsDialog(collectionPath: collectionPath,),
              )
          );
          NotificationService.onClickNotification.add(null);
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: mainAppBar(
          title: widget.topicName,
          searchBarController: searchBar,
          onSearch: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          }
        ),
        floatingActionButton: HomeSpeedDial(collectionPath: widget.collectionPath,),
        body: StreamBuilder(
          stream: db.collection(widget.collectionPath).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: const CircularProgressIndicator());
            }
            if (snapshot.data!.docs.length < 2) {
              return const Center(child: Text('Add a Set'));
            }

            final flashcards = snapshot.data!.docs;

            final filteredFlashcards = flashcards.where((flashcard) {
              final data = flashcard.data();
              final name = data['Name']?.toLowerCase() ?? '';
              return name.contains(searchQuery);
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              scrollDirection: Axis.vertical,
              itemCount: filteredFlashcards.length,
              itemBuilder: (context, index) {
                String id = filteredFlashcards[index].id;
                String name = filteredFlashcards[index].data()['Name'] ?? 'Loading...';
                String type = filteredFlashcards[index].data()['Type'] ?? 'Loading...';
                Color color = Color(int.parse(filteredFlashcards[index].data()['Color'] ?? '0xFFFFFFFF'));
                if(type == 'Topic') {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(context, createRoute(MainMenuScreen(collectionPath: '${widget.collectionPath}/$id/$id', topicName: name,)));
                      },
                      child: Topic(name: name, collectionPath: widget.collectionPath, id: id, color: color,)
                  );
                }
                else if(type == 'Set') {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(context, createRoute(FlashcardMenuScreen(collectionPath: '${widget.collectionPath}/$id/$id', setName: name,)));
                      },
                      child: Set(name: name, collectionPath: widget.collectionPath, id: id,)
                  );
                }
                else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        )
    );
  }
}



