import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/output_athlete.dart';
import '../models/workout_data.dart';
import 'output_auth_service.dart';  // Make sure this points to OutputAuthService

class OutputApiService {
  static final String? _baseUrl = dotenv.env['API_BASE_URL_OUTPUT'];

  /// Fetch athletes from the Output API
  static Future<List<Athlete_Output>> fetchOutputAthletes() async {

    final token = await OutputAuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/athletes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Athlete_Output.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load output athletes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching output athletes: $e');
    }
  }

  /// Fetch available exercises (metadata) from the Output API
  static Future<List<Map<String, dynamic>>> fetchExerciseMetadata() async {
    final token = await OutputAuthService.getToken();
    print('📡 Retrieved token: $token');
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/metadata'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load exercise metadata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exercise metadata: $e');
    }
  }

  /// Fetch workout data based on athlete(s), time range, and specific exercise
  static Future<List<dynamic>> fetchWorkoutData(
    List<String> athleteIds,
    DateTime startDate,
    DateTime endDate, {
    String? exerciseId,
  }) async {
    print('📡 fetchWorkoutData called with athleteIds: $athleteIds');
    try {
      final token = await OutputAuthService.getToken();

      final uri = Uri.parse('https://api.output.com/workouts').replace(queryParameters: {
        'athleteIds': athleteIds.join(','),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (exerciseId != null) 'exerciseId': exerciseId,
      });

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Raw API response body: ${response.body}');
      print('📡 Output API response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('workouts')) {
          return data['workouts'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        throw Exception('Failed to fetch workout data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchWorkoutData: $e');
      rethrow;
    }
  }
}
