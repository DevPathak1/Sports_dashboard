// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/athlete.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static final String _token = dotenv.env['API_TOKEN']!; 

  static Future<List<Athlete>> fetchAthletes() async {
  final response = await http.get(
    Uri.parse(_baseUrl),
    headers: {
      'Authorization': 'Bearer ${dotenv.env['API_TOKEN']}',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Athlete.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load users: ${response.statusCode}');
  }
}

}

