import 'dart:convert';
import 'dart:typed_data';

/// Display-only helpers for the JSON the plugin returns. The plugin sends the
/// SDK result unchanged; masking base64 and pulling out the images for the
/// thumbnails happens here, in the app.
class FormattedResult {
  FormattedResult(this.text, this.images);

  /// Pretty-printed JSON with base64 values shown as `...`.
  final String text;

  /// Images found in the result, keyed selfie / idFront / idBack / barcodeImage.
  final Map<String, Uint8List> images;
}

FormattedResult formatResult(String raw) {
  dynamic parsed;
  try {
    parsed = jsonDecode(raw);
  } catch (_) {
    return FormattedResult(raw, {});
  }
  if (parsed is! Map && parsed is! List) return FormattedResult(raw, {});

  final images = <String, Uint8List>{};
  if (parsed is Map<String, dynamic>) {
    _collect(images, 'idFront', _path(parsed, ['front', 'image']));
    _collect(images, 'idBack', _path(parsed, ['back', 'image']));
    _collect(
      images,
      'barcodeImage',
      _path(parsed, ['front', 'barcodeImage']) ?? _path(parsed, ['back', 'barcodeImage']),
    );
    _collect(images, 'selfie', _path(parsed, ['selfie', 'image']));
  }
  final text = const JsonEncoder.withIndent('  ').convert(_mask(parsed, ''));
  return FormattedResult(text, images);
}

dynamic _path(Map<String, dynamic> root, List<String> keys) {
  dynamic node = root;
  for (final key in keys) {
    if (node is Map && node.containsKey(key)) {
      node = node[key];
    } else {
      return null;
    }
  }
  return node;
}

void _collect(Map<String, Uint8List> out, String key, dynamic value) {
  if (value is! String || value.isEmpty) return;
  try {
    out[key] = base64Decode(value);
  } catch (_) {}
}

final _base64Chars = RegExp(r'^[A-Za-z0-9+/=\s]+$');

dynamic _mask(dynamic value, String key) {
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _mask(v, k.toString())));
  }
  if (value is List) return value.map((v) => _mask(v, key)).toList();
  if (value is String && value.length >= 100) {
    final k = key.toLowerCase();
    if (k.contains('base64') || k.contains('image') || k.contains('selfie')) return '...';
    if (value.startsWith('data:image')) return '...';
    if (value.length >= 1000 && _base64Chars.hasMatch(value)) return '...';
  }
  return value;
}
