import 'package:flutter/material.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import '../widgets/full_button.dart';
import '../widgets/message_box.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
      appBar: AppBar(title: const Text("OkHi")),
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
                title: "Get Location accuracy level",
                onPressed: _handleGetLocationAccuracyLevel,
              ),
              FullButton(
                title: "Create a digital address",
                onPressed: () async {
                  OkHi.startDigitalAddressVerification();
                },
              ),
              FullButton(
                title: "Create a physical address",
                onPressed: () async {
                  OkHi.startPhysicalAddressVerification();
                },
              ),
              FullButton(
                title: "Create a digital & physical address",
                onPressed: () async {
                  OkHi.startDigitalAndPhysicalAddressVerification();
                },
              ),
              FullButton(
                title: "Create an address",
                onPressed: () async {
                  OkHi.createAddress();
                },
              ),
              MessageBox(message: message),
            ],
          ),
        ),
      ),
    );
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
}
