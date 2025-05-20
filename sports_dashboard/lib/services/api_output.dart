import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/output_athlete.dart';
import '../models/workout_data.dart';

class OutputApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL_OUTPUT']!;
  static final String _token = dotenv.env['API_TOKEN_OUTPUT']!;

  /// Fetch athletes from the Output API
  static Future<List<Athlete_Output>> fetchOutputAthletes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/athletes'),
        headers: {'Authorization': 'Bearer $_token'},
      );

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

  /// Fetch available exercises (metadata) from the Output API
  static Future<List<Map<String, dynamic>>> fetchExerciseMetadata() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/metadata'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load exercise metadata');
      }
    } catch (e) {
      throw Exception('Error fetching exercise metadata: $e');
    }
  }

  /// Fetch workout data based on athlete(s), time range, and specific exercise
  static Future<List<Map<String, dynamic>>> fetchWorkoutData(
    List<String> athleteIds,
    DateTime startDate,
    DateTime endDate, {
    required String exerciseId,
  }) async {
    final requestBody = json.encode({
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'exerciseMetadataIds': [exerciseId.toString()],
      'athleteIds': athleteIds,
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/exercises/measurements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load workout data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching workout data: $e');
    }
  }
}
