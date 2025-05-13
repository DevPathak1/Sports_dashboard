import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/output_athlete.dart';
import 'package:sports_dashboard/models/workout_data.dart';


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
  static Future<List<WorkoutData>> fetchWorkoutData(
    List<String> athleteIds, DateTime startDate, DateTime endDate) async {
  final requestBody = json.encode({
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'exerciseMetadataIds': ['BARBELL_POWER_CLEAN'],
    'athleteIds': athleteIds,
  });

  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/exercises/measurements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['API_TOKEN_OUTPUT']}',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => WorkoutData.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load workout data: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    throw Exception('Error fetching workout data: $e');
  }
}

}