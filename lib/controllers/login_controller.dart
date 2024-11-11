import 'dart:convert';
import '../models/models.exp.dart';
import '../services/api_service.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  Future<LoginResponseModel?> loginUser(String phoneNumber, String password) async {
    const String endpoint = 'accounts/api/login/';

    try {
      final response = await _apiService.post(endpoint, {
        'phone_number': phoneNumber,
        'password': password,
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final loginResponse = LoginResponseModel.fromJson(jsonResponse['data']);
        _apiService.setAuthToken(loginResponse.authorizationToken); // تنظیم توکن
        print('Login successful: ${loginResponse.firstName}');
        return loginResponse;
      } else {
        throw Exception('Login failed: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Error in loginUser: $e');
      return null;
    }
  }
}
