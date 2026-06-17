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
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "idm_sdk_init":
        
        IDCapture.options.enableInstructionScreen = false
        SelfieCapture.options.enableInstructionScreen = false

        if let args = call.arguments as? Dictionary<String, Any>,
          let apiBaseUrl = args["apiBaseUrl"] as? String,
          let debug = args["debug"] as? String,
          let accessToken = args["accessToken"] as? String {
            
          UserDefaults.standard.set(String(apiBaseUrl), forKey: "apiBaseUrl")
          UserDefaults.standard.set(String(accessToken), forKey: "accessToken")
            
            if(debug.contains("y")){
                IDCapture.options.isDebugMode = true
                SelfieCapture.options.isDebugMode = true
                DocumentCapture.options.isDebugMode = true
            }else{
                IDCapture.options.isDebugMode = false
                SelfieCapture.options.isDebugMode = false
                DocumentCapture.options.isDebugMode = false
            }
            
            var authUrl = "https://auth.idmission.com/"

            if apiBaseUrl.contains("lab") {
                  authUrl = "https://labauth.idmission.com:9043/"
            } else if apiBaseUrl.contains("demo") {
                  authUrl = "https://demoauth.idmission.com/"
            } else if apiBaseUrl.contains("uat") {
                  authUrl = "https://uatauth.idmission.com/"
            } else if apiBaseUrl.contains("kyc") {
                  authUrl = "https://auth.idmission.com/"
            }

            //API Auth URL
            let defaultAuthUrl = "\(authUrl)auth/realms/identity/protocol/openid-connect/token"
            UserDefaults.standard.set(defaultAuthUrl, forKey: "authenticationURL")
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
            
            print("uniqueCustomerNumber ",uniqueCustomerNumber)
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                  
                  DispatchQueue.main.async {
                      if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                          IDentitySDKHelper().startIDValidationAndCustomerEnrolls(result: result, instance: vc);
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
            
            print("uniqueCustomerNumber ",uniqueCustomerNumber)
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                  
                  DispatchQueue.main.async {
                      if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                          IDentitySDKHelper().startCustomerEnrollBiometricss(result: result, instance: vc);
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
            
            print("uniqueCustomerNumber ",uniqueCustomerNumber)
            
            if(uniqueCustomerNumber>0){
                UserDefaults.standard.set(String(uniqueCustomerNumber), forKey: "uniqueCustomerNumber")
                
                DispatchQueue.main.async {
                    if let vc = UIApplication.shared.delegate?.window??.rootViewController  as? FlutterViewController {
                        IDentitySDKHelper().startCustomerVerifications(result: result, instance: vc);
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
