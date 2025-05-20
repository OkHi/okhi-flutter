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
        status = status == "notDetermined" ? "notDetermined" : status == "authorizedWhenInUse" ? "whenInuse" : status == "authorizedAlways" ? "always" : "denied"
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
        } else {
            result(FlutterError(code: "unauthorized", message: "invalid initialization credentials provided", details: nil))
            print("init failed")
        }
    }
    
    private func handleStartVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        
        let phoneNumber = arguments["phoneNumber"] as? String
        let userId = arguments["userId"] as? String
        let token = arguments["token"] as? String
        let locationId = arguments["locationId"] as? String
        let lat = arguments["lat"] as? Double
        let lon = arguments["lon"] as? Double
        let usageTypes = arguments["usageTypes"] as? [String] ?? []
        
        let enumUsageTypes: [OkHiUsageType] = usageTypes.compactMap { usageType in
            switch usageType {
            case OkHiUsageType.physicalVerification.rawValue:
                return .physicalVerification
            case OkHiUsageType.addressBook.rawValue:
                return .addressBook
            default:
                return .digitalVerification
            }
        }
        
        guard let phoneNumber = phoneNumber, let userId = userId, let token = token, let locationId = locationId, let lat = lat, let lon = lon else {
            result(FlutterError(code: "bad_request", message: "Invalid arguments provided for verification", details: nil))
            return
        }
        okverify.delegate = self
        self.flutterResult = result
        
        let user = OkHiUser(phoneNumber: phoneNumber).with(token: token).with(okHiId: userId)
        let location = OkHiLocation(identifier: locationId, lat: lat, lon: lon, usageTypes: enumUsageTypes)
        let response = OkCollectSuccessResponse(user: user, location: location)
        okverify.startAddressVerification(response: response)
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
