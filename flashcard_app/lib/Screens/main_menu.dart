import 'package:flutter/material.dart';
import 'package:flashcard_app/Widgets/topic.dart';
import 'package:flashcard_app/Widgets/speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/Widgets/set.dart';
import '../notifications.dart';
import 'flashcard_menu.dart';
import 'package:flashcard_app/Widgets/screen_widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen(
      {super.key, required this.collectionPath, required this.topicName});

  final String collectionPath;
  final String topicName;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

final db = FirebaseFirestore.instance;

const needToReview = 0;
const topic = 1;
const set = 2;

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController searchBar = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    listenToNotification();
    super.initState();
  }

  listenToNotification() {
    NotificationService.onClickNotification.stream.listen((event) {
      if (event != null) {
        List<String> payload = event.split('|*split*|');
        final String collectionPath = payload[0];
        final String setName =
            payload.length > 1 ? payload[1] : 'Flashcard App';
        Navigator.push(
            context,
            createRoute(FlashcardMenuScreen(
              collectionPath: collectionPath,
              setName: setName,
            )));
        showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
                  child: TestOptionsDialog(
                    collectionPath: collectionPath,
                    setName: setName,
                    testOptions: {
                      'Shuffle': false,
                      'Reversed Review': false,
                    },
                  ),
                ));
        NotificationService.onClickNotification.add(null);
      }
    });
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
            }),
        floatingActionButton: HomeSpeedDial(
          collectionPath: widget.collectionPath,
        ),
        body: StreamBuilder(
          stream:
              db.collection(widget.collectionPath).orderBy('Type').snapshots(),
          // Takes in snapshot stream ordered by type
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: const CircularProgressIndicator());
            }
            if (snapshot.data!.docs.length < 2) {
              // Less than 2 because collection always contains info doc which will not be displayed
              return const Center(child: Text('Add a Set'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> items =
                snapshot.data!.docs;

            final filteredItems = items.where((item) {
              final data = item.data();
              final name = data['Name']?.toLowerCase() ?? '';
              return name.contains(
                  searchQuery); // If the item contains the search query, display the item
            }).toList();

            return ListView.builder(
              padding: EdgeInsets.only(bottom: 100),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                String id = filteredItems[index].id;
                String name =
                    filteredItems[index].data()['Name'] ?? 'Loading...';
                int type = filteredItems[index].data()['Type'] ?? 'Loading...';
                if (type == topic) {
                  return Topic(
                    name: name,
                    collectionPath: widget.collectionPath,
                    id: id,
                    onTap: () {
                      Navigator.push(
                          context,
                          createRoute(MainMenuScreen(
                            collectionPath: '${widget.collectionPath}/$id/$id',
                            topicName: name,
                          )));
                    },
                  );
                } else if (type == set) {
                  return Set(
                    name: name,
                    collectionPath: widget.collectionPath,
                    id: id,
                    onTap: () {
                      Navigator.push(
                          context,
                          createRoute(FlashcardMenuScreen(
                            collectionPath: '${widget.collectionPath}/$id/$id',
                            setName: name,
                          )));
                    },
                  );
                } else if (type == needToReview) {
                  return needToReviewWidget(context, widget.collectionPath, id);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ));
  }
}

Widget needToReviewWidget(
        BuildContext context, String collectionPath, String id) =>
    Card(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        onTap: () {
          Navigator.push(
              context,
              createRoute(FlashcardMenuScreen.reviewList(
                collectionPath: '$collectionPath/$id/$id',
                setName: 'Need to Review',
                appBarIcon: Icon(
                  Icons.star,
                  color: Color(0xfffcba03),
                ),
              )));
        },
        leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.star,
              color: Color(0xfffcba03),
              size: 30,
            )),
        title: Text(
          'Need to Review',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
