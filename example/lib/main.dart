import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter/utils/utilities.dart';
import 'package:okhi_flutter_example/widgets/full_button.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OkHiLocation? location;
  bool isUserSet = false;
  String email = "", phone = "", firstName = "", lastName = "";

  String savedAddressID = "";

  void copyToClipboard(String type, String addressId) {
    Clipboard.setData(
      ClipboardData(text: 'Verification Type:$type\n Address ID: $addressId'),
    ).then((_) {
      if (addressId != "user_closed") {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[300],
            content: Text(
              'Verification Type:$type\n Address ID: $addressId \n Copied to clipboard',
            ),
          ),
        );
        return;
      }
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  _handleRequestLocationPermission() async {
    final result = await OkHi.requestLocationPermission();
  }

  _handleRequestBackgroundLocationPermission() async {
    final result = await OkHi.requestBackgroundLocationPermission();
  }

  _handleRequestEnableLocationService() async {
    final result = await OkHi.requestEnableLocationServices();
  }

  _handleRequestEnableNotifications() async {
    final result = await OkHi.requestNotificationsPermission();
  }

  _handleExceptions() async {
    throw Exception();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("OkHi")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 13.0,
              children: [
                Card(
                  elevation: 3.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.grey[100],
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Center(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.email,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          border: InputBorder.none,
                          hintText: "Email",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                        obscureText: false,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.grey[100],
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Center(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.supervised_user_circle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          border: InputBorder.none,
                          hintText: "First name",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            firstName = val;
                          });
                        },
                        obscureText: false,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.grey[100],
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Center(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.supervised_user_circle_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          border: InputBorder.none,
                          hintText: "Last name",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            lastName = val;
                          });
                        },
                        obscureText: false,
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 3.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Colors.grey[100],
                  child: Container(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Center(
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.phone_android_sharp,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          border: InputBorder.none,
                          hintText: "Phone number",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            phone = val;
                          });
                        },
                        obscureText: false,
                      ),
                    ),
                  ),
                ),
                isUserSet ? _postInitializeView() : _preInitializeView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _preInitializeView() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          FullButton(
            title: "Initialize OkHi",
            onPressed: () {
              if (email.isNotEmpty &&
                  firstName.isNotEmpty &&
                  phone.isNotEmpty) {
                _handleInitializeOkHi();
              } else {
                scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red[300],
                    content: const Text(
                      'Please fill in all required fields to proceed',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  _postInitializeView() {
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
        SizedBox(height: 25),
        FullButton(
          title: "Create address (Address book)",
          onPressed: () async {
            var result = await OkHi.createAddress();
            appDebugPrint("Create address result: $result");
            setState(() {
              savedAddressID = result.toString();
            });
            copyToClipboard("Create Address", result.toString());
          },
        ),
        FullButton(
          title: "Verify address (Address book)",
          onPressed: () async {
            if (savedAddressID.isNotEmpty) {
              var result = await OkHi.startSavedAddressVerification(
                savedAddressID,
              );
              setState(() {
                savedAddressID = "";
              });
              copyToClipboard("Verifying Address Book", result.toString());
            } else {
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red[300],
                  content: const Text(
                    'Please create an address first to proceed',
                  ),
                ),
              );
              return;
            }
          },
        ),
        FullButton(
          title: "Create a digital address",
          onPressed: () async {
            var result = await OkHi.startDigitalAddressVerification();
            appDebugPrint("Digital address result: $result");
            copyToClipboard("Digital", result.toString());
          },
        ),
        FullButton(
          title: "Create a physical address",
          onPressed: () async {
            var result = await OkHi.startPhysicalAddressVerification();
            appDebugPrint("Physical address result: $result");
            copyToClipboard("Physical", result.toString());
          },
        ),
        FullButton(
          title: "Create a digital & physical address",
          onPressed: () async {
            var result =
                await OkHi.startDigitalAndPhysicalAddressVerification();
            appDebugPrint("Digital & Physical address result: $result");
            copyToClipboard("Physical & Digital", result.toString());
          },
        ),
      ],
    );
  }

  _handleInitializeOkHi() async {
    final config = OkHiAppConfiguration(
      branchId: "",
      clientKey: "",
      env: OkHiEnv.prod,
    );

    final okHiUser = OkHiUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      appUserId: "okhiId_${Random().nextInt(100000)}",
      email: email,
      id: Random().nextInt(100000000).toString(),
    );

    OkHi.initialize(config, okHiUser)
        .then((result) {
          setState(() {
            isUserSet = true;
          });
        })
        .onError((error, stackTrace) {});
  }
}
