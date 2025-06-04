import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OutputAuthService {
  static String? _cachedToken;
  static final String? _refreshToken = dotenv.env['OUTPUT_REFRESH_TOKEN'];
  static const String _tokenUrl = 'https://api.outputsports.com/api/v1/oauth/token';
  static const String _testUrl = 'https://api.outputsports.com/api/v1/athletes';

  static Future<String> getToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      throw Exception('❌ OUTPUT_REFRESH_TOKEN is missing or empty in .env');
    }

    // If cached token is valid, return it
    if (_cachedToken != null && await _isValid(_cachedToken!)) {
      print('🔁 Using cached Output token');
      return _cachedToken!;
    }

    // Fetch a new token
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grantType': 'refresh_token',
          'refreshToken': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        final newToken = data['accessToken'];

        if (newToken == null || newToken.isEmpty) {
          throw Exception('❌ No access_token returned in Output API response');
        }

        _cachedToken = newToken;
        print('✅ Output token refreshed');
        return _cachedToken!;
      } else {
        throw Exception('❌ Failed to refresh Output token: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during Output token fetch: $e');
      rethrow;
    }
  }

  static Future<bool> _isValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_testUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
