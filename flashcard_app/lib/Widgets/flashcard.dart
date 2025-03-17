import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_app/Screens/main_menu.dart';
import 'package:animated_flip_widget/animated_flip_widget.dart';

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

class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    super.key,
    required this.front,
    required this.back,
    required this.flipController,
    this.frontImage,
    this.backImage,
  });

  final String front;
  final String back;
  final FlipController flipController;
  final String? frontImage;
  final String? backImage;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  final Color colorShowing = Colors.white;

  @override
  Widget build(BuildContext context) {
    return AnimatedFlipWidget(
      front: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6.0,
                    offset: const Offset(0, 5))
              ]),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.frontImage != null)
                  Expanded(
                    flex: 0,
                    child: Container(
                        color: Colors.black,
                        margin: const EdgeInsets.all(10),
                        child: Image.network(
                          widget.frontImage!,
                          fit: BoxFit.contain,
                        )),
                  ),
                SingleChildScrollView(
                  child: Text(
                    widget.front,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      back: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6.0,
                    offset: const Offset(0, 5))
              ]),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.backImage != null)
                  Expanded(
                    flex: 0,
                    child: Container(
                        color: Colors.black,
                        margin: const EdgeInsets.all(10),
                        child: Image.network(
                          widget.backImage!,
                          fit: BoxFit.contain,
                        )),
                  ),
                SingleChildScrollView(
                  child: Text(
                    widget.back,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      controller: widget.flipController,
      flipDirection: MediaQuery.of(context).orientation == Orientation.portrait
          ? FlipDirection.horizontal
          : FlipDirection.vertical,
    );
  }
}

class CreateFlashcard extends StatefulWidget {
  const CreateFlashcard({
    super.key,
    required this.collectionPath,
  });

  final String collectionPath;

  @override
  State<CreateFlashcard> createState() => _CreateFlashcardState();
}

class _CreateFlashcardState extends State<CreateFlashcard> {
  final TextEditingController front = TextEditingController();
  final TextEditingController back = TextEditingController();
  File? frontImage;
  Uint8List? frontImageData;
  File? backImage;
  Uint8List? backImageData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Create Flashcard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3.75,
                      maxWidth: MediaQuery.of(context).size.width / 1.6),
                  child: TextField(
                    maxLength: 150,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: front,
                    decoration: const InputDecoration(
                        hintText: 'Front',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null) {
                      setState(() {
                        if (kIsWeb) {
                          frontImageData = result.files.single.bytes;
                        } else {
                          frontImage = File(result.files.single.path!);
                        }
                      });
                    }
                  },
                  icon: Icon(Icons.image_search_rounded),
                )
              ],
            ),
            const SizedBox(
              height: 0,
            ),
            if (frontImage != null || frontImageData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kIsWeb
                        ? Image.memory(
                            frontImageData!,
                            width: 100,
                          )
                        : Image.file(
                            frontImage!,
                            width: 100,
                          ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            frontImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3.75,
                      maxWidth: MediaQuery.of(context).size.width / 1.6),
                  child: TextField(
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: back,
                    decoration: const InputDecoration(
                        hintText: 'Back',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null) {
                      setState(() {
                        if (kIsWeb) {
                          backImageData = result.files.single.bytes;
                        } else {
                          backImage = File(result.files.single.path!);
                        }
                      });
                    }
                  },
                  icon: Icon(Icons.image_search_rounded),
                )
              ],
            ),
            if (backImage != null || backImageData != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kIsWeb
                        ? Image.memory(
                            backImageData!,
                            width: 100,
                          )
                        : Image.file(
                            backImage!,
                            width: 100,
                          ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            backImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      await createFlashcard(front.text, back.text,
                          widget.collectionPath, frontImageData, backImageData);
                    } else {
                      await createFlashcard(front.text, back.text,
                          widget.collectionPath, frontImage, backImage);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Flashcard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> addFlashcard(Flashcard flashcard, String collectionPath) async {
  QuerySnapshot<Map<String, dynamic>> snapshot =
  await db.collection(collectionPath).get();
  db.collection(collectionPath).add({
    'Type': 'Flashcard',
    'Front': flashcard.front,
    'Back': flashcard.back,
    'Status': 0,
    'Index': snapshot.docs.length,
    'Front Image': flashcard.frontImage,
    'Back Image': flashcard.backImage,
  });
}

Future<void> createFlashcard(String front, String back, String collectionPath,
    dynamic frontImage, dynamic backImage) async {
  String? frontImageLink;
  String? backImageLink;
  if (frontImage.runtimeType.toString() == '_File') {
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('$collectionPath/${DateTime.now()}');
    await imageRef.putFile(frontImage);
    frontImageLink = await imageRef.getDownloadURL();
  }
  if (frontImage.runtimeType == Uint8List) {
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
  await addFlashcard(flashcard, collectionPath);
}

class FlashcardInfo extends StatelessWidget {
  const FlashcardInfo({
    super.key,
    required this.front,
    required this.back,
    required this.collectionPath,
    required this.id,
    this.frontImage,
    this.backImage,
    this.reorder = false,
    this.reviewList = false,
  });

  final String collectionPath;
  final String id;
  final String front;
  final String back;
  final String? frontImage;
  final String? backImage;
  final bool reorder;
  final bool reviewList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          tileColor: Colors.white,
          leading: frontImage != null || backImage != null ? SingleChildScrollView(
            child: Column(
              children: [
                if (frontImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Image.network(
                      frontImage!,
                      width: 50,
                    ),
                  ),
                SizedBox(
                  height: 10,
                ),
                if (backImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Image.network(
                      backImage!,
                      width: 50,
                    ),
                  ),
              ],
            ),
          ) : null,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      front,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      back,
                      style: const TextStyle(
                        fontSize: 14
                      )
                    ) // TODO: add text style
                  ],
                ),
              ),
            ],
          ),
          trailing: !reorder && !reviewList
              ? PopupMenuButton( //TODO fix massive mess
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            onTap: () {
                              Flashcard flashcard =
                                  Flashcard(front, back, frontImage, backImage);
                              addFlashcard(flashcard, '/Topics/Need to Review/Need to Review');
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xfffcba03)),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text('Need to Review'),
                              ],
                            )),
                        PopupMenuItem(
                          onTap: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                    child: EditFlashcard(
                                      collectionPath: collectionPath,
                                      id: id,
                                      front: front,
                                      back: back,
                                      frontImageLink: frontImage,
                                    ),
                                  )),
                          child: Row(
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            if (frontImage != null) {
                              final Reference imageRef = FirebaseStorage
                                  .instance
                                  .refFromURL(frontImage!);
                              await imageRef.delete();
                            }
                            if (backImage != null) {
                              final Reference imageRef = FirebaseStorage
                                  .instance
                                  .refFromURL(backImage!);
                              await imageRef.delete();
                            }
                            db.collection(collectionPath).doc(id).delete();
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.delete),
                              const SizedBox(
                                width: 8,
                              ),
                              const Text('Delete'),
                            ],
                          ),
                        ),
                      ]) : reviewList ?
              PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.close,),
                            SizedBox(width: 4,),
                            Text('Remove from List'),
                          ],
                        ),
                      onTap: () {
                        db.collection(collectionPath).doc(id).delete();
                      },
                    )
                  ]
              ) :
          kIsWeb ? null : Icon(Icons.reorder_rounded),
        ),
      ),
    );
  }
}

class EditFlashcard extends StatefulWidget {
  const EditFlashcard({
    super.key,
    required this.collectionPath,
    required this.id,
    required this.front,
    required this.back,
    this.frontImageLink,
    this.backImageLink,
  });

  final String collectionPath;
  final String id;
  final String front;
  final String back;
  final String? frontImageLink;
  final String? backImageLink;

  @override
  State<EditFlashcard> createState() => _EditFlashcardState();
}

class _EditFlashcardState extends State<EditFlashcard> {
  final TextEditingController frontVal = TextEditingController();
  final TextEditingController backVal = TextEditingController();
  File? newFrontImage;
  String? frontStoredImage;
  File? newBackImage;
  String? backStoredImage;

  @override
  void initState() {
    frontStoredImage = widget.frontImageLink;
    backStoredImage = widget.backImageLink;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    frontVal.text = widget.front;
    backVal.text = widget.back;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Edit Flashcard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3.75,
                      maxWidth: MediaQuery.of(context).size.width / 1.6),
                  child: TextField(
                    maxLength: 150,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: frontVal,
                    decoration: const InputDecoration(
                        hintText: 'Front',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                  ),
                ),
                if (frontStoredImage == null && newFrontImage == null)
                  IconButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.image);
                      if (result != null) {
                        setState(() {
                          newFrontImage = File(result.files.single.path!);
                        });
                      }
                    },
                    icon: Icon(Icons.image_search_rounded),
                  )
              ],
            ),
            const SizedBox(
              height: 0,
            ),
            if (newFrontImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.file(
                      newFrontImage!,
                      width: 100,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            newFrontImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            if (frontStoredImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      frontStoredImage!,
                      width: 100,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            frontStoredImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3.75,
                      maxWidth: MediaQuery.of(context).size.width / 1.6),
                  child: TextField(
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: backVal,
                    decoration: const InputDecoration(
                        hintText: 'Back',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                  ),
                ),
                if (backStoredImage == null && newBackImage == null)
                  IconButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.image);
                      if (result != null) {
                        setState(() {
                          newBackImage = File(result.files.single.path!);
                        });
                      }
                    },
                    icon: Icon(Icons.image_search_rounded),
                  )
              ],
            ),
            const SizedBox(
              height: 0,
            ),
            if (newBackImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.file(
                      newBackImage!,
                      width: 100,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            newBackImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            if (backStoredImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      backStoredImage!,
                      width: 100,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            backStoredImage = null;
                          });
                        },
                        icon: Icon(Icons.close_rounded))
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close
                    },
                    child: const Text('Close'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (frontStoredImage == null &&
                        widget.frontImageLink != null) {
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
                    if (backStoredImage == null &&
                        widget.backImageLink != null) {
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
                    if (context.mounted) {
                      Navigator.pop(context); // Close
                    }
                  },
                  child: const Text('Edit Flashcard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 1. Image -> Image   Stored image == widget.imagePath
// 2. Image -> No image   Stored image != widget.imagePath && Stored image == null
// 3. No image -> No image   Stored image == widget.imagePath && Stored image == null
// 4. No image -> New image    Stored image != widget.imagePath && Stored image != null
// 5. Image -> New image == Image -> no Image -> New image    Stored image != widget.imagePath &&

// is storedImage null?
