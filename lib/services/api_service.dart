import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://smssender2.liara.run/';
  String? _authToken; // نگهداری توکن

  // متد برای تنظیم توکن
  void setAuthToken(String token) {
    _authToken = token;
  }

  // متد GET با افزودن هدر Authorization
  Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl/$endpoint';
    try {
      return await http.get(
        Uri.parse(url),
        headers: {
          if (_authToken != null) 'Authorization': '$_authToken',
        },
      );
    } catch (e) {
      throw Exception('Error in GET request: $e');
    }
  }

  // متد POST با افزودن هدر Authorization
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = '$baseUrl/$endpoint';
    try {
      return await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Error in POST request: $e');
    }
  }
}
