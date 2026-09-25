import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

import 'identity_services_page.dart';
import 'qr_scanner_page.dart';
import 'widgets/animated_elevated_button.dart';

/// Page 1: SDK Configuration. Initialize SDK fetches the access token and
/// calls idm_sdk_init() in one step; on success it opens page 2
/// (IdentityServicesPage).
class SdkConfigurationPage extends StatefulWidget {
  const SdkConfigurationPage({super.key});

  @override
  State<SdkConfigurationPage> createState() => _SdkConfigurationPageState();
}

class _SdkConfigurationPageState extends State<SdkConfigurationPage> {
  bool _isLoading = false;
  String _apiBaseUrl = '';
  String _loginId = '';
  String _password = '';
  String _clientId = '';
  String _clientSecret = '';
  String _initError = '';
  bool _debugMode = false;

  late TextEditingController _apiBaseUrlController;
  late TextEditingController _loginIdController;
  late TextEditingController _passwordController;
  late TextEditingController _clientIdController;
  late TextEditingController _clientSecretController;

  @override
  void initState() {
    super.initState();
    _apiBaseUrlController = TextEditingController();
    _loginIdController = TextEditingController();
    _passwordController = TextEditingController();
    _clientIdController = TextEditingController();
    _clientSecretController = TextEditingController();
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    _loginIdController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  // Derive the auth/token endpoint from the captured API Base URL.
  // Mirrors the native sample's URL convention:
  //   https://api.idmission.com/      -> https://auth.idmission.com/auth/realms/identity/protocol/openid-connect/token
  //   https://apidemo.idmission.com/  -> https://demoauth.idmission.com/auth/realms/identity/protocol/openid-connect/token
  // Rule: strip the leading "api" from the first host label; the remaining
  // environment segment ("" or "demo") prefixes "auth".
  String? _deriveTokenUrl(String apiBaseUrl) {
    final match = RegExp(
      r'^(https?:\/\/)([^/]+)(\/.*)?$',
      caseSensitive: false,
    ).firstMatch(apiBaseUrl.trim());
    if (match == null) return null;
    final scheme = match.group(1)!;
    final labels = match.group(2)!.split('.');
    final first = labels[0].toLowerCase();
    final env = first.startsWith('api') ? first.substring(3) : first;
    labels[0] = '${env}auth';
    return '$scheme${labels.join('.')}/auth/realms/identity/protocol/openid-connect/token';
  }

  // Maps the "URL" field embedded in a configuration QR code to the matching
  // API Base URL, mirroring the environment lookup used by the native
  // reference app's Settings screen (kyc-uk / kyc-us checked before the
  // generic "kyc" substring, since both contain it).
  String? _deriveApiBaseUrlFromQrUrl(String? url) {
    final u = (url ?? '').toLowerCase();
    if (u.isEmpty) return null;
    if (u.contains('kyc-uk')) {
      return 'https://identity.london.idmission.xyz/identity/';
    }
    if (u.contains('kyc-us')) {
      return 'https://identity.virginia.idmission.xyz/identity/';
    }
    if (u.contains('demo')) return 'https://apidemo.idmission.com/';
    if (u.contains('uat')) return 'https://apiuat.idmission.com/';
    if (u.contains('lab')) return 'https://apilab.idmission.com/';
    if (u.contains('kyc')) return 'https://api.idmission.com/';
    return null;
  }

  Future<String> _fetchAccessToken(String tokenUrl) async {
    final form = {
      'grant_type': 'password',
      'client_id': _clientId,
      'client_secret': _clientSecret,
      'username': _loginId,
      'password': _password,
      'scope': 'api_access',
    };
    final body = form.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(tokenUrl));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/x-www-form-urlencoded',
    );
    request.add(utf8.encode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();

    Map<String, dynamic> json;
    try {
      json = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      json = {};
    }

    final accessToken = json['access_token'];
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        accessToken == null) {
      final message =
          json['error_description'] ??
          json['error'] ??
          'Token request failed (HTTP ${response.statusCode})';
      throw message.toString();
    }
    return accessToken as String;
  }

  Future<void> _onInitialize() async {
    setState(() {
      _isLoading = true;
      _initError = '';
    });
    try {
      final tokenUrl = _deriveTokenUrl(_apiBaseUrl);
      if (tokenUrl == null) {
        throw 'Enter a valid API Base URL before initializing.';
      }

      final accessToken = await _fetchAccessToken(tokenUrl);

      final result = await FlutterPluginIdentitySdk.idm_sdk_init(
        _apiBaseUrl,
        _debugMode ? 'y' : 'n',
        accessToken,
      );

      final succeeded = (result ?? '').toLowerCase().contains('success');
      if (!mounted) return;
      if (succeeded) {
        setState(() {
          _isLoading = false;
          _initError = '';
        });
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const IdentityServicesPage()),
        );
      } else {
        setState(() {
          _isLoading = false;
          _initError = result ?? 'SDK initialization failed.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initError = error.toString();
      });
    }
  }

  Future<void> _openScanner() async {
    final data = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (data != null) {
      _applyQrData(data);
    }
  }

  void _applyQrData(Map<String, dynamic> data) {
    final mappedUrl = _deriveApiBaseUrlFromQrUrl(data['URL'] as String?);
    setState(() {
      if (mappedUrl != null) {
        _apiBaseUrl = mappedUrl;
        _apiBaseUrlController.text = mappedUrl;
      }
      if (data['LoginId'] != null) {
        _loginId = data['LoginId'].toString();
        _loginIdController.text = _loginId;
      }
      if (data['Password'] != null) {
        _password = data['Password'].toString();
        _passwordController.text = _password;
      }
      if (data['ClientId'] != null) {
        _clientId = data['ClientId'].toString();
        _clientIdController.text = _clientId;
      }
      if (data['ClientSecret'] != null) {
        _clientSecret = data['ClientSecret'].toString();
        _clientSecretController.text = _clientSecret;
      }
      _initError = '';
    });
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
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

  Widget _buildDebugModeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enable Debug Mode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: _debugMode,
              activeColor: Colors.cyan,
              onChanged: (value) => setState(() => _debugMode = value),
            ),
          ],
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Identity Flutter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _openScanner,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text(
              'Scan QR',
              style: TextStyle(color: Colors.white),
            ),
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
                    controller: _apiBaseUrlController,
                    onChanged: (val) => _apiBaseUrl = val,
                  ),
                  _buildTextField(
                    label: 'Login ID',
                    hint: 'Login ID (username)',
                    icon: Icons.person,
                    controller: _loginIdController,
                    onChanged: (val) => _loginId = val,
                  ),
                  _buildTextField(
                    label: 'Password',
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    onChanged: (val) => _password = val,
                    obscureText: true,
                  ),
                  _buildTextField(
                    label: 'Client ID',
                    hint: 'Client ID',
                    icon: Icons.badge_outlined,
                    controller: _clientIdController,
                    onChanged: (val) => _clientId = val,
                  ),
                  _buildTextField(
                    label: 'Client Secret',
                    hint: 'Client Secret',
                    icon: Icons.key_outlined,
                    controller: _clientSecretController,
                    onChanged: (val) => _clientSecret = val,
                    obscureText: true,
                  ),
                  _buildDebugModeRow(),
                  const SizedBox(height: 8),
                  _buildActionButton('Initialize SDK', _onInitialize),
                  if (_initError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        _initError,
                        style: const TextStyle(
                          color: Color(0xFFEF4444), // Red 500
                          fontSize: 13,
                        ),
                      ),
                    ),
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
