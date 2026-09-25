import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

import 'widgets/animated_elevated_button.dart';

/// Page 2: shown only once initializeSDK() has succeeded on the SDK
/// Configuration page. Hosts every identity service call plus Submit.
class IdentityServicesPage extends StatefulWidget {
  const IdentityServicesPage({super.key});

  @override
  State<IdentityServicesPage> createState() => _IdentityServicesPageState();
}

class _IdentityServicesPageState extends State<IdentityServicesPage> {
  bool _isLoading = false;
  String _result = '';
  int _uniqueCustomerNumber = 0;
  late TextEditingController _uniqueCustomerNumberController;

  @override
  void initState() {
    super.initState();
    _uniqueCustomerNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _uniqueCustomerNumberController.dispose();
    super.dispose();
  }

  void _handleServiceCall(Future<String?> call) {
    setState(() {
      _isLoading = true;
      _result = '';
    });
    call
        .then((value) {
          setState(() {
            _isLoading = false;
            _result = value ?? 'Null response';
          });
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
            _result = 'Error: $error';
          });
        });
  }

  void idValidation() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID20('', 0));
  }

  void idValidationAndMatchFace() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID10('', 0));
  }

  void identifyCustomer() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID185());
  }

  void liveFaceCheck() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID660());
  }

  void idValidationAndcustomerEnroll() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID50(_uniqueCustomerNumber),
    );
  }

  void customerEnrollBiometrics() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID175(_uniqueCustomerNumber),
    );
  }

  void customerVerification() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID105(_uniqueCustomerNumber),
    );
  }

  void submitResult() {
    _handleServiceCall(FlutterPluginIdentitySdk.submit_result());
  }

  Widget _buildResultDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Slate 800
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF334155), // Slate 700
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'API RESPONSE',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_result.isNotEmpty)
                    Row(
                      children: [
                        _buildIconButton(Icons.copy, 'Copy Result', () {
                          Clipboard.setData(ClipboardData(text: _result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          Icons.clear_all,
                          'Clear',
                          () => setState(() => _result = ''),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? '// No response yet...' : _result,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8), // Slate 400
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(icon, size: 18, color: Colors.cyan.withOpacity(0.9)),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed, {
    bool secondary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: AnimatedElevatedButton(
        text: text,
        onPressed: onPressed,
        secondary: secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Identity Services',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_result.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => _result = ''),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      controller: _uniqueCustomerNumberController,
                      onChanged: (val) =>
                          _uniqueCustomerNumber = int.tryParse(val) ?? 0,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: 'Unique Customer Number',
                        hintText: 'Unique Customer Number',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF64748B),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.cyan,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  _buildActionButton('ID Validation', idValidation),
                  _buildActionButton(
                    'ID Validation & Face Match',
                    idValidationAndMatchFace,
                  ),
                  _buildActionButton('Identify Customer', identifyCustomer),
                  _buildActionButton('Live Face Check', liveFaceCheck),
                  _buildActionButton(
                    'Customer Enrollment',
                    idValidationAndcustomerEnroll,
                  ),
                  _buildActionButton(
                    'Customer Biometric Enrollment',
                    customerEnrollBiometrics,
                  ),
                  _buildActionButton(
                    'Customer Verification',
                    customerVerification,
                  ),
                  _buildActionButton('Submit', submitResult),
                  const SizedBox(height: 24),
                  _buildResultDisplay(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: Card(
                    elevation: 8,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
