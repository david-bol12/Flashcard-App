# Flashcard App
[Link to web version](https://flashcard-app-fe54f.web.app)<br/>

⚠️ Account system is not yet set up, feel free to add flashcards but please do not edit any prexisting flashcards ⚠️ <br/>

## Contents
[Organisation System](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#organisation-system)
- [Creating a Topic](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-topic)
- [Creating a Set](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-set)
- [Creating a Flashcard](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#creating-a-flashcard)
- [Adding an Image](https://github.com/david-bol12/Flashcard-App/blob/main/README.md#adding-an-image)



## Organisation System
Topic -> Set -> Flashcard
- Topics are collections containing Flashcard Sets or other Topics
- Flashcard Sets are collections containing Flashcards

  ** Types are saved as integers to make them easy to index on Menu Screen **

### Creating a Topic
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
<img height="500" src="https://github.com/user-attachments/assets/5f38acf1-49d8-4441-9ed6-427fc03fed23">

### Creating a Set
<img height="500" src="https://github.com/user-attachments/assets/e863a0ff-24a9-44ec-904b-7cf7fbf15267">

### Creating a Flashcard
<img height="500" src="https://github.com/user-attachments/assets/4553a877-7613-44e7-a03f-e234bc719be7">

### Adding an Image
<img height="500" src="https://github.com/user-attachments/assets/a5d19901-af2e-4be6-9b0b-b9c6c2f58bcb">

