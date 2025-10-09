import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_usage_type.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _launch = false;

  @override
  void initState() {
    super.initState();
    final config = OkHiAppConfiguration(
      branchId: "<my_branch_id>",
      clientKey: "<my_client_key_id>",
      env: OkHiEnv.prod,
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );
    OkHi.initialize(config).then((value) => print("init done"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OkHi Flutter Demo'),
        ),
        body: _renderBody(),
      ),
    );
  }

  _renderBody() {
    if (!_launch) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _launch = true;
            });
          },
          child: const Text('Verify an address'),
        ),
      );
    }
    return OkHiLocationManager(
      user: _createOkHiUser(),
      onCloseRequest: _handleOnClose,
      onError: _handleOnError,
      onSucess: _handleOnSuccess,
      configuration: OkHiLocationManagerConfiguration(
        usageTypes: [UsageType.digitalVerification],
      ),
    );
  }

  OkHiUser _createOkHiUser() {
    return OkHiUser(
      phone: "+2547..",
      firstName: "John",
      lastName: "Doe",
      appUserId: "abcd1234",
      email: "john@okhi.co",
    );
  }

  _handleOnSuccess(OkHiLocationManagerResponse response) async {
    setState(() {
      _launch = false;
    });
    final String locationId = await response.startVerification(null);
    print("started verification for $locationId");
  }

  _handleOnError(OkHiException exception) {
    print(exception.code);
    print(exception.message);
  }

  _handleOnClose() {
    setState(() {
      _launch = false;
    });
  }
}
