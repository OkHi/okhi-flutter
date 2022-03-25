import '../okhi_flutter.dart';

/// The OkHiLocationManagerResponse object contains information about the newly
/// created user and location once an address has been successfully created.
/// It can be used to extract information about the address and/or start address verification process.
class OkHiLocationManagerResponse {
  late OkHiUser user;
  late OkHiLocation location;

  OkHiLocationManagerResponse(Map<String, dynamic> data) {
    location = OkHiLocation.fromMap(data["location"]);
    user = OkHiUser.fromMap(phone: data["user"]["phone"], data: data["user"]);
  }

  @override
  String toString() {
    return '{"user": ${user.toString()}, "location": ${location.toString()}}';
  }

  Future<String> startVerification(
      OkHiVerificationConfiguration? configuration) {
    return OkHi.startVerification(user, location, configuration);
  }
}
