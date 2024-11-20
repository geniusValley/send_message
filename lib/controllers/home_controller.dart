import 'dart:convert';
import '../models/group_model.dart';
import '../models/contact_model.dart';
import '../services/api_service.dart';

class HomeController {
  final ApiService _apiService = ApiService();

  // متد برای تنظیم توکن
  Future<void> setAuthToken(String token) async {
    _apiService.setAuthToken(token);
  }

  Future<List<GroupModel>> fetchGroups() async {
    const String endpoint = 'contacts/api/group_list/';

    try {
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes))['data'];
        return data.map((group) => GroupModel.fromJson(group)).toList();
      } else {
        throw Exception('Failed to fetch groups: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Error in fetchGroups: $e');
      return [];
    }
  }

  Future<AddContactResponse?> addContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required String groupId,
  }) async {
    const String endpoint = 'contacts/api/create_contacts/';

    try {
      final response = await _apiService.post(endpoint, {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'gender': gender,
        'group_id': groupId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes))['data'];
        final message = json.decode(utf8.decode(response.bodyBytes))['message'] ?? 'کاربر با موفقیت اضافه شد.';

        final contact = ContactModel.fromJson(data);
        return AddContactResponse(contact: contact, message: message); // بازگشت کلاس AddContactResponse
      } else {
        throw Exception('Failed to add contact: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('Error in addContact: $e');
      return null; // اگر خطا باشد، null برمی‌گرداند
    }
  }

}

class AddContactResponse {
  final ContactModel contact;
  final String message;

  AddContactResponse({
    required this.contact,
    required this.message,
  });
}