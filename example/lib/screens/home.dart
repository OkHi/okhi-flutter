import 'package:flutter/material.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter_example/screens/create_address.dart';
import '../widgets/full_button.dart';
import '../widgets/message_box.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String message = "";
  OkHiUser okHiUser = OkHiUser(
    phone: "+2547..",
    firstName: "Jane",
    lastName: "Doe",
    appUserId: "abcd1234",
    email: "abcd@okhi.co",
  );
  OkHiLocation? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OkHi"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FullButton(
                title: "Login",
                onPressed: _handleLogin,
              ),
              FullButton(
                title: "Platform version",
                onPressed: _handlePlatformVersion,
              ),
              FullButton(
                title: "Location Services Check",
                onPressed: _handleIsLocationServicesEnabled,
              ),
              FullButton(
                title: "Location Permission Check",
                onPressed: _handleIsLocationPermissionGranted,
              ),
              FullButton(
                title: "Background Location Permission Check",
                onPressed: _handleIsBackgroundLocationPermissionGranted,
              ),
              FullButton(
                title: "Google Play Services Permission Check",
                onPressed: _handleIsGooglePlayServicesAvailable,
              ),
              FullButton(
                title: "Request location permission",
                onPressed: _handleRequestLocationPermission,
              ),
              FullButton(
                title: "Request background location permission",
                onPressed: _handleRequestBackgroundLocationPermission,
              ),
              FullButton(
                title: "Request enable location service",
                onPressed: _handleRequestEnableLocationService,
              ),
              FullButton(
                title: "Get Location accuracy level",
                onPressed: _handleGetLocationAccuracyLevel,
              ),
              FullButton(
                title: "Create an address",
                onPressed: () {
                  _handleCreateAnAddress(context);
                },
              ),
              FullButton(
                title: "Verify address",
                onPressed: () {
                  _handleVerifyAddress();
                },
                disabled: _handleVerificationButtonDisabled(),
              ),
              FullButton(
                title: "Stop address verification",
                onPressed: _handleStopVerification,
                disabled: _handleVerificationButtonDisabled(),
              ),
              FullButton(
                title: "Start foreground service",
                onPressed: _handleStartForegroundService,
              ),
              FullButton(
                title: "Stop foreground service",
                onPressed: _handleStopForegroundService,
              ),
              FullButton(
                title: "Is service running",
                onPressed: _handleCheckForegroundService,
              ),
              MessageBox(message: message)
            ],
          ),
        ),
      ),
    );
  }

  _handleLogin() async {
    final config = OkHiAppConfiguration(
      branchId: "bWpVwm65jy",
      clientKey: "3db1617f-b25b-4a80-8165-8077b4d1ea44",
      env: OkHiEnv.sandbox,
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );

    OkHi.initialize(config, okHiUser).then((result) {
      print(">>>>>>: $result");
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  _handlePlatformVersion() async {
    final result = await OkHi.platformVersion;
    setState(() {
      message = result;
    });
  }

  _handleIsLocationServicesEnabled() async {
    final result = await OkHi.isLocationServicesEnabled();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsLocationPermissionGranted() async {
    final result = await OkHi.isLocationPermissionGranted();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsBackgroundLocationPermissionGranted() async {
    final result = await OkHi.isBackgroundLocationPermissionGranted();
    setState(() {
      message = result.toString();
    });
  }

  _handleIsGooglePlayServicesAvailable() async {
    final result = await OkHi.isGooglePlayServicesAvailable();
    setState(() {
      message = result.toString();
    });
  }

  _handleRequestLocationPermission() async {
    final result = await OkHi.requestLocationPermission();
    setState(() {
      message = result.toString();
    });
  }

  _handleRequestBackgroundLocationPermission() async {
    final result = await OkHi.requestBackgroundLocationPermission();
    setState(() {
      message = result.toString();
    });
  }

  _handleRequestEnableLocationService() async {
    final result = await OkHi.requestEnableLocationServices();
    setState(() {
      message = result.toString();
    });
  }

  _handleGetLocationAccuracyLevel() async {
    final result = await OkHi.getLocationAccuracyLevel();
    setState(() {
      message = result.toString();
    });
  }

  _handleCreateAnAddress(BuildContext context) async {
    final result = await Navigator.push<OkHiLocationManagerResponse>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAddress(
          user: okHiUser,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        okHiUser = result.user;
        location = result.location;
        print(result.user);
        print(result.location);
      });
    }
  }

  _handleVerificationButtonDisabled() {
    if (location == null) {
      return true;
    }
    return false;
  }

  _handleVerifyAddress() async {
    if (location != null) {
      final result = await OkHi.startVerification(okHiUser, location!, null);
      setState(() {
        message = "Started verification for $result";
      });
    }
  }

  _handleStopVerification() async {
    if (location != null) {
      final result = await OkHi.stopVerification(okHiUser!, location!);
      setState(() {
        message = "Stopped verification for $result";
      });
    }
  }

  _handleStartForegroundService() async {
    final result = await OkHi.startForegroundService();
    setState(() {
      message = "Foreground service start: $result";
    });
  }

  _handleStopForegroundService() async {
    final result = await OkHi.stopForegroundService();
    setState(() {
      message = "Foreground service stop: $result";
    });
  }

  _handleCheckForegroundService() async {
    final result = await OkHi.isForegroundServiceRunning();
    setState(() {
      message = "Foreground service is running: $result";
    });
  }
}
