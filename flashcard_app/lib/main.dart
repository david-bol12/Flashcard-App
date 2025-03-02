import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  NotificationService.initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x0039a0ed)),
        brightness: Brightness.light,
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home:
      const MainMenuScreen(collectionPath: 'Topics', topicName: 'Flashcard App'),
    );
  }
}
