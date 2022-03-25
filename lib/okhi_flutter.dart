import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/models/okhi_location.dart';
import 'package:okhi_flutter/models/okhi_user.dart';
import './models/okhi_app_configuration.dart';
import './models/okhi_native_methods.dart';
import './models/okhi_verification_configuration.dart';
import './models/okhi_exception.dart';

// models export
export './okcollect/okhi_location_manager.dart';
export './models/okhi_app_configuration.dart';
export './models/okhi_env.dart';
export './models/okhi_user.dart';
export './models/okhi_location_manager_response.dart';
export './models/okhi_location_manager_configuration.dart';
export './models/okhi_notification.dart';
export './models/okhi_verification_configuration.dart';
export './models/okhi_location.dart';
export './models/okhi_exception.dart';

/// The primary class for integrating OkHi with your app.
class OkHi {
  static const MethodChannel _channel = MethodChannel('okhi_flutter');
  static OkHiAppConfiguration? _configuration;

  ///  Returns the system version of the current platform
  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod(OkHiNativeMethod.getPlatformVersion);
    return version;
  }

  /// Checks whether location services are enabled.
  static Future<bool> isLocationServicesEnabled() async {
    final bool result =
        await _channel.invokeMethod(OkHiNativeMethod.isLocationServicesEnabled);
    return result;
  }

  /// Checks whether when in use location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.isLocationPermissionGranted);
    return result;
  }

  /// Checks whether background location permission is granted.
  static Future<bool> isBackgroundLocationPermissionGranted() async {
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.isBackgroundLocationPermissionGranted);
    return result;
  }

  /// Android Only - Checks if Google Play Services is available.
  static Future<bool> isGooglePlayServicesAvailable() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.isGooglePlayServicesAvailable);
      return result;
    } else {
      throw OkHiException(
          code: OkHiException.unsupportedPlatformCode,
          message: OkHiException.unsupportedPlatformMessage);
    }
  }

  /// Requests for when in use location permission.
  static Future<bool> requestLocationPermission() async {
    final bool result =
        await _channel.invokeMethod(OkHiNativeMethod.requestLocationPermission);
    return result;
  }

  /// Requests for background location permission.
  static Future<bool> requestBackgroundLocationPermission() async {
    if (Platform.isAndroid) {
      final bool whenInUsePermission = await requestLocationPermission();
      if (!whenInUsePermission) {
        return false;
      }
    }
    final bool result = await _channel
        .invokeMethod(OkHiNativeMethod.requestBackgroundLocationPermission);
    return result;
  }

  /// Requests the user to enable location services by showing an in app modal on android and opening location settings on iOS.
  static Future<bool> requestEnableLocationServices() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.requestEnableLocationServices);
      return result;
    } else {
      throw OkHiException(
        code: OkHiException.unsupportedPlatformCode,
        message: OkHiException.unsupportedPlatformMessage,
      );
    }
  }

  /// Android Only - Requests user to enable Google Play Services.
  static Future<bool> requestEnableGooglePlayServices() async {
    if (Platform.isAndroid) {
      final bool result = await _channel
          .invokeMethod(OkHiNativeMethod.requestEnableGooglePlayServices);
      return result;
    } else {
      throw OkHiException(
        code: OkHiException.unsupportedPlatformCode,
        message: OkHiException.unsupportedPlatformMessage,
      );
    }
  }

  ///  Initializes the library with provided API Keys and optional notification configuration.
  ///  * [configuration] An instance of OkHiAppConfiguration
  static Future<bool> initialize(OkHiAppConfiguration configuration) async {
    _configuration = configuration;
    final credentials = {
      "branchId": configuration.branchId,
      "clientKey": configuration.clientKey,
      "environment": configuration.environmentRawValue,
      "notification": configuration.notification.toMap()
    };
    print("hmm...");
    return await _channel.invokeMethod(
        OkHiNativeMethod.initialize, credentials);
  }

  /// Returns the current configuration
  static OkHiAppConfiguration? getConfiguration() {
    return _configuration;
  }

  /// Starts verification for a particular address using the response object returned by OkHiLocationManager.
  /// * [user] An instance of OkHiUser
  /// * [location] An instance of OkHiLocation
  /// * [configuration] Optional Configures how verification will start on different platforms
  static Future<String> startVerification(OkHiUser user, OkHiLocation location,
      OkHiVerificationConfiguration? configuration) async {
    if (location.id == null || location.lat == null || location.lon == null) {
      throw OkHiException(
        code: OkHiException.badRequestCode,
        message: "Invalid arguments provided for starting verification",
      );
    }

    final config = configuration ?? OkHiVerificationConfiguration();
    return await _channel.invokeMethod(OkHiNativeMethod.startVerification, {
      "phoneNumber": user.phone,
      "locationId": location.id,
      "lat": location.lat,
      "lon": location.lon,
      "withForegroundService": config.withForegroundService,
    });
  }

  /// Stops verification for a particular address.
  /// * [user] An instance of OkHiUser
  /// * [location] An instance of OkHiLocation
  static Future<String> stopVerification(
      OkHiUser user, OkHiLocation location) async {
    if (location.id == null) {
      throw OkHiException(
        code: OkHiException.badRequestCode,
        message: "Invalid arguments provided for stopping verification",
      );
    } else {
      return await _channel.invokeMethod(OkHiNativeMethod.stopVerification, {
        "phoneNumber": user.phone,
        "locationId": location.id,
      });
    }
  }

  /// Android Only - Checks if the foreground service is running.
  static Future<bool> isForegroundServiceRunning() async {
    return await _channel
        .invokeMethod(OkHiNativeMethod.isForegroundServiceRunning);
  }

  /// Android Only - Starts a foreground service that speeds up rate of verification.
  static Future<bool> startForegroundService() async {
    return await _channel.invokeMethod(OkHiNativeMethod.startForegroundService);
  }

  /// Android Only - Stops previously started foreground services.
  static Future<bool> stopForegroundService() async {
    return await _channel.invokeMethod(OkHiNativeMethod.stopForegroundService);
  }

  /// Checks whether all necessary permissions and services are available in order to start the address verification process.
  /// * [requestServices] Attempt to activate / request all necesarry permissions and services
  static Future<bool> canStartVerification(bool requestServices) async {
    if (Platform.isIOS && !(await OkHi.isLocationServicesEnabled())) {
      throw OkHiException(
        code: OkHiException.serviceUnavailableCode,
        message: "Location services disabled",
      );
    }
    var hasLocationServices =
        Platform.isIOS ? true : await OkHi.isLocationServicesEnabled();
    var hasLocationPermission =
        await OkHi.isBackgroundLocationPermissionGranted();
    var hasGooglePlayService =
        Platform.isIOS ? true : await OkHi.isGooglePlayServicesAvailable();
    if (!requestServices) {
      return hasLocationServices &&
          hasLocationPermission &&
          hasGooglePlayService;
    }
    hasLocationServices =
        Platform.isIOS ? true : await OkHi.requestEnableLocationServices();
    hasLocationPermission = await OkHi.requestBackgroundLocationPermission();
    hasGooglePlayService =
        Platform.isIOS ? true : await OkHi.requestEnableGooglePlayServices();
    return hasLocationServices && hasLocationPermission && hasGooglePlayService;
  }
}
