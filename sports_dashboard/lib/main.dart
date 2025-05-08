import 'package:flutter/material.dart';
import 'screens/athlete_screen.dart'; // Import your athlete screen
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Important for web
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AthleteDropdownScreen(), 
    );
  }
}

