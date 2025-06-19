import UIKit
import IDentitySDK_Swift
import IDCapture_Swift
import SelfieCapture_Swift
import Flutter


var validateIdResult2: ValidateIdResult?                             // 20
var validateIdMatchFaceResult2: ValidateIdMatchFaceResult?           // 10
var customerEnrollResult2: CustomerEnrollResult?                     // 50
var customerEnrollBiometricsResult2: CustomerEnrollBiometricsResult? // 175
var customerVerificationResult2: CustomerVerificationResult?         // 105
var customerIdentifyResult2: CustomerIdentifyResult?                 // 185
var liveFaceCheckResult2: LiveFaceCheckResult?                       // 660

class ViewController: UIViewController {
    var texts: String!
    var result: FlutterResult!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction Methods

    // 20 - ID Validation
    func startIDValidation(result: @escaping FlutterResult, instance: UIViewController) {
        // start ID capture, presenting it from this view controller
        
        let cbs:String = UserDefaults.standard.string(forKey: "captureBack")!
        
        var options = AdditionalCustomerWFlagCommonDataV3()
        options.clientTraceId = UserDefaults.standard.string(forKey: "clientTraceId")
        options.sendProcessedImagesInResponse = .no
        options.sendInputImagesInResponse = .no
        IDentitySDK.idValidation(from: instance, options: options) { result1 in
            switch result1 {
            case .success(let validateIdResult):
                self.emptyResults()
                self.result = result
                validateIdResult2 = validateIdResult
                // pass the API request to the success view controller
                let successViewController = SuccessViewController()
                successViewController.validateIdResult = validateIdResult
                successViewController.frontDetectedData = validateIdResult.front
                successViewController.backDetectedData = validateIdResult.back
                successViewController.result = result
                let navigationController = UINavigationController(rootViewController: successViewController)
                instance.present(navigationController, animated: true)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
      
    }
  
    // 10 - ID Validation and Match Face
    func startIDValidationAndMatchFace(result: @escaping FlutterResult, instance: UIViewController) {
        let cbs:String = UserDefaults.standard.string(forKey: "captureBack")!
                
        var options = AdditionalCustomerWFlagCommonDataV3()
        options.clientTraceId = UserDefaults.standard.string(forKey: "clientTraceId")
        options.sendProcessedImagesInResponse = .yes
        options.sendInputImagesInResponse = .no
        options.idBackImageRequired = .no
        
        IDentitySDK.idValidationAndMatchFace(from: instance, options: options) { result1 in
            switch result1 {
            case .success(let validateIdMatchFaceResult):
                    self.emptyResults()
                    self.result = result
                    validateIdMatchFaceResult2=validateIdMatchFaceResult
                    // pass the API request to the success view controller
                    let successViewController = SuccessViewController()
                    successViewController.validateIdMatchFaceResult = validateIdMatchFaceResult
                    successViewController.frontDetectedData = validateIdMatchFaceResult.front
                    successViewController.backDetectedData = validateIdMatchFaceResult.back
                    successViewController.result = result
                    let navigationController = UINavigationController(rootViewController: successViewController)
                    instance.present(navigationController, animated: true)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
    }

    // 50 - ID Validation And Customer Enroll
    func startIDValidationAndCustomerEnroll(result: @escaping FlutterResult, instance: UIViewController) {
        let personalData = PersonalCustomerCommonRequestEnrollDataV3(uniqueNumber: UserDefaults.standard.string(forKey: "uniqueCustomerNumber") ?? "0")
        var options = AdditionalCustomerWFlagCommonDataV3()
        options.sendProcessedImagesInResponse = .no
        options.sendInputImagesInResponse = .no
          IDentitySDK.idValidationAndCustomerEnroll(from: instance, personalData: personalData, options: options) { result1 in
              switch result1 {
              case .success(var customerEnrollResult):
                      self.emptyResults()
                      self.result = result
                      customerEnrollResult2=customerEnrollResult
                      // pass the API request to the success view controller
                      let successViewController = SuccessViewController()
                      successViewController.customerEnrollResult = customerEnrollResult
                      successViewController.frontDetectedData = customerEnrollResult.front
                      successViewController.backDetectedData = customerEnrollResult.back
                      successViewController.result = result
                  let navigationController = UINavigationController(rootViewController: successViewController)
                      instance.present(navigationController, animated: true, completion: nil)
              case .failure(let error):
                  print(error.localizedDescription)
                  self.sendData(result: result, text: error.localizedDescription)
              }
          }
      }
  
    // 175 - Customer Enroll Biometrics
    func startCustomerEnrollBiometrics(result: @escaping FlutterResult, instance: UIViewController) {
        let personalData = PersonalCustomerCommonRequestDataV3(uniqueNumber: UserDefaults.standard.string(forKey: "uniqueCustomerNumber") ?? "0")
        let options = AdditionalCustomerEnrollBiometricRequestDataV3()
        IDentitySDK.customerEnrollBiometrics(from: instance, personalData: personalData, options: options) { result1 in
            switch result1 {
            case .success(var customerEnrollBiometricsResult):
                    self.emptyResults()
                    self.result = result
                    customerEnrollBiometricsResult2=customerEnrollBiometricsResult
                    // pass the API request to the success view controller
                    let successViewController = SuccessViewController()
                    successViewController.customerEnrollBiometricsResult = customerEnrollBiometricsResult
                    successViewController.result = result
                    let navigationController = UINavigationController(rootViewController: successViewController)
                instance.present(navigationController, animated: true, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
    }

    // 105 - Customer Verification
    func startCustomerVerification(result: @escaping FlutterResult, instance: UIViewController) {
        let personalData = PersonalCustomerVerifyData(uniqueNumber: UserDefaults.standard.string(forKey: "uniqueCustomerNumber") ?? "0")
        IDentitySDK.customerVerification(from: instance, personalData: personalData) { result1 in
            switch result1 {
            case .success(var customerVerificationResult):
                    self.emptyResults()
                    self.result = result
                    customerVerificationResult2=customerVerificationResult
                    // pass the API request to the success view controller
                    let successViewController = SuccessViewController()
                    successViewController.customerVerificationResult = customerVerificationResult
                    successViewController.result = result
                    let navigationController = UINavigationController(rootViewController: successViewController)
                instance.present(navigationController, animated: true, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
    }

    // 185 - Identify Customer
    func startIdentifyCustomer(result: @escaping FlutterResult, instance: UIViewController) {
        IDentitySDK.identifyCustomer(from: instance) { result1 in
            switch result1 {
            case .success(let customerIdentifyResult):
                    self.emptyResults()
                    self.result = result
                    customerIdentifyResult2=customerIdentifyResult
                    // pass the API request to the success view controller
                    let successViewController = SuccessViewController()
                    successViewController.customerIdentifyResult = customerIdentifyResult
                    successViewController.result = result
                    let navigationController = UINavigationController(rootViewController: successViewController)
                instance.present(navigationController, animated: true, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
    }

    // 660 - Live Face Check
    func startLiveFaceCheck(result: @escaping FlutterResult, instance: UIViewController) {
        // start selfie capture, presenting it from this view controller
        IDentitySDK.liveFaceCheck(from: instance) { result1 in
            switch result1 {
            case .success(let liveFaceCheckResult):
                    self.emptyResults()
                    self.result = result
                    liveFaceCheckResult2=liveFaceCheckResult
                    // pass the API request to the success view controller
                    let successViewController = SuccessViewController()
                    successViewController.liveFaceCheckResult = liveFaceCheckResult
                    successViewController.result = result
                    let navigationController = UINavigationController(rootViewController: successViewController)
                instance.present(navigationController, animated: true, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
                self.sendData(result: result, text: error.localizedDescription)
            }
        }
    }

    func submitResult(result: @escaping FlutterResult, instance: UIViewController) {
      self.result = result
      submit()
    }

    @objc func submit() {
        if let validateIdResult = validateIdResult2 {
            validateIdResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                validateIdResult2 = nil
                switch result {
                case .success(let response):
                    var hostDataString = ""
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                        self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let validateIdMatchFaceResult = validateIdMatchFaceResult2 {
            validateIdMatchFaceResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                validateIdMatchFaceResult2 = nil
                switch result {
                case .success(let response):
                    var hostDataString = ""
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                      self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let customerEnrollResult = customerEnrollResult2 {
            customerEnrollResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                customerEnrollResult2 = nil
                switch result {
                case .success(let response):
                    var hostDataString = ""
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                      self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let customerEnrollBiometricsResult = customerEnrollBiometricsResult2 {
            customerEnrollBiometricsResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                customerEnrollBiometricsResult2 = nil
                switch result {
                case .success(let response):
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                        self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let customerVerificationResult = customerVerificationResult2 {
            customerVerificationResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                customerVerificationResult2 = nil
                switch result {
                case .success(var response):
                    // stub out the base64 image text for logging
                    response.responseCustomerVerifyData?.extractedPersonalData?.enrolledFaceImage = "..."

                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                        self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let customerIdentifyResult = customerIdentifyResult2 {
            customerIdentifyResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                customerIdentifyResult2 = nil
                switch result {
                case .success(var response):
                    // stub out the base64 image text for logging
                    response.responseCustomerData?.extractedPersonalData?.enrolledFaceImage = "..."

                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                        self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        } else if let liveFaceCheckResult = liveFaceCheckResult2 {
            liveFaceCheckResult.submit { result in
                self.navigationItem.leftBarButtonItem = nil
                liveFaceCheckResult2 = nil
                switch result {
                case .success(let response):
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    if let data = try? encoder.encode(response), let json = String(data: data, encoding: .utf8) {
                        self.texts = json
                    }
                    self.sendData()
                case .failure(let error):
                    self.texts = error.localizedDescription
                    self.sendData()
                }
            }
        }
    }
    
    private func sendData() {
      let dict2:NSMutableDictionary? = ["data" : self.texts ?? ["data" : "error"]]
        print("sendData", self.texts)
        result(self.texts ?? "error")
    }
    
    private func sendData(result: @escaping FlutterResult, text: String) {
      let dict2:NSMutableDictionary? = ["data" : text ]
        result(text)
    }
    
    func emptyResults(){
      validateIdResult2 = nil
      validateIdMatchFaceResult2 = nil
      customerEnrollResult2 = nil
      customerEnrollBiometricsResult2 = nil
      customerVerificationResult2 = nil
      customerIdentifyResult2 = nil
      liveFaceCheckResult2 = nil
    }
}
