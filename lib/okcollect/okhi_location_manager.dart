import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../okhi_flutter.dart';
import '../models/okhi_constant.dart';
import '../models/okhi_native_methods.dart';

/// The OkHiLocationManager enables you to launch OkHi from your app and collect accurate addresses from your users.
class OkHiLocationManager extends StatefulWidget {
  final OkHiUser user;
  late final OkHiLocationManagerConfiguration locationManagerConfiguration;
  final Function(OkHiLocationManagerResponse response)? onSucess;
  final Function(OkHiException exception)? onError;
  final Function()? onCloseRequest;

  OkHiLocationManager({
    Key? key,
    required this.user,
    OkHiLocationManagerConfiguration? configuration,
    this.onSucess,
    this.onError,
    this.onCloseRequest,
  })  : locationManagerConfiguration =
            configuration ?? OkHiLocationManagerConfiguration(),
        super(key: key);

  @override
  _OkHiLocationManagerState createState() => _OkHiLocationManagerState();

  static setUser(OkHiUser user) {}
}

class _OkHiLocationManagerState extends State<OkHiLocationManager> {
  WebViewController? _controller;
  String? _appIdentifier;
  String? _appVersion;
  String _locationManagerUrl = OkHiConstant.sandboxLocationManagerUrl;
  Map<String, Object>? _coords;
  Map<String, Object>? _deviceInfo;
  List<dynamic>? _geofences;
  String _locationPermissionLevel = "denied";
  String _locationAccuracyLevel = "no_permission";
  final MethodChannel _channel = const MethodChannel('okhi_flutter');
  bool _canOpenProtectedApps = false;
  bool _androidAlwaysRequested = false;

  @override
  void initState() {
    super.initState();
    _handleInitState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return PopScope(
      onPopInvoked: (didPop) {
        _handleWillPopScope();
      },
      child: WebViewWidget(controller: _controller!),
    );
  }

  Future<bool> _handleWillPopScope() async {
    bool canGoBack = await _controller?.canGoBack() ?? false;
    if (canGoBack) {
      await _controller?.goBack();
    }
    return !canGoBack;
  }

  Future<String> _fetchLocationManagerUrl(String env) async {
    final platformVersion = await OkHi.platformVersion;
    if (Platform.isIOS ||
        (Platform.isAndroid && int.parse(platformVersion) > 23)) {
      if (env == "dev") {
        return OkHiConstant.devLocationManagerUrl;
      } else if (env == "prod") {
        return OkHiConstant.prodLocationManagerUrl;
      } else {
        return OkHiConstant.sandboxLocationManagerUrl;
      }
    } else {
      if (env == "dev") {
        return OkHiConstant.legacyDevLocationManagerUrl;
      } else if (env == "prod") {
        return OkHiConstant.legacyProdLocationManagerUrl;
      } else {
        return OkHiConstant.legacySandboxLocationManagerUrl;
      }
    }
  }

  _handleInitState() async {
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    final configuration = OkHi.getConfiguration();
    if (configuration != null) {
      _locationManagerUrl =
          await _fetchLocationManagerUrl(configuration.environmentRawValue);
      await _getAppInformation();
      _locationPermissionLevel = await OkHi.fetchLocationPermissionStatus();
      _deviceInfo = await OkHi.retrieveDeviceInfo();
      _geofences = await OkHi.fetchRegisteredGeofences();
      _locationAccuracyLevel = await OkHi.getLocationAccuracyLevel();
      if (_locationPermissionLevel != "denied") {
        _coords = await _fetchCoords();
      }
      if (Platform.isAndroid) {
        _canOpenProtectedApps = await OkHi.canOpenProtectedApps();
      }
      setState(() {
        _controller = WebViewController()
          ..loadRequest(Uri.parse(_locationManagerUrl))
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel("FlutterOkHi",
              onMessageReceived: _handleMessageReceived)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(onPageFinished: _handlePageLoaded),
          );
      });
    } else if (widget.onError != null) {
      widget.onError!(
        OkHiException(
          code: OkHiException.unauthorizedCode,
          message: OkHiException.unauthorizedMessage,
        ),
      );
    }
  }

  _handlePageLoaded(String page) async {
    var user = {"phone": widget.user.phone};
    if (widget.user.firstName != null) {
      user["firstName"] = widget.user.firstName!;
    }
    if (widget.user.lastName != null) {
      user["lastName"] = widget.user.lastName!;
    }
    if (widget.user.email != null) {
      user["email"] = widget.user.email!;
    }
    if (widget.user.appUserId != null) {
      user["appUserId"] = widget.user.appUserId!;
    }
    Map<String, dynamic> context = {
      "container": {"name": _appIdentifier, "version": _appVersion},
      "developer": {"name": "external"},
      "library": {
        "name": "okhiFlutter",
        "version": OkHiConstant.libraryVersion
      },
      "platform": {"name": "flutter"},
      "permissions": {"location": _locationPermissionLevel},
      "device": {
        "manufacturer": _deviceInfo!["manufacturer"],
        "model": _deviceInfo!["model"],
        "platform": _deviceInfo!["platform"],
        "osVersion": _deviceInfo!["osVersion"],
      },
      "locationAccuracyLevel": _locationAccuracyLevel,
    };
    if (_coords != null) {
      context["coordinates"] = {
        "currentLocation": {
          "lat": _coords!["lat"],
          "lng": _coords!["lng"],
          "accuracy": _coords!["accuracy"],
        },
      };
    }

    var usageTypeList = [];
    for (var type in (widget.locationManagerConfiguration.usageTypes)) {
      usageTypeList.add(type.toString());
    }
    final configuration = OkHi.getConfiguration();
    var data = {
      "url": _locationManagerUrl,
      "message": widget.locationManagerConfiguration.withCreateMode
          ? "start_app"
          : "select_location",
      "payload": {
        "locations": _geofences,
        "style": {
          "base": {
            "color": widget.locationManagerConfiguration.color,
            "logo": widget.locationManagerConfiguration.logoUrl,
            "name": "OkHi"
          }
        },
        "user": user,
        "auth": {
          "branchId": configuration?.branchId,
          "clientKey": configuration?.clientKey
        },
        "context": context,
        "config": {
          "streetView": widget.locationManagerConfiguration.withStreetView,
          "protectedApps": _canOpenProtectedApps,
          "appBar": {
            "color": widget.locationManagerConfiguration.color,
            "visible": widget.locationManagerConfiguration.withAppBar
          },
          "addressTypes": {
            "home": widget.locationManagerConfiguration.withHomeAddressType,
            "work": widget.locationManagerConfiguration.withWorkAddressType
          },
          "permissionsOnboarding": true,
          "usageTypes": usageTypeList
        },
        "location": widget.locationManagerConfiguration.locationId != null
            ? {"id": widget.locationManagerConfiguration.locationId}
            : null
      }
    };
    final payload = jsonEncode(data);
    _saveLaunchPayload(payload);
    await _overrideGeolocation(_controller!);
    await _controller?.runJavaScript("""
    function receiveMessage (data) {
      if (FlutterOkHi && FlutterOkHi.postMessage) {
        FlutterOkHi.postMessage(data);
      }
    }
    var bridge = { receiveMessage: receiveMessage };
    window.startOkHiLocationManager(bridge, $payload);
    """);
  }

  _handleMessageReceived(JavaScriptMessage jsMessage) {
    final Map<String, dynamic> data = jsonDecode(jsMessage.message);
    final String message = data["message"];
    switch (message) {
      case "location_created":
      case "location_updated":
      case "location_selected":
        _handleMessageSuccess(data["payload"]);
        break;
      case "fatal_exit":
        _handleMessageError(data["payload"]);
        break;
      case "request_enable_protected_apps":
        _handleRequestOpenProtectedApps();
        break;
      case "request_location_permission":
        _handleRequestLocationPermission(data["payload"]);
        break;
      case "fetch_current_location":
        _handleFetchCurrentLocation();
        break;
      case "open_app_settings":
        _handleOpenAppSettings();
        break;
      case "exit_app":
        _handleMessageExit();
        break;
      default:
    }
  }

  _handleOpenAppSettings() async {
    try {
      bool isPermGranted = await OkHi.isBackgroundLocationPermissionGranted();
      if (isPermGranted) {
        await _controller?.goBack();
      } else {
        await OkHi.openAppSettings();
      }
    } catch (e) {
      return;
    }
  }

  _handleFetchCurrentLocation() async {
    try {
      if (_coords != null) {
        String jsString =
            "window.receiveCurrentLocation({lat: ${_coords!['lat']},lng: ${_coords!['lng']},accuracy: ${_coords!['accuracy']}})";
        await _controller?.runJavaScript(jsString);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _runWebViewCallback(String result) async {
    String level = await OkHi.getLocationAccuracyLevel();
    if (result == "blocked" || result == "denied") {
      if (level == "approximate") {
        result = "whenInUse";
      }
    }
    Map<String, dynamic> update = {
      'locationAccuracyLevel': level,
    };
    String jsonUpdate = jsonEncode(update)
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"'); // Escape for JS string
    String jsString = """
    (function (){
      if (typeof runOkHiLocationManagerCallback === "function") {
        runOkHiLocationManagerCallback("$result", "$jsonUpdate")
      }
    })()
  """;
    await _controller?.runJavaScript(jsString);
    if (level == "precise" || level == "approximate") {
      _coords = await _fetchCoords();
    }
  }

  /// This is due to an issue with the webview
  /// It doesn't pick up the permission change during the active session i.e
  /// Calling watchPosition / getCurrentPosition doesn't work until user closes webview and comes back
  /// To fix that we override the implemntation and use coords retrived directly from phones GPS
  _overrideGeolocation(WebViewController controller) async {
    try {
      String jsString =
          "(function(){navigator.geolocation.watchPosition=function(s,e,o){if(window.FlutterOkHi&&FlutterOkHi.postMessage){FlutterOkHi.postMessage(JSON.stringify({message:'fetch_current_location',payload:{}}));}window.receiveCurrentLocation=function(l){s({coords:{latitude:l.lat,longitude:l.lng,accuracy:l.accuracy,altitude:null,altitudeAccuracy:null,heading:null,speed:null},timestamp:Date.now()});};};navigator.geolocation.getCurrentPosition=function(s,e,o){if(window.FlutterOkHi&&FlutterOkHi.postMessage){FlutterOkHi.postMessage(JSON.stringify({message:'fetch_current_location',payload:{}}));}window.receiveCurrentLocation=function(l){s({coords:{latitude:l.lat,longitude:l.lng,accuracy:l.accuracy,altitude:null,altitudeAccuracy:null,heading:null,speed:null},timestamp:Date.now()});};};})();";
      await controller.runJavaScript(jsString);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }

  _handleAndroidRequestLocationPermission(String level) async {
    bool isLocationPermissionGranted = await OkHi.isLocationPermissionGranted();
    bool isBackgroundLocationPermissionGranted =
        await OkHi.isBackgroundLocationPermissionGranted();
    String locationAccuracyLevel = await OkHi.getLocationAccuracyLevel();
    if (isBackgroundLocationPermissionGranted &&
        locationAccuracyLevel == "precise") {
      _runWebViewCallback("always");
    } else if (isLocationPermissionGranted &&
        locationAccuracyLevel == "precise" &&
        level != "always") {
      _runWebViewCallback("whenInUse");
    } else if (level == "whenInUse" &&
        locationAccuracyLevel == "no_permission") {
      bool result = await OkHi.requestLocationPermission();
      _runWebViewCallback(result ? "whenInUse" : "denied");
    } else if (level == "always" && !_androidAlwaysRequested) {
      bool result = await OkHi.requestBackgroundLocationPermission();
      _runWebViewCallback(result ? "always" : "denied");
      _androidAlwaysRequested = true;
    } else if (level == "whenInUse" && locationAccuracyLevel == "approximate") {
      bool result = await OkHi.requestLocationPermission();
      _runWebViewCallback(result ? "whenInUse" : "denied");
    } else {
      await OkHi.openAppSettings();
    }
  }

  _handleIOSRequestLocationPermission(String level) async {
    bool isLocationPermissionGranted = await OkHi.isLocationPermissionGranted();
    bool isBackgroundLocationPermissionGranted =
        await OkHi.isBackgroundLocationPermissionGranted();
    String locationAccuracyLevel = await OkHi.getLocationAccuracyLevel();

    if (isBackgroundLocationPermissionGranted &&
        locationAccuracyLevel == "precise") {
      _runWebViewCallback("always");
    } else if (level == "whenInUse" &&
        isLocationPermissionGranted &&
        locationAccuracyLevel == "precise") {
      _runWebViewCallback("whenInUse");
    } else if (level == "whenInUse" && !isLocationPermissionGranted) {
      bool result = await OkHi.requestLocationPermission();
      _runWebViewCallback(result ? "whenInUse" : "denied");
    } else {
      await OkHi.openAppSettings();
    }
  }

  _handleRequestLocationPermission(Map<String, dynamic> data) {
    if (Platform.isAndroid) {
      _handleAndroidRequestLocationPermission(data["level"]);
    } else if (Platform.isIOS) {
      _handleIOSRequestLocationPermission(data["level"]);
    } else if (widget.onError != null) {
      widget.onError!(OkHiException(
          code: OkHiException.unsupportedPlatformCode,
          message: "Platform not supported"));
    }
  }

  _handleMessageError(String data) {
    if (widget.onError != null) {
      widget.onError!(
        OkHiException(
          code: OkHiException.unknownErrorCode,
          message: data,
        ),
      );
    }
  }

  _handleMessageSuccess(Map<String, dynamic> data) {
    if (widget.onSucess != null) {
      widget.onSucess!(OkHiLocationManagerResponse(data));
    }
  }

  _handleMessageExit() {
    if (widget.onCloseRequest != null) {
      widget.onCloseRequest!();
    }
  }

  _handleRequestOpenProtectedApps() {
    try {
      OkHi.openProtectedApps();
      // ignore: empty_catches
    } catch (e) {}
  }

  _getAppInformation() async {
    const MethodChannel _channel = MethodChannel('okhi_flutter');
    _appIdentifier =
        await _channel.invokeMethod(OkHiNativeMethod.getAppIdentifier);
    _appVersion = await _channel.invokeMethod(OkHiNativeMethod.getAppVersion);
  }

  Future<Map<String, Object>?> _fetchCoords() async {
    bool isServiceAvailable = await OkHi.isLocationServicesEnabled();
    bool isPermissionGranted = await OkHi.isLocationPermissionGranted();
    if (isServiceAvailable && isPermissionGranted) {
      return OkHi.getCurrentLocation();
    }
    return null;
  }

  _saveLaunchPayload(String payload) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod(
          "setItem", {"key": "okcollect-launch-payload", "value": payload});
    }
  }
}
