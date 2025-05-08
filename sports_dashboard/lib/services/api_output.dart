import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/output_athlete.dart';

class OutputApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL_OUTPUT']!;
  static final String _token = dotenv.env['API_TOKEN_OUTPUT']!; 

  // Fetch Output Athletes from API 2
  static Future<List<Athlete_Output>> fetchOutputAthletes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/athletes'), headers: {
        'Authorization': 'Bearer ${dotenv.env['API_TOKEN_OUTPUT']}', 
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Athlete_Output.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load output athletes');
      }
    } catch (e) {
      throw Exception('Error fetching output athletes: $e');
    }
  }

  // Fetch Workout Data for Selected Athletes
  static Future<List<Map<String, dynamic>>> fetchWorkoutData(List<String> athleteIds, DateTime startDate, DateTime endDate) async {
    final String url = '$_baseUrl/workout-data'; // Replace with the actual workout data endpoint

    // Create the request body
    final requestBody = json.encode({
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'exerciseMetadataIds': ['BARBELL_BENCH_PRESS_SP'], // Add any other exercises you need
      'athleteIds': athleteIds, // This will be the list of athlete IDs from API 2
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/exercises/measurements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['API_TOKEN_OUTPUT']}', // Replace with your actual JWT token
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Parse the response body into the list of workout data
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load workout data');
      }
    } catch (e) {
      throw Exception('Error fetching workout data: $e');
    }
  }
}