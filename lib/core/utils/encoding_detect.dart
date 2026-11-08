import 'dart:convert';
import 'dart:typed_data';

enum DetectedEncoding {
  utf8,
  utf16Le,
  utf16Be,
  latin1,
}

class EncodingDetector {
  static DetectedEncoding detect(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      return DetectedEncoding.utf8; // UTF-8 BOM
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      return DetectedEncoding.utf16Le; // UTF-16 LE BOM
    }
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      return DetectedEncoding.utf16Be; // UTF-16 BE BOM
    }

    try {
      utf8.decode(bytes);
      return DetectedEncoding.utf8;
    } catch (_) {
      return DetectedEncoding.latin1;
    }
  }

  static String decodeText(Uint8List bytes) {
    final enc = detect(bytes);
    switch (enc) {
      case DetectedEncoding.utf8:
        // Strip BOM if present
        if (bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF) {
          return utf8.decode(bytes.sublist(3), allowMalformed: true);
        }
        return utf8.decode(bytes, allowMalformed: true);
      case DetectedEncoding.utf16Le:
        final actual = (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE)
            ? bytes.sublist(2)
            : bytes;
        final buffer = actual.buffer.asUint16List(actual.offsetInBytes, actual.lengthInBytes ~/ 2);
        return String.fromCharCodes(buffer);
      case DetectedEncoding.utf16Be:
        final actual = (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF)
            ? bytes.sublist(2)
            : bytes;
        final chars = <int>[];
        for (int i = 0; i < actual.length - 1; i += 2) {
          chars.add((actual[i] << 8) | actual[i + 1]);
        }
        return String.fromCharCodes(chars);
      case DetectedEncoding.latin1:
        return latin1.decode(bytes, allowInvalid: true);
    }
  }

  static Uint8List encodeText(String text, [DetectedEncoding encoding = DetectedEncoding.utf8]) {
    switch (encoding) {
      case DetectedEncoding.utf8:
        return Uint8List.fromList(utf8.encode(text));
      case DetectedEncoding.latin1:
        return Uint8List.fromList(latin1.encode(text));
      case DetectedEncoding.utf16Le:
        final bytes = <int>[0xFF, 0xFE]; // BOM
        for (final unit in text.codeUnits) {
          bytes.add(unit & 0xFF);
          bytes.add((unit >> 8) & 0xFF);
        }
        return Uint8List.fromList(bytes);
      case DetectedEncoding.utf16Be:
        final bytes = <int>[0xFE, 0xFF]; // BOM
        for (final unit in text.codeUnits) {
          bytes.add((unit >> 8) & 0xFF);
          bytes.add(unit & 0xFF);
        }
        return Uint8List.fromList(bytes);
    }
  }
}

