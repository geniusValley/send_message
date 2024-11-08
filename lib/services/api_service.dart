import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://smssender2.liara.run/';

  Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl/$endpoint';
    try {
      return await http.get(Uri.parse(url));
    } catch (e) {
      throw Exception('Error in GET request: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = '$baseUrl/$endpoint';
    try {
      return await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Error in POST request: $e');
    }
  }
}