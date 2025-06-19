package com.idmission.newsdkflutter.flutter_plugin_identity_sdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.idmission.sdk2.capture.IdMissionCaptureLauncher;
import com.idmission.sdk2.capture.presentation.camera.helpers.CaptureBack;
import com.idmission.sdk2.capture.presentation.camera.helpers.ProcessedCapture;
import com.idmission.sdk2.client.model.AdditionalCustomerFlagData;
import com.idmission.sdk2.client.model.BypassAgeValidation;
import com.idmission.sdk2.client.model.BypassNameMatching;
import com.idmission.sdk2.client.model.CameraFacing;
import com.idmission.sdk2.client.model.CameraOrientation;
import com.idmission.sdk2.client.model.DeDupDataRequiredInResponse;
import com.idmission.sdk2.client.model.DeDuplicationRequired;
import com.idmission.sdk2.client.model.DeduplicationSynchronous;
import com.idmission.sdk2.client.model.DocumentCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.IDCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.IDCaptureOptions;
import com.idmission.sdk2.client.model.IDColorOptions;
import com.idmission.sdk2.client.model.IDFontOptions;
import com.idmission.sdk2.client.model.IDImageOptions;
import com.idmission.sdk2.client.model.IDImageResolutionCheck;
import com.idmission.sdk2.client.model.IDLayoutOptions;
import com.idmission.sdk2.client.model.IDStringOptions;
import com.idmission.sdk2.client.model.IdBackImageRequired;
import com.idmission.sdk2.client.model.ManualReviewRequired;
import com.idmission.sdk2.client.model.NeedImmediateResponse;
import com.idmission.sdk2.client.model.PostDataAPIRequired;
import com.idmission.sdk2.client.model.PostDataOnReviewRequired;
import com.idmission.sdk2.client.model.SDKCustomizationOptions;
import com.idmission.sdk2.client.model.SelfieCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.SendInputImagesInPost;
import com.idmission.sdk2.client.model.SendInputImagesInResponse;
import com.idmission.sdk2.client.model.SendProcessedImagesInPost;
import com.idmission.sdk2.client.model.SendProcessedImagesInResponse;
import com.idmission.sdk2.client.model.SignatureCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.StripSpecialCharacter;
import com.idmission.sdk2.client.model.VerifyDataWithHost;
import com.idmission.sdk2.client.model.VideoIdCaptureCustomizationOptions;
import com.idmission.sdk2.identityproofing.IdentityProofingSDK;
import android.os.Parcelable;
import android.util.Base64;
import android.util.Base64OutputStream;
import android.util.Log;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
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
            int clientTraceId = getIntent().getIntExtra("clientTraceId",0);
            AdditionalCustomerFlagData acfd = new AdditionalCustomerFlagData(clientTraceId+"");
            IdentityProofingSDK.INSTANCE.idValidation(CallPluginActivity.this);
        }else if(serviceID==10){
            int clientTraceId = getIntent().getIntExtra("clientTraceId",0);
            AdditionalCustomerFlagData acfd = new AdditionalCustomerFlagData(clientTraceId+"");
            IdentityProofingSDK.INSTANCE.idValidationAndMatchFace(CallPluginActivity.this);
        }else if(serviceID==185){
            IdentityProofingSDK.INSTANCE.identifyCustomer(CallPluginActivity.this);
        }else if(serviceID==660){
            IdentityProofingSDK.INSTANCE.liveFaceCheck(CallPluginActivity.this);
        }else if(serviceID==50){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
            IdentityProofingSDK.INSTANCE.idValidationAndcustomerEnroll(CallPluginActivity.this, uniqueCustomerNumber+"");
        }else if(serviceID==175){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
            IdentityProofingSDK.INSTANCE.customerEnrollBiometrics(CallPluginActivity.this, uniqueCustomerNumber+"");
        }else if(serviceID==105){
            int uniqueCustomerNumber = getIntent().getIntExtra("uniqueCustomerNumber",0);
            IdentityProofingSDK.INSTANCE.customerVerification(CallPluginActivity.this, uniqueCustomerNumber+"");
        }

    }

    CaptureBack getCaptureBackValue(String s){
        if(s.contains("y")){
            return CaptureBack.YES;
        }else if(s.contains("n")){
            return CaptureBack.NO;
        }else{
            return CaptureBack.AUTO;
        }
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
                                realDocumentData.put("file",getStringFile(rd.getFile()));
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
                                realFaceData.put("file",getStringFile(rf.getFile()));
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
            }
        }
        onBackPressed();
    }

    // Converting File to Base64.encode String type using Method
    public String getStringFile(File f) {
        InputStream inputStream = null;
        String encodedFile= "", lastVal;
        try {
            inputStream = new FileInputStream(f.getAbsolutePath());

            byte[] buffer = new byte[10240];//specify the size to allow
            int bytesRead;
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            Base64OutputStream output64 = new Base64OutputStream(output, Base64.DEFAULT);

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                output64.write(buffer, 0, bytesRead);
            }
            output64.close();
            encodedFile =  output.toString();
        }
        catch (FileNotFoundException e1 ) {
            e1.printStackTrace();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        lastVal = encodedFile;
        return lastVal;
    }

}

