import 'dart:convert';
import '../models/group_model.dart';
import '../models/contact_model.dart';
import '../services/api_service.dart';

class HomeController {
  final ApiService _apiService = ApiService();

  Future<List<GroupModel>> fetchGroups() async {
    const String endpoint = 'contacts/api/group_list/';

    try {
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((group) => GroupModel.fromJson(group)).toList();
      } else {
        throw Exception('Failed to fetch groups: ${response.body}');
      }
    } catch (e) {
      print('Error in fetchGroups: $e');
      return [];
    }
  }

  Future<ContactModel?> addContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
    required int groupId,
  }) async {
    const String endpoint = 'contacts/api/create_contacts/';

    try {
      final response = await _apiService.post(endpoint, {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'gender': gender,
        'groups': groupId,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return ContactModel.fromJson(data);
      } else {
        throw Exception('Failed to add contact: ${response.body}');
      }
    } catch (e) {
      print('Error in addContact: $e');
      return null;
    }
  }
}
