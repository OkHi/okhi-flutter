class OkHiException implements Exception {
  String code;
  String message;

  static const String networkError = 'network_error';
  static const String networkErrorMessage =
      'Unable to establish a connection with OkHi servers';
  static const String unknownErrorCode = 'unknown_error';
  static const String uknownErrorMessage =
      'Unable to process the request. Something went wrong';
  static const String invalidPhoneCode = 'invalid_phone';
  static const String invalidPhoneMessage =
      'Invalid phone number provided. Please make sure its in MSISDN standard format';
  static const String unauthorizedCode = 'unauthorized';
  static const String unauthorizedMessage = 'Invalid credentials provided';
  static const String permissionDeniedCode = 'permission_denied';
  static const String serviceUnavailableCode = 'service_unavailable';
  static const String unsupportedPlatformCode = 'unsupported_platform';
  static const String unsupportedPlatformMessage =
      'Current platform is not supported';
  static const String badRequestCode = 'bad_request';
  static const String badRequestMessage = 'Invalid parameters provided';

  OkHiException({required this.code, required this.message});
}
