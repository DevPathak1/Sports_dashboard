import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'vald_auth_service.dart'; // your token file

class SmartSpeedApiService {
  static final String _baseUrl = dotenv.env['SMARTSPEED_ENDPOINT']!;
  static final String _token = dotenv.env['SMARTSPEED_TOKEN']!;
  static final String _teamId = dotenv.env['TENANT_ID']!;
  static final String _groupId = dotenv.env['GROUP_ID']!;

  /// Fetch test results from SmartSpeed API for a given athlete
  static Future<Map<String, dynamic>> fetchSmartSpeedTest({
    required String athleteId,
    int page = 1,
  }) async {
    if (_baseUrl == null || _tenantId == null || _groupId == null) {
      throw Exception('❌ Missing required environment variables for SmartSpeed API.');
    }

    final token = await ValdAuthService.getToken();
    final url = Uri.parse(
      '$_baseUrl/v1/team/$_tenantId/tests?AthleteId=$athleteId&GroupUnderTestId=$_groupId&Page=$page',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json', // or 'text/plain' if required by API
        },
      );

      if (response.statusCode == 200) {
        print('✅ Successfully fetched test data for athlete $athleteId');
        return json.decode(response.body);
      } else {
        print('❌ Failed to fetch test data: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch SmartSpeed tests');
      }
    } catch (e) {
      print('❌ Exception while fetching SmartSpeed data: $e');
      rethrow;
    }
  }
}


