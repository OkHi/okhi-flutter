/// Used to configure how address verification will run on different platforms
class OkHiVerificationConfiguration {
  bool withForegroundService = true;
  OkHiVerificationConfiguration({bool? withForegroundService}) {
    this.withForegroundService = withForegroundService ?? true;
  }
}
