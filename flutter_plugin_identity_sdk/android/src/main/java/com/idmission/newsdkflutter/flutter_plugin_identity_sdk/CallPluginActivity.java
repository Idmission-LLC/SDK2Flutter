package com.idmission.newsdkflutter.flutter_plugin_identity_sdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.idmission.sdk2.capture.IdMissionCaptureLauncher;
import com.idmission.sdk2.capture.presentation.camera.helpers.CaptureBack;
import com.idmission.sdk2.capture.presentation.camera.helpers.ProcessedCapture;
import com.idmission.sdk2.identityproofing.IdentityProofingSDK;
import android.os.Parcelable;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;

public class CallPluginActivity extends Activity {

    private List<ProcessedCapture> processedCaptures = new ArrayList<>();
    public static String result;
    private IdMissionCaptureLauncher launcher = new IdMissionCaptureLauncher();
    boolean resultDisplayed = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        int serviceID = getIntent().getIntExtra("serviceID", 20);

        if(serviceID==20){
            try {
                IdentityProofingSDK.idValidation(this, CaptureBack.AUTO);
            } catch (Exception e) {
                result = "SDK is not initialized. Please ensure initialization is completed before use.";
                FlutterPluginIdentitySdkPlugin.sendResponse();
                finish();
            }
        }else if(serviceID==10){
            try {
                IdentityProofingSDK.idValidationAndMatchFace(this, CaptureBack.AUTO);
            } catch (Exception e) {
                result = "SDK is not initialized. Please ensure initialization is completed before use.";
                FlutterPluginIdentitySdkPlugin.sendResponse();
                finish();
            }
        }else if(serviceID==185){
            try {
                IdentityProofingSDK.identifyCustomer(this);
            } catch (Exception e) {
                result = "SDK is not initialized. Please ensure initialization is completed before use.";
                FlutterPluginIdentitySdkPlugin.sendResponse();
                finish();
            }
        }else if(serviceID==660){
            try {
                IdentityProofingSDK.liveFaceCheck(this);
            } catch (Exception e) {
                result = "SDK is not initialized. Please ensure initialization is completed before use.";
                FlutterPluginIdentitySdkPlugin.sendResponse();
                finish();
            }
        }else if(serviceID==50){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
                try {
                    if(uniqueCustomerNumber>0){
                        IdentityProofingSDK.idValidationAndcustomerEnroll(CallPluginActivity.this, uniqueCustomerNumber+"");
                    }else{
                        result = "Unique customer number is required.";
                        FlutterPluginIdentitySdkPlugin.sendResponse();
                        finish();
                    }
                } catch (Exception e) {
                    result = "SDK is not initialized. Please ensure initialization is completed before use.";
                    FlutterPluginIdentitySdkPlugin.sendResponse();
                    finish();
                }
        }else if(serviceID==175){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
                try {
                    if(uniqueCustomerNumber>0){
                        IdentityProofingSDK.customerEnrollBiometrics(CallPluginActivity.this, uniqueCustomerNumber+"");
                    }else{
                        result = "Unique customer number is required.";
                        FlutterPluginIdentitySdkPlugin.sendResponse();
                        finish();
                    }
                } catch (Exception e) {
                    result = "SDK is not initialized. Please ensure initialization is completed before use.";
                    FlutterPluginIdentitySdkPlugin.sendResponse();
                    finish();
                }
        }else if(serviceID==105){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
                    try {
                        if(uniqueCustomerNumber>0){
                            IdentityProofingSDK.customerVerification(CallPluginActivity.this, uniqueCustomerNumber+"");
                        }else{
                            result = "Unique customer number is required.";
                            FlutterPluginIdentitySdkPlugin.sendResponse();
                            finish();
                        }
                    } catch (Exception e) {
                        result = "SDK is not initialized. Please ensure initialization is completed before use.";
                        FlutterPluginIdentitySdkPlugin.sendResponse();
                        finish();
                    }
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        FlutterPluginIdentitySdkPlugin.sendResponse();
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (data != null) {
            if (requestCode == IdMissionCaptureLauncher.CAPTURE_REQUEST_CODE) {
                try{
                    Parcelable[] processedCaptures = data.getExtras().getParcelableArray(IdMissionCaptureLauncher.EXTRA_PROCESSED_CAPTURES);

                    JSONObject jo = new JSONObject();

                    for (Parcelable pc : processedCaptures)
                    {
                        if (pc instanceof ProcessedCapture.DocumentDetectionResult.RealDocument) {
                            try {
                                ProcessedCapture.DocumentDetectionResult.RealDocument rd = (ProcessedCapture.DocumentDetectionResult.RealDocument) pc;

                                JSONObject realDocumentData = new JSONObject();
                                realDocumentData.put("barcodeMap",rd.getBarcodeMap());
                                realDocumentData.put("barcodeString",rd.getBarcodeString());
                                realDocumentData.put("mrzMap",rd.getMrzMap());
                                realDocumentData.put("confidenceScore",rd.getConfidenceScore());
                                realDocumentData.put("detectedRect",rd.getDetectedRect());
                                realDocumentData.put("faceMatch",rd.getFaceMatch());
                                realDocumentData.put("faceOnId",rd.getFaceOnId());
                                realDocumentData.put("file",rd.getFile());
                                realDocumentData.put("mrzString",rd.getMrzString());
                                realDocumentData.put("ocrString",rd.getOcrString());
                                realDocumentData.put("operation",rd.getOperation());
                                realDocumentData.put("realnessScore",rd.getRealnessScore());
                                realDocumentData.put("timeDetectedAt",rd.getTimeDetectedAt());
                                realDocumentData.put("timeFinishedAt",rd.getTimeFinishedAt());
                                realDocumentData.put("timeStartedAt",rd.getTimeStartedAt());
                                realDocumentData.put("timeWithinBoundsAt",rd.getTimeWithinBoundsAt());
                                realDocumentData.put("modelName",rd.getModelName());

                                if(jo.toString().contains("realDocument")){
                                    jo.put("realDocument"+"_1",realDocumentData);
                                }else{
                                    jo.put("realDocument",realDocumentData);
                                }
                            }catch(Exception e){}
                        }else if (pc instanceof ProcessedCapture.DocumentDetectionResult.SpoofDocument) {
                            try {
                                ProcessedCapture.DocumentDetectionResult.SpoofDocument sd = (ProcessedCapture.DocumentDetectionResult.SpoofDocument) pc;

                                JSONObject spoofDocumentData = new JSONObject();
                                spoofDocumentData.put("confidenceScore",sd.getConfidenceScore());
                                spoofDocumentData.put("detectedRect",sd.getDetectedRect());
                                spoofDocumentData.put("operation",sd.getOperation());
                                spoofDocumentData.put("realnessScore",sd.getRealnessScore());
                                spoofDocumentData.put("timeDetectedAt",sd.getTimeDetectedAt());
                                spoofDocumentData.put("timeFinishedAt",sd.getTimeFinishedAt());
                                spoofDocumentData.put("timeStartedAt",sd.getTimeStartedAt());
                                spoofDocumentData.put("timeWithinBoundsAt",sd.getTimeWithinBoundsAt());
                                spoofDocumentData.put("modelName",sd.getModelName());

                                jo.put("spoofDocument",spoofDocumentData);
                            }catch(Exception e){}
                        }else if (pc instanceof ProcessedCapture.LiveFaceDetectionResult.RealFace) {
                            try {
                                ProcessedCapture.LiveFaceDetectionResult.RealFace rf = (ProcessedCapture.LiveFaceDetectionResult.RealFace) pc;

                                JSONObject realFaceData = new JSONObject();
                                realFaceData.put("detectedRect",rf.getDetectedRect());
                                realFaceData.put("operation",rf.getOperation());
                                realFaceData.put("timeDetectedAt",rf.getTimeDetectedAt());
                                realFaceData.put("timeFinishedAt",rf.getTimeFinishedAt());
                                realFaceData.put("timeStartedAt",rf.getTimeStartedAt());
                                realFaceData.put("timeWithinBoundsAt",rf.getTimeWithinBoundsAt());
                                realFaceData.put("faceMatch",rf.getFaceMatch());
                                realFaceData.put("file",rf.getFile());
                                realFaceData.put("livenessScore",rf.getLivenessScore());

                                jo.put("realFace",realFaceData);
                            }catch(Exception e){}
                        }else if (pc instanceof ProcessedCapture.LiveFaceDetectionResult.SpoofFace) {
                            try {
                                ProcessedCapture.LiveFaceDetectionResult.SpoofFace sf = (ProcessedCapture.LiveFaceDetectionResult.SpoofFace) pc;

                                JSONObject spoofFaceData = new JSONObject();
                                spoofFaceData.put("detectedRect",sf.getDetectedRect());
                                spoofFaceData.put("operation",sf.getOperation());
                                spoofFaceData.put("timeDetectedAt",sf.getTimeDetectedAt());
                                spoofFaceData.put("timeFinishedAt",sf.getTimeFinishedAt());
                                spoofFaceData.put("timeStartedAt",sf.getTimeStartedAt());
                                spoofFaceData.put("timeWithinBoundsAt",sf.getTimeWithinBoundsAt());
                                spoofFaceData.put("livenessScore",sf.getLivenessScore());

                                jo.put("spoofFace",spoofFaceData);
                            }catch(Exception e){}
                        }
                    }

                    result = jo.toString();
                    FlutterPluginIdentitySdkPlugin.sendResponse();
                }catch(Exception e){
                    e.printStackTrace();
                }
            }else{
                    result = "Error";
                    FlutterPluginIdentitySdkPlugin.sendResponse();
            }
        }else if(resultCode == RESULT_CANCELED) {
            result = "The operation was cancelled by the user.";
            FlutterPluginIdentitySdkPlugin.sendResponse();
        }else{
            result = "Error";
            FlutterPluginIdentitySdkPlugin.sendResponse();
        }
        onBackPressed();
    }

}

