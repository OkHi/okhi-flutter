import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/models/okhi_location_manager_configuration.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter/utils/utilities.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HomeApp());
}

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _MyAppState();
}

class _MyAppState extends State<HomeApp> {
  OkHiLocation? location;
  bool isUserSet = false;
  bool isLoading = false;
  String email = "", phone = "", firstName = "", lastName = "";

  String savedAddressID = "";
  String appUserId = "";
  String? userId;
  String environment = "dev";
  late OkHiUser okHiUser;

  void copyToClipboard(String type, String addressId) {
    if (addressId != "user_closed") {
      ClipboardData clipboardData;
      if (type == "userId") {
        clipboardData = ClipboardData(text: 'User ID: $addressId');
      } else {
        clipboardData = ClipboardData(text: '$type: $addressId');
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
              "$type: $addressId \nCopied to clipboard.\n\nPlease share it on the QA group";
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                isUserSet ? "Welcome, ${okHiUser.firstName}" : "OkHi",
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                ),
              ),
              Spacer(),
              isUserSet
                  ? IconButton(
                      onPressed: () {
                        _handleOkHiLogout();
                      },
                      icon: Icon(Icons.logout, color: Colors.teal, size: 20),
                    )
                  : Container(),
            ],
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: isUserSet ? _postInitializeView() : _preInitializeView(),
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

  Color getEnvState(value) {
    if (value == environment) {
      return Colors.teal.shade100;
    } else {
      return Colors.white;
    }
  }

  _preInitializeView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 13.0,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Card(
              elevation: 3.0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              shadowColor: Colors.teal[100],
              child: InkWell(
                onTap: () {
                  setState(() {
                    environment = "prod";
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: getEnvState("prod"), width: 3.0),
                  ),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.27,
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Center(
                    child: Text(
                      "PROD",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
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
              shadowColor: Colors.teal[100],
              child: InkWell(
                onTap: () {
                  setState(() {
                    environment = "sandbox";
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: getEnvState("sandbox"),
                      width: 3.0,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.27,
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Center(
                    child: Text(
                      "SANDBOX",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
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
              shadowColor: Colors.teal[100],
              child: InkWell(
                onTap: () {
                  setState(() {
                    environment = "dev";
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: getEnvState("dev"), width: 3.0),
                  ),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.27,
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Center(
                    child: Text(
                      "DEV",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3),
        Text(
          "Enter User credentials",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.w500,
            fontSize: 19,
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
        SizedBox(height: 5),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              final hasRequiredFields =
                  email.trim().isNotEmpty &&
                  firstName.trim().isNotEmpty &&
                  phone.trim().isNotEmpty;
              if (hasRequiredFields) {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _postInitializeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 10, right: 10),
          child: Row(
            children: [
              Text(
                "${okHiUser.email}",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Container(
                width: 5,
                height: 5,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              InkWell(
                onTap: () async {
                  copyToClipboard("userId", userId.toString());
                },
                child: Row(
                  children: [
                    Text(
                      userId.toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.copy, color: Colors.teal, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              setState(() {
                isLoading = true;
              });
              OkHi.createAddress(
                onSuccess: (user, location) {
                  setState(() {
                    savedAddressID = location.id.toString();
                  });
                  copyToClipboard("Create Address", location.id.toString());
                },
                onError: (error) {
                  showSnackBarError('Create Address error: ${error.message}');
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Create address (Address book)",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              if (savedAddressID.isNotEmpty) {
                setState(() {
                  isLoading = true;
                });
                OkHi.startDigitalAddressVerification(
                  locationId: savedAddressID,
                  onSuccess: (user, location) {
                    setState(() {
                      savedAddressID = "";
                    });
                    copyToClipboard(
                      "Verifying Address Book",
                      location.id.toString(),
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
            child: Container(
              decoration: BoxDecoration(
                color: savedAddressID.isNotEmpty
                    ? Colors.teal.shade100
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Verify saved address (Address book)",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              setState(() {
                isLoading = true;
              });
              OkHi.startDigitalAddressVerification(
                onSuccess: (user, location) {
                  copyToClipboard("Digital Address", location.id.toString());
                },
                onError: (error) {
                  showSnackBarError('Digital Address error: ${error.message}');
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Create a digital address",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              setState(() {
                isLoading = true;
              });
              OkHi.startPhysicalAddressVerification(
                onSuccess: (user, location) {
                  copyToClipboard("Physical Address", location.id.toString());
                },
                onError: (error) {
                  showSnackBarError('Physical Address error: ${error.message}');
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Create a physical address",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () {
              setState(() {
                isLoading = true;
              });
              OkHi.startDigitalAndPhysicalAddressVerification(
                onSuccess: (user, location) {
                  copyToClipboard(
                    "Physical & Digital Address",
                    location.id.toString(),
                  );
                },
                onError: (error) {
                  showSnackBarError(
                    'Physical & Digital Address error: ${error.message}',
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Create a digital & physical address",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 25),
        Text(
          "Resource Status Checks",
          style: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.isLocationServicesEnabled();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Location services are enabled"
                        : "Location services are disabled",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Location services status",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.isLocationPermissionGranted();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Location permission is granted"
                        : "Location permission is denied",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Location permission status",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.isBackgroundLocationPermissionGranted();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Background location permission is granted"
                        : "Background location permission is denied",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Background location permission status",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: Platform.isAndroid ? 10 : 0),
        Platform.isAndroid
            ? Card(
                elevation: 3.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                shadowColor: Colors.teal[100],
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var result = await OkHi.isGooglePlayServicesAvailable();
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green[300],
                        duration: Duration(seconds: 6),
                        content: Text(
                          result
                              ? "Google Play Services is available"
                              : "Google Play Services is not available",
                        ),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    height: MediaQuery.of(context).size.height * 0.06,
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Center(
                      child: Text(
                        "Google Play Services status",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        SizedBox(height: 10),
        Platform.isAndroid
            ? Card(
                elevation: 3.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                shadowColor: Colors.teal[100],
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var result = await OkHi.isNotificationsEnabled();
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green[300],
                        duration: Duration(seconds: 6),
                        content: Text(
                          result
                              ? "Notifications are enabled"
                              : "Notifications are disabled",
                        ),
                      ),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    height: MediaQuery.of(context).size.height * 0.06,
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Center(
                      child: Text(
                        "Notifications status",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),

        SizedBox(height: 25),
        Text(
          "Resource Request Actions",
          style: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.requestNotificationsPermission();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Notifications requested successfully"
                        : "Notifications request failed",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Request notifications permission",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.requestEnableLocationServices();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Enable location services requested successfully"
                        : "Enable location services request failed",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Enable location services",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.requestLocationPermission();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Location services requested successfully"
                        : "Location services request failed",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Request location permission",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Card(
          elevation: 3.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Colors.teal[100],
          child: InkWell(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              var result = await OkHi.requestBackgroundLocationPermission();
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green[300],
                  duration: Duration(seconds: 6),
                  content: Text(
                    result
                        ? "Background location services requested successfully"
                        : "Background location services request failed",
                  ),
                ),
              );
              setState(() {
                isLoading = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: MediaQuery.of(context).size.height * 0.06,
              padding: const EdgeInsets.only(left: 15.0),
              child: Center(
                child: Text(
                  "Request background location permission",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
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
          branchId: "",
          clientKey: "",
          env: OkHiEnv.dev,
        );
      case "prod":
        return OkHiAppConfiguration(
          branchId: "",
          clientKey: "",
          env: OkHiEnv.prod,
        );
      case "sandbox":
        return OkHiAppConfiguration(
          branchId: "",
          clientKey: "",
          env: OkHiEnv.sandbox,
        );
      default:
        return OkHiAppConfiguration(
          branchId: "",
          clientKey: "",
          env: OkHiEnv.dev,
        );
    }
  }

  _handleInitializeOkHi() async {
    final appConfig = getConfig();
    setState(() {
      isLoading = true;
    });

    final locationManagerConfiguration = OkHiLocationManagerConfiguration(
      color: "#008080",
      appName: "OkHi Flutter Demo",
      logoUrl:
          "https://storage.googleapis.com/okhi-cdn/images/logos/okhi-logo-white.png",
      withAppBar: true,
      withCreateMode: true,
      withHomeAddressType: true,
      withWorkAddressType: false,
      withStreetView: true,
    );

    okHiUser = OkHiUser(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      appUserId: "flutterAppUser1000000",
      email: email,
      id: userId,
    );

    OkHi.login(appConfig, okHiUser, locationManagerConfiguration)
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

  _handleOkHiLogout() async {
    OkHi.logout()
        .then((result) {
          appDebugPrint("The returned ids are: $result");

          setState(() {
            isUserSet = false;
            appUserId = "";
            userId = "";
            savedAddressID = "";
            isLoading = false;
          });
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green[300],
              content: const Text('OkHi Logout successful'),
            ),
          );
        })
        .onError((error, stackTrace) {
          showSnackBarError("OkHi Logout error: $error");
        });
  }
}
