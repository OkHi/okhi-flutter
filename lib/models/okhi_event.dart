import 'package:okhi_flutter/models/okhi_location.dart';
import 'package:okhi_flutter/models/okhi_user.dart';

class OkHiEvent {
  final String resultType;
  final String methodCall;
  final OkHiUser? user;
  final OkHiLocation? location;
  final String? code;
  final String? message;

  OkHiEvent({
    required this.resultType,
    required this.methodCall,
    this.user,
    this.location,
    this.code,
    this.message,
  });

  factory OkHiEvent.fromMap(Map<String, dynamic> map) {
    return OkHiEvent(
      resultType: map['type'],
      methodCall: map['methodCall'],
      user: map['user'] != null
          ? OkHiUser.fromMap(phone: map['user']['phone'], data: map['user'])
          : null,
      location: map['location'] != null
          ? OkHiLocation.fromMap(map['location'])
          : null,
      code: map['code'],
      message: map['message'],
    );
  }
}
