import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../okhi_flutter.dart';
import '../models/okhi_user.dart';
import '../models/okhi_constant.dart';
import '../models/okhi_location_manager_configuration.dart';
import '../models/okhi_location_manager_response.dart';
import '../models/okhi_native_methods.dart';
import '../models/okhi_exception.dart';

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
  Map<String, Object>? coords;
  bool _isLoading = true;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _handleInitState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    return WillPopScope(
      onWillPop: _handleWillPopScope,
      child: WebView(
        initialUrl: _locationManagerUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
            name: 'FlutterOkHi',
            onMessageReceived: _handleMessageReceived,
          )
        },
        onWebViewCreated: _handleOnWebViewCreated,
        onPageFinished: _handlePageLoaded,
      ),
    );
  }

  Future<bool> _handleWillPopScope() async {
    bool canGoBack = await _controller?.canGoBack() ?? false;
    if (canGoBack) {
      await _controller?.goBack();
    }
    return !canGoBack;
  }

  _handleInitState() async {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    final configuration = OkHi.getConfiguration();
    if (configuration != null) {
      if (configuration.environmentRawValue == "dev") {
        _signInUrl = OkHiConstant.devSignInUrl;
        _locationManagerUrl = OkHiConstant.devLocationManagerUrl;
      } else if (configuration.environmentRawValue == "prod") {
        _signInUrl = OkHiConstant.prodSignInUrl;
        _locationManagerUrl = OkHiConstant.prodLocationManagerUrl;
      }
      final bytes =
          utf8.encode("${configuration.branchId}:${configuration.clientKey}");
      _accessToken = 'Token ${base64.encode(bytes)}';
      await _signInUser();
      await _getAppInformation();
      _locationPermissionGranted = await OkHi.isLocationPermissionGranted();
      if (_locationPermissionGranted) {
        const MethodChannel _channel = MethodChannel('okhi_flutter');
        coords = await _channel.invokeMapMethod("getCurrentLocation");
      }
      if (_authorizationToken != null) {
        setState(() {
          _isLoading = false;
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

  _handleOnWebViewCreated(WebViewController controller) {
    _controller = controller;
  }

  _handlePageLoaded(String page) {
    Object? lat = 0;
    Object? lng = 0;
    Object? accuracy = 0;
    if (coords != null) {
      lat = coords!["lat"];
      lng = coords!["lng"];
      accuracy = coords!["accuracy"];
    }
    var data = {
      "message": "select_location",
      "payload": {
        "style": {
          "base": {
            "color": widget.locationManagerConfiguration.color,
            "logo": widget.locationManagerConfiguration.logoUrl,
            "name": "OkHi"
          }
        },
        "user": {"phone": widget.user.phone},
        "auth": {"authToken": _authorizationToken},
        "context": {
          "container": {"name": _appIdentifier, "version": _appVersion},
          "developer": {"name": "external"},
          "library": {
            "name": "okhiFlutter",
            "version": OkHiConstant.libraryVersion
          },
          "platform": {"name": "flutter"},
          "permissions": {
            "location": _locationPermissionGranted ? "whenInUse" : "denied"
          },
          "coordinates": {
            "currentLocation": {
              "lat": lat,
              "lng": lng,
              "accuracy": accuracy,
            },
          },
        },
        "config": {
          "streetView": widget.locationManagerConfiguration.withStreetView,
          "appBar": {
            "color": widget.locationManagerConfiguration.color,
            "visible": widget.locationManagerConfiguration.withAppBar
          }
        }
      }
    };
    final payload = jsonEncode(data);
    _controller?.runJavascript("""
    function receiveMessage (data) {
      if (FlutterOkHi && FlutterOkHi.postMessage) {
        FlutterOkHi.postMessage(data);
      }
    }
    var bridge = { receiveMessage: receiveMessage };
    window.startOkHiLocationManager(bridge, $payload);
    """);
  }

  _handleMessageReceived(JavascriptMessage jsMessage) {
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
      case "exit_app":
        _handleMessageExit();
        break;
      default:
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
}
