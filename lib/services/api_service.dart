import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
String? _authToken;
class ApiService {
  final String baseUrl = 'https://smssender2.liara.run/';


  ApiService() {
    _loadAuthToken(); // بارگذاری توکن هنگام ساخت نمونه از ApiService
  }

  // متد برای تنظیم توکن و ذخیره آن در SharedPreferences
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // متد برای بارگذاری توکن از SharedPreferences
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // متد GET با افزودن هدر Authorization
  Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
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
    final url = '$baseUrl$endpoint';
    try {
      return await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': '$_authToken',
        },
        body: json.encode(body),
      );
    } catch (e) {
      throw Exception('Error in POST request: $e');
    }
  }
}
// class ApiService {
//   final String baseUrl = 'https://smssender2.liara.run/';
//   String? _authToken; // نگهداری توکن
//
//   // متد برای تنظیم توکن
//   void setAuthToken(String token) {
//     _authToken = token;
//   }
//
//   // متد GET با افزودن هدر Authorization
//   Future<http.Response> get(String endpoint) async {
//     final url = '$baseUrl$endpoint';
//     try {
//       return await http.get(
//         Uri.parse(url),
//         headers: {
//           if (_authToken != null) 'Authorization': '$_authToken',
//         },
//       );
//     } catch (e) {
//       throw Exception('Error in GET request: $e');
//     }
//   }
//
//   // متد POST با افزودن هدر Authorization
//   Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
//     final url = '$baseUrl$endpoint';
//     try {
//       return await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//         },
//         body: json.encode(body),
//       );
//     } catch (e) {
//       throw Exception('Error in POST request: $e');
//     }
//   }
// }
