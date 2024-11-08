class LoginResponseModel {
  final String authorizationToken;
  final String userId;
  final String phoneNumberDisplay;
  final String firstName;
  final String lastName;

  LoginResponseModel({
    required this.authorizationToken,
    required this.userId,
    required this.phoneNumberDisplay,
    required this.firstName,
    required this.lastName,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      authorizationToken: json['Authorization'],
      userId: json['user_id'],
      phoneNumberDisplay: json['phone_number_display'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}
