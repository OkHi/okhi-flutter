class OkHiEvent {
  final String resultType;
  final String methodCall;
  final String? locationId;
  final String? code;
  final String? message;

  OkHiEvent({
    required this.resultType,
    required this.methodCall,
    this.locationId,
    this.code,
    this.message,
  });

  factory OkHiEvent.fromMap(Map<String, dynamic> map) {
    return OkHiEvent(
      resultType: map['type'],
      methodCall: map['methodCall'],
      locationId: map['locationId'],
      code: map['code'],
      message: map['message'],
    );
  }
}
