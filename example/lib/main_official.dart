import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_app_configuration.dart';
import 'package:okhi_flutter/models/okhi_env.dart';
import 'package:okhi_flutter/models/okhi_user.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter/utils/utilities.dart';

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
    final config = OkHiAppConfiguration(
      branchId: "<my_branch_id>",
      clientKey: "<my_client_key_id>",
      env: OkHiEnv.prod,
    );

    final user = _createOkHiUser();
    OkHi.initialize(config, user).then((value) => appDebugPrint("init done"));
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
