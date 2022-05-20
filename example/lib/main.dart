import 'package:flutter/material.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter_example/screens/home.dart';

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
    final config = OkHiAppConfiguration.withRawValue(
      branchId: "UD3tyqVt50",
      clientKey: "bcb6e880-5294-4045-b0c7-5303cc1a9983",
      environmentRawValue: "dev",
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );
    OkHi.initialize(config).then((result) {
      print(">>>>>>: $result");
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}