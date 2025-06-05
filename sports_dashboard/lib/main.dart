import 'package:flutter/material.dart';
import 'screens/athlete_screen.dart'; // Import your athlete screen
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/smartspeed_api.dart'; // Import your SmartSpeed service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Important for web
  testFetch();
  runApp(const MyApp());
}


void testFetch() async {
  try {
    final data = await SmartSpeedService.fetchSmartSpeedTest(
      athleteId: 'a183eccd-f88e-46b1-a47f-69c27dc11264',
    );
    print('Test results: $data');
  } catch (e) {
    print('Error fetching tests: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

