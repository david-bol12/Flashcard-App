import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_app/Widgets/screen_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'basic_test.dart';
import 'main_menu.dart';
import 'package:flashcard_app/Widgets/flashcard.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:toastification/toastification.dart';

class FlashcardMenuScreen extends StatefulWidget {
  const FlashcardMenuScreen({
    super.key,
    required this.collectionPath,
    required this.setName,
    this.appBarTitle = 'Flashcard App',
    this.appBarIcon,
    this.addFlashcardButton = true,
    this.uploadCSV = true,
    this.exportCSV = true,
    this.reorder = true,
    this.emptySetText = 'Add a Flashcard',
    this.reviewList = false,
  });

  const FlashcardMenuScreen.reviewList({
    super.key,
    required this.collectionPath,
    required this.setName,
    this.appBarTitle = 'Need to Review',
    this.appBarIcon,
    this.addFlashcardButton = false,
    this.uploadCSV = false,
    this.exportCSV = true,
    this.reorder = true,
    this.emptySetText = 'No Flashcards to Review!',
    this.reviewList = true,
  });

  final String collectionPath;
  final String setName;
  final String appBarTitle;
  final Icon? appBarIcon;
  final bool addFlashcardButton;
  final bool uploadCSV;
  final bool exportCSV;
  final bool reorder;
  final String emptySetText;
  final bool reviewList;

  @override
  State<FlashcardMenuScreen> createState() => _FlashcardMenuScreenState();
}

class _FlashcardMenuScreenState extends State<FlashcardMenuScreen> {
  final TextEditingController searchBarController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        searchBarController: searchBarController,
        onSearch: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    if (widget.uploadCSV)
                      PopupMenuItem(
                        onTap: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                              child: UploadCsv(
                            collectionPath: widget.collectionPath,
                          )),
                        ),
                        child: const Text('Upload from CSV'),
                      ),
                    if (widget.exportCSV)
                      PopupMenuItem(
                        onTap: () async {
                          exportCsv(widget.collectionPath, widget.setName);
                        },
                        child: const Text('Export as CSV'),
                      ),
                    if (widget.reorder)
                      PopupMenuItem(
                        onTap: () async {
                          QuerySnapshot<Map<String, dynamic>>
                              flashcardsSnapshot = await db
                                  .collection(widget.collectionPath)
                                  .orderBy('Index')
                                  .get();
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              flashcards = flashcardsSnapshot.docs;
                          if (context.mounted) {
                            showDialog(
                                //TODO: Clean Messy code
                                context: context,
                                builder: (BuildContext context) => Scaffold(
                                      appBar: AppBar(
                                        title: Text(widget.appBarTitle),
                                      ),
                                      floatingActionButton:
                                          FloatingActionButton.extended(
                                              onPressed: () {
                                                int index = 0;
                                                for (QueryDocumentSnapshot<
                                                        Map<String,
                                                            dynamic>> flashcard
                                                    in flashcards) {
                                                  db
                                                      .collection(
                                                          widget.collectionPath)
                                                      .doc(flashcard.id)
                                                      .update({'Index': index});
                                                  index++;
                                                }
                                                Navigator.pop(context);
                                              },
                                              label: const Row(
                                                children: [
                                                  Text('Done'),
                                                  Icon(Icons.done),
                                                ],
                                              )),
                                      body: ReorderableListView.builder(
                                          padding: EdgeInsets.only(bottom: 100),
                                          onReorder: (oldIndex, newIndex) {
                                            QueryDocumentSnapshot<
                                                    Map<String, dynamic>>
                                                flashcard =
                                                flashcards[oldIndex];
                                            flashcards.removeAt(oldIndex);
                                            flashcards.insert(
                                                newIndex > oldIndex
                                                    ? newIndex - 1
                                                    : newIndex,
                                                flashcard);
                                          },
                                          itemCount: flashcards.length,
                                          itemBuilder: (context, index) {
                                            String id = flashcards[index].id;
                                            String front = flashcards[index]
                                                    .data()['Front'] ??
                                                '';
                                            String back = flashcards[index]
                                                    .data()['Back'] ??
                                                '';
                                            String type = flashcards[index]
                                                .data()['Type'];
                                            if (type == 'Flashcard') {
                                              return FlashcardInfo(
                                                front: front,
                                                back: back,
                                                collectionPath:
                                                    widget.collectionPath,
                                                id: id,
                                                key: Key(index.toString()),
                                                reorder: true,
                                              );
                                            }
                                            return SizedBox.shrink(
                                              key: Key(index.toString()),
                                            );
                                          }),
                                    ));
                          }
                        },
                        child: const Text('Reorder Flashcards'),
                      )
                  ])
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.addFlashcardButton)
              FloatingActionButton.extended(
                heroTag: 'addFlashcard',
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                      backgroundColor: Theme.of(context). dialogBackgroundColor,
                      child: CreateFlashcard(
                          collectionPath: widget.collectionPath)),
                ),
                label: const Text('Add Flashcard'),
                icon: const Icon(Icons.add),
              ),
            FloatingActionButton.extended(
              heroTag: 'test',
              onPressed: () async {
                int count = await db
                    .collection(widget.collectionPath)
                    .count()
                    .get()
                    .then((result) => result.count!);
                if(context.mounted) {
                  if (count > 1) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            Dialog(
                              child: TestOptionsDialog(
                                  collectionPath: widget.collectionPath,
                                  setName: widget.setName,
                                  testOptions: widget.reviewList ? {
                                    'Shuffle': false,
                                    'Reversed Review': false,
                                    'Remove on Correct': true,
                                  } :
                                  {
                                    'Shuffle': false,
                                    'Reversed Review': false,
                                  }
                              ),
                            ));
                  }
                  else {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: Text('No Flashcards to Review'),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                }
              },
              label: const Text('Test'),
              icon: const Icon(Icons.assignment),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
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
    );
  }
}

class UploadCsv extends StatefulWidget {
  const UploadCsv({
    super.key,
    required this.collectionPath,
  });

  final String collectionPath;

  @override
  State<UploadCsv> createState() => _UploadCsvState();
}

class _UploadCsvState extends State<UploadCsv> {
  String? fileName;
  String? uploadFileData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload from CSV',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 30),
            GestureDetector(
                onTap: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.custom, allowedExtensions: [
                    'csv',
                  ]);
                  if (result != null) {
                    PlatformFile uploadFile = result.files.single;
                    uploadFileData = kIsWeb
                        ? String.fromCharCodes(uploadFile.bytes!.toList())
                        : File(uploadFile.path!).readAsStringSync();
                    setState(() {
                      fileName = result.files.single.name;
                    });
                  } else {
                    // User canceled the picker
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(fileName == null
                          ? Icons.file_upload_outlined
                          : Icons.folder_outlined),
                      const SizedBox(width: 4),
                      Text(fileName ?? 'Choose File')
                    ],
                  )),
                )),
            const SizedBox(
              height: 10,
            ),
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
                  onPressed: () {
                    if (uploadFileData != null) {
                      uploadCsv(uploadFileData!, widget.collectionPath);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Upload CSV'),
                ),
              ],
            ),
          ]),
    );
  }
}

void uploadCsv(String uploadFileData, String collectionPath) {
  List<List<String>> data = const CsvToListConverter(shouldParseNumbers: false)
      .convert(
          uploadFileData); // Reads uploaded file and converts it to a List<List<Front, Back>>
  for (List list in data) {
    createFlashcard(list[0], list[1], collectionPath, null,
        null); // Creates flashcard from each List<Front, Back>
  }
}

void exportCsv(String collectionPath, String setName) async {
  // Web uses FileSaver package as FilePicker does not have web support
  // Android + Windows use FilePicker as it allows the user to choose where they
  // store the file
  if (kIsWeb) {
    await db
        .collection(collectionPath)
        .get() // Gets flashcard set data
        .then((QuerySnapshot snapshot) async {
      List<List<String>> csvData = [];
      for (DocumentSnapshot flashcard in snapshot.docs) {
        Map<String, dynamic> data = flashcard.data() as Map<String, dynamic>;
        String? front = data['Front'];
        String? back = data['Back'];
        if (front != null && back != null) {
          csvData.add([front, back]); // Adds the flashcard front + back to CSV
        }
      }
      String csv = ListToCsvConverter().convert(csvData);
      Uint8List bytes = Uint8List.fromList(utf8.encode(csv)); // Web downloads must be in utf8
      await FileSaver.instance
          .saveFile(name: setName, bytes: bytes, ext: 'csv'); // Saves file to Downloads
    });
  } else {
    PermissionStatus request;
    if (Platform.isAndroid) {
      request = await Permission.manageExternalStorage.request();
    } else {
      request = PermissionStatus.denied; // Only Android requires permissions
    }
    if (request.isGranted || !Platform.isAndroid) {
      String? path = await FilePicker.platform.getDirectoryPath();
      await db.collection(collectionPath).get().then((QuerySnapshot snapshot) {
        List<List<String>> csvData = [];
        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String? front = data['Front'];
          String? back = data['Back'];
          if (front != null && back != null) {
            csvData.add([front, back]);
          }
        }
        if (path != null) {
          File('$path/$setName.csv')
              .writeAsStringSync(const ListToCsvConverter().convert(csvData));
        }
      });
    }
  }
}

class TestOptionsDialog extends StatefulWidget {
  const TestOptionsDialog(
      {
        super.key,
        required this.collectionPath,
        required this.setName,
        required this.testOptions,
      });

  final String collectionPath;
  final String setName;
  final Map<String, dynamic> testOptions;

  @override
  State<TestOptionsDialog> createState() => _TestOptionsDialogState();
}

class _TestOptionsDialogState extends State<TestOptionsDialog> {

  Map<String, dynamic> testOptions = {};

  @override
  void initState() {
    testOptions = widget.testOptions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Test Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          for (String option in testOptions.keys)
            if (testOptions[option].runtimeType == bool)
              SwitchListTile(
                  value: testOptions[option],
                  title: Text(option),
                  onChanged: (value) {
                    setState(() {
                      testOptions[option] = value;
                    });
                  }),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close')),
              TextButton(
                  onPressed: () {
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
                  },
                  child: Text(
                    'Test',
                  ))
            ],
          )
        ],
      ),
    );
  }
}
