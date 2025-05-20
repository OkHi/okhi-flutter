## 1.1.28

- fix: Reply already submitted error on native android when fetching location

## 1.1.27

- fix: overriding geolocation web api on android + ios

## 1.1.26

- upgrade: removed deprecated api usage

## 1.1.25

- upgrade: bump up native android libraries

## 1.1.24

- fix: ios callback when requesting for always permission with precise granted

## 1.1.23

- fix: android callback when requesting for when in use with precise granted

## 1.1.22

- feature: enabled checking precise location before address verification starts
- feature: `OkHi.getLocationAccuracyLevel` to retrive the current location accuracy level of the device
- upgrade: bump up android:okverify to v1.9.72
- upgrade: bump up android:core to v1.7.38
- upgrade: bump up iOS:OkHi to v and android:core to 1.9.52

## 1.1.21

- fix: added namespace to build.gradle fixing `Namespace not specified. Specify a namespace in the module's build file..` Enables targetting Android SDK 35

## 1.1.20

- upgrade: bump up native ios library to v1.9.50

## 1.1.19

- Updated extra location properties to OkHiLocation class `gpsAccuracy` from typeOf double to string

## 1.1.18

- added extralocation properties to OkHiLocation class
  `ward, formattedAddress, postCode, lga, lgaCode, unit, gpsAccuracy, businessName, type, district, addressLine`
- upgrade: bump up android:core to v1.7.32
- upgrade: bump up android:okverify to v1.9.67
- upgrade: bump up ios:OkHi to v1.9.48

## 1.1.17

- Release: Update example code

## 1.1.16

- Release: Moved to stable release.

## 1.1.15-beta

- Feature: Enable usage type verification.
- Feature: appUserId as property of OkHiUser.
- Feature: OkHiLocationManager now accepts locationIds for previously created addresses for either digital and/or physical verification.
- Update android:core to 1.7.31
- Update android:okverify to 1.9.66

## 1.1.14

- Feature: OkLite. Verify addresses physically, digitally or both.
- Upgrade: android:okverify:1.9.49, android:core:1.7.24, iOS OkHi 1.9.40
- Feature: Build patches

## 1.1.13

- Feature: OkLite. Verify addresses physically, digitally or both.
- Upgrade: android:okverify:1.9.49, android:core:1.7.24, iOS OkHi 1.9.40

## 1.1.12

- Feature: added email to OkHiUser class

## 1.1.11

- Upgrade: native ios library to 1.9.36
- Docs: updated README.md

## 1.1.10

- Upgrade: android-okverify to v1.9.45

- ## 1.1.9

## 1.1.8

- Feature: Improved fetching of GPS coordinates.
- Fix: Black screen when OkCollect launches.

## 1.1.7

- Feature: Improved fetching of GPS coordinates during the address creation process on iOS.

## 1.1.6

- Feature: Quickstart
- Feature: OkCollect will now show addresses that are already being verified, preventing users from creating unnexessary duplicate addresses
- Fix: Geolocation services not available issue on Android
- Upgrade: android-okverify to v1.9.42
- Upgrade: OkHi-iOS to v1.9.35
- Minor bug fixes and stability improvements

## 1.1.5

- Upgrade: flutter dependencies to latest versions

## 1.1.4

- Feature: Enable apps targetting sdk 34 (Android 14)
- Upgrade: android-core to v1.7.17
- Upgrade: android-okverify to v1.9.39
- Upgrade: OkHi-iOS to v1.9.34
- Minor bug fixes and stability improvments

## 1.1.3

- Upgrade: android-okverify to v1.9.32
- Minor bug fixes and stability improvments

## 1.1.2

- Upgrade: ios native library
- Minor bug fixes and stability improvments

## 1.1.1

- Migration: Migrated native android deps to okhi maven repo
- Upgrade: Upgraded android native libraries dependancies

## 1.1.0

- Upgrade: Upgraded native libraries dependancies
- Feature: Enabled android 5+ devices to create and verify devices

## 1.0.9

- Upgrade: Upgraded gradle to fix lStar issue. Requires setting compileSdkVersion + targetSdkVersion to 33
- Upgrade: Upgraded webview_flutter to 4.0.2

## 1.0.8

- Feature: Enabled create only mode in OkHiLocationManager
- Fix: Main thread warning with CLLocationManager.locationServicesEnabled()
- Upgrade: Upgraded to flutter_weview v4+

## 1.0.7

- Upgraded native OkHi libraries
- General fixes and stability improvements

## 1.0.6

- Upgraded native OkHi libraries
- Support up-to-date dependencies
- General fixes and stability improvements

## 1.0.5

- Upgraded native OkHi libraries
- Support up-to-date dependencies
- Added improvements for chinese based android devices
- General fixes and stability improvements

## 1.0.4

- Android sdk 31 support
- Include user information on OkHiLocationManagerResponse
- Added more location properties to OkHiLocation
- General fixes and stability improvements

## 1.0.3

- Enabled different address types for creation within OkHiLocationManager

## 1.0.2

- Fixes and general improvements

## 1.0.1

- Fix Geolocation issue on Android
- Upgraded native libraries

## 0.0.1

- Initial release
