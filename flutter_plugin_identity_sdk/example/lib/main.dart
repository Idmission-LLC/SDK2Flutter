import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  String _api_base_url = '';
  String _access_token = '';
  String _capture_back = '';
  String _debug = '';
  int _unique_customer_number = 0;
  int _client_trace_id = 0;
  late TextEditingController _api_base_url_controller;
  late TextEditingController _access_token_controller;
  late TextEditingController _capture_back_controller;
  late TextEditingController _debug_controller;
  late TextEditingController _unique_customer_number_controller;
  late TextEditingController _client_trace_id_controller;

  @override
  void initState() {
    super.initState();
    _api_base_url_controller = TextEditingController();
    _access_token_controller = TextEditingController();
    _capture_back_controller = TextEditingController();
    _debug_controller = TextEditingController();
    _unique_customer_number_controller = TextEditingController();
    _client_trace_id_controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _api_base_url_controller.dispose();
    _access_token_controller.dispose();
    _capture_back_controller.dispose();
    _debug_controller.dispose();
    _unique_customer_number_controller.dispose();
    _client_trace_id_controller.dispose();
    super.dispose();
  }

  void initialize() {
    FlutterPluginIdentitySdk.idm_sdk_init(_api_base_url, _debug, _access_token).then((value) => set_result(value!));
  }

  void idValidation() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID20(_capture_back, _client_trace_id).then((value) => set_result(value!));
  }

  void idValidationAndMatchFace() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID10(_capture_back, _client_trace_id).then((value) => set_result(value!));
  }

  void identifyCustomer() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID185().then((value) => set_result(value!));
  }

  void liveFaceCheck() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID660().then((value) => set_result(value!));
  }

  void idValidationAndcustomerEnroll() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID50(_unique_customer_number).then((value) => set_result(value!));
  }

  void customerEnrollBiometrics() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID175(_unique_customer_number).then((value) => set_result(value!));
  }

  void customerVerification() {
    FlutterPluginIdentitySdk.idm_sdk_serviceID105(_unique_customer_number).then((value) => set_result(value!));
  }

  void submitResult() {
    FlutterPluginIdentitySdk.submit_result().then((value) => set_result(value!));
  }

  void set_result(String result) {
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Identity SDK'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'API Base URL',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _api_base_url_controller,
                  onChanged:  (String value) async {
                    _api_base_url = value;
                  },
                  onSubmitted: (String value) async {
                    _api_base_url = value;
                  },
              ),
              TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Access Token',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _access_token_controller,
                  onChanged:  (String value) async {
                    _access_token = value;
                  },                  
                  onSubmitted: (String value) async {
                    _access_token = value;
                  },
              ),
              TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Capture Back',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _capture_back_controller,
                  onChanged:  (String value) async {
                    _capture_back = value;
                  },                  
                  onSubmitted: (String value) async {
                    _capture_back = value;
                  },
              ),
              TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Debug',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _debug_controller,
                  onChanged:  (String value) async {
                    _debug = value;
                  },                  
                  onSubmitted: (String value) async {
                    _debug = value;
                  },
              ),
              TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Unique Customer Number',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _unique_customer_number_controller,
                  onChanged:  (String value) async {
                    _unique_customer_number = int.parse(value);
                  },                  
                  onSubmitted: (String value) async {
                    _unique_customer_number = int.parse(value);
                  },
              ),
              TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: 'Client Trace ID',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  controller: _client_trace_id_controller,
                  onChanged:  (String value) async {
                    _client_trace_id = int.parse(value);
                  },                  
                  onSubmitted: (String value) async {
                    _client_trace_id = int.parse(value);
                  },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Initialize'),
                    onPressed: () => initialize(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('ID Validation'),
                    onPressed: () => idValidation(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('ID Validation and Match Face'),
                    onPressed: () => idValidationAndMatchFace(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Identify Customer'),
                    onPressed: () => idValidation(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Live Face Check'),
                    onPressed: () => liveFaceCheck(),
                  ),
                ],
              ),                                          
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('ID Validation and Customer Enroll'),
                    onPressed: () => idValidationAndcustomerEnroll(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Customer Enroll Biometrics'),
                    onPressed: () => customerEnrollBiometrics(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Customer Verification'),
                    onPressed: () => customerVerification(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.all(10),
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    child: Text('Submit Result'),
                    onPressed: () => submitResult(),
                  ),
                ],
              ),
              Text('$_result\n'),
            ],
          ),
        ),
      ),
    );
  }
}
