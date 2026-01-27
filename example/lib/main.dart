import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
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
  bool isLoading = false;
  String email = "", phone = "", firstName = "", lastName = "";

  String savedAddressID = "";
  String appUserId = "";
  String userId = "No Id";
  String environment = "dev";

  void copyToClipboard(String type, String addressId) {
    if (addressId != "user_closed") {
      ClipboardData clipboardData;
      if (type == "userId") {
        clipboardData = ClipboardData(text: 'User ID: $addressId');
      } else {
        clipboardData = ClipboardData(
          text: 'Verification Type:$type\n Address ID: $addressId',
        );
      }

      Clipboard.setData(clipboardData).then((_) {
        setState(() {
          isLoading = false;
        });
        var text = "";
        if (type == "userId") {
          text =
              'User ID: $addressId \nCopied to clipboard.\n\nPlease share it on the QA group';
        } else {
          text =
              "Verification Type:$type\n Address ID: $addressId \nCopied to clipboard.\n\nPlease share it on the QA group";
        }

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[300],
            duration: Duration(seconds: 6),
            content: Text(text),
          ),
        );
      });
      return;
    }
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
        body: Stack(
          children: [
            SingleChildScrollView(
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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(),
          ],
        ),
      ),
    );
  }

  _preInitializeView() {
    return Column(
      children: [
        Row(
          children: [
            Card(
              elevation: 3.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              shadowColor: Colors.grey[100],
              child: SizedBox(
                width: 125,
                height: 50,
                child: Center(
                  child: DropdownButton<String>(
                    value: environment,
                    items: <String>['dev', 'prod', 'sandbox'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 20)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        environment = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        FullButton(
          title: "Initialize OkHi",
          onPressed: () {
            if (email.isNotEmpty && firstName.isNotEmpty && phone.isNotEmpty) {
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
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.grey[100],
          child: InkWell(
            onTap: () {
              copyToClipboard("userId", userId);
            },
            child: SizedBox(
              width: 160,
              height: 50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userId,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "click to copy",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 25),
        FullButton(
          title: "Create address (Address book)",
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            OkHi.createAddress(
              onSuccess: (locationId) {
                setState(() {
                  savedAddressID = locationId.toString();
                });
                copyToClipboard("Create Address", locationId.toString());
              },
              onError: (error) {
                showSnackBarError('Create Address error: ${error.message}');
              },
            );
          },
        ),
        FullButton(
          title: "Create a digital address",
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            OkHi.startDigitalAddressVerification(
              onSuccess: (locationId) {
                copyToClipboard("Digital Address", locationId.toString());
              },
              onError: (error) {
                showSnackBarError('Digital Address error: ${error.message}');
              },
            );
          },
        ),
        FullButton(
          title: "Verify address (Address book)",
          onPressed: () {
            if (savedAddressID.isNotEmpty) {
              setState(() {
                isLoading = true;
              });
              OkHi.startSavedAddressVerification(
                locationId: savedAddressID,
                onSuccess: (locationId) {
                  setState(() {
                    savedAddressID = "";
                  });
                  copyToClipboard(
                    "Verifying Address Book",
                    locationId.toString(),
                  );
                },
                onError: (error) {
                  showSnackBarError(
                    'Verifying Address Book error: ${error.message}',
                  );
                },
              );
            } else {
              showSnackBarError('Please create an address first to proceed');
              return;
            }
          },
        ),
        FullButton(
          title: "Create a physical address",
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            OkHi.startPhysicalAddressVerification(
              onSuccess: (locationId) {
                copyToClipboard("Physical Address", locationId.toString());
              },
              onError: (error) {
                showSnackBarError('Physical Address error: ${error.message}');
              },
            );
          },
        ),
        FullButton(
          title: "Create a digital & physical address",
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            OkHi.startDigitalAndPhysicalAddressVerification(
              onSuccess: (locationId) {
                copyToClipboard(
                  "Physical & Digital Address",
                  locationId.toString(),
                );
              },
              onError: (error) {
                showSnackBarError(
                  'Physical & Digital Address error: ${error.message}',
                );
              },
            );
          },
        ),
      ],
    );
  }

  showSnackBarError(String message) {
    setState(() {
      isLoading = false;
    });
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[300],
        duration: Duration(seconds: 6),
        content: Text(message),
      ),
    );
  }

  OkHiAppConfiguration getConfig() {
    switch (environment) {
      case "dev":
        return OkHiAppConfiguration(
          branchId: "UD3tyqVt50",
          clientKey: "bcb6e880-5294-4045-b0c7-5303cc1a9983",
          env: OkHiEnv.dev,
        );
      case "prod":
        return OkHiAppConfiguration(
          branchId: "CJZqjVZlIG",
          clientKey: "5dee3c5a-bc76-44db-a583-7fb35f45071f",
          env: OkHiEnv.prod,
        );
      case "sandbox":
        return OkHiAppConfiguration(
          branchId: "89IJLMjf9M",
          clientKey: "bcb6e880-5294-4045-b0c7-5303cc1a9983",
          env: OkHiEnv.sandbox,
        );
      default:
        return OkHiAppConfiguration(
          branchId: "UD3tyqVt50",
          clientKey: "bcb6e880-5294-4045-b0c7-5303cc1a9983",
          env: OkHiEnv.dev,
        );
    }
  }

  _handleInitializeOkHi() async {
    final config = getConfig();
    setState(() {
      isLoading = true;
    });
    final okHiUser = OkHiUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      appUserId: appUserId,
      email: email,
      id: userId,
    );

    OkHi.initialize(config, okHiUser)
        .then((result) {
          setState(() {
            isUserSet = true;
            appUserId = "flutterAppUser1000000";
            userId = Random().nextInt(100000000).toString();
            isLoading = false;
          });
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green[300],
              content: const Text('OkHi Initialized successfully'),
            ),
          );
        })
        .onError((error, stackTrace) {
          showSnackBarError("OkHi Initialization error: $error");
        });
  }
}
