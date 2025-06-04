
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/vald_auth_service.dart'; // Auth token retrieval

class Athlete_Vald {
  final String id;
  final String first_name;
  final String last_name;

  Athlete_Vald({
    required this.id,
    required this.first_name,
    required this.last_name,
  });

  factory Athlete_Vald.fromJson(Map<String, dynamic> json) {
    return Athlete_Vald(
      id: json['profileId'] ?? '',
      first_name: json['givenName'] ?? '',
      last_name: json['familyName'] ?? '',
    );
  }
}

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
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      final List<dynamic> data = jsonMap['data'];
      return data.map((json) => Athlete_Vald.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Vald athletes: ${response.statusCode}');
    }
  }
}
