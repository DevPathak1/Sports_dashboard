import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/smartspeed.dart';

class SmartSpeedApiService {
  static final String _baseUrl = dotenv.env['SMARTSPEED_ENDPOINT']!;
  static final String _token = dotenv.env['SMARTSPEED_TOKEN']!;
  static final String _teamId = dotenv.env['TENANT_ID']!;
  static final String _groupId = dotenv.env['GROUP_ID']!;

 static Future<List<SmartSpeedTest>> fetchsmartSpeedTests(String athleteId, {int page = 1}) async {
  final uri = Uri.parse(
    '$_baseUrl/v1/team/$_teamId/tests?AthleteId=$athleteId&GroupUnderTestId=$_groupId&Page=$page',
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $_token',
      'accept': 'text/plain',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = jsonDecode(response.body);
    return body.map((json) => SmartSpeedTest.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch VALD test data');
  }
}
}

