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
  bool _isLoading = false;
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

  void initialize() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_init(
        _api_base_url,
        _debug,
        _access_token,
      ),
    );
  }

  void idValidation() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID20(
        _capture_back,
        _client_trace_id,
      ),
    );
  }

  void idValidationAndMatchFace() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID10(
        _capture_back,
        _client_trace_id,
      ),
    );
  }

  void identifyCustomer() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID185());
  }

  void liveFaceCheck() {
    _handleServiceCall(FlutterPluginIdentitySdk.idm_sdk_serviceID660());
  }

  void idValidationAndcustomerEnroll() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID50(_unique_customer_number),
    );
  }

  void customerEnrollBiometrics() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID175(_unique_customer_number),
    );
  }

  void customerVerification() {
    _handleServiceCall(
      FlutterPluginIdentitySdk.idm_sdk_serviceID105(_unique_customer_number),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)), // Slate 500
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyan, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: AnimatedElevatedButton(text: text, onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate
          primary: const Color(0xFF0F172A),
          secondary: Colors.cyan,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            'Identity Flutter',
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
                    _buildTextField(
                      label: 'API Base URL',
                      hint: 'https://api.example.com',
                      icon: Icons.link,
                      controller: _api_base_url_controller,
                      onChanged: (val) => _api_base_url = val,
                    ),
                    _buildTextField(
                      label: 'Access Token',
                      hint: 'Enter your Access token',
                      icon: Icons.vpn_key,
                      controller: _access_token_controller,
                      onChanged: (val) => _access_token = val,
                    ),
                    _buildTextField(
                      label: 'Debug Level',
                      hint: 'y or n',
                      icon: Icons.bug_report,
                      controller: _debug_controller,
                      onChanged: (val) => _debug = val,
                    ),
                    _buildTextField(
                      label: 'Unique Customer Number',
                      hint: 'Unique Customer Number',
                      icon: Icons.person_outline,
                      controller: _unique_customer_number_controller,
                      onChanged: (val) =>
                          _unique_customer_number = int.tryParse(val) ?? 0,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'OPERATIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    _buildActionButton('Initialize SDK', initialize),
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
      ),
    );
  }
}

class AnimatedElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.cyan.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            onPressed: widget.onPressed,
            child: Text(widget.text.toUpperCase()),
          ),
        ),
      ),
    );
  }
}
