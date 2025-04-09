![Screen_Recording_20250403_153105-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/f42ca4fa-a6b4-499a-b13a-0ae275613ed6)# Flashcard App
Please feel free to view the Web App

[Link to Web App](https://flashcard-app-fe54f.web.app)<br/>

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
- [Reordering Flashcards](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#reordering-flashcards)

[CSV Conversion](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#csv-conversion)
- [Export CSV](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#export-csv)
- [Import CSV](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#import-csv)

[Need to Review List](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#need-to-review-list)

[Notification Service](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#notification-service)





## Screens

- [Menu Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#menu-screen)
- [Flashcard Set Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#flashcard-set-screen)
- [Test Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#test-screen)
- [Test Result Screen](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#test-result-screen)

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

Then they the list of filteredItems is intputted into a ListView.builder, displaying the Topic/Set Widget

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
            return const SizedBox.shrink(); //Can't return null so return invisible widget
          },
        );
```
<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/41f59126-26e7-42c0-8a20-8576d1c73034">
</p>

### Flashcard Set Screen
Flashcard Set Screen contains:
  - Any Flashcards in the current Collection Path
  - Search bar to search through Flashcards
  - Floating Action Button to add new Flashcards
  - Floating Action Button to begin Test
  - A trailing option button in the app bar to export/import flashcards as a CSV, and reorder flashcards

Similarly to the Menu Screen, the Flashcard Set Screen operates using a StreamBuilder taking in a snapshot stream from the current collection path (ordered by their index), filters the input based on the current search query, and displays the appropriate FlashcardInfo widgets using a ListView.builder

```dart
    StreamBuilder(
          stream:
              db.collection(widget.collectionPath).orderBy('Index').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: const CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text(widget.emptySetText));
            }
            final flashcards = snapshot.data!.docs;
            final filteredFlashcards = flashcards.where((flashcard) {
              final String front =
                  flashcard.data()['Front']?.toLowerCase() ?? '';
              final String back = flashcard.data()['Back']?.toLowerCase() ?? '';
              return front.contains(searchQuery) || back.contains(searchQuery);
            }).toList();

            return ListView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: filteredFlashcards.length,
                itemBuilder: (context, index) {
                  String id = filteredFlashcards[index].id;
                  String front =
                      filteredFlashcards[index].data()['Front'] ?? '';
                  String back = filteredFlashcards[index].data()['Back'] ?? '';
                  String type = filteredFlashcards[index].data()['Type'];
                  String? frontImage =
                      filteredFlashcards[index].data()['Front Image'];
                  String? backImage =
                      filteredFlashcards[index].data()['Back Image'];
                  if (type == 'Flashcard') {
                    return FlashcardInfo(
                      front: front,
                      back: back,
                      collectionPath: widget.collectionPath,
                      id: id,
                      frontImage: frontImage,
                      backImage: backImage,
                      reviewList: widget.reviewList,
                    );
                  }
                  return null;
                });
          }),
```

Each Flashcard Object has 6 parameters
```dart
    'Type': 'Flashcard', //TODO change to int type system
    'Front': flashcard.front,
    'Back': flashcard.back,
    'Index': snapshot.docs.length, // Index is used to order/reorder flashcards
    'Front Image': flashcard.frontImage,
    'Back Image': flashcard.backImage,
```

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/c32ad515-35c1-4c0a-b53a-99bcf4604df94">
</p>

Clicking the Test button displays a dialog box where the user can edit a number of test settings before beginning the test

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/3997cae8-2c79-4d93-9d43-4ff9f5d33468">
</p>

### Test Screen

Test Screen contains:
  - 1 Flippable Flashcard
  - FlashcardNavigator Widget

The Test Screen takes in a range of parameters including a list of Flashcards at the current Collection Path
```dart
    db
        .collection(widget.collectionPath)
        .orderBy('Index')
        .get() // Gets Collection Snapshot
        .then((flashcardsSnapshot) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
          flashcards = flashcardsSnapshot.docs;
      if (testOptions['Shuffle'] == true) {
        flashcards.shuffle();
      }
      if (context.mounted) {
        Navigator.push(
            context,
            createRoute(BasicTestScreen(
              flashcards: flashcards,
              removeOnCorrect: testOptions['Remove on Correct'] ?? false,
              reversedReview: testOptions['Reversed Review'] ?? false,
              collectionPath: widget.collectionPath,
              setName: widget.setName,
            )));
      }
    });
```

The Flashcard Widget uses the AnimatedFlipWidget package to flip the widget once tapped.

As the user cycles through the flashcards the Flashcard Widget displays the current flashcard's data

However when moving on to the next flashcard, i needed the Flashcard Widget to reset from whatever state it was currently in, to face-up, hence I edited the package to add a reset method to the Animated Flip Widget's Flip Controller.

 ```dart
void reset() {
    duration = const Duration(seconds: 0);
    _angle = 0;
    _angleController.sink.add(_angle);
  }
```

The FlashcardNavigator widget at the bottom of the screen is used to mark flashcards correct/incorrect and cycle through them.

Marking a card correct/incorrect increments the flashcardIndex, moving to the next flashcard in the list and adds the flashcard to the correct/incorrect list

```dart
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
```
```dart
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
            onCorrect: () {
                correctFlashcards.add(widget.flashcards[flashcardIndex]);
                if(widget.removeOnCorrect == true) {
                  db.collection(widget.collectionPath).doc(widget.flashcards[flashcardIndex].id).delete();
                }
                forward();
            },
            onIncorrect: () {
                incorrectFlashcards.add(widget.flashcards[flashcardIndex]);
                forward();
            },
          ),
```




<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/b7c96d5c-f296-4c11-85e7-565774746464">
</p>


### Test Result Screen

Test Result Screen Contains:
  - Confetti Animation
  - Feedback Message
  - Correct/Incorrect Stat Containers
  - Study Reminder Switch
  - Progress Bar
  - Retry/Finish FAB

The Confetti animation is imported from the Confetti package. It plays upon the user scoring over 75% in a test.

The Feedback Message displayed depends on the score achieved in the test.

```dart
String feedback(progress) {
    Map<double, String> feedbackResponses = {
      0.25: 'Keep Practicing!',
      0.5: 'Getting There!',
      0.75: 'Great Work!',
      1.0: 'Fantastic!'
    };

    for (double score in feedbackResponses.keys) {
      if (progress <= score) {
        if (score >= 0.75) {
          Future.delayed(Duration(milliseconds: 500), () {
            _confettiController.play();
          });
        }
        return feedbackResponses[score] ?? 'Good Job';
      }
    }
    return 'Good Job!';
  }
```
The Correct/Incorrect Stat Containers take a count of the correct/incorrect flashcard lists and display the respective value

The Study Reminder Switch can be toggled on and off by the user. This value is checked when the Test Result Screen is closed. If true, it sends a reminder notification to the user after 1 hour.

```dart
PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (sendReminder) {
          NotificationService.scheduledNotification(
              'Time to Study?',
              notificationBody(widget.setName),
              DateTime.now().add(Duration(hours: 1)),
              payload: '${widget.collectionPath}|*split*|${widget.setName}'); // Notification payload gives collection path + set name
        }
      },
```

The Progress Bar gets the percentage of correct flashcards and displays it.

```dart
double progress = (correctCount + incorrectCount) == 0
        ? 0 // Ensures that it doesn't result in 0 / 0
        : correctCount / (correctCount + incorrectCount);
```

It also uses a Tween Animation Builder to animate the bar + value increasing.

```dart
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
```

If the user scores less than 100% on a test then the Retry FAB will be displayed. Clicking on it routes the user to another test with all the flashcards they answered incorrectly. Otherwise, a Finish FAB is displayed which simply pops the current screen.

```dart
floatingActionButton: incorrectCount > 0
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      createRoute(BasicTestScreen(
                        flashcards: widget.incorrectFlashcards,
                        reversedReview: widget.reversedReview,
                        collectionPath: widget.collectionPath,
                        setName: widget.setName,
                      )));
                },
                label: const Text('Retry'),
                icon: const Icon(Icons.refresh),
                backgroundColor: Colors.blueAccent,
              )
            : FloatingActionButton.extended(
          onPressed: () {
            Navigator.pop(context);
          },
          label: const Text('Finish'),
          icon: const Icon(Icons.check_rounded),
          backgroundColor: Colors.blueAccent,
        ),
```

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/1984b98d-46af-43d8-bc67-b049d2abe066">
</p>


## Organisation System

- [Creating a Topic](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-topic)
- [Creating a Set](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-set)
- [Creating a Flashcard](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-flashcard)
- [Adding an Image](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#adding-an-image)


Topic -> Sub Topic/Set

Set -> Flashcard

- Topics are collections containing Flashcard Sets or other Topics
- Flashcard Sets are collections containing Flashcards

  ** Types are saved as integers to make them easy to index on Menu Screen **

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
<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/5f38acf1-49d8-4441-9ed6-427fc03fed23">
</p>


### Creating a Set

Creating a set operates nearly identically to creating a Topic, except the type is saved as 2.

```dart
onPressed: () {
                  String id = DateTime.now().toString();
                  db.collection(collectionPath).doc(id).set({'Name' : setName.text, 'Type' : 2});
                  db.collection('$collectionPath/$id/$id').doc('~~info~~').set({'Type' : -1,});
                  // A collection must have at least 1 document -> info doc fulfills this
                  Navigator.pop(context);
                },
```

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/e863a0ff-24a9-44ec-904b-7cf7fbf15267">
</p>

### Creating a Flashcard

Creating a Flashcard once again operates similarly to creating a Topic/Set but with more parameters.

```dart
class Flashcard {
  final String front;
  final String back;
  final String? frontImage;
  final String? backImage;

  Flashcard(
    this.front,
    this.back,
    this.frontImage,
    this.backImage,
  );
}
```

Flashcards are also created with an Index parameter which allows them to be ordered.

```dart
Future<void> addFlashcard(Flashcard flashcard, String collectionPath) async {
  QuerySnapshot<Map<String, dynamic>> snapshot =
  await db.collection(collectionPath).get();
  db.collection(collectionPath).add({
    'Type': 'Flashcard', //TODO change to int type system
    'Front': flashcard.front,
    'Back': flashcard.back,
    'Index': snapshot.docs.length,
    'Front Image': flashcard.frontImage,
    'Back Image': flashcard.backImage,
  });
}
```

Differently to a Topic/Set, Flashcards also deal with images which need to be uploaded to Cloud Storage.

```dart
Future<void> createFlashcard(String front, String back, String collectionPath,
    dynamic frontImage, dynamic backImage) async {
  String? frontImageLink;
  String? backImageLink;
  if (frontImage.runtimeType.toString() == '_File') { // Mobile/Windows devices upload images as files
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('$collectionPath/${DateTime.now()}');
    await imageRef.putFile(frontImage); // Uploads file to given directory
    frontImageLink = await imageRef.getDownloadURL(); // Gets download URL so flutter can display it as a network image
  }
  if (frontImage.runtimeType == Uint8List) { // On the web images are uploaded as a list of bytes
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('$collectionPath/${DateTime.now()}');
    await imageRef.putData(frontImage);
    frontImageLink = await imageRef.getDownloadURL();
  }
  if (backImage.runtimeType.toString() == '_File') {
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('$collectionPath/${DateTime.now()}');
    await imageRef.putFile(backImage);
    backImageLink = await imageRef.getDownloadURL();
  }
  if (backImage.runtimeType == Uint8List) {
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('$collectionPath/${DateTime.now()}');
    await imageRef.putData(backImage);
    backImageLink = await imageRef.getDownloadURL();
  }
  Flashcard flashcard = Flashcard(front, back, frontImageLink, backImageLink);
  await addFlashcard(flashcard, collectionPath); // Runs addFlashcard function (shown above) to create Firestore doc
}
```

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/4553a877-7613-44e7-a03f-e234bc719be7">
</p>

### Adding an Image

Flashcards can also be editted to change text and add/remove images.

This means that upon changing a flashcard's image the old image (if any) must be deleted and the new image (if any) must be uploaded.

```dart

// Function ran upon when 'Edit Flashcard' Button is pressed  

onPressed: () async {
        if (frontStoredImage == null && widget.frontImageLink != null) { // If there is no image
          // Image -> No Image
          final Reference imageRef = FirebaseStorage.instance
              .refFromURL(widget.frontImageLink!);
          await imageRef.delete();
        }
        if (newFrontImage != null) {
          // No image -> New image,
          final Reference imageRef = FirebaseStorage.instance
              .ref()
              .child(
                  '${widget.collectionPath}/${DateTime.now()}'); // Cloud Location
          await imageRef
              .putFile(newFrontImage!); // Upload image to cloud
          frontStoredImage = await imageRef
              .getDownloadURL(); // Get URL to ref image
        }
        if (backStoredImage == null && widget.backImageLink != null) {
          final Reference imageRef = FirebaseStorage.instance
              .refFromURL(widget.backImageLink!);
          await imageRef.delete();
        }
        if (newBackImage != null) {
          // No image -> New image,
          final Reference imageRef = FirebaseStorage.instance
              .ref()
              .child(
                  '${widget.collectionPath}/${DateTime.now()}'); // Cloud Location
          await imageRef
              .putFile(newFrontImage!); // Upload image to cloud
          backStoredImage = await imageRef
              .getDownloadURL(); // Get URL to ref image
        }
        db.collection(widget.collectionPath).doc(widget.id).update({
          'Front': frontVal.text,
          'Back': backVal.text,
          'Front Image': frontStoredImage,
          'Back Image': backStoredImage,
        });
```

<p align="center">
  <img height="500" src="https://github.com/user-attachments/assets/a5d19901-af2e-4be6-9b0b-b9c6c2f58bcb">
</p>

### Reordering Flashcards

## CSV Conversion
- [Export CSV](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#export-csv)
- [Import CSV](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#import-csv)

### Export CSV

### Import CSV

## Need to Review List

## Notification Service

