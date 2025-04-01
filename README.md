# Flashcard App
[Link to web version](https://flashcard-app-fe54f.web.app)<br/>

⚠️ Account system is not yet set up, feel free to add flashcards but please do not edit any prexisting flashcards ⚠️ <br/>

## Contents
[Screens](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#screens)
- [Menu Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#menu-screen)
- [Flashcard Set Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#flashcard-set-screen)
- [Test Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#test-screen)
- [Test Result Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#test-result-screen)
  
[Organisation System](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#organisation-system)
- [Creating a Topic](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-topic)
- [Creating a Set](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-set)
- [Creating a Flashcard](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-flashcard)
- [Adding an Image](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#adding-an-image)


## Screens

Menu Screen -> Menu Screen/Flashcard Set Screen

Flashcard Set Screen -> Test Screen -> Test Result Screen

### Menu Screen

Main Menu Screen contains:
  - Need to Review List
  - Any Topics/Sets in the current Collection Path
  - Search bar to search through Topics/Sets
  - Floating Action Button to add new Topics/Sets

Topics/Sets are displayed using a StreamBuilder

StreamBuilder takes in a snapshot from the current Collection Path and sorts the items within it based on their type, then filters them based on the search query in the search bar 

  ```dart
    StreamBuilder(
          stream:
              db.collection(widget.collectionPath).orderBy('Type').snapshots(), // Takes in snapshot stream ordered by type
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: const CircularProgressIndicator());
            }
            if (snapshot.data!.docs.length < 2) { // Less than 2 because collection always contains info doc which will not be displayed
              return const Center(child: Text('Add a Set'));
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> items = snapshot.data!.docs;

            final filteredItems = items.where((item) {
              final data = item.data();
              final name = data['Name']?.toLowerCase() ?? '';
              return name.contains(searchQuery); // If the item contains the search query, display the item
            }).toList();
  ```

Then they the list of filteredItems is intputted into a ListView.builder, displaying the Topic/Set

```dart
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
```

<img height="500" src="https://github.com/user-attachments/assets/41f59126-26e7-42c0-8a20-8576d1c73034">

### Flashcard Set Screen

### Test Screen

### Test Result Screen

## Organisation System

Topic -> Sub Topic/Set

Set -> Flashcard
- Topics are collections containing Flashcard Sets or other Topics
- Flashcard Sets are collections containing Flashcards

  <b> ** Types are saved as integers to make them easy to index on Menu Screen **</b>

### Creating a Topic

When creating a Topic a dialog box is shown where the user can input the Topic name
On creating the Topic the below function is called creating:
 - A document in the current Collection Path
 - A collection in said document
 - An info doc in said collection to keep the collection open. Firestore requires at least 1 doc in a collection.

 ```dart
String id = DateTime.now().toString(); // Using current date as ensures unique id
db // Instance of Firebase Firestore
    .collection(collectionPath) // Function takes collectionPath as a parameter
    .doc(id) // Creates a doc which stores the Topic collection
    .set({
       'Name': topicName.text, // Topic name taken from text field
       'Type': 1 // Type 1 = Topic
     });
db
    .collection('$collectionPath/$id/$id')
    .doc('~~info~~') // Creating an info doc keeps the Firestore Collection open
    .set({'Type': -1});
```

Topics can be edited/deleted by clicking the trailing edit icon

<img height="500" src="https://github.com/user-attachments/assets/5f38acf1-49d8-4441-9ed6-427fc03fed23">


### Creating a Set
<img height="500" src="https://github.com/user-attachments/assets/e863a0ff-24a9-44ec-904b-7cf7fbf15267">

### Creating a Flashcard
<img height="500" src="https://github.com/user-attachments/assets/4553a877-7613-44e7-a03f-e234bc719be7">

### Adding an Image
<img height="500" src="https://github.com/user-attachments/assets/a5d19901-af2e-4be6-9b0b-b9c6c2f58bcb">

