#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint okhi_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'okhi_flutter'
  s.version          = '2.0.4'
  s.summary          = 'The OkHi Flutter library enables you to collect and verify your user addresses.'
  s.description      = <<-DESC
The official OkHi Flutter plugin for collecting and verifying user addresses on iOS and Android.
                       DESC
  s.homepage         = 'https://docs.okhi.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OkHi' => 'tech@okhi.co' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'OkHi', '1.10.18'
end
