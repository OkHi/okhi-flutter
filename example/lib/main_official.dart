import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_location_manager_configuration.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter_example/widgets/full_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _launch = false;

  @override
  void initState() {
    super.initState();
    final appConfig = OkHiAppConfiguration(
      branchId: "<my_branch_id>",
      clientKey: "<my_client_key_id>",
      env: OkHiEnv.prod,
    );

    final locationManagerConfiguration = OkHiLocationManagerConfiguration(
      color: "#029e52",
      appName: "OkHi Flutter Demo",
      logoUrl:
          "https://okhi.com/wp-content/uploads/2020/06/cropped-okhi-favicon-192x192.png",
      withAppBar: true,
      withCreateMode: true,
      withHomeAddressType: true,
      withWorkAddressType: true,
      withStreetView: true,
    );

    final user = _createOkHiUser();
    OkHi.initialize(appConfig, user, locationManagerConfiguration)
        .then((result) {
          // result is true if successful
        })
        .onError((error, stackTrace) {
          // handle initialization error
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('OkHi Flutter Demo')),
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
    } else {
      return Column(
        children: [
          Text(
            "OkHi Initialized successful!",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          FullButton(
            title: "Create a digital address",
            onPressed: () {
              OkHi.startDigitalAddressVerification(
                onSuccess: (locationId) {
                  // location id of the created address
                },
                onError: (error) {
                  // handle error
                },
              );
            },
          ),
        ],
      );
    }
  }

  OkHiUser _createOkHiUser() {
    return OkHiUser(
      phone: "+25471...",
      firstName: "John",
      lastName: "Doe",
      appUserId: "abcd1234",
      email: "john@okhi.co",
    );
  }
}
