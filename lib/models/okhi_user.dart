import 'dart:convert';

/// Defines the structure of the user object requried by OkHi services and libraries.
class OkHiUser {
  String phone;
  String? firstName;
  String? lastName;
  String? id;
  String? email;
  String? appUserId;
  String? token;

  OkHiUser({
    required this.phone,
    this.firstName,
    this.lastName,
    this.id,
    this.email,
    this.appUserId,
    this.token,
  });

  OkHiUser.fromMap({required this.phone, required Map<String, dynamic> data}) {
    id = data.containsKey("id") ? data["id"] : null;
    firstName = data.containsKey("firstName")
        ? data["firstName"]
        : data.containsKey("first_name")
            ? data["first_name"]
            : null;
    lastName = data.containsKey("lastName")
        ? data["lastName"]
        : data.containsKey("last_name")
            ? data["last_name"]
            : null;
    email = data.containsKey("email") ? data["email"] : null;
    appUserId = data.containsKey("app_user_id")
        ? data["app_user_id"]
        : data.containsKey("appUserId")
            ? data["appUserId"]
            : null;
    token = data.containsKey("token") ? data["token"] : null;
  }

  @override
  String toString() {
    return jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "id": id,
      "phone": phone,
      "email": email,
      "appUserId": appUserId,
      "token": token
    });
  }
}
