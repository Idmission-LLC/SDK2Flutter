import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner. Pops with the parsed configuration record (a
/// Map<String, dynamic>) once a valid code is found, or with null if the
/// user cancels.
///
/// The expected payload is a JSON array holding a single object with
/// LoginId / Password / ClientId / ClientSecret / URL, matching the native
/// reference app's QRExtractedData (see
/// Identity_2.0/.../screens/scanner/QRExtractedData.kt). No scanWindow is
/// set on the scanner itself -- the green corner brackets + red laser line
/// below are a purely visual guide (matching the React Native wrapper's
/// scanner UI); detection still runs across the full camera frame, since
/// restricting detection to a region that doesn't match a QR's aspect
/// ratio is what caused scans to be silently rejected in that app.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  bool _handled = false;
  late final AnimationController _laserController;

  static const double _frameSize = 260;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _parseQrPayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      final record = decoded is List ? decoded.first : decoded;
      if (record is Map) {
        return Map<String, dynamic>.from(record);
      }
    } catch (_) {}
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final data = _parseQrPayload(raw);
      if (data != null) {
        _handled = true;
        Navigator.of(context).pop(data);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan Configuration QR Code'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(onDetect: _onDetect),
          IgnorePointer(
            child: Center(
              child: SizedBox(
                width: _frameSize,
                height: _frameSize,
                child: AnimatedBuilder(
                  animation: _laserController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ScannerOverlayPainter(
                        laserPosition: _laserController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double laserPosition;

  const _ScannerOverlayPainter({required this.laserPosition});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLength = 24.0;
    const strokeWidth = 4.0;

    final cornerPaint = Paint()
      ..color = const Color(0xFF22C55E) // green
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset.zero, const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(Offset.zero, const Offset(0, cornerLength), cornerPaint);
    // Top-right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      cornerPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      cornerPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      cornerPaint,
    );

    // Animated laser line sweeping top to bottom and back.
    final laserPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    final y = size.height * laserPosition;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), laserPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.laserPosition != laserPosition;
  }
}
