import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/utils/byte_format.dart';
import '../../workspace/document_session.dart';

enum TargetImageFormat { jpg, png, gif, bmp }

class ImageProcessor {
  /// Transforms and re-encodes image bytes
  static Uint8List processImage({
    required Uint8List inputBytes,
    required int rotationDegrees,
    required bool flipH,
    required bool flipV,
    int? resizeWidth,
    int? resizeHeight,
    TargetImageFormat format = TargetImageFormat.jpg,
    int quality = 85,
  }) {
    img.Image? decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      return inputBytes;
    }

    // 1. Rotation
    if (rotationDegrees != 0) {
      decoded = img.copyRotate(decoded, angle: rotationDegrees);
    }

    // 2. Flip
    if (flipH) {
      decoded = img.copyFlip(decoded, direction: img.FlipDirection.horizontal);
    }
    if (flipV) {
      decoded = img.copyFlip(decoded, direction: img.FlipDirection.vertical);
    }

    // 3. Resize if specified
    if (resizeWidth != null && resizeHeight != null && resizeWidth > 0 && resizeHeight > 0) {
      decoded = img.copyResize(decoded, width: resizeWidth, height: resizeHeight);
    }

    // 4. Encode according to selected format & quality
    switch (format) {
      case TargetImageFormat.jpg:
        return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
      case TargetImageFormat.png:
        return Uint8List.fromList(img.encodePng(decoded));
      case TargetImageFormat.gif:
        return Uint8List.fromList(img.encodeGif(decoded));
      case TargetImageFormat.bmp:
        return Uint8List.fromList(img.encodeBmp(decoded));
    }
  }
}

class ImageEditorDialog extends StatefulWidget {
  final DocumentSession session;

  const ImageEditorDialog({super.key, required this.session});

  @override
  State<ImageEditorDialog> createState() => _ImageEditorDialogState();
}

class _ImageEditorDialogState extends State<ImageEditorDialog> {
  TargetImageFormat _format = TargetImageFormat.jpg;
  double _quality = 85.0;
  bool _isProcessing = false;
  int? _origWidth;
  int? _origHeight;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _inspectOriginalImage();
  }

  void _inspectOriginalImage() {
    final decoded = img.decodeImage(widget.session.initialBytes);
    if (decoded != null) {
      _origWidth = decoded.width;
      _origHeight = decoded.height;
      _widthController.text = '$_origWidth';
      _heightController.text = '$_origHeight';
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _applyAndSave() async {
    setState(() => _isProcessing = true);

    try {
      final newW = int.tryParse(_widthController.text) ?? _origWidth;
      final newH = int.tryParse(_heightController.text) ?? _origHeight;

      final processedBytes = ImageProcessor.processImage(
        inputBytes: widget.session.initialBytes,
        rotationDegrees: widget.session.imageRotationDegrees,
        flipH: widget.session.imageFlippedH,
        flipV: widget.session.imageFlippedV,
        resizeWidth: newW,
        resizeHeight: newH,
        format: _format,
        quality: _quality.toInt(),
      );

      if (mounted) {
        Navigator.of(context).pop(processedBytes);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('इमेज एडिट व कंप्रेस करें'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format Selector
            const Text('फॉर्मेट चुनें:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<TargetImageFormat>(
              segments: const [
                ButtonSegment(value: TargetImageFormat.jpg, label: Text('JPG')),
                ButtonSegment(value: TargetImageFormat.png, label: Text('PNG')),
                ButtonSegment(value: TargetImageFormat.gif, label: Text('GIF')),
                ButtonSegment(value: TargetImageFormat.bmp, label: Text('BMP')),
              ],
              selected: {_format},
              onSelectionChanged: (set) => setState(() => _format = set.first),
            ),
            const SizedBox(height: 16),

            // Quality Slider (for JPG)
            if (_format == TargetImageFormat.jpg) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('क्वालिटी (Quality):'),
                  Text('${_quality.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _quality,
                min: 10,
                max: 100,
                divisions: 18,
                label: '${_quality.toInt()}%',
                onChanged: (val) => setState(() => _quality = val),
              ),
            ],

            const SizedBox(height: 8),

            // Resize dimensions
            const Text('रिसाइज़ (पिक्सेल):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'चौड़ाई (W)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ऊंचाई (H)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'मूल आकार: ${_origWidth ?? 0} × ${_origHeight ?? 0} px · ${ByteFormat.format(widget.session.initialBytes.length)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('रद्द करें'),
        ),
        FilledButton(
          onPressed: _isProcessing ? null : _applyAndSave,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('लागू करें (Apply)'),
        ),
      ],
    );
  }
}
