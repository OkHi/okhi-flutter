import Flutter
import UIKit
import OkHi
import CoreLocation

public class SwiftOkhiFlutterPlugin: NSObject, FlutterPlugin {
    private enum LocationPermissionRequestType: String {
        case whenInUse = "whenInUse"
        case always = "always"
    }
    private var flutterResult: FlutterResult?
    private var locationPermissionRequestType: LocationPermissionRequestType = .always
    private let okverify: OkVerify
    private let coreLocationManager: CLLocationManager
    public override init() {
        okverify = OkVerify()
        coreLocationManager = CLLocationManager()
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.init()
        coreLocationManager.delegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "okhi_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftOkhiFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
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
        case "startVerification":
            handleStartVerification(call, result)
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
        default:
            result(FlutterMethodNotImplemented)
            break
        }
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
        if okverify.isLocationPermissionGranted() {
            result(true)
            return
        }
        self.flutterResult = result
        okverify.delegate = self
        okverify.requestLocationPermission()
        locationPermissionRequestType = .whenInUse
    }
    
    private func handleRequestBackgroundLocationPermission(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if isBackgroundLocationPermissionGranted() {
            result(true)
            return
        }
        okverify.delegate = self
        self.flutterResult = result
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
        if okverify.isLocationServicesEnabled() {
            return CLLocationManager.authorizationStatus() == .authorizedAlways
        } else {
            return false
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let branchId = arguments["branchId"] as? String
        let clientKey = arguments["clientKey"] as? String
        let envRaw = arguments["environment"] as? String ?? "sandbox"
        self.flutterResult = result
        if let branchId = branchId, let clientKey = clientKey {
            okverify.delegate = self
            okverify.initialize(branchId: branchId, clientKey: clientKey, environment: envRaw)
            print("init started, \(branchId), \(clientKey), \(envRaw)")
        } else {
            result(FlutterError(code: "unauthorized", message: "invalid initialization credentials provided", details: nil))
            print("init failed")
        }
    }
    
    private func handleStartVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let phoneNumber = arguments["phoneNumber"] as? String
        let locationId = arguments["locationId"] as? String
        let lat = arguments["lat"] as? Double
        let lon = arguments["lon"] as? Double
        if let locationId = locationId, let lat = lat, let lon = lon, let phoneNumber = phoneNumber {
            self.flutterResult = result
            let user = OkHiUser(phoneNumber: phoneNumber)
            let location = OkHiLocation(identifier: locationId, lat: lat, lon: lon)
            okverify.delegate = self
            okverify.startAddressVerification(user: user, location: location)
        } else {
            result(FlutterError(code: "bad_request", message: "invalid arguments provided for verification", details: nil))
        }
    }
    
    private func handleStopVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let locationId = arguments["locationId"] as? String
        if let locationId = locationId {
            self.flutterResult = result
            okverify.delegate = self
            okverify.stopAddressVerification(locationId: locationId)
        } else {
            result(FlutterError(code: "bad_request", message: "invalid arguments provided for stopping verification", details: nil))
        }
    }
    
    private func handleGetCurrentLocation(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        self.flutterResult = result
        if (okverify.isLocationPermissionGranted()) {
            coreLocationManager.requestLocation()
        } else {
            result(FlutterError(code: "permission_denied", message: "location permission is not granted", details: nil))
        }
    }
    
}

extension SwiftOkhiFlutterPlugin: OkVerifyDelegate {
    public func verify(_ okverify: OkVerify, didChangeLocationPermissionStatus requestType: OkVerifyLocationPermissionRequestType, status: Bool) {
        if let flutterResult = flutterResult {
            if locationPermissionRequestType == .whenInUse && requestType == .whenInUse {
                flutterResult(status)
            } else if locationPermissionRequestType == .always && requestType == .always {
                flutterResult(status)
            } else {
                flutterResult(false)
            }
        }
    }
    
    public func verify(_ okverify: OkVerify, didInitialize result: Bool) {
        print("init complete")
        if let flutterResult = flutterResult {
            flutterResult(result)
        }
    }
    
    public func verify(_ okverify: OkVerify, didEncounterError error: OkVerifyError) {
        if let flutterResult = flutterResult {
            flutterResult(FlutterError(code: error.code, message: error.message, details: nil))
        }
    }
    
    public func verify(_ okverify: OkVerify, didStartAddressVerificationFor locationId: String) {
        if let flutterResult = flutterResult {
            flutterResult(locationId)
        }
    }
    
    public func verify(_ okverify: OkVerify, didStopVerificationFor locationId: String) {
        if let flutterResult = flutterResult {
            flutterResult(locationId)
        }
    }
    
    public func verify(_ okverify: OkVerify, didUpdateLocationPermissionStatus status: CLAuthorizationStatus) {
        // TODO: handle event transmission
    }
    
    public func verify(_ okverify: OkVerify, didUpdateNotificationPermissionStatus status: Bool) {
        
    }
}

extension SwiftOkhiFlutterPlugin: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if let result = self.flutterResult {
                let coords = [
                    "lat": location.coordinate.latitude,
                    "lng": location.coordinate.longitude,
                    "accuracy": location.horizontalAccuracy
                ]
                result(coords)
                self.flutterResult = nil
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let result = self.flutterResult {
            result(FlutterError(code: "unknown_error", message: "unable to obtain location", details: nil))
            self.flutterResult = nil
        }
    }
}
