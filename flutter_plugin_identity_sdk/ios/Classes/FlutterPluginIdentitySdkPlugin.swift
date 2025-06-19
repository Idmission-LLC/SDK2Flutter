import Flutter
import UIKit
import IDentitySDK_Swift

public class FlutterPluginIdentitySdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_plugin_identity_sdk", binaryMessenger: registrar.messenger())
    let instance = FlutterPluginIdentitySdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "idm_sdk_init":
        
        if let args = call.arguments as? Dictionary<String, Any>,
          let apiBaseUrl = args["apiBaseUrl"] as? String,
          let debug = args["debug"] as? String,
          let accessToken = args["accessToken"] as? String {
            
          UserDefaults.standard.set(String(apiBaseUrl), forKey: "apiBaseUrl")
          UserDefaults.standard.set(String(accessToken), forKey: "accessToken")
            
            IDCapture.options.enableRealId = false
      
            if(debug.contains("y")){
                IDCapture.options.isDebugMode = true
                SelfieCapture.options.isDebugMode = true
                DocumentCapture.options.isDebugMode = true
            }else{
                IDCapture.options.isDebugMode = false
                SelfieCapture.options.isDebugMode = false
                DocumentCapture.options.isDebugMode = false
            }
        }
      
        IDentitySDKHelper().initializeSDK(result: result)
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
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startIDValidations(result: result, instance: vc);
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
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startIDValidationAndMatchFaces(result: result, instance: vc);
            }
        }
    case "idm_sdk_serviceID50":
        if let args = call.arguments as? Dictionary<String, Any>,
          let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
          UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
        } else {
          UserDefaults.standard.set("0", forKey: "uniqueCustomerNumber")
        }
        
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startIDValidationAndCustomerEnrolls(result: result, instance: vc);
            }
        }
    case "idm_sdk_serviceID175":
        if let args = call.arguments as? Dictionary<String, Any>,
          let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
          UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
        } else {
          UserDefaults.standard.set("0", forKey: "uniqueCustomerNumber")
        }
        
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startCustomerEnrollBiometricss(result: result, instance: vc);
            }
        }
    case "idm_sdk_serviceID105":
        if let args = call.arguments as? Dictionary<String, Any>,
          let uniqueCustomerNumber = args["uniqueCustomerNumber"] as? Int {
          UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
        } else {
          UserDefaults.standard.set("0", forKey: "uniqueCustomerNumber")
        }
        
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startCustomerVerifications(result: result, instance: vc);
            }
        }
    case "idm_sdk_serviceID185":
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startIdentifyCustomers(result: result, instance: vc);
            }
        }
    case "idm_sdk_serviceID660":
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().startLiveFaceChecks(result: result, instance: vc);
            }
        }
    case "submit_result":
        DispatchQueue.main.async {
            print("ssss")
            if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                IDentitySDKHelper().submitResult(result: result, instance: vc);
            }
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    
    public func sendResponseTo(result: @escaping FlutterResult, resultString: String) {
        result(resultString)
    }
    
}
