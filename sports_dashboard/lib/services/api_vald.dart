import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/vald_athlete.dart';
import 'vald_auth_service.dart'; // Import the file where you placed the auth logic

class ValdApiService {
  final String baseUrl = dotenv.env['API_BASE_URL_VALD'] ?? '';

  Future<List<Athlete_Vald>> fetchAthletes(String tenantId, String groupId) async {
    final token = await ValdAuthService.getToken();

    final uri = Uri.parse('$baseUrl/profiles').replace(queryParameters: {
      'TenantId': tenantId,
      'GroupId': groupId,
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Athlete_Vald.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Vald athletes: ${response.statusCode}');
    }
  }
}
