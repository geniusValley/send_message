class ContactModel {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final List<int> groups;

  ContactModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.groups,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      groups: List<int>.from(json['groups']),
    );
  }
}