import UIKit
import IDentityMediumSDK
import SelfieCaptureMedium
import IDCaptureMedium
import Flutter

class SuccessViewController: UIViewController {
    var validateIdResult: ValidateIdResult?                             // 20
    var validateIdMatchFaceResult: ValidateIdMatchFaceResult?           // 10
    var customerEnrollResult: CustomerEnrollResult?                     // 50
    var customerEnrollBiometricsResult: CustomerEnrollBiometricsResult? // 175
    var customerVerificationResult: CustomerVerificationResult?         // 105
    var customerIdentifyResult: CustomerIdentifyResult?                 // 185
    var liveFaceCheckResult: LiveFaceCheckResult?                       // 660

    var frontDetectedData: DetectedData?
    var backDetectedData: DetectedData?

    var texts: String!
    var result: FlutterResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Return the result object exactly as the SDK returned it (as JSON), not the
        // API request.
        if let r = validateIdResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = validateIdMatchFaceResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = customerEnrollResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = customerEnrollBiometricsResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = customerVerificationResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = customerIdentifyResult {
            texts = CaptureResultSerializer.text(of: r)
        } else if let r = liveFaceCheckResult {
            texts = CaptureResultSerializer.text(of: r)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
      self.sendData()
      self.dismiss()
    }
  
    private func sendData() {
        result(self.texts ?? "error")
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
