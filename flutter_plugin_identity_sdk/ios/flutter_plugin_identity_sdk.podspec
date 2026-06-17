#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_plugin_identity_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_plugin_identity_sdk'
  s.version          = '11.1.7'
  s.summary          = 'IDmission Identity Flutter Plugin for iOS.'
  s.description      = <<-DESC
Flutter plugin wrapping the IDmission Identity SDK (IDentityMediumSDK2.0 11.1.7.2.4).
Provides identity verification, document capture, face match, and biometric enrollment.
                       DESC
  s.homepage         = 'https://github.com/Idmission-LLC/SDK2Flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'IDmission' => 'support@idmission.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'IDentityMediumSDK2.0'
  s.dependency 'IDentityMediumModels'
  s.dependency 'TensorFlowLiteSwift'
  s.dependency 'GoogleMLKit/TextRecognition'
  s.dependency 'GoogleMLKit/FaceDetection'
  s.dependency 'GoogleMLKit/ImageLabeling'
  s.dependency 'OpenSSL-Universal'
  s.dependency 'GZIP'
  s.platform = :ios, '13.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
