import Foundation
import IDentityMediumSDK
import SelfieCaptureMedium
import IDCaptureMedium
import Flutter

class IDentitySDKHelper : NSObject{

    // SDK version plus the ML model file names in use. Model names are empty
    // until the SDK has been initialized (models are downloaded on init).
    static func sdkInfo() -> [String: Any] {
        let models: [(String, String)] = [
            ("Face Detector", IDentitySDK.faceDetectorModelName),
            ("Face Landmarks", IDentitySDK.faceLandmarkModelName),
            ("Face BlendedShapes", IDentitySDK.faceBlendedShapesModelName),
            ("Liveness", IDentitySDK.livenessModelName),
            ("Focus Face", IDentitySDK.focusFaceModelName),
            ("Face Mask", IDentitySDK.faceMaskModelName),
            ("Focus", IDentitySDK.focusModelName),
            ("Doc Realness", IDentitySDK.docRealnessModelName),
            ("Doc Detection", IDentitySDK.docDetectionModelName),
            ("PaddleOCR Detection", IDentitySDK.paddleOCRDetectionModelName),
            ("PaddleOCR Recognition", IDentitySDK.paddleOCRRecognitionModelName),
        ]
        return [
            "version": IDentitySDK.version,
            "models": models
                .filter { !$0.1.isEmpty }
                .map { ["name": $0.0, "value": $0.1] },
        ]
    }

    func initializeSDK(result: @escaping FlutterResult,
                       apiBaseUrl: String,
                       accessToken: String,
                       language: Language = .en,
                       isGPSEnabled: Bool = true,
                       geolocationRequired: Bool = false,
                       isUpdateModelsData: Bool = true,
                       isScreenRecordingEnabled: Bool = false) {
        print(IDentitySDK.version)

        IDentitySDK.apiBaseUrl = apiBaseUrl
        IDentitySDK.isScreenRecordingEnabled(isScreenRecordingEnabled)
        IDentitySDK.initializeSDK(language: language, isGPSEnabled: isGPSEnabled, geolocationRequired: geolocationRequired, isUpdateModelsData: isUpdateModelsData, accessToken: accessToken) { error in
            if let error = error {
                print("!!! initialize SDK ERROR: \(error.localizedDescription)")
                result("Error")
            } else {
                print("!!! initialize SDK SUCCESS")
                result("SDK successfully initialized")
            }
        }
         
        }
        
  // 20 - ID Validation
  func startIDValidations(result: @escaping FlutterResult, instance: UIViewController) {
       ViewController().startIDValidation(result: result, instance: instance);
  }
 
  // 10 - ID Validation and Match Face
  func startIDValidationAndMatchFaces(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startIDValidationAndMatchFace(result: result, instance: instance);
  }
  
  // 50 - ID Validation And Customer Enroll
  func startIDValidationAndCustomerEnrolls(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startIDValidationAndCustomerEnroll(result: result, instance: instance);
  }
  
  // 175 - Customer Enroll Biometrics
  func startCustomerEnrollBiometricss(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startCustomerEnrollBiometrics(result: result, instance: instance);
  }
  
  // 105 - Customer Verification
  func startCustomerVerifications(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startCustomerVerification(result: result, instance: instance);
  }
  
  // 185 - Identify Customer
    func startIdentifyCustomers(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().startIdentifyCustomer(result: result, instance: instance);
  }
  
  // 660 - Live Face Check
    func startLiveFaceChecks(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().startLiveFaceCheck(result: result, instance: instance);
  }
    
    func submitResult(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().submitResult(result: result, instance: instance);
   }
}
