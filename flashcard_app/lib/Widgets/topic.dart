import 'package:flutter/material.dart';
import 'package:flashcard_app/Screens/main_menu.dart';

class Topic extends StatelessWidget {
  const Topic({
    super.key,
    required this.name,
    required this.collectionPath,
    required this.id,
    required this.onTap,
  });

  final String name;
  final String collectionPath;
  final String id;
  final Function onTap;

  //TODO DRY Code
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () {
          onTap();
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.folder,
              color: Colors.grey,
            )),
        trailing: PopupMenuButton(
            iconSize: 20,
            icon: const Icon(Icons.edit),
            itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                              child: EditTopic(
                                collectionPath: collectionPath,
                                id: id,
                                name: name,
                              ),
                            )),
                    child: const Text('Edit'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      db.collection(collectionPath).doc(id).delete();
                    },
                    child: const Text('Delete'),
                  ),
                ]),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Topic',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class CreateTopic extends StatelessWidget {
  CreateTopic({super.key, required this.collectionPath});

  final TextEditingController topicName = TextEditingController();
  final String collectionPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Create a Topic',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            style: const TextStyle(
              fontSize: 14,
            ),
            controller: topicName,
            decoration: const InputDecoration(
                hintText: 'Topic Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              TextButton(
                onPressed: () {
                  String id = DateTime.now().toString(); // Using current date as ensures unique id
                  db // Instance of Firebase Firestore
                      .collection(collectionPath)
                      .doc(id)
                      .set({'Name': topicName.text, 'Type': 1});
                  db
                      .collection('$collectionPath/$id/$id')
                      .doc('~~info~~') // Creating an info doc keeps the Firestore Collection open
                      .set({'Type': -1});
                  Navigator.pop(context);
                },
                child: const Text('Add Topic'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditTopic extends StatelessWidget {
  EditTopic({
    super.key,
    required this.collectionPath,
    required this.id,
    required this.name,
  });

  final String collectionPath;
  final String id;
  final TextEditingController editedName = TextEditingController();
  final String name;

  @override
  Widget build(BuildContext context) {
    editedName.text = name;

    void submitName(String newName) {
      db.collection(collectionPath).doc(id).update({'Name': newName});
      Navigator.pop(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Edit Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'Topic Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)))),
              controller: editedName,
              onSubmitted: (String name) {
                submitName(name);
              })
        ],
      ),
    );
  }
}
