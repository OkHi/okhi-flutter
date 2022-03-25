#import "OkhiFlutterPlugin.h"
#if __has_include(<okhi_flutter/okhi_flutter-Swift.h>)
#import <okhi_flutter/okhi_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "okhi_flutter-Swift.h"
#endif

@implementation OkhiFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOkhiFlutterPlugin registerWithRegistrar:registrar];
}
@end
