import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:file_studio/features/viewers/image/image_editor.dart';

void main() {
  group('ImageProcessor Tests', () {
    late Uint8List testImageBytes;

    setUp(() {
      // Create a 100x50 red test image
      final testImg = img.Image(width: 100, height: 50);
      img.fill(testImg, color: img.ColorRgb8(255, 0, 0));
      testImageBytes = Uint8List.fromList(img.encodePng(testImg));
    });

    test('Rotates image and swaps width/height on 90 deg', () {
      final processed = ImageProcessor.processImage(
        inputBytes: testImageBytes,
        rotationDegrees: 90,
        flipH: false,
        flipV: false,
        format: TargetImageFormat.png,
      );

      final decoded = img.decodeImage(processed);
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(50));
      expect(decoded.height, equals(100));
    });

    test('Resizes image to target dimensions', () {
      final processed = ImageProcessor.processImage(
        inputBytes: testImageBytes,
        rotationDegrees: 0,
        flipH: false,
        flipV: false,
        resizeWidth: 40,
        resizeHeight: 20,
        format: TargetImageFormat.jpg,
        quality: 90,
      );

      final decoded = img.decodeImage(processed);
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(40));
      expect(decoded.height, equals(20));
    });
  });
}

