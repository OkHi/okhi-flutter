class OkHiEvent {
  final String resultType;
  final String methodCall;
  final dynamic user;
  final dynamic location;
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
      user: map['user'],
      location: map['location'],
      code: map['code'],
      message: map['message'],
    );
  }
}
