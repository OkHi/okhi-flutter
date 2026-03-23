import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okhi_flutter/models/okhi_location_manager_configuration.dart';
import 'package:okhi_flutter/okhi_flutter.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const HomeApp());
// }
//
// class HomeApp extends StatefulWidget {
//   const HomeApp({super.key});
//
//   @override
//   State<HomeApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<HomeApp> {
//   OkHiLocation? location;
//   bool isUserSet = false;
//   bool isLoading = false;
//   String email = "", phone = "", firstName = "", lastName = "";
//
//   String savedAddressID = "";
//   String appUserId = "";
//   String? userId;
//   String environment = "dev";
//   late OkHiUser okHiUser;
//
//   void copyToClipboard(String type, String addressId) {
//     if (addressId != "user_closed") {
//       ClipboardData clipboardData;
//       if (type == "userId") {
//         clipboardData = ClipboardData(text: 'User ID: $addressId');
//       } else {
//         clipboardData = ClipboardData(text: '$type: $addressId');
//       }
//
//       Clipboard.setData(clipboardData).then((_) {
//         setState(() {
//           isLoading = false;
//         });
//         var text = "";
//         if (type == "userId") {
//           text =
//               'User ID: $addressId \nCopied to clipboard.\n\nPlease share it on the QA group';
//         } else {
//           text =
//               "$type: $addressId \nCopied to clipboard.\n\nPlease share it on the QA group";
//         }
//
//         scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.green[300],
//             duration: Duration(seconds: 6),
//             content: Text(text),
//           ),
//         );
//       });
//       return;
//     }
//   }
//
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       navigatorKey: navigatorKey,
//       home: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             children: [
//               Text(
//                 isUserSet ? "Welcome, ${okHiUser.firstName}" : "OkHi",
//                 style: const TextStyle(
//                   color: Colors.teal,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 27,
//                 ),
//               ),
//               Spacer(),
//               isUserSet
//                   ? IconButton(
//                       onPressed: () {
//                         _handleOkHiLogout();
//                       },
//                       icon: Icon(Icons.logout, color: Colors.teal, size: 20),
//                     )
//                   : Container(),
//             ],
//           ),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(13.0),
//                 child: isUserSet ? _postInitializeView() : _preInitializeView(),
//               ),
//             ),
//             isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : Container(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color getEnvState(value) {
//     if (value == environment) {
//       return Colors.teal.shade100;
//     } else {
//       return Colors.white;
//     }
//   }
//
//   _preInitializeView() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       spacing: 13.0,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Card(
//               elevation: 3.0,
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               shadowColor: Colors.teal[100],
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     environment = "prod";
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15.0),
//                     border: Border.all(color: getEnvState("prod"), width: 3.0),
//                   ),
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   width: MediaQuery.of(context).size.width * 0.27,
//                   padding: const EdgeInsets.only(left: 15.0),
//                   child: Center(
//                     child: Text(
//                       "PROD",
//                       style: TextStyle(
//                         color: Colors.teal,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Card(
//               elevation: 3.0,
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               shadowColor: Colors.teal[100],
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     environment = "sandbox";
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15.0),
//                     border: Border.all(
//                       color: getEnvState("sandbox"),
//                       width: 3.0,
//                     ),
//                   ),
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   width: MediaQuery.of(context).size.width * 0.27,
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: Center(
//                     child: Text(
//                       "SANDBOX",
//                       style: TextStyle(
//                         color: Colors.teal,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Card(
//               elevation: 3.0,
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               shadowColor: Colors.teal[100],
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     environment = "dev";
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15.0),
//                     border: Border.all(color: getEnvState("dev"), width: 3.0),
//                   ),
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   width: MediaQuery.of(context).size.width * 0.27,
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: Center(
//                     child: Text(
//                       "DEV",
//                       style: TextStyle(
//                         color: Colors.teal,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 3),
//         Text(
//           "Enter User credentials",
//           style: TextStyle(
//             color: Colors.teal,
//             fontWeight: FontWeight.w500,
//             fontSize: 19,
//           ),
//         ),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.grey[100],
//           child: Container(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: Center(
//               child: TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w700,
//                 ),
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.email,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                   border: InputBorder.none,
//                   hintText: "Email",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade300,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 onChanged: (val) {
//                   setState(() {
//                     email = val;
//                   });
//                 },
//                 obscureText: false,
//               ),
//             ),
//           ),
//         ),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.grey[100],
//           child: Container(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: Center(
//               child: TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w700,
//                 ),
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.supervised_user_circle,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                   border: InputBorder.none,
//                   hintText: "First name",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade300,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 onChanged: (val) {
//                   setState(() {
//                     firstName = val;
//                   });
//                 },
//                 obscureText: false,
//               ),
//             ),
//           ),
//         ),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.grey[100],
//           child: Container(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: Center(
//               child: TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w700,
//                 ),
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.supervised_user_circle_outlined,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                   border: InputBorder.none,
//                   hintText: "Last name",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade300,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 onChanged: (val) {
//                   setState(() {
//                     lastName = val;
//                   });
//                 },
//                 obscureText: false,
//               ),
//             ),
//           ),
//         ),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.grey[100],
//           child: Container(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: Center(
//               child: TextFormField(
//                 keyboardType: TextInputType.emailAddress,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w700,
//                 ),
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.phone_android_sharp,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                   border: InputBorder.none,
//                   hintText: "Phone number",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade300,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 onChanged: (val) {
//                   setState(() {
//                     phone = val;
//                   });
//                 },
//                 obscureText: false,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 5),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               // if (email.isNotEmpty &&
//               //     firstName.isNotEmpty &&
//               //     phone.isNotEmpty) {
//               _handleInitializeOkHi();
//               // } else {
//               //   scaffoldMessengerKey.currentState?.showSnackBar(
//               //     SnackBar(
//               //       backgroundColor: Colors.red[300],
//               //       content: const Text(
//               //         'Please fill in all required fields to proceed',
//               //       ),
//               //     ),
//               //   );
//               // }
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Login",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 17,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   _postInitializeView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsetsGeometry.only(left: 10, right: 10),
//           child: Row(
//             children: [
//               Text(
//                 "${okHiUser.email}",
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                   fontSize: 16,
//                 ),
//               ),
//               Container(
//                 width: 5,
//                 height: 5,
//                 margin: EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   color: Colors.teal,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   copyToClipboard("userId", userId.toString());
//                 },
//                 child: Row(
//                   children: [
//                     Text(
//                       userId.toString(),
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 15,
//                       ),
//                     ),
//                     SizedBox(width: 5),
//                     Icon(Icons.copy, color: Colors.teal, size: 15),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 15),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 isLoading = true;
//               });
//               OkHi.createAddress(
//                 onSuccess: (user, location) {
//                   setState(() {
//                     savedAddressID = location.id.toString();
//                   });
//                   copyToClipboard("Create Address", location.id.toString());
//                 },
//                 onError: (error) {
//                   showSnackBarError('Create Address error: ${error.message}');
//                 },
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Create address (Address book)",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               if (savedAddressID.isNotEmpty) {
//                 setState(() {
//                   isLoading = true;
//                 });
//                 OkHi.startDigitalAddressVerification(
//                   locationId: savedAddressID,
//                   onSuccess: (user, location) {
//                     setState(() {
//                       savedAddressID = "";
//                     });
//                     copyToClipboard(
//                       "Verifying Address Book",
//                       location.id.toString(),
//                     );
//                   },
//                   onError: (error) {
//                     showSnackBarError(
//                       'Verifying Address Book error: ${error.message}',
//                     );
//                   },
//                 );
//               } else {
//                 showSnackBarError('Please create an address first to proceed');
//                 return;
//               }
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: savedAddressID.isNotEmpty
//                     ? Colors.teal.shade100
//                     : Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Verify saved address (Address book)",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 isLoading = true;
//               });
//               OkHi.startDigitalAddressVerification(
//                 onSuccess: (user, location) {
//                   copyToClipboard("Digital Address", location.id.toString());
//                 },
//                 onError: (error) {
//                   showSnackBarError('Digital Address error: ${error.message}');
//                 },
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Create a digital address",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 isLoading = true;
//               });
//               OkHi.startPhysicalAddressVerification(
//                 onSuccess: (user, location) {
//                   copyToClipboard("Physical Address", location.id.toString());
//                 },
//                 onError: (error) {
//                   showSnackBarError('Physical Address error: ${error.message}');
//                 },
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Create a physical address",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 isLoading = true;
//               });
//               OkHi.startDigitalAndPhysicalAddressVerification(
//                 onSuccess: (user, location) {
//                   copyToClipboard(
//                     "Physical & Digital Address",
//                     location.id.toString(),
//                   );
//                 },
//                 onError: (error) {
//                   showSnackBarError(
//                     'Physical & Digital Address error: ${error.message}',
//                   );
//                 },
//               );
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Create a digital & physical address",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 25),
//         Text(
//           "Resource Status Checks",
//           style: const TextStyle(
//             color: Colors.teal,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.isLocationServicesEnabled();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Location services are enabled"
//                         : "Location services are disabled",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Location services status",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.isLocationPermissionGranted();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Location permission is granted"
//                         : "Location permission is denied",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Location permission status",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.isBackgroundLocationPermissionGranted();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Background location permission is granted"
//                         : "Background location permission is denied",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Background location permission status",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: Platform.isAndroid ? 10 : 0),
//         Platform.isAndroid
//             ? Card(
//                 elevation: 3.0,
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 shadowColor: Colors.teal[100],
//                 child: InkWell(
//                   onTap: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     var result = await OkHi.isGooglePlayServicesAvailable();
//                     scaffoldMessengerKey.currentState?.showSnackBar(
//                       SnackBar(
//                         backgroundColor: Colors.green[300],
//                         duration: Duration(seconds: 6),
//                         content: Text(
//                           result
//                               ? "Google Play Services is available"
//                               : "Google Play Services is not available",
//                         ),
//                       ),
//                     );
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.teal.shade100,
//                       borderRadius: BorderRadius.circular(15.0),
//                     ),
//                     height: MediaQuery.of(context).size.height * 0.06,
//                     padding: const EdgeInsets.only(left: 15.0),
//                     child: Center(
//                       child: Text(
//                         "Google Play Services status",
//                         style: TextStyle(
//                           color: Colors.teal,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             : Container(),
//         SizedBox(height: 10),
//         Platform.isAndroid
//             ? Card(
//                 elevation: 3.0,
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0),
//                 ),
//                 shadowColor: Colors.teal[100],
//                 child: InkWell(
//                   onTap: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     var result = await OkHi.isNotificationsEnabled();
//                     scaffoldMessengerKey.currentState?.showSnackBar(
//                       SnackBar(
//                         backgroundColor: Colors.green[300],
//                         duration: Duration(seconds: 6),
//                         content: Text(
//                           result
//                               ? "Notifications are enabled"
//                               : "Notifications are disabled",
//                         ),
//                       ),
//                     );
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.teal.shade100,
//                       borderRadius: BorderRadius.circular(15.0),
//                     ),
//                     height: MediaQuery.of(context).size.height * 0.06,
//                     padding: const EdgeInsets.only(left: 15.0),
//                     child: Center(
//                       child: Text(
//                         "Notifications status",
//                         style: TextStyle(
//                           color: Colors.teal,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             : Container(),
//
//         SizedBox(height: 25),
//         Text(
//           "Resource Request Actions",
//           style: const TextStyle(
//             color: Colors.teal,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.requestNotificationsPermission();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Notifications requested successfully"
//                         : "Notifications request failed",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Request notifications permission",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.requestEnableLocationServices();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Enable location services requested successfully"
//                         : "Enable location services request failed",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Enable location services",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.requestLocationPermission();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Location services requested successfully"
//                         : "Location services request failed",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Request location permission",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Card(
//           elevation: 3.0,
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           shadowColor: Colors.teal[100],
//           child: InkWell(
//             onTap: () async {
//               setState(() {
//                 isLoading = true;
//               });
//               var result = await OkHi.requestBackgroundLocationPermission();
//               scaffoldMessengerKey.currentState?.showSnackBar(
//                 SnackBar(
//                   backgroundColor: Colors.green[300],
//                   duration: Duration(seconds: 6),
//                   content: Text(
//                     result
//                         ? "Background location services requested successfully"
//                         : "Background location services request failed",
//                   ),
//                 ),
//               );
//               setState(() {
//                 isLoading = false;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.teal.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               height: MediaQuery.of(context).size.height * 0.06,
//               padding: const EdgeInsets.only(left: 15.0),
//               child: Center(
//                 child: Text(
//                   "Request background location permission",
//                   style: TextStyle(
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 15),
//       ],
//     );
//   }
//
//   showSnackBarError(String message) {
//     setState(() {
//       isLoading = false;
//     });
//     scaffoldMessengerKey.currentState?.showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.red[300],
//         duration: Duration(seconds: 6),
//         content: Text(message),
//       ),
//     );
//   }
//
//   OkHiAppConfiguration getConfig() {
//     switch (environment) {
//       case "dev":
//         return OkHiAppConfiguration(
//           branchId: "",
//           clientKey: "",
//           env: OkHiEnv.dev,
//         );
//       case "prod":
//         return OkHiAppConfiguration(
//           branchId: "",
//           clientKey: "",
//           env: OkHiEnv.prod,
//         );
//       case "sandbox":
//         return OkHiAppConfiguration(
//           branchId: "",
//           clientKey: "",
//           env: OkHiEnv.sandbox,
//         );
//       default:
//         return OkHiAppConfiguration(
//           branchId: "",
//           clientKey: "",
//           env: OkHiEnv.dev,
//         );
//     }
//   }
//
//   _handleInitializeOkHi() async {
//     final appConfig = getConfig();
//     setState(() {
//       isLoading = true;
//     });
//
//     final locationManagerConfiguration = OkHiLocationManagerConfiguration(
//       color: "#008080",
//       appName: "OkHi Flutter Demo",
//       logoUrl:
//           "https://storage.googleapis.com/okhi-cdn/images/logos/okhi-logo-white.png",
//       withAppBar: true,
//       withCreateMode: true,
//       withHomeAddressType: true,
//       withWorkAddressType: false,
//       withStreetView: true,
//     );
//
//     okHiUser = OkHiUser(
//       phone: phone,
//       firstName: firstName,
//       lastName: lastName,
//       appUserId: "flutterAppUser1000000",
//       email: email,
//       id: userId,
//     );
//
//     OkHi.login(appConfig, okHiUser, locationManagerConfiguration)
//         .then((result) {
//           setState(() {
//             isUserSet = true;
//             appUserId = "flutterAppUser1000000";
//             userId = Random().nextInt(100000000).toString();
//             isLoading = false;
//           });
//           scaffoldMessengerKey.currentState?.showSnackBar(
//             SnackBar(
//               backgroundColor: Colors.green[300],
//               content: const Text('OkHi Initialized successfully'),
//             ),
//           );
//         })
//         .onError((error, stackTrace) {
//           showSnackBarError("OkHi Initialization error: $error");
//         });
//   }
//
//   _handleOkHiLogout() async {
//     OkHi.logout()
//         .then((result) {
//           appDebugPrint("The returned ids are: $result");
//
//           setState(() {
//             isUserSet = false;
//             appUserId = "";
//             userId = "";
//             savedAddressID = "";
//             isLoading = false;
//           });
//           scaffoldMessengerKey.currentState?.showSnackBar(
//             SnackBar(
//               backgroundColor: Colors.green[300],
//               content: const Text('OkHi Logout successful'),
//             ),
//           );
//         })
//         .onError((error, stackTrace) {
//           showSnackBarError("OkHi Logout error: $error");
//         });
//   }
// }

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OkHiDemoApp());
}

// ---------------------------------------------------------------------------
// Root app
// ---------------------------------------------------------------------------
class OkHiDemoApp extends StatelessWidget {
  const OkHiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OkHi Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF008080),
        useMaterial3: true,
      ),
      home: const OkHiHomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Home page — full OkHi lifecycle
// ---------------------------------------------------------------------------
class OkHiHomePage extends StatefulWidget {
  const OkHiHomePage({super.key});

  @override
  State<OkHiHomePage> createState() => _OkHiHomePageState();
}

class _OkHiHomePageState extends State<OkHiHomePage> {
  // ── Scaffold messenger key for SnackBars from async callbacks ────────────
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ── UI state ─────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isUserSet = false;

  // ── OkHi state ───────────────────────────────────────────────────────────
  OkHiEnv _selectedEnv = OkHiEnv.sandbox;
  String _appUserId = '';
  String _userId = '';
  String _savedAddressId = '';

  // ── Text controllers ──────────────────────────────────────────────────────
  final _phoneCtrl = TextEditingController(text: '+254');
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _appUserIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _branchIdCtrl = TextEditingController();
  final _clientKeyCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _appUserIdCtrl.dispose();
    _emailCtrl.dispose();
    _branchIdCtrl.dispose();
    _clientKeyCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) => setState(() => _isLoading = value);

  void _showSnackBar(String message, {bool isError = false}) {
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[700] : Colors.teal[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showSnackBarError(String message) =>
      _showSnackBar(message, isError: true);

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard');
  }

  // ── OkHi config builder ───────────────────────────────────────────────────

  OkHiAppConfiguration _getConfig() => OkHiAppConfiguration(
    branchId: _branchIdCtrl.text.trim(),
    clientKey: _clientKeyCtrl.text.trim(),
    env: _selectedEnv,
  );

  OkHiUser _getUser() => OkHiUser(
    phone: _phoneCtrl.text.trim(),
    firstName: _firstNameCtrl.text.trim(),
    lastName: _lastNameCtrl.text.trim(),
    appUserId: _appUserIdCtrl.text.trim(),
    email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    id: _userId.isEmpty ? null : _userId,
  );

  OkHiLocationManagerConfiguration _getLocationManagerConfig() =>
      OkHiLocationManagerConfiguration(
        color: '#008080',
        appName: 'OkHi Flutter Demo',
        logoUrl: 'https://cdn.okhi.co/icon.png',
        withAppBar: true,
        withCreateMode: true,
        withHomeAddressType: true,
        withWorkAddressType: false,
        withStreetView: true,
      );

  // ── Permission actions ────────────────────────────────────────────────────

  Future<void> _requestLocationServices() async {
    _setLoading(true);
    final granted = await OkHi.requestEnableLocationServices();
    _setLoading(false);
    _showSnackBar(granted ? 'Location services enabled' : 'Not enabled');
  }

  Future<void> _requestLocationPermission() async {
    _setLoading(true);
    final granted = await OkHi.requestLocationPermission();
    _setLoading(false);
    _showSnackBar(
      granted ? 'Location permission granted' : 'Permission denied',
    );
  }

  Future<void> _requestBackgroundPermission() async {
    _setLoading(true);
    final granted = await OkHi.requestBackgroundLocationPermission();
    _setLoading(false);
    _showSnackBar(
      granted ? 'Background permission granted' : 'Permission denied',
    );
  }

  // ── OkHi login ────────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (_branchIdCtrl.text.trim().isEmpty ||
        _clientKeyCtrl.text.trim().isEmpty) {
      _showSnackBarError('Branch ID and Client Key are required');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty ||
        _firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _appUserIdCtrl.text.trim().isEmpty) {
      _showSnackBarError(
        'Phone, first name, last name and app user ID are required',
      );
      return;
    }

    _setLoading(true);
    OkHi.login(_getConfig(), _getUser(), _getLocationManagerConfig())
        .then((result) {
          setState(() {
            _isUserSet = true;
            _appUserId = _appUserIdCtrl.text.trim();
          });
          _setLoading(false);
          _showSnackBar('Login successful');
        })
        .onError((error, stackTrace) {
          _setLoading(false);
          if (error is OkHiException) {
            _showSnackBarError('[${error.code}] ${error.message}');
          } else {
            _showSnackBarError(error.toString());
          }
        });
  }

  // ── OkHi logout ───────────────────────────────────────────────────────────

  Future<void> _logout() async {
    _setLoading(true);
    OkHi.logout()
        .then((result) {
          setState(() {
            _isUserSet = false;
            _appUserId = '';
            _userId = '';
            _savedAddressId = '';
          });
          _setLoading(false);
          _showSnackBar('Logged out');
        })
        .onError((error, stackTrace) {
          _setLoading(false);
          if (error is OkHiException) {
            _showSnackBarError('[${error.code}] ${error.message}');
          } else {
            _showSnackBarError(error.toString());
          }
        });
  }

  // ── Address operations ────────────────────────────────────────────────────

  void _onAddressSuccess(dynamic user, dynamic location) {
    final locationId = location.id as String? ?? '';
    setState(() => _savedAddressId = locationId);
    _setLoading(false);
    _copyToClipboard(locationId, 'Location ID');
    _showSnackBar('Success — Location ID: $locationId');
  }

  void _onAddressError(OkHiException error) {
    _setLoading(false);
    _showSnackBarError('[${error.code}] ${error.message}');
  }

  Future<void> _startDigitalVerification() async {
    _setLoading(true);
    OkHi.startDigitalAddressVerification(
      locationId: _savedAddressId.isEmpty ? null : _savedAddressId,
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _startPhysicalVerification() async {
    _setLoading(true);
    OkHi.startPhysicalAddressVerification(
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _startDigitalAndPhysicalVerification() async {
    _setLoading(true);
    OkHi.startDigitalAndPhysicalAddressVerification(
      onSuccess: _onAddressSuccess,
      onError: _onAddressError,
    );
  }

  Future<void> _createAddress() async {
    _setLoading(true);
    OkHi.createAddress(onSuccess: _onAddressSuccess, onError: _onAddressError);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OkHi Flutter Demo'),
          centerTitle: true,
          backgroundColor: const Color(0xFF008080),
          foregroundColor: Colors.white,
          actions: [
            if (_isUserSet)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: _isLoading ? null : _logout,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Status chip ──────────────────────────────────────
                    _StatusChip(isLoggedIn: _isUserSet, appUserId: _appUserId),
                    const SizedBox(height: 20),

                    // ── Credentials section ──────────────────────────────
                    if (!_isUserSet) ...[
                      _SectionHeader('Environment'),
                      _EnvSelector(
                        selected: _selectedEnv,
                        onChanged: (env) => setState(() => _selectedEnv = env),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader('App Credentials'),
                      _buildTextField(
                        _branchIdCtrl,
                        'Branch ID',
                        Icons.vpn_key,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _clientKeyCtrl,
                        'Client Key',
                        Icons.lock_outline,
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader('User Details'),
                      _buildTextField(
                        _phoneCtrl,
                        'Phone (+2547...)',
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _firstNameCtrl,
                        'First Name',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _lastNameCtrl,
                        'Last Name',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _appUserIdCtrl,
                        'App User ID',
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _emailCtrl,
                        'Email (optional)',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text('Login'),
                        style: _primaryButtonStyle(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Permissions section ──────────────────────────────
                    _SectionHeader('Permissions'),
                    _PermissionRow(
                      label: 'Enable Location Services',
                      icon: Icons.location_on_outlined,
                      onTap: _isLoading ? null : _requestLocationServices,
                    ),
                    const SizedBox(height: 8),
                    _PermissionRow(
                      label: 'Request Location Permission',
                      icon: Icons.my_location,
                      onTap: _isLoading ? null : _requestLocationPermission,
                    ),
                    const SizedBox(height: 8),
                    _PermissionRow(
                      label: 'Request Background Location',
                      icon: Icons.gps_fixed,
                      onTap: _isLoading ? null : _requestBackgroundPermission,
                    ),

                    if (_isUserSet) ...[
                      const SizedBox(height: 24),
                      // ── Address operations ───────────────────────────
                      _SectionHeader('Address Verification'),
                      _ActionButton(
                        label: 'Digital Verification',
                        icon: Icons.verified_outlined,
                        subtitle: _savedAddressId.isEmpty
                            ? 'Creates a new address'
                            : 'Re-verifying: ${_savedAddressId.substring(0, 8)}…',
                        onTap: _startDigitalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Physical Verification',
                        icon: Icons.home_work_outlined,
                        subtitle: 'Schedule a physical visit',
                        onTap: _startPhysicalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Digital + Physical',
                        icon: Icons.sync_alt,
                        subtitle: 'Both verification methods',
                        onTap: _startDigitalAndPhysicalVerification,
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        label: 'Create Address Only',
                        icon: Icons.add_location_alt_outlined,
                        subtitle: 'No verification — address book only',
                        onTap: _createAddress,
                      ),

                      // ── Saved address ────────────────────────────────
                      if (_savedAddressId.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionHeader('Saved Address'),
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.bookmark_outline,
                              color: Color(0xFF008080),
                            ),
                            title: const Text('Location ID'),
                            subtitle: Text(
                              _savedAddressId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy_outlined),
                              onPressed: () => _copyToClipboard(
                                _savedAddressId,
                                'Location ID',
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Widget helpers ─────────────────────────────────────────────────────────

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF008080),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    textStyle: const TextStyle(fontSize: 16),
  );
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Color(0xFF008080),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isLoggedIn;
  final String appUserId;
  const _StatusChip({required this.isLoggedIn, required this.appUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLoggedIn
            ? Colors.teal.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLoggedIn ? Colors.teal : Colors.orange),
      ),
      child: Row(
        children: [
          Icon(
            isLoggedIn ? Icons.check_circle_outline : Icons.info_outline,
            color: isLoggedIn ? Colors.teal : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLoggedIn
                  ? 'Logged in as $appUserId'
                  : 'Not logged in — fill in credentials below',
              style: TextStyle(
                color: isLoggedIn ? Colors.teal[800] : Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvSelector extends StatelessWidget {
  final OkHiEnv selected;
  final ValueChanged<OkHiEnv> onChanged;

  const _EnvSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<OkHiEnv>(
      segments: const [
        ButtonSegment(value: OkHiEnv.dev, label: Text('Dev')),
        ButtonSegment(value: OkHiEnv.sandbox, label: Text('Sandbox')),
        ButtonSegment(value: OkHiEnv.prod, label: Text('Prod')),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PermissionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF008080),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
