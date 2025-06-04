import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ValdAuthService {
  static String? _accessToken;
  static DateTime? _expiresAt;

  static Future<String> getToken() async {
    final clientId = dotenv.env['VALD_CLIENT_ID'];
    final clientSecret = dotenv.env['VALD_CLIENT_SECRET'];
    final tokenUrl = 'https://security.valdperformance.com/connect/token';

    if (clientId == null || clientSecret == null) {
      throw Exception('❌ VALD_CLIENT_ID or VALD_CLIENT_SECRET is missing in .env file.');
    }

    // Return cached token if it's still valid
    if (_accessToken != null && _expiresAt != null && DateTime.now().isBefore(_expiresAt!)) {
      print('🔁 Using cached token');
      return _accessToken!;
    }

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final expiresIn = data['expires_in'] ?? 7200;

        final token = data['access_token'];
        if (token == null) {
          throw Exception('❌ Token response did not contain an access_token.');
        }

        _accessToken = token;
        _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

        print('✅ Fetched new token, expires in $expiresIn seconds');
        return _accessToken!;
      } else {
        print('❌ Failed to fetch token: ${response.body}');
        throw Exception('Failed to retrieve token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception occurred while fetching token: $e');
      rethrow;
    }
  }
}
