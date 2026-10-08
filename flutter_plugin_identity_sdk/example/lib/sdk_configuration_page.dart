import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _authUrl = '';
  String _accessToken = '';
  // True once the user has typed their own auth URL; until then it follows
  // the API Base URL.
  bool _authUrlEdited = false;
  bool _tokenGenerated = false;
  String _tokenError = '';
  String _initError = '';
  bool _debugMode = false;
  // Defaults match the native IDentity app.
  bool _screenRecording = false;
  bool _gpsEnabled = true;
  bool _geolocationRequired = false;
  String _sdkVersion = '';
  List<Map<String, String>> _sdkModels = [];

  // Settings are persisted only after a successful SDK initialization, so the
  // last working configuration (typed or scanned from a QR code) is restored
  // when returning to this screen or relaunching the app.
  static const _prefsPrefix = 'idmission.settings.';

  late TextEditingController _apiBaseUrlController;
  late TextEditingController _loginIdController;
  late TextEditingController _passwordController;
  late TextEditingController _clientIdController;
  late TextEditingController _clientSecretController;
  late TextEditingController _authUrlController;
  late TextEditingController _accessTokenController;

  @override
  void initState() {
    super.initState();
    _apiBaseUrlController = TextEditingController();
    _loginIdController = TextEditingController();
    _passwordController = TextEditingController();
    _clientIdController = TextEditingController();
    _clientSecretController = TextEditingController();
    _authUrlController = TextEditingController();
    _accessTokenController = TextEditingController();
    _loadSettings();
    _loadSdkInfo();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String str(String key) => prefs.getString('$_prefsPrefix$key') ?? '';
      if (!mounted) return;
      setState(() {
        _apiBaseUrl = str('apiBaseUrl');
        _loginId = str('loginId');
        _password = str('password');
        _clientId = str('clientId');
        _clientSecret = str('clientSecret');
        _authUrl = str('authUrl');
        _accessToken = str('accessToken');
        _authUrlEdited =
            _authUrl.isNotEmpty &&
            _authUrl != (_deriveTokenUrl(_apiBaseUrl) ?? '');
        _apiBaseUrlController.text = _apiBaseUrl;
        _loginIdController.text = _loginId;
        _passwordController.text = _password;
        _clientIdController.text = _clientId;
        _clientSecretController.text = _clientSecret;
        _authUrlController.text = _authUrl;
        _accessTokenController.text = _accessToken;
        _debugMode = prefs.getBool('${_prefsPrefix}debugMode') ?? _debugMode;
        _screenRecording =
            prefs.getBool('${_prefsPrefix}screenRecording') ?? _screenRecording;
        _gpsEnabled = prefs.getBool('${_prefsPrefix}gpsEnabled') ?? _gpsEnabled;
        _geolocationRequired =
            prefs.getBool('${_prefsPrefix}geolocationRequired') ??
            _geolocationRequired;
      });
    } catch (e) {
      debugPrint('Failed to load saved settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_prefsPrefix}apiBaseUrl', _apiBaseUrl);
      await prefs.setString('${_prefsPrefix}loginId', _loginId);
      await prefs.setString('${_prefsPrefix}password', _password);
      await prefs.setString('${_prefsPrefix}clientId', _clientId);
      await prefs.setString('${_prefsPrefix}clientSecret', _clientSecret);
      await prefs.setString('${_prefsPrefix}authUrl', _authUrl);
      await prefs.setString('${_prefsPrefix}accessToken', _accessToken);
      await prefs.setBool('${_prefsPrefix}debugMode', _debugMode);
      await prefs.setBool('${_prefsPrefix}screenRecording', _screenRecording);
      await prefs.setBool('${_prefsPrefix}gpsEnabled', _gpsEnabled);
      await prefs.setBool(
        '${_prefsPrefix}geolocationRequired',
        _geolocationRequired,
      );
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  Future<void> _loadSdkInfo() async {
    try {
      final info = await FlutterPluginIdentitySdk.getSDKInfo();
      final models = (info['models'] as List? ?? const [])
          .map((m) => Map<String, String>.from(m as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _sdkVersion = (info['version'] ?? '').toString();
        _sdkModels = models;
      });
    } catch (e) {
      debugPrint('Failed to read SDK info: $e');
    }
  }

  @override
  void dispose() {
    _apiBaseUrlController.dispose();
    _loginIdController.dispose();
    _passwordController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _authUrlController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  // Derive the auth/token endpoint from the captured API Base URL, using the
  // same environment -> auth host table as the native IDentity apps:
  //   https://api.idmission.com/                 -> https://auth.idmission.com/
  //   https://apidemo.idmission.com/             -> https://demoauth.idmission.com/
  //   https://apiuat.idmission.com/              -> https://uatauth.idmission.com/
  //   https://apilab.idmission.com:9043/         -> https://labauth.idmission.com:9043/
  //   https://identity.london.idmission.xyz/...  -> https://auth.london.idmission.xyz/
  //   https://identity.virginia.idmission.xyz/...-> https://auth.idmission.com/
  String? _deriveTokenUrl(String apiBaseUrl) {
    final match = RegExp(
      r'^(https?:\/\/)([^/]+)(\/.*)?$',
      caseSensitive: false,
    ).firstMatch(apiBaseUrl.trim());
    if (match == null) return null;
    final scheme = match.group(1)!;
    final host = match.group(2)!;
    const tokenPath = '/auth/realms/identity/protocol/openid-connect/token';
    final h = host.toLowerCase();
    if (h.startsWith('identity.london.')) {
      return '${scheme}auth.london.idmission.xyz$tokenPath';
    }
    if (h.startsWith('identity.virginia.')) {
      return '${scheme}auth.idmission.com$tokenPath';
    }
    final labels = host.split('.');
    final first = labels[0].toLowerCase();
    final env = first.startsWith('api') ? first.substring(3) : first;
    labels[0] = '${env}auth';
    return '$scheme${labels.join('.')}$tokenPath';
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
    if (u.contains('lab')) return 'https://apilab.idmission.com:9043/';
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

  // Editing any field that feeds the token invalidates the generated-token tick.
  void _edit(VoidCallback change) {
    change();
    if (_tokenGenerated) setState(() => _tokenGenerated = false);
  }

  void _onApiBaseUrlChanged(String value) {
    _apiBaseUrl = value;
    if (!_authUrlEdited) {
      setState(() {
        _authUrl = _deriveTokenUrl(value) ?? '';
        _authUrlController.text = _authUrl;
        _tokenGenerated = false;
      });
    }
  }

  Future<void> _onGenerateToken() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _tokenError = '';
    });
    try {
      final tokenUrl = _authUrl.trim().isNotEmpty
          ? _authUrl.trim()
          : _deriveTokenUrl(_apiBaseUrl);
      if (tokenUrl == null || Uri.tryParse(tokenUrl)?.hasScheme != true) {
        throw 'Enter the Access Token Auth URL (or an API Base URL) first.';
      }
      if (_clientId.isEmpty ||
          _clientSecret.isEmpty ||
          _loginId.isEmpty ||
          _password.isEmpty) {
        throw 'Enter Client ID, Client Secret, Login ID and Password first.';
      }

      final token = await _fetchAccessToken(tokenUrl);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _accessToken = token;
        _accessTokenController.text = token;
        _tokenGenerated = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _tokenGenerated = false;
        _tokenError = error.toString();
      });
    }
  }

  Future<void> _onInitialize() async {
    setState(() {
      _isLoading = true;
      _initError = '';
    });
    try {
      if (!_apiBaseUrl.toLowerCase().startsWith('http')) {
        throw 'Enter a valid API Base URL before initializing.';
      }
      if (_accessToken.trim().isEmpty) {
        throw 'Generate or enter an Access Token before initializing.';
      }

      final result = await FlutterPluginIdentitySdk.idm_sdk_init(
        _apiBaseUrl,
        _debugMode ? 'y' : 'n',
        _accessToken.trim(),
        enableGPS: _gpsEnabled,
        geolocationRequired: _geolocationRequired,
        enableScreenRecording: _screenRecording,
      );

      final succeeded = (result ?? '').toLowerCase().contains('success');
      if (!mounted) return;
      if (succeeded) {
        setState(() {
          _isLoading = false;
          _initError = '';
        });
        await _saveSettings();
        _loadSdkInfo();
        if (!mounted) return;
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const IdentityServicesPage()));
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
        if (!_authUrlEdited) {
          _authUrl = _deriveTokenUrl(mappedUrl) ?? '';
          _authUrlController.text = _authUrl;
        }
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
      _tokenError = '';
      _tokenGenerated = false;
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
    bool compact = false,
  }) {
    return Padding(
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          prefixIcon: compact
              ? null
              : Icon(icon, color: const Color(0xFF64748B)), // Slate 500
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
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPairRow(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    // The whole row toggles, so it is easy to tap.
    void toggle(bool v) => setState(() => onChanged(v));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => toggle(!value),
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.95,
                    child: Switch(
                      value: value,
                      activeColor: Colors.cyan,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: toggle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSdkInfoCard() {
    const titleStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF64748B),
    );
    const valueStyle = TextStyle(fontSize: 15, color: Color(0xFF0F172A));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SDK Version', style: titleStyle),
            Text(_sdkVersion.isEmpty ? '-' : _sdkVersion, style: valueStyle),
            const SizedBox(height: 10),
            const Text('Models', style: titleStyle),
            if (_sdkModels.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Available after the SDK is initialized.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              )
            else
              for (final model in _sdkModels) ...[
                const SizedBox(height: 8),
                Text('${model['name']} Model', style: titleStyle),
                Text(model['value'] ?? '', style: valueStyle),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: AnimatedElevatedButton(
        text: text,
        onPressed: onPressed,
        height: 44,
      ),
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
            label: const Text('Scan QR', style: TextStyle(color: Colors.white)),
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
                    label: 'Access Token Auth URL',
                    hint:
                        'https://auth.example.com/auth/realms/identity/protocol/openid-connect/token',
                    icon: Icons.vpn_key_outlined,
                    controller: _authUrlController,
                    onChanged: (val) => _edit(() {
                      _authUrl = val;
                      _authUrlEdited = val.isNotEmpty;
                    }),
                    keyboardType: TextInputType.url,
                  ),
                  _buildPairRow(
                    _buildTextField(
                      label: 'Login ID',
                      hint: 'Login ID',
                      icon: Icons.person,
                      controller: _loginIdController,
                      onChanged: (val) => _edit(() => _loginId = val),
                      compact: true,
                    ),
                    _buildTextField(
                      label: 'Password',
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      onChanged: (val) => _edit(() => _password = val),
                      obscureText: true,
                      compact: true,
                    ),
                  ),
                  _buildPairRow(
                    _buildTextField(
                      label: 'Client ID',
                      hint: 'Client ID',
                      icon: Icons.badge_outlined,
                      controller: _clientIdController,
                      onChanged: (val) => _edit(() => _clientId = val),
                      compact: true,
                    ),
                    _buildTextField(
                      label: 'Client Secret',
                      hint: 'Client Secret',
                      icon: Icons.key_outlined,
                      controller: _clientSecretController,
                      onChanged: (val) => _edit(() => _clientSecret = val),
                      obscureText: true,
                      compact: true,
                    ),
                  ),
                  _buildActionButton(
                    _tokenGenerated
                        ? 'Generate Access Token \u2713'
                        : 'Generate Access Token \u2715',
                    _onGenerateToken,
                  ),
                  if (_tokenError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        _tokenError,
                        style: const TextStyle(
                          color: Color(0xFFEF4444), // Red 500
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'API Base URL',
                    hint: 'https://api.example.com',
                    icon: Icons.link,
                    controller: _apiBaseUrlController,
                    onChanged: _onApiBaseUrlChanged,
                    keyboardType: TextInputType.url,
                  ),
                  _buildTextField(
                    label: 'Access Token',
                    hint: 'Generate a token above, or paste one',
                    icon: Icons.token_outlined,
                    controller: _accessTokenController,
                    onChanged: (val) => _accessToken = val,
                  ),
                  _buildSwitchRow(
                    'Enable Debug Mode',
                    _debugMode,
                    (v) => _debugMode = v,
                  ),
                  _buildSwitchRow(
                    'Enable Screen Recording',
                    _screenRecording,
                    (v) => _screenRecording = v,
                  ),
                  _buildSwitchRow(
                    'Enable GPS Location',
                    _gpsEnabled,
                    (v) => _gpsEnabled = v,
                  ),
                  _buildSwitchRow(
                    'Geolocation Required',
                    _geolocationRequired,
                    (v) => _geolocationRequired = v,
                  ),
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
                  _buildSdkInfoCard(),
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
