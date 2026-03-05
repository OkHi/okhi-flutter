# Agent.md — OkHi Flutter Integration

## Project Overview

This is a Flutter application that integrates the **OkHi address verification SDK** (`okhi_flutter`). It supports three verification environments (dev, sandbox, prod) and covers the full OkHi lifecycle: user login, address creation, digital/physical verification, and logout. Firebase is also wired up (currently disabled via a comment).

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Address Verification | `okhi_flutter` |
| Firebase | `firebase_core` (optional, commented out) |
| State Management | `setState` (local widget state) |
| Min Android SDK | 21 |
| Target/Compile Android SDK | 36 |
| Min iOS | 12.0 |

---

## Project Structure

```
lib/
  main_workspace.dart     # Root app entry point + full OkHi lifecycle UI
  firebase_options.dart   # Firebase platform config (auto-generated)
android/
  app/
    build.gradle          # compileSdk=36, minSdk=21, targetSdk=36
    src/main/
      AndroidManifest.xml # Location + notification permissions
      proguard-rules.pro  # ProGuard rules for OkHi & OkHttp
ios/
  Runner/
    AppDelegate.swift     # OkHi.OK.startMonitoring() on launch
    Info.plist            # NSLocation* usage descriptions
  Podfile                 # platform :ios, '12.0'
```

---

## Environment Configuration

The app supports three OkHi environments, selectable at runtime via the UI:

```dart
OkHiEnv.dev      // Development
OkHiEnv.sandbox  // Staging / QA
OkHiEnv.prod     // Production
```

Each environment requires its own `branchId` and `clientKey` from OkHi. These are currently empty strings in `getConfig()` — **fill these in before running**:

```dart
OkHiAppConfiguration(
  branchId: "<your_branch_id>",
  clientKey: "<your_client_key>",
  env: OkHiEnv.prod,
)
```

---

## OkHi Initialization Flow

Call `OkHi.login()` once during app startup (or after the user sets their credentials). This must complete before any address operations are performed.

```dart
OkHi.login(appConfig, okHiUser, locationManagerConfig)
  .then((result) { /* ready */ })
  .onError((error, stackTrace) { /* handle */ });
```

**`OkHiUser` fields:**

| Field | Required | Notes |
|---|---|---|
| `phone` | Yes | Must include country code, e.g. `+2547...` — use your real number during testing |
| `firstName` | Yes | |
| `lastName` | Yes | |
| `appUserId` | Yes | Your internal user identifier |
| `email` | No | |
| `id` | No | OkHi user ID (if previously known) |

**`OkHiLocationManagerConfiguration` fields used in this project:**

```dart
OkHiLocationManagerConfiguration(
  color: "#008080",
  appName: "OkHi Flutter Demo",
  logoUrl: "https://...",
  withAppBar: true,
  withCreateMode: true,
  withHomeAddressType: true,
  withWorkAddressType: false,  // Work address type is disabled
  withStreetView: true,
)
```

---

## Address Verification Methods

### Digital Verification (primary)
```dart
OkHi.startDigitalAddressVerification(
  locationId: null,           // null = create new; pass saved ID to re-verify
  onSuccess: (user, location) { print(location.id); },
  onError: (error) { print(error.code); print(error.message); },
);
```

### Physical Verification
```dart
OkHi.startPhysicalAddressVerification(
  onSuccess: (user, location) {},
  onError: (error) {},
);
```

### Both Physical + Digital
```dart
OkHi.startDigitalAndPhysicalAddressVerification(
  onSuccess: (user, location) {},
  onError: (error) {},
);
```

### Address Book Only (create without verifying)
```dart
OkHi.createAddress(
  onSuccess: (user, location) {},
  onError: (error) {},
);
```

### Persist and Re-verify Later
1. Create address → store `okhiLocation.id` (device storage or server).
2. On next session, pass `locationId` into `startDigitalAddressVerification`.

---

## Location Permissions Flow

The app exposes three explicit permission request actions:

```dart
OkHi.requestEnableLocationServices()       // Enable GPS
OkHi.requestLocationPermission()           // Foreground location
OkHi.requestBackgroundLocationPermission() // Background location (needed for digital verification)
```

All three return a `bool` indicating success. Background location permission is required for digital verification to function correctly.

---

## Logout

```dart
OkHi.logout().then((result) {
  // Stops signal collection; clear local user state
}).onError((error, stackTrace) {});
```

On logout, reset all local user state: `isUserSet`, `appUserId`, `userId`, `savedAddressID`.

---

## Android Setup

### `app/build.gradle`
```gradle
android {
  compileSdk = 36
  defaultConfig {
    minSdk = 21
    targetSdk = 36
  }
}
```

### `AndroidManifest.xml` — Required Permissions
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"
    android:foregroundServiceType="location"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### `AndroidManifest.xml` — Notification Metadata
```xml
<meta-data android:name="io.okhi.android.notification_title" android:value="Address verification" />
<meta-data android:name="io.okhi.android.notification_text" android:value="Your address is currently being verified" />
<meta-data android:name="io.okhi.android.notification_icon" android:resource="@drawable/ic_launcher" />
```

### ProGuard (`proguard-rules.pro`)

Required if `minifyEnabled = true`:
```gradle
-dontwarn sun.reflect.**
-dontwarn java.beans.**
-dontwarn sun.nio.ch.**
-dontwarn sun.misc.**
-keep class com.esotericsoftware.** {*;}
-keep class java.beans.** { *; }
-keep class sun.reflect.** { *; }
-keep class sun.nio.ch.** { *; }
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-dontwarn okhttp3.internal.platform.ConscryptPlatform
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-keepclassmembers class io.okhi.android_okcollect.interfaces.WebAppInterface {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class io.okhi.android_background_geofencing.models.** { *; }
```

---

## iOS Setup

### `Podfile`
```ruby
platform :ios, '12.0'
```

### `Info.plist`
```xml
<key>NSLocationAlwaysUsageDescription</key>
<string>Grant to enable verifying your addresses.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Grant to enable creating addresses at your current location.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Grant to enable creating and verifying your addresses.</string>
```

### `AppDelegate.swift`
```swift
import OkHi

override func application(...) -> Bool {
    OkHi.OK.startMonitoring()   // Must be called before plugin registration
    GeneratedPluginRegistrant.register(with: self)
    return super.application(...)
}
```

### Xcode — Background Modes
Enable both under **Signing & Capabilities → Background Modes**:
- Location updates
- Background fetch

---

## UI Patterns Used

- `setState` is used for all local state changes (loading indicator, user set flag, saved IDs).
- `GlobalKey<ScaffoldMessengerState>` is used to show `SnackBar` messages from outside the widget tree (e.g., inside async callbacks).
- `GlobalKey<NavigatorState>` is registered on `MaterialApp` for potential programmatic navigation.
- Results (location IDs, user IDs) are copied to the clipboard via `Clipboard.setData()` and surfaced via SnackBar for QA sharing.
- Loading state (`isLoading`) wraps all async OkHi calls and is toggled via `setState` before and after each call.

---

## Error Handling

All OkHi errors surface an `OkHiException` with two fields:

```dart
onError: (error) {
  print(error.code);     // Machine-readable error code
  print(error.message);  // Human-readable description
}
```

The app displays errors as red SnackBars via `showSnackBarError(message)`.

---

## Installation

```bash
# Add the dependency
flutter pub add okhi_flutter

# Install iOS pods
cd ios/ && pod install --repo-update && cd ../
```
