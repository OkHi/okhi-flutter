import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/models/okhi_user.dart';
import 'package:okhi_flutter/utils/utilities.dart';
import './models/okhi_app_configuration.dart';
import './models/okhi_native_methods.dart';
import './models/okhi_exception.dart';

// models export
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
    final String version = await _channel.invokeMethod(
      OkHiNativeMethod.getPlatformVersion,
    );
    return version;
  }

  /// Checks whether location services are enabled.
  static Future<bool> isLocationServicesEnabled() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.isLocationServicesEnabled,
    );
    return result;
  }

  /// Checks whether when in use location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.isLocationPermissionGranted,
    );
    return result;
  }

  /// Checks whether Notifications are enabled.
  static Future<bool> isNotificationsEnabled() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.isNotificationsEnabled,
    );
    return result;
  }

  /// Checks whether background location permission is granted.
  static Future<bool> isBackgroundLocationPermissionGranted() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.isBackgroundLocationPermissionGranted,
    );
    return result;
  }

  /// Android Only - Checks if Google Play Services is available.
  static Future<bool> isGooglePlayServicesAvailable() async {
    if (Platform.isAndroid) {
      final bool result = await _channel.invokeMethod(
        OkHiNativeMethod.isGooglePlayServicesAvailable,
      );
      return result;
    } else {
      throw OkHiException(
        code: OkHiException.unsupportedPlatformCode,
        message: OkHiException.unsupportedPlatformMessage,
      );
    }
  }

  /// Requests Notifications permission.
  static Future<bool> requestNotificationsPermission() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.requestEnableNotifications,
    );
    return result;
  }

  /// Requests for when in use location permission.
  static Future<bool> requestLocationPermission() async {
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.requestLocationPermission,
    );
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
    final bool result = await _channel.invokeMethod(
      OkHiNativeMethod.requestBackgroundLocationPermission,
    );
    return result;
  }

  /// Requests the user to enable location services by showing an in app modal on android and opening location settings on iOS.
  static Future<bool> requestEnableLocationServices() async {
    if (Platform.isAndroid) {
      final bool result = await _channel.invokeMethod(
        OkHiNativeMethod.requestEnableLocationServices,
      );
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
      final bool result = await _channel.invokeMethod(
        OkHiNativeMethod.requestEnableGooglePlayServices,
      );
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
  ///  * [okHiUser] An instance of OkHiUser, nullable
  static Future<bool> initialize(
    OkHiAppConfiguration configuration,
    OkHiUser? okHiUser,
  ) async {
    _configuration = configuration;

    if (okHiUser == null) {
      debugPrint(
          '⚠️ [OkHi]: Missing OkHiUser parameter in initialize(). Providing a user helps verify previous addresses. See https://docs.okhi.com');
    }

    final credentials = {
      "branchId": configuration.branchId,
      "clientKey": configuration.clientKey,
      "environment": configuration.environmentRawValue,

      // Optional arguments for addresses auto-syncing
      "phoneNumber": okHiUser?.phone,
      "userId": okHiUser?.id,
      "token": okHiUser?.token,
      "email": okHiUser?.email,
      "firstname": okHiUser?.firstName,
      "lastname": okHiUser?.lastName,
      "appUserId": okHiUser?.appUserId,
    };

    bool initState = false;
    try {
      initState = await _channel.invokeMethod(
        OkHiNativeMethod.initialize,
        credentials,
      );

      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          Platform.isIOS) {
        await _channel.invokeMethod(OkHiNativeMethod.onStart);
      }
    } catch (e) {
      appDebugPrint("OkHi Initialization error: $e");
      // ignore
    }

    return initState;
  }

  /// Returns the current configuration
  static OkHiAppConfiguration? getConfiguration() {
    return _configuration;
  }

  /// Starts Digital verification for a particular address.
  static Future<String> startDigitalAddressVerification() async {
    return await _channel.invokeMethod(
      OkHiNativeMethod.startDigitalAddressVerification,
    );
  }

  /// Starts Physical verification for a particular address.
  static Future<String> startPhysicalAddressVerification() async {
    return await _channel.invokeMethod(
      OkHiNativeMethod.startPhysicalAddressVerification,
    );
  }

  /// Starts Digital And Physical verification for a particular address.
  static Future<String> startDigitalAndPhysicalAddressVerification() async {
    return await _channel.invokeMethod(
      OkHiNativeMethod.startDigitalAndPhysicalAddressVerification,
    );
  }

  /// Create a Digital address for a particular location.
  static Future<String> createAddress() async {
    return await _channel.invokeMethod(OkHiNativeMethod.createAddress);
  }

  /// Android Only - Checks whether current device can open "Protected Apps Settings" available in Transsion Group android devices such as Infinix and Tecno
  /// When your application is included in protected apps, verification processes are less likely to be terminated by the OS. Increasing rate of users being verified.
  static Future<bool> canOpenProtectedApps() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod(OkHiNativeMethod.canOpenProtectedApps);
    }
    return false;
  }

  /// Android Only - Opens "Protected Apps Settings" available in Transsion Group android devices such as Infinix and Tecno
  /// When your application is included in protected apps, verification processes are less likely to be terminated by the OS. Increasing rate of users being verified.
  static Future<void> openProtectedApps() async {
    await _channel.invokeMethod(OkHiNativeMethod.openProtectedApps);
  }

  static Future<Map<String, Object>?> retrieveDeviceInfo() async {
    return await _channel.invokeMapMethod(OkHiNativeMethod.retrieveDeviceInfo);
  }

  static Future<String> fetchLocationPermissionStatus() async {
    return await _channel.invokeMethod(
      OkHiNativeMethod.fetchLocationPermissionStatus,
    );
  }

  static Future<List<dynamic>> fetchRegisteredGeofences() async {
    final geofences = await _channel.invokeMethod(
      OkHiNativeMethod.fetchRegisteredGeofences,
    );
    if (geofences != null) {
      return jsonDecode(geofences);
    }
    return [];
  }

  static Future<bool> openAppSettings() async {
    return await _channel.invokeMethod(OkHiNativeMethod.openAppSettings);
  }

  static Future<Map<String, Object>?> getCurrentLocation() async {
    final Map<String, Object>? coords = await _channel.invokeMapMethod(
      OkHiNativeMethod.getCurrentLocation,
    );
    return coords;
  }

  static Future<String> getLocationAccuracyLevel() async {
    return await _channel.invokeMethod(
      OkHiNativeMethod.getLocationAccuracyLevel,
    );
  }
}
