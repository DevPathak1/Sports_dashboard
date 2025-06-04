import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/athlete.dart';

class ApiService {
  static final String? _baseUrl = dotenv.env['API_BASE_URL'];
  static final String? _token = dotenv.env['API_TOKEN'];

  static Future<List<Athlete>> fetchAthletes() async {
    if (_baseUrl == null || _token == null || _baseUrl!.isEmpty || _token!.isEmpty) {
      throw Exception('❌ API_BASE_URL or API_TOKEN is missing or empty in .env file.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/athletes'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Athlete.fromJson(json)).toList();
      } else {
        throw Exception('❌ Failed to load athletes: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('❌ Error fetching athletes: $e');
    }
  }
}
