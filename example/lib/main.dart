import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
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

  bool _startVerification = false;

  @override
  void initState() {
    super.initState();
    final config = OkHiAppConfiguration(
      branchId: "<branchId>",
      clientKey: "<clientKey>",
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
        body: displayHomePage()
      ),
    );
  }

  displayHomePage(){
    if(_startVerification){
      return OkHiLocationManager(
        user: OkHiUser(phone: "+254712345678"),
        onSucess: (response) {
          response.startVerification(null);
        },
        onError: (error) {
          print(error.code);
          print(error.message);
        },
      );
    } else {
      return Center(
        child: InkWell(
          onTap: (){
            setState(() {
              _startVerification = true;
            });
          },
          child: Center(
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.teal,
                child: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(
                    "Start Verification",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15
                    ),
                  ),
                )
            ),
          )
        ),
      );
    }
  }
}