import 'package:flutter/material.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final config = OkHiAppConfiguration(
      branchId: "",
      clientKey: "",
      env: OkHiEnv.sandbox,
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );
    OkHi.initialize(config).then((result) {
      print(result);
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Create an address"),
        ),
        body: OkHiLocationManager(
          user: OkHiUser(phone: "+254712345678"),
          onSucess: (response) {
            response.startVerification(null);
          },
          onError: (error) {
            print(error.code);
            print(error.message);
          },
        ),
      ),
    );
  }
}