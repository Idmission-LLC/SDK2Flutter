package com.idmission.newsdkflutter.flutter_plugin_identity_sdk;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;

import androidx.annotation.NonNull;

import com.idmission.sdk2.capture.IdMissionCaptureLauncher;
import com.idmission.sdk2.capture.presentation.camera.helpers.ProcessedCapture;
import com.idmission.sdk2.client.model.AdditionalCustomerLiveCheckResponseData;
import com.idmission.sdk2.client.model.AliasesResponse;
import com.idmission.sdk2.client.model.CameraFacing;
import com.idmission.sdk2.client.model.CameraOrientation;
import com.idmission.sdk2.client.model.CommonApiResponse;
import com.idmission.sdk2.client.model.CriminalRecordResponse;
import com.idmission.sdk2.client.model.DocumentCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.ExtractedIdData;
import com.idmission.sdk2.client.model.ExtractedPersonalData;
import com.idmission.sdk2.client.model.HostDataResponse;
import com.idmission.sdk2.client.model.IDCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.IDCaptureOptions;
import com.idmission.sdk2.client.model.IDColorOptions;
import com.idmission.sdk2.client.model.IDFontOptions;
import com.idmission.sdk2.client.model.IDImageOptions;
import com.idmission.sdk2.client.model.IDLayoutOptions;
import com.idmission.sdk2.client.model.IDStringOptions;
import com.idmission.sdk2.client.model.InitializationStage;
import com.idmission.sdk2.client.model.InitializationState;
import com.idmission.sdk2.client.model.InitializeResponse;
import com.idmission.sdk2.client.model.NmResultResponse;
import com.idmission.sdk2.client.model.OffensesResponse;
import com.idmission.sdk2.client.model.PepResultResponse;
import com.idmission.sdk2.client.model.ProfilesResponse;
import com.idmission.sdk2.client.model.Response;
import com.idmission.sdk2.client.model.ResponseCustomerData;
import com.idmission.sdk2.client.model.ResultData;
import com.idmission.sdk2.client.model.SDKCustomizationOptions;
import com.idmission.sdk2.client.model.SelfieCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.SexOffendersResponse;
import com.idmission.sdk2.client.model.SignatureCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.Status;
import com.idmission.sdk2.client.model.TextMatchResultResponse;
import com.idmission.sdk2.client.model.UpdateInitialization;
import com.idmission.sdk2.client.model.VideoIdCaptureCustomizationOptions;
import com.idmission.sdk2.client.model.WlsResultResponse;
import com.idmission.sdk2.identityproofing.IdentityProofingSDK;
import com.idmission.sdk2.utils.LANGUAGE;

import org.json.JSONObject;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterPluginIdentitySdkPlugin */
public class FlutterPluginIdentitySdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  Activity activity;
  Context context;
  String initializeApiBaseUrl = "https://kyc.idmission.com/";
  String apiBaseUrl,authUrl = "https://api.idmission.com/";
  String accessToken = "";
  boolean isDebug = false;

  private List<ProcessedCapture> processedCaptures = new ArrayList<>();
  private String response;
  private IdMissionCaptureLauncher launcher = new IdMissionCaptureLauncher();
  private static Result resultCallback;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_plugin_identity_sdk");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("idm_sdk_init")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;

      apiBaseUrl = (String) map.get("apiBaseUrl");
      authUrl = (String) map.get("apiBaseUrl");

      String debug = (String) map.get("debug");
      if(null!=debug && debug.contains("y")){
        isDebug=true;
      }

      accessToken = (String) map.get("accessToken");
      
      new BackgroundTask(result).execute();
    } else if (call.method.equals("idm_sdk_serviceID20")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
      int clientTraceId = (int) map.get("clientTraceId");
      //String captureBack = (String) map.get("captureBack");

      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("clientTraceId", clientTraceId);
      //i.putExtra("captureBack", captureBack);
      i.putExtra("serviceID", 20);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID10")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
      int clientTraceId = (int) map.get("clientTraceId");
      //String captureBack = (String) map.get("captureBack");
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 10);
      i.putExtra("clientTraceId", clientTraceId);
      //i.putExtra("captureBack", captureBack);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID185")) {
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 185);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID660")) {
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 660);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID50")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
      int uniqueCustomerNumber = (int) map.get("uniqueCustomerNumber");
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 50);
      i.putExtra("uniqueCustomerNumber", uniqueCustomerNumber);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID175")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
      int uniqueCustomerNumber = (int) map.get("uniqueCustomerNumber");
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 175);
      i.putExtra("uniqueCustomerNumber", uniqueCustomerNumber);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("idm_sdk_serviceID105")) {
      HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
      int uniqueCustomerNumber = (int) map.get("uniqueCustomerNumber");
      Intent i = new Intent(activity, CallPluginActivity.class);
      i.putExtra("serviceID", 105);
      i.putExtra("uniqueCustomerNumber", uniqueCustomerNumber);
      activity.startActivityForResult(i, 1);
      resultCallback = result;
    } else if (call.method.equals("submit_result")) {
      new FinalSubmitTask(result).execute();
    } else {
      result.notImplemented();
    }
  }

  public static void sendResponse(){
    if(null!=resultCallback){
      resultCallback.success(CallPluginActivity.result);
    }
    resultCallback=null;
  }

  class BackgroundTask extends AsyncTask<Void, Void, Response<InitializeResponse>> {
    Result result;

    BackgroundTask(Result results){
      result = results;
    }

    @Override
    protected void onPostExecute(Response<InitializeResponse> initializeResponseResponse) {
      super.onPostExecute(initializeResponseResponse);
      try {
        result.success(initializeResponseResponse.getResult().toString());
      }catch(Exception e){
        result.success("Error");
      }
    }

    @Override
    protected Response<InitializeResponse> doInBackground(Void... voids) {
      /* Response<InitializeResponse> response =IdentityProofingSDK.INSTANCE.initialize(activity, apiBaseUrl,accessToken);*/
      Response<InitializeResponse> response =
              IdentityProofingSDK.INSTANCE.initialize(activity,
                      apiBaseUrl,
                      isDebug,
                      true,
                      new SDKCustomizationOptions(),
                      true,
                      accessToken);
      return response;
    }
  }

  class FinalSubmitTask extends AsyncTask<Void, Void, Response<CommonApiResponse>> {
    Result result;

    FinalSubmitTask(Result results){
      result = results;
    }

    @Override
    protected void onPostExecute(Response<CommonApiResponse> apiResponse) {
      super.onPostExecute(apiResponse);
      if(apiResponse.getErrorStatus()!=null) {
        result.success(apiResponse.getErrorStatus().getStatusMessage());
      } else  {
        result.success(parseResponse(apiResponse));
      }
    }

    @Override
    protected Response<CommonApiResponse> doInBackground(Void... voids) {
      Response<CommonApiResponse> response =
              IdentityProofingSDK.INSTANCE.finalSubmit(activity);
      return response;
    }
  }

  private void writeToFile(String data, Context context) {
    try {
      OutputStreamWriter outputStreamWriter = new OutputStreamWriter(context.openFileOutput("result.txt", Context.MODE_PRIVATE));
      outputStreamWriter.write(data);
      outputStreamWriter.close();
    }
    catch (IOException e) {
      Log.e("Exception", "File write failed: " + e.toString());
    }
  }

  private String parseResponse(Response<CommonApiResponse> response){
    JSONObject jo = new JSONObject();
    try {
      JSONObject statusData = new JSONObject();

      Status status = response.getResult().getStatus();
      statusData.put("statusCode",status.getStatusCode());
      statusData.put("requestId",status.getRequestId());
      statusData.put("errorData",status.getErrorData());
      statusData.put("statusMessage",status.getStatusMessage());

      jo.put("status", statusData);
    }catch(Exception e){}

    try {
      JSONObject resultData = new JSONObject();

      ResultData rd = response.getResult().getResultData();
      resultData.put("uniqueRequestId",rd.getUniqueRequestId());
      resultData.put("verificationResultCode",rd.getVerificationResultCode());
      resultData.put("verificationResultId",rd.getVerificationResultId());
      resultData.put("verificationResult",rd.getVerificationResult());

      jo.put("resultData", resultData);
    }catch(Exception e){}

    try {
      JSONObject responseCustomerData = new JSONObject();
      JSONObject extractedIdData = new JSONObject();
      JSONObject extractedPersonalData = new JSONObject();
      JSONObject hostDataResponseData = new JSONObject();
      JSONObject criminalRecordResponseData = new JSONObject();
      JSONObject aliasesResponseData = new JSONObject();
      JSONObject offensesResponseData = new JSONObject();
      JSONObject profilesResponseData = new JSONObject();
      JSONObject nmResultResponseResponseData = new JSONObject();
      JSONObject pepResultResponseData = new JSONObject();
      JSONObject textMatchResultResponseData = new JSONObject();
      JSONObject sexOffendersResponseData = new JSONObject();
      JSONObject profilesResponse2Data = new JSONObject();
      JSONObject wlsResultResponseData = new JSONObject();

      ResponseCustomerData rcd = response.getResult().getResponseCustomerData();

      try {
        ExtractedIdData eid = rcd.getExtractedIdData();
        extractedIdData.put("ageOver18",eid.getAgeOver18());
        extractedIdData.put("barcodeDataParsed",eid.getBarcodeDataParsed());
        extractedIdData.put("idCountry",eid.getIdCountry());
        extractedIdData.put("idDateOfBirth",eid.getIdDateOfBirth());
        extractedIdData.put("idDateOfBirthFormatted",eid.getIdDateOfBirthFormatted());
        extractedIdData.put("idDateOfBirthNonEng",eid.getIdDateOfBirthNonEng());
        extractedIdData.put("idExpirationDate",eid.getIdExpirationDate());
        extractedIdData.put("idExpirationDateFormatted",eid.getIdExpirationDateFormatted());
        extractedIdData.put("idExpirationDateNonEng",eid.getIdExpirationDateNonEng());
        extractedIdData.put("idIssueCountry",eid.getIdIssueCountry());
        extractedIdData.put("idIssueDate",eid.getIdIssueDate());
        extractedIdData.put("idIssueDateNonEng",eid.getIdIssueDateNonEng());
        extractedIdData.put("idNotExpired",eid.getIdNotExpired());
        extractedIdData.put("idNumber",eid.getIdNumber());
        extractedIdData.put("idNumberNonEng",eid.getIdNumberNonEng());
        extractedIdData.put("idNumber1",eid.getIdNumber1());
        extractedIdData.put("idNumber2",eid.getIdNumber2());
        extractedIdData.put("idNumber2NonEng",eid.getIdNumber2NonEng());
        extractedIdData.put("idNumber3",eid.getIdNumber3());
        extractedIdData.put("idState",eid.getIdState());
        extractedIdData.put("idType",eid.getIdType());
        extractedIdData.put("mrzData",eid.getMrzData());
        extractedIdData.put("mrzErrorMessage",eid.getMrzErrorMessage());
        extractedIdData.put("nationality",eid.getNationality());
        extractedIdData.put("negativeDBMatchFound",eid.getNegativeDBMatchFound());
        extractedIdData.put("validIdNumber",eid.getValidIdNumber());
        extractedIdData.put("idProcessImageFront",eid.getIdProcessImageFront());
        extractedIdData.put("idProcessImageBack",eid.getIdProcessImageBack());
        extractedIdData.put("profession",eid.getProfession());
        extractedIdData.put("professionNonEng",eid.getProfessionNonEng());
        extractedIdData.put("photoOnId",eid.getPhotoOnId());
        responseCustomerData.put("extractedIdData",extractedIdData);
      }catch(Exception e){}

      try {
        ExtractedPersonalData epd = rcd.getExtractedPersonalData();
        extractedPersonalData.put("addressLine1",epd.getAddressLine1());
        extractedPersonalData.put("addressLine1NonEng",epd.getAddressLine1NonEng());
        extractedPersonalData.put("addressLine2",epd.getAddressLine2());
        extractedPersonalData.put("addressLine2NonEng",epd.getAddressLine2NonEng());
        extractedPersonalData.put("city",epd.getCity());
        extractedPersonalData.put("addressNonEng",epd.getAddressNonEng());
        extractedPersonalData.put("country",epd.getCountry());
        extractedPersonalData.put("state",epd.getState());
        extractedPersonalData.put("district",epd.getDistrict());
        extractedPersonalData.put("postalCode",epd.getPostalCode());
        extractedPersonalData.put("dob",epd.getDob());
        extractedPersonalData.put("email",epd.getEmail());
        extractedPersonalData.put("enrolledDate",epd.getEnrolledDate());
        extractedPersonalData.put("firstName",epd.getFirstName());
        extractedPersonalData.put("firstNameNonEng",epd.getFirstNameNonEng());
        extractedPersonalData.put("gender",epd.getGender());
        extractedPersonalData.put("lastName",epd.getLastName());
        extractedPersonalData.put("lastName2",epd.getLastName2());
        extractedPersonalData.put("lastNameNonEng",epd.getLastNameNonEng());
        extractedPersonalData.put("name",epd.getName());
        extractedPersonalData.put("phone",epd.getPhone());
        extractedPersonalData.put("uniqueNumber",epd.getUniqueNumber());
        extractedPersonalData.put("middleName",epd.getMiddleName());
        extractedPersonalData.put("middleNameNonEng",epd.getMiddleNameNonEng());
        extractedPersonalData.put("middleNameNonEng",epd.getMiddleNameNonEng());
        responseCustomerData.put("extractedPersonalData",extractedPersonalData);
      }catch(Exception e){}

      try {
        HostDataResponse hdr = rcd.getHostData();

        try {
          CriminalRecordResponse crr = hdr.getCriminalRecord();

          try {
            AliasesResponse ar = crr.getAliasesResponse();
            aliasesResponseData.put("firstName",ar.getFirstName());
            aliasesResponseData.put("middleName",ar.getMiddleName());
            aliasesResponseData.put("lastName",ar.getLastName());
            aliasesResponseData.put("fullName",ar.getFullName());
            criminalRecordResponseData.put("aliases",aliasesResponseData);
          }catch(Exception e){}

          try {
            OffensesResponse or = crr.getOffensesResponse();
            offensesResponseData.put("addmissionDate",or.getAddmissionDate());
            offensesResponseData.put("ageOfVictim",or.getAgeOfVictim());
            offensesResponseData.put("arrestingAgency",or.getArrestingAgency());
            offensesResponseData.put("caseNumber",or.getCaseNumber());
            offensesResponseData.put("category",or.getCategory());
            offensesResponseData.put("chargeFillingDate",or.getChargeFillingDate());
            offensesResponseData.put("closedDate",or.getClosedDate());
            offensesResponseData.put("code",or.getCode());
            offensesResponseData.put("counts",or.getCounts());
            offensesResponseData.put("courts",or.getCourts());
            offensesResponseData.put("dateConvicted",or.getDateConvicted());
            offensesResponseData.put("dateOfCrime",or.getDateOfCrime());
            offensesResponseData.put("dateOfWarrant",or.getDateOfWarrant());
            offensesResponseData.put("description",or.getDescription());
            offensesResponseData.put("dispositionDate",or.getDispositionDate());
            offensesResponseData.put("dispostion",or.getDispostion());
            offensesResponseData.put("facility",or.getFacility());
            offensesResponseData.put("jurisdication",or.getJurisdication());
            offensesResponseData.put("prisonerNumber",or.getPrisonerNumber());
            offensesResponseData.put("relationshipToVictim",or.getRelationshipToVictim());
            offensesResponseData.put("releaseDate",or.getReleaseDate());
            offensesResponseData.put("section",or.getSection());
            offensesResponseData.put("sentence",or.getSentence());
            offensesResponseData.put("sentenceDate",or.getSentenceDate());
            offensesResponseData.put("subsection",or.getSubsection());
            offensesResponseData.put("title",or.getTitle());
            offensesResponseData.put("warrantDate",or.getWarrantDate());
            offensesResponseData.put("warrantNumber",or.getWarrantNumber());
            offensesResponseData.put("weaponsUsed",or.getWeaponsUsed());
            criminalRecordResponseData.put("offenses",offensesResponseData);
          }catch(Exception e){}

          try {
            ProfilesResponse pr = crr.getProfiles();
            profilesResponseData.put("city",pr.getCity());
            profilesResponseData.put("country",pr.getCountry());
            profilesResponseData.put("fullName",pr.getFullName());
            profilesResponseData.put("firstName",pr.getFirstName());
            profilesResponseData.put("middleName",pr.getMiddleName());
            profilesResponseData.put("address",pr.getAddress());
            profilesResponseData.put("convictionType",pr.getConvictionType());
            profilesResponseData.put("countryCode",pr.getCountryCode());
            profilesResponseData.put("countryName",pr.getCountryName());
            profilesResponseData.put("dobOfBirth",pr.getDobOfBirth());
            profilesResponseData.put("drivingLicenseVerificationResult",pr.getDrivingLicenseVerificationResult());
            profilesResponseData.put("internalId",pr.getInternalId());
            profilesResponseData.put("internalIdCriminalRecords",pr.getInternalIdCriminalRecords());
            profilesResponseData.put("lastName",pr.getLastName());
            profilesResponseData.put("photoUrl",pr.getPhotoUrl());
            profilesResponseData.put("postalCode",pr.getPostalCode());
            profilesResponseData.put("sex",pr.getSex());
            profilesResponseData.put("source",pr.getSource());
            profilesResponseData.put("state",pr.getState());
            profilesResponseData.put("street1",pr.getStreet1());
            profilesResponseData.put("street2",pr.getStreet2());
            profilesResponseData.put("verificationResult",pr.getVerificationResult());
            criminalRecordResponseData.put("profiles",profilesResponseData);
          }catch(Exception e){}

          hostDataResponseData.put("criminalRecord",criminalRecordResponseData);

        }catch(Exception e){}

        try {
          NmResultResponse nrr = hdr.getNmresult();
          nmResultResponseResponseData.put("createdOnNM",nrr.getCreatedOnNM());
          nmResultResponseResponseData.put("orderIdNM",nrr.getOrderIdNM());
          nmResultResponseResponseData.put("resultCountNM",nrr.getResultCountNM());
          nmResultResponseResponseData.put("orderStatusNM",nrr.getOrderStatusNM());
          nmResultResponseResponseData.put("orderUrlNM",nrr.getOrderUrlNM());
          nmResultResponseResponseData.put("productIdNM",nrr.getProductIdNM());
          nmResultResponseResponseData.put("vital4APIHostTried",nrr.getVital4APIHostTried());
          hostDataResponseData.put("nmResult",nmResultResponseResponseData);
        }catch(Exception e){}

        try {
          PepResultResponse prr = hdr.getPepresult();
          pepResultResponseData.put("createdOnPEP",prr.getCreatedOnPEP());
          pepResultResponseData.put("orderIdPEP",prr.getOrderIdPEP());
          pepResultResponseData.put("resultCountPEP",prr.getResultCountPEP());
          pepResultResponseData.put("productId_PEP",prr.getProductId_PEP());
          pepResultResponseData.put("orderUrlPEP",prr.getOrderUrlPEP());
          pepResultResponseData.put("orderStatus_PEP",prr.getOrderStatus_PEP());
          hostDataResponseData.put("pepresult",pepResultResponseData);
        }catch(Exception e){}

        try {
          TextMatchResultResponse tmrr = hdr.getTextMatchResult();
          textMatchResultResponseData.put("address",tmrr.getAddress());
          textMatchResultResponseData.put("addressCityMatch",tmrr.getAddressCityMatch());
          textMatchResultResponseData.put("addressLine1Match",tmrr.getAddressLine1Match());
          textMatchResultResponseData.put("addressLine2Match",tmrr.getAddressLine2Match());
          textMatchResultResponseData.put("addressZIP4Match",tmrr.getAddressZIP4Match());
          textMatchResultResponseData.put("addressStateCodeMatch",tmrr.getAddressStateCodeMatch());
          textMatchResultResponseData.put("addressZIP5Match",tmrr.getAddressZIP5Match());
          textMatchResultResponseData.put("documentCategoryMatch",tmrr.getDocumentCategoryMatch());
          textMatchResultResponseData.put("driverLicenseExpirationDateMatch",tmrr.getDriverLicenseExpirationDateMatch());
          textMatchResultResponseData.put("driverLicenseIssueDateMatch",tmrr.getDriverLicenseIssueDateMatch());
          textMatchResultResponseData.put("driverLicenseNumberMatch",tmrr.getDriverLicenseNumberMatch());
          textMatchResultResponseData.put("hostTried",tmrr.getHostTried());
          textMatchResultResponseData.put("identiFraudHostTried",tmrr.getIdentiFraudHostTried());
          textMatchResultResponseData.put("personBirthDateMatch",tmrr.getPersonBirthDateMatch());
          textMatchResultResponseData.put("personFirstNameExactMatch",tmrr.getPersonFirstNameExactMatch());
          textMatchResultResponseData.put("personFirstNameFuzzyAlternateMatch",tmrr.getPersonFirstNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personFirstNameFuzzyPrimaryMatch",tmrr.getPersonFirstNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personLastNameExactMatch",tmrr.getPersonLastNameExactMatch());
          textMatchResultResponseData.put("personLastNameFuzzyAlternateMatch",tmrr.getPersonLastNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personLastNameFuzzyPrimaryMatch",tmrr.getPersonLastNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personMiddleInitialMatch",tmrr.getPersonMiddleInitialMatch());
          textMatchResultResponseData.put("personMiddleNameExactMatch",tmrr.getPersonMiddleNameExactMatch());
          textMatchResultResponseData.put("personMiddleNameFuzzyAlternateMatch",tmrr.getPersonMiddleNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personMiddleNameFuzzyPrimaryMatch",tmrr.getPersonMiddleNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personSexCodeMatch",tmrr.getPersonSexCodeMatch());
          textMatchResultResponseData.put("servicePresent",tmrr.getServicePresent());
          textMatchResultResponseData.put("thirdPartyVerificationResultDescription",tmrr.getThirdPartyVerificationResultDescription());
          textMatchResultResponseData.put("verificationResult",tmrr.getVerificationResult());
          hostDataResponseData.put("textMatchResult",textMatchResultResponseData);
        }catch(Exception e){}

        try {
          SexOffendersResponse sor = hdr.getSexOffenders();

          try {
            ProfilesResponse pr2 = sor.getProfiles();
            profilesResponse2Data.put("city",pr2.getCity());
            profilesResponse2Data.put("country",pr2.getCountry());
            profilesResponse2Data.put("fullName",pr2.getFullName());
            profilesResponse2Data.put("firstName",pr2.getFirstName());
            profilesResponse2Data.put("middleName",pr2.getMiddleName());
            profilesResponse2Data.put("address",pr2.getAddress());
            profilesResponse2Data.put("convictionType",pr2.getConvictionType());
            profilesResponse2Data.put("countryCode",pr2.getCountryCode());
            profilesResponse2Data.put("countryName",pr2.getCountryName());
            profilesResponse2Data.put("dobOfBirth",pr2.getDobOfBirth());
            profilesResponse2Data.put("drivingLicenseVerificationResult",pr2.getDrivingLicenseVerificationResult());
            profilesResponse2Data.put("internalId",pr2.getInternalId());
            profilesResponse2Data.put("internalIdCriminalRecords",pr2.getInternalIdCriminalRecords());
            profilesResponse2Data.put("lastName",pr2.getLastName());
            profilesResponse2Data.put("photoUrl",pr2.getPhotoUrl());
            profilesResponse2Data.put("postalCode",pr2.getPostalCode());
            profilesResponse2Data.put("sex",pr2.getSex());
            profilesResponse2Data.put("source",pr2.getSource());
            profilesResponse2Data.put("state",pr2.getState());
            profilesResponse2Data.put("street1",pr2.getStreet1());
            profilesResponse2Data.put("street2",pr2.getStreet2());
            profilesResponse2Data.put("verificationResult",pr2.getVerificationResult());
            sexOffendersResponseData.put("profiles",profilesResponse2Data);
          }catch(Exception e){}

          hostDataResponseData.put("sexOffenders",sexOffendersResponseData);
        }catch(Exception e){}

        try {
          WlsResultResponse wrr = hdr.getWlsresult();
          wlsResultResponseData.put("createdOnWLS",wrr.getCreatedOnWLS());
          wlsResultResponseData.put("orderIdWLS",wrr.getOrderIdWLS());
          wlsResultResponseData.put("resultCountWLS",wrr.getResultCountWLS());
          wlsResultResponseData.put("productIdWLS",wrr.getProductIdWLS());
          wlsResultResponseData.put("orderStatusWLS",wrr.getOrderStatusWLS());
          wlsResultResponseData.put("orderUrlWLS",wrr.getOrderUrlWLS());
          hostDataResponseData.put("wlsresult",wlsResultResponseData);
        }catch(Exception e){}

        responseCustomerData.put("hostDataResponse",hostDataResponseData);
      }catch(Exception e){}

      jo.put("responseCustomerData", responseCustomerData);
    }catch(Exception e){}

    try {
      JSONObject responseCustomerVerifyData = new JSONObject();
      JSONObject extractedIdData = new JSONObject();
      JSONObject extractedPersonalData = new JSONObject();
      JSONObject hostDataResponseData = new JSONObject();
      JSONObject criminalRecordResponseData = new JSONObject();
      JSONObject aliasesResponseData = new JSONObject();
      JSONObject offensesResponseData = new JSONObject();
      JSONObject profilesResponseData = new JSONObject();
      JSONObject nmResultResponseResponseData = new JSONObject();
      JSONObject pepResultResponseData = new JSONObject();
      JSONObject textMatchResultResponseData = new JSONObject();
      JSONObject sexOffendersResponseData = new JSONObject();
      JSONObject profilesResponse2Data = new JSONObject();
      JSONObject wlsResultResponseData = new JSONObject();

      ResponseCustomerData rcvd = response.getResult().getResponseCustomerVerifyData();

      try {
        ExtractedIdData eid = rcvd.getExtractedIdData();
        extractedIdData.put("ageOver18",eid.getAgeOver18());
        extractedIdData.put("barcodeDataParsed",eid.getBarcodeDataParsed());
        extractedIdData.put("idCountry",eid.getIdCountry());
        extractedIdData.put("idDateOfBirth",eid.getIdDateOfBirth());
        extractedIdData.put("idDateOfBirthFormatted",eid.getIdDateOfBirthFormatted());
        extractedIdData.put("idDateOfBirthNonEng",eid.getIdDateOfBirthNonEng());
        extractedIdData.put("idExpirationDate",eid.getIdExpirationDate());
        extractedIdData.put("idExpirationDateFormatted",eid.getIdExpirationDateFormatted());
        extractedIdData.put("idExpirationDateNonEng",eid.getIdExpirationDateNonEng());
        extractedIdData.put("idIssueCountry",eid.getIdIssueCountry());
        extractedIdData.put("idIssueDate",eid.getIdIssueDate());
        extractedIdData.put("idIssueDateNonEng",eid.getIdIssueDateNonEng());
        extractedIdData.put("idNotExpired",eid.getIdNotExpired());
        extractedIdData.put("idNumber",eid.getIdNumber());
        extractedIdData.put("idNumberNonEng",eid.getIdNumberNonEng());
        extractedIdData.put("idNumber1",eid.getIdNumber1());
        extractedIdData.put("idNumber2",eid.getIdNumber2());
        extractedIdData.put("idNumber2NonEng",eid.getIdNumber2NonEng());
        extractedIdData.put("idNumber3",eid.getIdNumber3());
        extractedIdData.put("idState",eid.getIdState());
        extractedIdData.put("idType",eid.getIdType());
        extractedIdData.put("mrzData",eid.getMrzData());
        extractedIdData.put("mrzErrorMessage",eid.getMrzErrorMessage());
        extractedIdData.put("nationality",eid.getNationality());
        extractedIdData.put("negativeDBMatchFound",eid.getNegativeDBMatchFound());
        extractedIdData.put("validIdNumber",eid.getValidIdNumber());
        extractedIdData.put("idProcessImageFront",eid.getIdProcessImageFront());
        extractedIdData.put("idProcessImageBack",eid.getIdProcessImageBack());
        extractedIdData.put("profession",eid.getProfession());
        extractedIdData.put("professionNonEng",eid.getProfessionNonEng());
        extractedIdData.put("photoOnId",eid.getPhotoOnId());
        responseCustomerVerifyData.put("extractedIdData",extractedIdData);
      }catch(Exception e){}

      try {
        ExtractedPersonalData epd = rcvd.getExtractedPersonalData();
        extractedPersonalData.put("addressLine1",epd.getAddressLine1());
        extractedPersonalData.put("addressLine1NonEng",epd.getAddressLine1NonEng());
        extractedPersonalData.put("addressLine2",epd.getAddressLine2());
        extractedPersonalData.put("addressLine2NonEng",epd.getAddressLine2NonEng());
        extractedPersonalData.put("city",epd.getCity());
        extractedPersonalData.put("addressNonEng",epd.getAddressNonEng());
        extractedPersonalData.put("country",epd.getCountry());
        extractedPersonalData.put("state",epd.getState());
        extractedPersonalData.put("district",epd.getDistrict());
        extractedPersonalData.put("postalCode",epd.getPostalCode());
        extractedPersonalData.put("dob",epd.getDob());
        extractedPersonalData.put("email",epd.getEmail());
        extractedPersonalData.put("enrolledDate",epd.getEnrolledDate());
        extractedPersonalData.put("firstName",epd.getFirstName());
        extractedPersonalData.put("firstNameNonEng",epd.getFirstNameNonEng());
        extractedPersonalData.put("gender",epd.getGender());
        extractedPersonalData.put("lastName",epd.getLastName());
        extractedPersonalData.put("lastName2",epd.getLastName2());
        extractedPersonalData.put("lastNameNonEng",epd.getLastNameNonEng());
        extractedPersonalData.put("name",epd.getName());
        extractedPersonalData.put("phone",epd.getPhone());
        extractedPersonalData.put("uniqueNumber",epd.getUniqueNumber());
        extractedPersonalData.put("middleName",epd.getMiddleName());
        extractedPersonalData.put("middleNameNonEng",epd.getMiddleNameNonEng());
        responseCustomerVerifyData.put("extractedPersonalData",extractedPersonalData);
      }catch(Exception e){}

      try {
        HostDataResponse hdr = rcvd.getHostData();

        try {
          CriminalRecordResponse crr = hdr.getCriminalRecord();

          try {
            AliasesResponse ar = crr.getAliasesResponse();
            aliasesResponseData.put("firstName",ar.getFirstName());
            aliasesResponseData.put("middleName",ar.getMiddleName());
            aliasesResponseData.put("lastName",ar.getLastName());
            aliasesResponseData.put("fullName",ar.getFullName());
            criminalRecordResponseData.put("aliases",aliasesResponseData);
          }catch(Exception e){}

          try {
            OffensesResponse or = crr.getOffensesResponse();
            offensesResponseData.put("addmissionDate",or.getAddmissionDate());
            offensesResponseData.put("ageOfVictim",or.getAgeOfVictim());
            offensesResponseData.put("arrestingAgency",or.getArrestingAgency());
            offensesResponseData.put("caseNumber",or.getCaseNumber());
            offensesResponseData.put("category",or.getCategory());
            offensesResponseData.put("chargeFillingDate",or.getChargeFillingDate());
            offensesResponseData.put("closedDate",or.getClosedDate());
            offensesResponseData.put("code",or.getCode());
            offensesResponseData.put("counts",or.getCounts());
            offensesResponseData.put("courts",or.getCourts());
            offensesResponseData.put("dateConvicted",or.getDateConvicted());
            offensesResponseData.put("dateOfCrime",or.getDateOfCrime());
            offensesResponseData.put("dateOfWarrant",or.getDateOfWarrant());
            offensesResponseData.put("description",or.getDescription());
            offensesResponseData.put("dispositionDate",or.getDispositionDate());
            offensesResponseData.put("dispostion",or.getDispostion());
            offensesResponseData.put("facility",or.getFacility());
            offensesResponseData.put("jurisdication",or.getJurisdication());
            offensesResponseData.put("prisonerNumber",or.getPrisonerNumber());
            offensesResponseData.put("relationshipToVictim",or.getRelationshipToVictim());
            offensesResponseData.put("releaseDate",or.getReleaseDate());
            offensesResponseData.put("section",or.getSection());
            offensesResponseData.put("sentence",or.getSentence());
            offensesResponseData.put("sentenceDate",or.getSentenceDate());
            offensesResponseData.put("subsection",or.getSubsection());
            offensesResponseData.put("title",or.getTitle());
            offensesResponseData.put("warrantDate",or.getWarrantDate());
            offensesResponseData.put("warrantNumber",or.getWarrantNumber());
            offensesResponseData.put("weaponsUsed",or.getWeaponsUsed());
            criminalRecordResponseData.put("offenses",offensesResponseData);
          }catch(Exception e){}

          try {
            ProfilesResponse pr = crr.getProfiles();
            profilesResponseData.put("city",pr.getCity());
            profilesResponseData.put("country",pr.getCountry());
            profilesResponseData.put("fullName",pr.getFullName());
            profilesResponseData.put("firstName",pr.getFirstName());
            profilesResponseData.put("middleName",pr.getMiddleName());
            profilesResponseData.put("address",pr.getAddress());
            profilesResponseData.put("convictionType",pr.getConvictionType());
            profilesResponseData.put("countryCode",pr.getCountryCode());
            profilesResponseData.put("countryName",pr.getCountryName());
            profilesResponseData.put("dobOfBirth",pr.getDobOfBirth());
            profilesResponseData.put("drivingLicenseVerificationResult",pr.getDrivingLicenseVerificationResult());
            profilesResponseData.put("internalId",pr.getInternalId());
            profilesResponseData.put("internalIdCriminalRecords",pr.getInternalIdCriminalRecords());
            profilesResponseData.put("lastName",pr.getLastName());
            profilesResponseData.put("photoUrl",pr.getPhotoUrl());
            profilesResponseData.put("postalCode",pr.getPostalCode());
            profilesResponseData.put("sex",pr.getSex());
            profilesResponseData.put("source",pr.getSource());
            profilesResponseData.put("state",pr.getState());
            profilesResponseData.put("street1",pr.getStreet1());
            profilesResponseData.put("street2",pr.getStreet2());
            profilesResponseData.put("verificationResult",pr.getVerificationResult());
            criminalRecordResponseData.put("profiles",profilesResponseData);
          }catch(Exception e){}

          hostDataResponseData.put("criminalRecord",criminalRecordResponseData);
        }catch(Exception e){}

        try {
          NmResultResponse nrr = hdr.getNmresult();
          nmResultResponseResponseData.put("createdOnNM",nrr.getCreatedOnNM());
          nmResultResponseResponseData.put("orderIdNM",nrr.getOrderIdNM());
          nmResultResponseResponseData.put("resultCountNM",nrr.getResultCountNM());
          nmResultResponseResponseData.put("orderStatusNM",nrr.getOrderStatusNM());
          nmResultResponseResponseData.put("orderUrlNM",nrr.getOrderUrlNM());
          nmResultResponseResponseData.put("productIdNM",nrr.getProductIdNM());
          nmResultResponseResponseData.put("vital4APIHostTried",nrr.getVital4APIHostTried());
          hostDataResponseData.put("nmResult",nmResultResponseResponseData);
        }catch(Exception e){}

        try {
          PepResultResponse prr = hdr.getPepresult();
          pepResultResponseData.put("createdOnPEP",prr.getCreatedOnPEP());
          pepResultResponseData.put("orderIdPEP",prr.getOrderIdPEP());
          pepResultResponseData.put("resultCountPEP",prr.getResultCountPEP());
          pepResultResponseData.put("productId_PEP",prr.getProductId_PEP());
          pepResultResponseData.put("orderUrlPEP",prr.getOrderUrlPEP());
          pepResultResponseData.put("orderStatus_PEP",prr.getOrderStatus_PEP());
          hostDataResponseData.put("pepresult",pepResultResponseData);
        }catch(Exception e){}

        try {
          TextMatchResultResponse tmrr = hdr.getTextMatchResult();
          textMatchResultResponseData.put("address",tmrr.getAddress());
          textMatchResultResponseData.put("addressCityMatch",tmrr.getAddressCityMatch());
          textMatchResultResponseData.put("addressLine1Match",tmrr.getAddressLine1Match());
          textMatchResultResponseData.put("addressLine2Match",tmrr.getAddressLine2Match());
          textMatchResultResponseData.put("addressZIP4Match",tmrr.getAddressZIP4Match());
          textMatchResultResponseData.put("addressStateCodeMatch",tmrr.getAddressStateCodeMatch());
          textMatchResultResponseData.put("addressZIP5Match",tmrr.getAddressZIP5Match());
          textMatchResultResponseData.put("documentCategoryMatch",tmrr.getDocumentCategoryMatch());
          textMatchResultResponseData.put("driverLicenseExpirationDateMatch",tmrr.getDriverLicenseExpirationDateMatch());
          textMatchResultResponseData.put("driverLicenseIssueDateMatch",tmrr.getDriverLicenseIssueDateMatch());
          textMatchResultResponseData.put("driverLicenseNumberMatch",tmrr.getDriverLicenseNumberMatch());
          textMatchResultResponseData.put("hostTried",tmrr.getHostTried());
          textMatchResultResponseData.put("identiFraudHostTried",tmrr.getIdentiFraudHostTried());
          textMatchResultResponseData.put("personBirthDateMatch",tmrr.getPersonBirthDateMatch());
          textMatchResultResponseData.put("personFirstNameExactMatch",tmrr.getPersonFirstNameExactMatch());
          textMatchResultResponseData.put("personFirstNameFuzzyAlternateMatch",tmrr.getPersonFirstNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personFirstNameFuzzyPrimaryMatch",tmrr.getPersonFirstNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personLastNameExactMatch",tmrr.getPersonLastNameExactMatch());
          textMatchResultResponseData.put("personLastNameFuzzyAlternateMatch",tmrr.getPersonLastNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personLastNameFuzzyPrimaryMatch",tmrr.getPersonLastNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personMiddleInitialMatch",tmrr.getPersonMiddleInitialMatch());
          textMatchResultResponseData.put("personMiddleNameExactMatch",tmrr.getPersonMiddleNameExactMatch());
          textMatchResultResponseData.put("personMiddleNameFuzzyAlternateMatch",tmrr.getPersonMiddleNameFuzzyAlternateMatch());
          textMatchResultResponseData.put("personMiddleNameFuzzyPrimaryMatch",tmrr.getPersonMiddleNameFuzzyPrimaryMatch());
          textMatchResultResponseData.put("personSexCodeMatch",tmrr.getPersonSexCodeMatch());
          textMatchResultResponseData.put("servicePresent",tmrr.getServicePresent());
          textMatchResultResponseData.put("thirdPartyVerificationResultDescription",tmrr.getThirdPartyVerificationResultDescription());
          textMatchResultResponseData.put("verificationResult",tmrr.getVerificationResult());
          hostDataResponseData.put("textMatchResult",textMatchResultResponseData);
        }catch(Exception e){}

        try {
          SexOffendersResponse sor = hdr.getSexOffenders();

          try {
            ProfilesResponse pr2 = sor.getProfiles();
            profilesResponse2Data.put("city",pr2.getCity());
            profilesResponse2Data.put("country",pr2.getCountry());
            profilesResponse2Data.put("fullName",pr2.getFullName());
            profilesResponse2Data.put("firstName",pr2.getFirstName());
            profilesResponse2Data.put("middleName",pr2.getMiddleName());
            profilesResponse2Data.put("address",pr2.getAddress());
            profilesResponse2Data.put("convictionType",pr2.getConvictionType());
            profilesResponse2Data.put("countryCode",pr2.getCountryCode());
            profilesResponse2Data.put("countryName",pr2.getCountryName());
            profilesResponse2Data.put("dobOfBirth",pr2.getDobOfBirth());
            profilesResponse2Data.put("drivingLicenseVerificationResult",pr2.getDrivingLicenseVerificationResult());
            profilesResponse2Data.put("internalId",pr2.getInternalId());
            profilesResponse2Data.put("internalIdCriminalRecords",pr2.getInternalIdCriminalRecords());
            profilesResponse2Data.put("lastName",pr2.getLastName());
            profilesResponse2Data.put("photoUrl",pr2.getPhotoUrl());
            profilesResponse2Data.put("postalCode",pr2.getPostalCode());
            profilesResponse2Data.put("sex",pr2.getSex());
            profilesResponse2Data.put("source",pr2.getSource());
            profilesResponse2Data.put("state",pr2.getState());
            profilesResponse2Data.put("street1",pr2.getStreet1());
            profilesResponse2Data.put("street2",pr2.getStreet2());
            profilesResponse2Data.put("verificationResult",pr2.getVerificationResult());
            sexOffendersResponseData.put("profiles",profilesResponse2Data);
          }catch(Exception e){}

          hostDataResponseData.put("sexOffenders",sexOffendersResponseData);
        }catch(Exception e){}

        try {
          WlsResultResponse wrr = hdr.getWlsresult();
          wlsResultResponseData.put("createdOnWLS",wrr.getCreatedOnWLS());
          wlsResultResponseData.put("orderIdWLS",wrr.getOrderIdWLS());
          wlsResultResponseData.put("resultCountWLS",wrr.getResultCountWLS());
          wlsResultResponseData.put("productIdWLS",wrr.getProductIdWLS());
          wlsResultResponseData.put("orderStatusWLS",wrr.getOrderStatusWLS());
          wlsResultResponseData.put("orderUrlWLS",wrr.getOrderUrlWLS());
          hostDataResponseData.put("wlsresult",wlsResultResponseData);
        }catch(Exception e){}
        responseCustomerVerifyData.put("hostDataResponse",hostDataResponseData);
      }catch(Exception e){}

      jo.put("responseCustomerVerifyData", responseCustomerVerifyData);
    }catch(Exception e){}

    try {
      JSONObject additionalCustomerLiveCheckResponseData = new JSONObject();

      AdditionalCustomerLiveCheckResponseData aclcrd = response.getResult().getAdditionalData();
      additionalCustomerLiveCheckResponseData.put("liveFaceDetectionFlag",aclcrd.getLiveFaceDetectionFlag());

      jo.put("additionalCustomerLiveCheckResponseData", additionalCustomerLiveCheckResponseData);
    }catch(Exception e){}

    return jo.toString();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {}

  @Override
  public void onDetachedFromActivity() {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
