import UIKit
import Flutter
import OkHi

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let okverify = OkVerify()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        OkVerify.startMonitoring()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
