import Foundation
import IDentityMediumSDK
import SelfieCaptureMedium
import IDCaptureMedium
import Flutter

class IDentitySDKHelper : NSObject{
  
    @IBAction func initializeSDK(result: @escaping FlutterResult){
        print("initializeSDK")
        print(IDentitySDK.version)
        
        IDentitySDK.apiBaseUrl = UserDefaults.apiBaseURL
        IDentitySDK.initializeSDK(language: UserDefaults.SDKlanguage, isUpdateModelsData: UserDefaults.isUpdateModelData, accessToken: UserDefaults.accessToken) { error in
            if let error = error {
                print("!!! initialize SDK ERROR: \(error.localizedDescription)")
            } else {
                print("!!! initialize SDK SUCCESS")
                result("SDK successfully initialized")
            }
        }
  }
        
  // 20 - ID Validation
  @IBAction func startIDValidations(result: @escaping FlutterResult, instance: UIViewController) {
       ViewController().startIDValidation(result: result, instance: instance);
  }
 
  // 10 - ID Validation and Match Face
  @IBAction func startIDValidationAndMatchFaces(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startIDValidationAndMatchFace(result: result, instance: instance);
  }
  
  // 50 - ID Validation And Customer Enroll
  @IBAction func startIDValidationAndCustomerEnrolls(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startIDValidationAndCustomerEnroll(result: result, instance: instance);
  }
  
  // 175 - Customer Enroll Biometrics
  @IBAction func startCustomerEnrollBiometricss(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startCustomerEnrollBiometrics(result: result, instance: instance);
  }
  
  // 105 - Customer Verification
  @IBAction func startCustomerVerifications(result: @escaping FlutterResult, instance: UIViewController) {
    ViewController().startCustomerVerification(result: result, instance: instance);
  }
  
  // 185 - Identify Customer
    @IBAction func startIdentifyCustomers(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().startIdentifyCustomer(result: result, instance: instance);
  }
  
  // 660 - Live Face Check
    @IBAction func startLiveFaceChecks(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().startLiveFaceCheck(result: result, instance: instance);
  }
    
    @IBAction func submitResult(result: @escaping FlutterResult, instance: UIViewController) {
        ViewController().submitResult(result: result, instance: instance);
   }
}
