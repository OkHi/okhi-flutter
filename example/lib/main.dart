import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_location_manager_configuration.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInitialized = false;

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
    if (!isInitialized) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            final user = _createOkHiUser();
            OkHi.login(appConfig, user, locationManagerConfiguration)
                .then((result) {
                  setState(() {
                    isInitialized = true;
                  });
                })
                .onError((error, stackTrace) {
                  // handle initialization error
                });
          },
          child: const Text('Initialize OkHi'),
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
          InkWell(
            child: Text("Create a digital address"),
            onTap: () {
              OkHi.startDigitalAddressVerification(
                locationId: null,
                onSuccess: (user, location) {
                  if (kDebugMode) {
                    print(
                      "Digital address verification successful! Location ID: ${location.id}",
                    );
                  }
                },
                onError: (error) {
                  if (kDebugMode) {
                    print("Digital address verification failed! Error: $error");
                  }
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
