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
    final notification = OkHiAndroidNotification(
      title: "Verification in progress",
      text: "Verifying your address",
      channelId: "okhi",
      channelName: "OkHi",
      channelDescription: "Verification alerts",
    );
    final config = OkHiAppConfiguration(
      branchId: "<my_branch_id>",
      clientKey: "<my_client_id>",
      env: OkHiEnv.sandbox,
      notification: notification,
    );
    OkHi.initialize(config).then((result) {
      print("initialization result: $result");
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
