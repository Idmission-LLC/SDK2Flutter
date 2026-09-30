import 'dart:typed_data';

import 'package:flutter/material.dart';

const _labels = {
  'selfie': 'Selfie',
  'idFront': 'ID Front',
  'idBack': 'ID Back',
  'barcodeImage': 'Barcode',
};
const _order = ['selfie', 'idFront', 'idBack', 'barcodeImage'];

/// Row of small thumbnails, one per captured image. Tapping a thumbnail opens
/// a full-screen viewer with a close button.
class CapturedImagesStrip extends StatelessWidget {
  const CapturedImagesStrip({super.key, required this.images});

  final Map<String, Uint8List> images;

  @override
  Widget build(BuildContext context) {
    final keys = _order.where(images.containsKey).toList();
    if (keys.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CAPTURED IMAGES',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: keys.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final key = keys[i];
                  return GestureDetector(
                    onTap: () => showCapturedImageViewer(
                      context,
                      {for (final k in keys) k: images[k]!},
                      initialKey: key,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            images[key]!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[key] ?? key,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen viewer: swipe between images, pinch to zoom, X to close.
Future<void> showCapturedImageViewer(
  BuildContext context,
  Map<String, Uint8List> images, {
  String? initialKey,
}) {
  final keys = _order.where(images.containsKey).toList();
  final initial = initialKey == null ? 0 : keys.indexOf(initialKey).clamp(0, keys.length - 1);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    useSafeArea: false,
    builder: (_) => _Viewer(images: images, keys: keys, initial: initial),
  );
}

class _Viewer extends StatefulWidget {
  const _Viewer({required this.images, required this.keys, required this.initial});

  final Map<String, Uint8List> images;
  final List<String> keys;
  final int initial;

  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final PageController _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.keys.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(child: Image.memory(widget.images[widget.keys[i]]!)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    '${_labels[widget.keys[_index]] ?? widget.keys[_index]}'
                    '${widget.keys.length > 1 ? '  (${_index + 1}/${widget.keys.length})' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
