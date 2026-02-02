import './okhi_env.dart';

/// Defines the current mode you'll be using OkHi's services, your API Keys, as well as your application's meta information.
class OkHiAppConfiguration {
  final String branchId;
  final String clientKey;
  OkHiEnv env = OkHiEnv.sandbox;
  String environmentRawValue = "sandbox";

  OkHiAppConfiguration({
    required this.branchId,
    required this.clientKey,
    required this.env,
  }) {
    if (env == OkHiEnv.prod) {
      environmentRawValue = "prod";
    }
    if (env == OkHiEnv.dev) {
      environmentRawValue = "dev";
    }
  }

  OkHiAppConfiguration.withRawValue({
    required this.branchId,
    required this.clientKey,
    required this.environmentRawValue,
  });
}
