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
  OkHiUser? user;
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
                title: "Request enable Google Play Service",
                onPressed: _handleEnableGooglePlayService,
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
              FullButton(
                title: "ExampleFN",
                onPressed: _handleExampleFN,
              ),
              MessageBox(message: message)
            ],
          ),
        ),
      ),
    );
  }

  _handleExampleFN() async {
    print(">>>>:${await OkHi.exampleFN("Hi")}");
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

  _handleEnableGooglePlayService() async {
    final result = await OkHi.requestEnableGooglePlayServices();
    setState(() {
      message = result.toString();
    });
  }

  _handleCreateAnAddress(BuildContext context) async {
    final result = await Navigator.push<OkHiLocationManagerResponse>(context,
        MaterialPageRoute(builder: (context) => const CreateAddress()));
    if (result != null) {
      setState(() {
        user = result.user;
        location = result.location;
      });
    }
  }

  _handleVerificationButtonDisabled() {
    if (user == null || location == null) {
      return true;
    }
    return false;
  }

  _handleVerifyAddress() async {
    if (user != null && location != null) {
      final result = await OkHi.startVerification(user!, location!, null);
      setState(() {
        message = "Started verification for $result";
      });
    }
  }

  _handleStopVerification() async {
    if (user != null && location != null) {
      final result = await OkHi.stopVerification(user!, location!);
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
