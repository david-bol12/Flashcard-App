import 'package:flutter/material.dart';
import 'package:flashcard_app/Screens/main_menu.dart';
import 'package:flashcard_app/Icons/additional_icons.dart';

class Set extends StatelessWidget {
  const Set({
    super.key,
    required this.name,
    required this.collectionPath,
    required this.id
  });

  final String name;
  final String collectionPath;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            FlashcardIcons.flashcardIcon,
            color: Colors.grey,
            size: 32,
          )
        ),
        trailing: PopupMenuButton(
            iconSize: 20,
            icon: const Icon(Icons.edit),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: EditSet(
                        collectionPath: collectionPath,
                        id: id,
                        name: name,
                      ),
                    )
                ),
                child: const Text('Edit'),
              ),
              PopupMenuItem(
                onTap: () {
                  db.collection(collectionPath).doc(id).delete();
                },
                child: const Text('Delete'),
              ),
            ]
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Flashcard Set',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class CreateSet extends StatelessWidget {
  CreateSet({
    super.key,
    required this.collectionPath
  });

  final TextEditingController setName = TextEditingController();
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
            'Create a Set',
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
            controller: setName,
            decoration: const InputDecoration(
                hintText: 'Set Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                )
            ),
          ),
          const SizedBox(height: 10),
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
                  String id = DateTime.now().toString();
                  db.collection(collectionPath).doc(id).set({'Name' : setName.text, 'Type' : 2});
                  db.collection('$collectionPath/$id/$id').doc('~~info~~').set({'Type' : -1, 'Status' : 0});
                  // A collection must have at least 1 document -> info doc fulfills this
                  Navigator.pop(context);
                },
                child: const Text('Add Set'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditSet extends StatelessWidget {
  EditSet({
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

    void submitName (String newName) {
      db.collection(collectionPath).doc(id).update({'Name' : newName});
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0
            ),
          ),
          const SizedBox(height: 30,),
          TextField(
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'Set Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  )
              ),
              controller: editedName,
              onSubmitted: (String name) {
                submitName(name);
              }
          )
        ],
      ),
    );
  }
}