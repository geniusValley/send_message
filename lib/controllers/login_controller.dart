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
        final data = json.decode(response.body)['data'];
        return LoginResponseModel.fromJson(data);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Error in loginUser: $e');
      return null;
    }
  }
}
