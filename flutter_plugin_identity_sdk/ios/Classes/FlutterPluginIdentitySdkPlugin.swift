import Flutter
import UIKit
import IDentityMediumSDK
import SelfieCaptureMedium
import IDCaptureMedium

public class FlutterPluginIdentitySdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_plugin_identity_sdk", binaryMessenger: registrar.messenger())
    let instance = FlutterPluginIdentitySdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSDKInfo":
      result(IDentitySDKHelper.sdkInfo())
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "idm_sdk_init":
        IDCapture.options.enableInstructionScreen = false
        SelfieCapture.options.enableInstructionScreen = false

        guard let args = call.arguments as? [String: Any],
              let apiBaseUrl = args["apiBaseUrl"] as? String,
              let accessToken = args["accessToken"] as? String else {
            result("Error")
            return
        }
        let debug = (args["debug"] as? String ?? "").contains("y")
        IDCapture.options.isDebugMode = debug
        SelfieCapture.options.isDebugMode = debug
        DocumentCapture.options.isDebugMode = debug

        // Unknown or missing languages fall back to English.
        let language = Language(rawValue: (args["language"] as? String ?? "en").lowercased()) ?? .en
        IDentitySDKHelper().initializeSDK(
            result: result,
            apiBaseUrl: apiBaseUrl,
            accessToken: accessToken,
            language: language == .none ? .en : language,
            isGPSEnabled: args["enableGPS"] as? Bool ?? true,
            geolocationRequired: args["geolocationRequired"] as? Bool ?? false,
            isUpdateModelsData: args["isUpdateModelsData"] as? Bool ?? true,
            isScreenRecordingEnabled: args["enableScreenRecording"] as? Bool ?? false)
    case "idm_sdk_serviceID20":
        if let args = call.arguments as? Dictionary<String, Any>,
          let clientTraceId = args["clientTraceId"] as? Int {
          UserDefaults.standard.set(String(clientTraceId), forKey: "clientTraceId")
        } else {
          UserDefaults.standard.set("0", forKey: "clientTraceId")
        }
        
        if let args = call.arguments as? Dictionary<String, Any>,
          let captureBack = args["captureBack"] as? String {
          UserDefaults.standard.set(String(captureBack), forKey: "captureBack")
        } else {
          UserDefaults.standard.set("auto", forKey: "captureBack")
        }
        
        DispatchQueue.main.async {
            if let vc = Self.flutterViewController() {
                IDentitySDKHelper().startIDValidations(result: result, instance: vc);
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
            }
        }
    case "idm_sdk_serviceID10":
        if let args = call.arguments as? Dictionary<String, Any>,
          let clientTraceId = args["clientTraceId"] as? Int {
          UserDefaults.standard.set(String(clientTraceId), forKey: "clientTraceId")
        } else {
          UserDefaults.standard.set("0", forKey: "clientTraceId")
        }
        
        if let args = call.arguments as? Dictionary<String, Any>,
          let captureBack = args["captureBack"] as? String {
          UserDefaults.standard.set(String(captureBack), forKey: "captureBack")
        } else {
          UserDefaults.standard.set("auto", forKey: "captureBack")
        }
        
        DispatchQueue.main.async {
            if let vc = Self.flutterViewController() {
                IDentitySDKHelper().startIDValidationAndMatchFaces(result: result, instance: vc);
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
            }
        }
    case "idm_sdk_serviceID50":
        if let args = call.arguments as? Dictionary<String, Any>,
          let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
            
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                  
                  DispatchQueue.main.async {
                      if let vc = Self.flutterViewController() {
                          IDentitySDKHelper().startIDValidationAndCustomerEnrolls(result: result, instance: vc);
                      } else {
                          result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
                      }
                  }
            } else {
                result("Unique custome number is required")
            }
            
          
        } else {
            result("Unique custome number is required")
        }
        
        
    case "idm_sdk_serviceID175":
        if let args = call.arguments as? Dictionary<String, Any>,
          let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
            
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                  
                  DispatchQueue.main.async {
                      if let vc = Self.flutterViewController() {
                          IDentitySDKHelper().startCustomerEnrollBiometricss(result: result, instance: vc);
                      } else {
                          result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
                      }
                  }
            } else {
                result("Unique custome number is required")
            }
            
          
        } else {
            result("Unique custome number is required")
        }
        
        
    case "idm_sdk_serviceID105":
        if let args = call.arguments as? Dictionary<String, Any>,
           let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
            
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                
                DispatchQueue.main.async {
                    if let vc = Self.flutterViewController() {
                        IDentitySDKHelper().startCustomerVerifications(result: result, instance: vc);
                    } else {
                        result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
                    }
                }
            } else {
                result("Unique custome number is required")
            }
            
            
        } else {
            result("Unique custome number is required")
        }
        
    case "idm_sdk_serviceID185":
        DispatchQueue.main.async {
            if let vc = Self.flutterViewController() {
                IDentitySDKHelper().startIdentifyCustomers(result: result, instance: vc);
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
            }
        }
    case "idm_sdk_serviceID660":
        DispatchQueue.main.async {
            if let vc = Self.flutterViewController() {
                IDentitySDKHelper().startLiveFaceChecks(result: result, instance: vc);
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
            }
        }
    case "submit_result":
        DispatchQueue.main.async {
            if let vc = Self.flutterViewController() {
                IDentitySDKHelper().submitResult(result: result, instance: vc);
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Flutter root view controller not found", details: nil))
            }
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
    // The root view controller is found through the connected window scenes:
    // with the UIScene lifecycle, `UIApplication.delegate.window` is nil.
    static func flutterViewController() -> FlutterViewController? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        let root = windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? windows.first?.rootViewController
            ?? UIApplication.shared.delegate?.window??.rootViewController
        return root as? FlutterViewController
    }

}
