import Flutter
import UIKit
import OkHi
import CoreLocation

public class OkhiFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private enum LocationPermissionRequestType: String {
        case whenInUse = "whenInUse"
        case always = "always"
    }
    private var locationPermissionRequestType: LocationPermissionRequestType = .always
    private let okverify: OkVerify
    private let coreLocationManager: CLLocationManager
    private var eventSink: FlutterEventSink?

    private var verificationSuccessResult: ((Any) -> Void)?
    private var verificationErrorResult: ((FlutterError) -> Void)?

    private func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        var topController = keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        if let navigationController = topController as? UINavigationController {
            return navigationController.visibleViewController
        }
        if let tabController = topController as? UITabBarController {
            return tabController.selectedViewController
        }
        return topController
    }

    public override init() {
        coreLocationManager = CLLocationManager()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 9.0, *) {
            coreLocationManager.allowsBackgroundLocationUpdates = true
        }
        okverify = OkVerify()
        super.init()
        coreLocationManager.delegate = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "okhi_flutter", binaryMessenger: registrar.messenger())
        let instance = OkhiFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(name: "okhi_flutter_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    // Called when the first listener is set on the Flutter side
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    // Called when the last listener is cancelled on the Flutter side
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func emit(_ data: [String: Any?]) {
        DispatchQueue.main.async {
            self.eventSink?(data)
        }
    }

    func close() {
        DispatchQueue.main.async {
            self.eventSink?(FlutterEndOfEventStream)
            self.eventSink = nil
        }
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "getPlatformVersion":
            handlePlatformVersion(call, result)
            break
        case "isLocationServicesEnabled":
            handleIsLocationServicesEnabled(call, result)
            break
        case "isLocationPermissionGranted":
            handleIsLocationPermissionGranted(call, result)
            break
        case "isBackgroundLocationPermissionGranted":
            handleIsBackgroundLocationPermissionGranted(call, result)
            break
        case "requestLocationPermission":
            handleRequestLocationPermission(call, result)
            break
        case "requestBackgroundLocationPermission":
            handleRequestBackgroundLocationPermission(call, result)
            break
        case "getAppIdentifier":
            handleGetAppIdentifier(call, result)
            break
        case "getAppVersion":
            handleGetAppVersion(call, result)
            break
        case "initialize":
            handleInitialize(call, result)
            break
        case "startDigitalAddressVerification":
            handleStartDigitalVerification(call, result)
            break
        case "startPhysicalAddressVerification":
            handleStartPhysicalVerification(call, result)
            break
        case "startDigitalAndPhysicalAddressVerification":
            handleStartDigitalAndPhysicalVerification(call, result)
            break
        case "createAddress":
            handleCreateAddress(call, result)
            break
        case "startSavedAddressVerification":
            handleVerifySavedAddress(call, result)
            break
        case "stopVerification":
            handleStopVerification(call, result)
            break
        case "getCurrentLocation":
            handleGetCurrentLocation(call, result)
            break
        case "onStart":
            handleOnStart(call, result)
            break
        case "retrieveDeviceInfo":
            handleRetrieveDeviceInfo(call, result)
            break
        case "fetchLocationPermissionStatus":
            handleFetchLocationPermissionStatus(call, result)
            break
        case "fetchRegisteredGeofences":
            handleFetchRegisteredGeofences(call, result)
            break
        case "openAppSettings":
            handleOpenAppSettings(call, result)
        case "getLocationAccuracyLevel":
            handleGetLocationAccuracyLevel(call, result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

    private func handleGetLocationAccuracyLevel(_ call: FlutterMethodCall, _ result: FlutterResult) {
        let level = OkVerify.getLocationAccuracyLevel()
        result(level)
    }

    private func handleOpenAppSettings(_ call: FlutterMethodCall, _ result: FlutterResult) {
        OkVerify.openAppSettings()
        result(true)
    }

    private func handleFetchRegisteredGeofences(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        do {
            let geofences: [[String: Any]] = OkVerify.fetchRegisteredGeofences()
            let jsonData = try JSONSerialization.data(withJSONObject: geofences, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                result(NSNull())
                return
            }
            result(jsonString)
        } catch {
            result(NSNull())
        }
    }

    private func handleFetchLocationPermissionStatus(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        var status = fetchLocationPermissionStatus(status: getLocationAuthorizationStatus(manager: CLLocationManager()))
        status = status == "notDetermined" ? "notDetermined" : status == "authorizedWhenInUse" ? "whenInUse" : status == "authorizedAlways" ? "always" : "denied"
        result(status)
    }

    private func handleRetrieveDeviceInfo(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let deviceInfoDict: NSDictionary = [
            "manufacturer": "Apple",
            "model": UIDevice.current.modelName,
            "osVersion": UIDevice.current.systemVersion,
            "platform": "ios"
        ]
        result(deviceInfoDict)
    }

    private func handleOnStart(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        OkVerify.onStart { initState in
            result(initState)
        }
    }

    private func handlePlatformVersion(_ call: FlutterMethodCall, _ result: FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }

    private func handleIsLocationServicesEnabled(_ call: FlutterMethodCall, _ result: FlutterResult) {
        result(okverify.isLocationServicesEnabled())
    }

    private func handleIsLocationPermissionGranted(_ call: FlutterMethodCall, _ result: FlutterResult) {
        result(okverify.isLocationPermissionGranted())
    }

    private func handleIsBackgroundLocationPermissionGranted(_ call: FlutterMethodCall, _ result: FlutterResult) {
        result(isBackgroundLocationPermissionGranted())
    }

    private func handleRequestLocationPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        okverify.delegate = self
        if okverify.isLocationPermissionGranted() {
            result(true)
            return
        }
        self.verificationSuccessResult = { granted in
            result(granted)
        }
        self.verificationErrorResult = { error in
            result(error)
        }
        locationPermissionRequestType = .whenInUse
        okverify.requestLocationPermission()
    }

    private func handleRequestBackgroundLocationPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if isBackgroundLocationPermissionGranted() {
            result(true)
            return
        }
        okverify.delegate = self
        self.verificationSuccessResult = { granted in
            result(granted)
        }
        self.verificationErrorResult = { error in
            result(error)
        }
        locationPermissionRequestType = .always
        okverify.requestBackgroundLocationPermission()
    }

    private func handleGetAppIdentifier(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let bundleID = Bundle.main.bundleIdentifier
        result(bundleID ?? "")
    }

    private func handleGetAppVersion(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        result(appVersion ?? "")
    }

    private func isBackgroundLocationPermissionGranted() -> Bool {
        okverify.delegate = self
        if okverify.isLocationServicesEnabled() {
            return CLLocationManager.authorizationStatus() == .authorizedAlways
        } else {
            return false
        }
    }

    private func handleInitialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {

        // todo: Verify where theme is passed to in IOS
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let branchId = arguments["branchId"] as? String
        let clientKey = arguments["clientKey"] as? String
        let envRaw = arguments["environment"] as? String ?? "sandbox"

        let locationManagerConfiguration = arguments("locationManagerConfiguration") as? [String: Any] ?? [String: Any]()

        let phoneNumber = arguments["phoneNumber"] as? String
        let firstName = arguments["firstname"] as? String
        let lastName = arguments["lastname"] as? String
        let email = arguments["email"] as? String
        let userId = arguments["userId"] as? String
        let token = arguments["token"] as? String

        if let branchId = branchId, let clientKey = clientKey {
            guard let phoneNumber = phoneNumber, let userId = userId, let firstName = firstName else {
                result(FlutterError(code: "bad_request", message: "Invalid arguments provided for verification", details: nil))
                return
            }

            let auth = OkHiAuth(
                branchId: branchId,
                clientKey: clientKey,
                environment: envRaw,
                appContext: OkHiAppContext().withAppMeta(name: "OkHi Global", version: "1.0.0", build: "1") // Verify when this is used
            )

            let user = OkHiUser(phoneNumber: phoneNumber)
                .with(firstName: firstName)
                .with(lastName: lastName ?? "")
                .with(email: email ?? "")
                .with(appUserId: userId) // Verify if this is a required field
                .with(token: token ?? "")
                .with(okHiId: userId)

            OK.shared.login(auth: auth, user: user)
            print("OkHi Initialized successfully on iOS platform")
            result(true)
        } else {
            result(FlutterError(code: "unauthorized", message: "invalid initialization credentials provided", details: nil))
        }
    }

    private func handleStartDigitalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            result(FlutterError(code: "internal_error", message: "Unable to get root view controller", details: nil))
            return
        }
        OK.shared.startAddressVerification(vc: viewController) { response, error in
            if let error = error {
                result(FlutterError(code: "verification_error", message: error.message, details: nil))
                return
            }
            guard let locationId = response?.location.id else {
                result(FlutterError(code: "verification_failed", message: "Verification failed to return a location ID", details: nil))
                return
            }
            print("Successfully started verification for \(locationId)")
            self.emit(
                [
                    "type": "success",
                    "methodCall": "startAddressVerification",
                    "locationId": locationId
                ]
            )
        }
    }

    private func handleStartPhysicalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            result(FlutterError(code: "internal_error", message: "Unable to get root view controller", details: nil))
            return
        }
        OK.shared.startPhysicalAddressVerification(vc: viewController) { response, error in
            guard let locationId = response?.location.id else { return }
            print("Successfully started verification for \(locationId)")
            self.emit(
                [
                    "type": "success",
                    "methodCall": "startPhysicalAddressVerification",
                    "locationId": locationId
                ]
            )
        }
    }

    private func handleStartDigitalAndPhysicalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            result(FlutterError(code: "internal_error", message: "Unable to get root view controller", details: nil))
            return
        }
        OK.shared.startDigitalAndPhysicalAddressVerification(vc: viewController) { response, error in
            guard let locationId = response?.location.id else { return }
            print("Successfully started verification for \(locationId)")
            self.emit(
                [
                    "type": "success",
                    "methodCall": "startAddressVerification",
                    "locationId": locationId
                ]
            )
        }
    }

    private func handleCreateAddress(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            result(FlutterError(code: "internal_error", message: "Unable to get root view controller", details: nil))
            return
        }
        OK.shared.createAddress(vc: viewController) { response, error in
            guard let locationId = response?.location.id else { return }
            print("Successfully created address for \(locationId)")
            do {
                self.emit(
                    [
                        "type": "success",
                        "methodCall": "createAddress",
                        "locationId": locationId
                    ]
                )
            } catch {
                print("Error on emit: \(error)")
            }
        }
    }

    private func handleVerifySavedAddress(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        let locationId = arguments["locationId"] as? String
        let okhiLocation: OkHiLocation = OkHiLocation(
            identifier: locationId ?? ""
        )

        guard let rootViewController = topViewController() else {
            result(FlutterError(code: "internal_error", message: "Unable to get root view controller", details: nil))
            return
        }

        OK.shared.startAddressVerification(vc: rootViewController, location: okhiLocation) { response, error in
          guard let locationId = response?.location.id else { return }
          print("Successfully created address for \(locationId)")
            self.emit(
                [
                    "type": "success",
                    "methodCall": "startAddressVerification",
                    "locationId": locationId
                ]
            )
        }
    }

    private func handleStopVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let locationId = arguments["locationId"] as? String
        if let locationId = locationId {
            okverify.delegate = self
            self.verificationSuccessResult = { granted in
                result(granted)
            }
            self.verificationErrorResult = { error in
                result(error)
            }
            okverify.stopAddressVerification(locationId: locationId)
        } else {
            result(FlutterError(code: "bad_request", message: "invalid arguments provided for stopping verification", details: nil))
        }
    }

    private func handleGetCurrentLocation(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let location = coreLocationManager.location, abs(location.timestamp.timeIntervalSinceNow) < 60, location.horizontalAccuracy <= 50 {
            let coords = [
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude,
                "accuracy": location.horizontalAccuracy
            ]
            result(coords)
        } else {
            self.verificationSuccessResult = { granted in
                result(granted)
            }
            self.verificationErrorResult = { error in
                result(error)
            }

            if (okverify.isLocationPermissionGranted()) {
                coreLocationManager.requestLocation()
            } else {
                result(FlutterError(code: "permission_denied", message: "location permission is not granted", details: nil))
            }
        }
    }

    private func getLocationAuthorizationStatus(manager: CLLocationManager) -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return manager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    private func fetchLocationPermissionStatus(status: CLAuthorizationStatus) -> String {
        var str: String = ""
        switch status {
        case .notDetermined:
            str = "notDetermined"
        case .restricted:
            str = "restricted"
        case .denied:
            str = "denied"
        case .authorizedAlways:
            str = "authorizedAlways"
        case .authorizedWhenInUse:
            str = "authorizedWhenInUse"
        case .authorized:
            str = "authorized"
        @unknown default:
            str = "unknown"
        }
        return str
    }
}

extension OkhiFlutterPlugin: OkVerifyDelegate {
    public func verify(_ okverify: OkVerify, didChangeLocationPermissionStatus requestType: OkVerifyLocationPermissionRequestType, status: Bool) {
        if locationPermissionRequestType == .whenInUse && requestType == .whenInUse {
            verificationSuccessResult?(status)
        } else if locationPermissionRequestType == .always && requestType == .always {
            verificationSuccessResult?(status)
        } else {
            verificationSuccessResult?(false)
        }
        verificationSuccessResult = nil
        verificationErrorResult = nil
    }

    public func verify(_ okverify: OkVerify, didInitialize result: Bool) {
        verificationSuccessResult?(result)
        verificationSuccessResult = nil
        verificationErrorResult = nil
    }

    public func verify(_ okverify: OkVerify, didEncounterError error: OkVerifyError) {
        verificationErrorResult?(FlutterError(code: error.code, message: error.message, details: nil))
        verificationErrorResult = nil
        verificationSuccessResult = nil
    }

    public func verify(_ okverify: OkVerify, didStartAddressVerificationFor locationId: String) {
        verificationSuccessResult?(locationId)
        verificationSuccessResult = nil
        verificationErrorResult = nil
    }

    public func verify(_ okverify: OkVerify, didStopVerificationFor locationId: String) {
        verificationSuccessResult?(locationId)
        verificationSuccessResult = nil
        verificationErrorResult = nil
    }

    public func verify(_ okverify: OkVerify, didUpdateLocationPermissionStatus status: CLAuthorizationStatus) {
        // TODO: handle event transmission
    }

    public func verify(_ okverify: OkVerify, didUpdateNotificationPermissionStatus status: Bool) {

    }
}

extension OkhiFlutterPlugin: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coords = [
                "lat": location.coordinate.latitude,
                "lng": location.coordinate.longitude,
                "accuracy": location.horizontalAccuracy
            ]
            verificationSuccessResult?(coords)
            verificationSuccessResult = nil
            verificationErrorResult = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        verificationErrorResult?(FlutterError(code: "unknown_error", message: "unable to obtain location", details: nil))
        verificationErrorResult = nil
        verificationSuccessResult = nil
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
