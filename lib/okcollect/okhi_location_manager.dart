import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
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
  String? _accessToken;
  String? _authorizationToken;
  String? _appIdentifier;
  String? _appVersion;
  String _signInUrl = OkHiConstant.sandboxSignInUrl;
  String _locationManagerUrl = OkHiConstant.sandboxLocationManagerUrl;
  Map<String, Object>? _coords;
  Map<String, Object>? _deviceInfo;
  List<dynamic>? _geofences;
  String _locationPermissionLevel = "denied";
  final MethodChannel _channel = const MethodChannel('okhi_flutter');
  bool _canOpenProtectedApps = false;
  bool _isLocationEnabled = false;

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
    return WillPopScope(
      onWillPop: _handleWillPopScope,
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

  _fetchSignInUrl(String env) {
    if (env == "dev") {
      return OkHiConstant.devSignInUrl;
    } else if (env == "prod") {
      return OkHiConstant.prodSignInUrl;
    } else {
      return OkHiConstant.sandboxSignInUrl;
    }
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
      _isLocationEnabled = await OkHi.isLocationServicesEnabled();
      if (_locationPermissionLevel != "denied") {
        if(_isLocationEnabled){
          _coords = await _fetchCoords();
        } else {
          if (widget.onError != null) {
            widget.onError!(OkHiException(
                code: OkHiException.serviceUnavailableCode,
                message: "Please enable your location to continue."));
          }
          return;
        }
      }

      _signInUrl = _fetchSignInUrl(configuration.environmentRawValue);
      _locationManagerUrl =
          await _fetchLocationManagerUrl(configuration.environmentRawValue);
      final bytes =
          utf8.encode("${configuration.branchId}:${configuration.clientKey}");
      _accessToken = 'Token ${base64.encode(bytes)}';
      await _signInUser();
      await _getAppInformation();
      _locationPermissionLevel = await OkHi.fetchLocationPermissionStatus();
      _deviceInfo = await OkHi.retrieveDeviceInfo();
      _geofences = await OkHi.fetchRegisteredGeofences();
      if (Platform.isAndroid) {
        _canOpenProtectedApps = await OkHi.canOpenProtectedApps();
      }
      if (!widget.locationManagerConfiguration.withPermissionsOnboarding &&
          _locationPermissionLevel != "always") {
        if (widget.onError != null) {
          widget.onError!(OkHiException(
              code: OkHiException.permissionDeniedCode,
              message:
                  "Always location permission required to launch okcollect"));
        }
        return;
      }
      if (_authorizationToken != null) {
        setState(() {
          _controller = WebViewController()
            ..loadRequest(Uri.parse(_locationManagerUrl))
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..addJavaScriptChannel("FlutterOkHi",
                onMessageReceived: _handleMessageReceived)
            ..setNavigationDelegate(
              NavigationDelegate(onPageFinished: _handlePageLoaded),
            );
        });
      }
    } else if (widget.onError != null) {
      widget.onError!(
        OkHiException(
          code: OkHiException.unauthorizedCode,
          message: OkHiException.unauthorizedMessage,
        ),
      );
    }
  }

  _handlePageLoaded(String page) {
    var user = {"phone": widget.user.phone};
    if (widget.user.firstName != null) {
      user["firstName"] = widget.user.firstName!;
    }
    if (widget.user.lastName != null) {
      user["lastName"] = widget.user.lastName!;
    }
    Map<String, Map<String, Object?>> context = {
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
      }
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
        "auth": {"authToken": _authorizationToken},
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
          "permissionsOnboarding":
              widget.locationManagerConfiguration.withPermissionsOnboarding,
        }
      }
    };
    final payload = jsonEncode(data);
    _saveLaunchPayload(payload);
    _controller?.runJavaScript("""
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
      case "exit_app":
        _handleMessageExit();
        break;
      default:
    }
  }

  _runWebViewCallback(String result) {
    String jsString =
        "(function (){ if (typeof runOkHiLocationManagerCallback === \"function\") { runOkHiLocationManagerCallback(\"$result\") } })()";
    _controller?.runJavaScript(jsString);
  }

  /// This is due to an issue with the webview
  /// It doesn't pick up the permission change during the active session i.e
  /// Calling watchPosition / getCurrentPosition doesn't work until user closes webview and comes back
  /// To fix that we override the implemntation and use coords retrived directly from phones GPS
  _overrideGeolocation(WebViewController controller) async {
    try {
      Map<String, Object>? coords = await OkHi.getCurrentLocation();
      String jsString =
          "(function(){navigator.geolocation.watchPosition=function(s,e,o){return s({coords:{latitude:${coords!['lat']},longitude:${coords['lng']},accuracy:${coords['accuracy']},altitude:null,altitudeAccuracy:null,heading:null,speed:null},timestamp:Date.now()},123)};navigator.geolocation.getCurrentPosition=function(s,e,o){return s({coords:{latitude:${coords['lat']},longitude:${coords['lng']},accuracy:${coords['accuracy']},altitude:null,altitudeAccuracy:null,heading:null,speed:null},timestamp:Date.now()})}})();";
      await controller.runJavaScript(jsString);
    } catch (e) {
      return;
    }
  }

  _handleAndroidRequestLocationPermission(String level) async {
    if (level == 'whenInUse') {
      bool result = await OkHi.requestLocationPermission();
      if (result && _controller != null) {
        await _overrideGeolocation(_controller!);
      }
      _runWebViewCallback(result ? 'whenInUse' : 'blocked');
    } else if (level == 'always') {
      bool result = await OkHi.requestBackgroundLocationPermission();
      _runWebViewCallback(result ? 'always' : 'blocked');
    }
  }

  _handleIOSRequestLocationPermission(String level) async {
    bool isServiceAvailable = await OkHi.isLocationServicesEnabled();
    if (!isServiceAvailable) {
      await OkHi.openAppSettings();
    } else if (level == 'whenInUse') {
      bool result = await OkHi.requestLocationPermission();
      if (result && _controller != null) {
        await _overrideGeolocation(_controller!);
      }
      _runWebViewCallback(result ? level : 'denied');
    } else if (level == 'always') {
      bool granted = await OkHi.isBackgroundLocationPermissionGranted();
      if (granted) {
        _runWebViewCallback(level);
      } else {
        await OkHi.openAppSettings();
      }
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

  _signInUser() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': _accessToken ?? ''
    };
    final body = jsonEncode({
      "phone": widget.user.phone,
      "scopes": ["address"]
    });
    final parsedUrl = Uri.parse(_signInUrl);
    try {
      final response = await http
          .post(
            parsedUrl,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        _authorizationToken = body["authorization_token"];
      } else if (widget.onError != null) {
        switch (response.statusCode) {
          case 400:
            widget.onError!(
              OkHiException(
                code: OkHiException.invalidPhoneCode,
                message: OkHiException.invalidPhoneMessage,
              ),
            );
            break;
          case 401:
            widget.onError!(
              OkHiException(
                code: OkHiException.unauthorizedCode,
                message: OkHiException.unauthorizedMessage,
              ),
            );
            break;
          default:
            widget.onError!(
              OkHiException(
                code: OkHiException.unknownErrorCode,
                message: OkHiException.uknownErrorMessage,
              ),
            );
        }
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(
          OkHiException(
            code: OkHiException.networkError,
            message: OkHiException.networkErrorMessage,
          ),
        );
      }
    }
  }

  Future<Map<String, Object>?> _fetchCoords() async {
    bool isServiceAvailable = await OkHi.isLocationPermissionGranted();
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
