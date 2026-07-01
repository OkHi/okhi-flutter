import Flutter
import UIKit
import OkHi
import CoreLocation
import Foundation

public class OkhiFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private enum LocationPermissionRequestType: String {
        case whenInUse = "whenInUse"
        case always = "always"
    }
    private var locationPermissionRequestType: LocationPermissionRequestType = .always
    private let okverify: OkVerify
    private var appConfig: OkHiConfig
    private var theme: OkHiTheme
    private let coreLocationManager: CLLocationManager
    private var eventSink: FlutterEventSink?

    private var verificationSuccessResult: ((Any) -> Void)?
    private var verificationErrorResult: ((FlutterError) -> Void)?
    private var activeOperationToken: Int = 0

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
        appConfig = OkHiConfig()
        theme = OkHiTheme()
        
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

    private func emit(_ data: [String: Any?]) {
        do {
            let jsonSafeData = data.compactMapValues { $0 } as [String: Any]
            let jsonData = try JSONSerialization.data(withJSONObject: jsonSafeData, options: [])

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.eventSink?(jsonString)
                }
            }
        } catch {
            print("Error serializing JSON: \(error)")
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
        case "logout":
            handleLogout(call, result)
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

        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let branchId = arguments["branchId"] as? String
        let clientKey = arguments["clientKey"] as? String
        let envRaw = arguments["environment"] as? String ?? "sandbox"


        let locationManagerConfiguration = arguments["locationManagerConfiguration"] as? [String: Any] ?? [String: Any]()
        print("OkHi Initialized locationManagerConfiguration: \(locationManagerConfiguration)")
        
        
        let phoneNumber = arguments["phoneNumber"] as? String
        let firstName = arguments["firstName"] as? String
        let lastName = arguments["lastName"] as? String
        
        let email = arguments["email"] as? String
        let userId = arguments["userId"] as? String
        let appUserId = arguments["appUserId"] as? String
        let token = arguments["token"] as? String

        if let branchId = branchId, let clientKey = clientKey {
            guard let phoneNumber = phoneNumber, let firstName = firstName else {
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
                .with(appUserId: appUserId ?? "")
                .with(token: token ?? "")
                .with(okHiId: userId ?? "")

            appConfig = OkHiConfig()
                .withAddressTypes(
                    work: locationManagerConfiguration["withWorkAddressType"] as? Bool == true,
                    home: locationManagerConfiguration["withHomeAddressType"] as? Bool == true
                )

            theme = OkHiTheme()
                .with(appBarColor: locationManagerConfiguration["color"] as? String ?? "#005D67")
                .with(primaryColor: locationManagerConfiguration["color"] as? String ?? "#005D67")
                .with(logoUrl: locationManagerConfiguration["logoUrl"] as? String ?? "")

            do {
                self.activeOperationToken += 1
                OK.shared.login(auth: auth, user: user){ list in
                    print("OkHi Initialized successfully on iOS platform: \(list)")
                    result(true)
                }
            } catch {
                result(false)
            }
        } else {
            result(FlutterError(code: "unauthorized", message: "invalid initialization credentials provided", details: nil))
        }
    }

    private func handleLogout(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        OK.shared.logout() { locationIds in
            let ids = locationIds as? [String] ?? []
            DispatchQueue.main.async {
                result(ids)
            }
        }
    }

    private func handleStartDigitalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        var okhiLocation: OkHiLocation? = nil
        var appConfigInstance: OkHiConfig = appConfig
        var method = "startDigitalAddressVerification"

        let arguments = call.arguments as? [String: Any] ?? [:]
        let locationId = arguments["locationId"] as? String
        if(locationId != nil) {
            okhiLocation = OkHiLocation(
                identifier: locationId ?? ""
            )
            appConfigInstance = appConfig.withUsageTypes(
                usageTypes: [OkHiUsageType.digitalVerification]
            )
            method = "startSavedAddressVerification"
        }

        guard let viewController = topViewController() else {
            self.emit(
                [
                    "type": "error",
                    "methodCall": method,
                    "code" : "internal_error",
                    "message" : "Unable to get root view controller"
                ]
            )
            return
        }

        let token = activeOperationToken
        OK.shared.startAddressVerification(vc: viewController, theme: theme, config: appConfigInstance, location: okhiLocation) { [weak self] response, error in
            guard let self = self, self.activeOperationToken == token else { return }
            if let validResponse = response {
                self.emit(self.getSuccessEvent(methodCall: method, response: validResponse))
            } else if let error = error {
                self.emit(
                    [
                        "type": "error",
                        "methodCall": method,
                        "code" : error.code,
                        "message" : error.message
                    ]
                )
            }
        }
        result(nil)
    }

    private func handleStartPhysicalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            self.emit(
                [
                    "type": "error",
                    "methodCall": "startPhysicalAddressVerification",
                    "code" : "internal_error",
                    "message" : "Unable to get root view controller"
                ]
            )
            return
        }

        let token = activeOperationToken
        OK.shared.startPhysicalAddressVerification(vc: viewController, theme: theme, config: appConfig) { [weak self] response, error in
            guard let self = self, self.activeOperationToken == token else { return }
            if let validResponse = response {
                self.emit(self.getSuccessEvent(methodCall: "startPhysicalAddressVerification", response: validResponse))
            } else if let error = error {
                self.emit(
                    [
                        "type": "error",
                        "methodCall": "startPhysicalAddressVerification",
                        "code" : error.code,
                        "message" : error.message
                    ]
                )
            }
        }
        result(nil)
    }

    private func handleStartDigitalAndPhysicalVerification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            self.emit(
                [
                    "type": "error",
                    "methodCall": "startDigitalAndPhysicalAddressVerification",
                    "code" : "internal_error",
                    "message" : "Unable to get root view controller"
                ]
            )
            return
        }
        let token = activeOperationToken
        OK.shared.startDigitalAndPhysicalAddressVerification(vc: viewController, theme: theme, config: appConfig) { [weak self] response, error in
            guard let self = self, self.activeOperationToken == token else { return }
            if let validResponse = response {
                self.emit(self.getSuccessEvent(methodCall: "startDigitalAndPhysicalAddressVerification", response: validResponse))
            } else if let error = error {
                self.emit(
                    [
                        "type": "error",
                        "methodCall": "startDigitalAndPhysicalAddressVerification",
                        "code" : error.code,
                        "message" : error.message
                    ]
                )
            }
        }
        result(nil)
    }

    private func handleCreateAddress(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let viewController = topViewController() else {
            self.emit(
                [
                    "type": "error",
                    "methodCall": "createAddress",
                    "code" : "internal_error",
                    "message" : "Unable to get root view controller"
                ]
            )
            return
        }
        let token = activeOperationToken
        OK.shared.createAddress(vc: viewController, theme: theme, config: appConfig) { [weak self] response, error in
            guard let self = self, self.activeOperationToken == token else { return }
            if let validResponse = response {
                self.emit(self.getSuccessEvent(methodCall: "createAddress", response: validResponse))
            } else if let error = error {
                self.emit(
                    [
                        "type": "error",
                        "methodCall": "createAddress",
                        "code" : error.code,
                        "message" : error.message
                    ]
                )
            }
        }
        result(nil)
    }

    private func getSuccessEvent(methodCall: String, response: OkHiSuccessResponse) -> [String : Any?] {
        let user = response.user
        let location = response.location
        let geo = location.geoPoint

        var okUser: [String: Any?] = [:]
        okUser["phone"] = user.phone ?? ""
        okUser["firstName"] = user.firstName ?? ""
        okUser["lastName"] = user.lastName ?? ""
        okUser["email"] = user.email ?? ""
        okUser["appUserId"] = user.appUserId ?? ""
        okUser["token"] = user.token ?? ""
        okUser["id"] = user.id ?? ""

        var okLocation: [String: Any?] = [:]
        okLocation["id"] = location.id ?? ""
        okLocation["lat"] = geo.lat ?? 0.0
        okLocation["lng"] = geo.lon ?? 0.0
        okLocation["city"] = location.city ?? ""
        okLocation["country"] = location.country ?? ""
        okLocation["directions"] = location.directions ?? ""
        okLocation["displayTitle"] = location.displayTitle ?? ""
        okLocation["otherInformation"] = location.otherInformation ?? ""
        okLocation["photoUrl"] = location.photo ?? ""
        okLocation["plusCode"] = location.plusCode ?? ""
        okLocation["propertyName"] = location.propertyName ?? ""
        okLocation["propertyNumber"] = location.propertyNumber ?? ""
        okLocation["state"] = location.state ?? ""
        okLocation["streetName"] = location.streetName ?? ""
        okLocation["streetViewPanoId"] = location.streetView?.panoId ?? ""
        okLocation["streetViewPanoUrl"] = location.streetView?.url ?? ""
        okLocation["subtitle"] = location.subtitle ?? ""
        okLocation["title"] = location.title ?? ""
        okLocation["url"] = location.url ?? ""
        okLocation["userId"] = location.userId ?? ""
        okLocation["neighborhood"] = location.neighborhood ?? ""
        okLocation["countryCode"] = location.countryCode ?? ""
        okLocation["usageTypes"] = location.usageTypes ?? ""
        okLocation["ward"] = location.ward ?? ""
        okLocation["formattedAddress"] = location.formattedAddress ?? ""
        okLocation["postCode"] = location.postCode ?? ""
        okLocation["lga"] = location.lga ?? ""
        okLocation["lgaCode"] = location.lgaCode ?? ""
        okLocation["unit"] = location.unit ?? ""
        okLocation["gpsAccuracy"] = location.gpsAccuracy ?? ""
        okLocation["businessName"] = location.businessName ?? ""
        okLocation["type"] = location.type ?? ""
        okLocation["district"] = location.district ?? ""
        okLocation["addressLine"] = location.addressLine ?? ""

        return [
            "type": "success",
            "methodCall": methodCall,
            "user": okUser,
            "location": okLocation
        ]
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
