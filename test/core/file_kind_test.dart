import 'package:flutter_test/flutter_test.dart';
import 'package:file_studio/core/file_kind.dart';

void main() {
  group('FileKindDetector Tests', () {
    test('Detects by extension', () {
      expect(FileKindDetector.detect('document.txt'), equals(FileKind.text));
      expect(FileKindDetector.detect('index.html'), equals(FileKind.html));
      expect(FileKindDetector.detect('data.csv'), equals(FileKind.csv));
      expect(FileKindDetector.detect('photo.jpg'), equals(FileKind.image));
      expect(FileKindDetector.detect('report.pdf'), equals(FileKind.pdf));
      expect(FileKindDetector.detect('song.mp3'), equals(FileKind.audio));
      expect(FileKindDetector.detect('video.mp4'), equals(FileKind.video));
      expect(FileKindDetector.detect('files.zip'), equals(FileKind.archive));
    });

    test('Detects by magic bytes when extension is missing', () {
      // JPEG magic: FF D8 FF
      expect(
        FileKindDetector.detect('unknown', [0xFF, 0xD8, 0xFF, 0xE0]),
        equals(FileKind.image),
      );

      // PNG magic: 89 50 4E 47
      expect(
        FileKindDetector.detect('unknown', [0x89, 0x50, 0x4E, 0x47]),
        equals(FileKind.image),
      );

      // PDF magic: %PDF
      expect(
        FileKindDetector.detect('unknown', [0x25, 0x50, 0x44, 0x46]),
        equals(FileKind.pdf),
      );

      // ZIP magic: PK..
      expect(
        FileKindDetector.detect('unknown', [0x50, 0x4B, 0x03, 0x04]),
        equals(FileKind.archive),
      );
    });

    test('Detects UTF-8 text vs binary via heuristic', () {
      // Printable UTF-8 text in Hindi
      final hindiText = 'नमस्ते भारत'.codeUnits;
      expect(FileKindDetector.detect('sample', hindiText), equals(FileKind.text));

      // Binary with null bytes
      final binaryBytes = [0x00, 0x01, 0x02, 0x00, 0xFF];
      expect(FileKindDetector.detect('sample', binaryBytes), equals(FileKind.binary));
    });

    test('isEditableText correctly filters text kinds', () {
      expect(FileKindDetector.isEditableText(FileKind.text), isTrue);
      expect(FileKindDetector.isEditableText(FileKind.html), isTrue);
      expect(FileKindDetector.isEditableText(FileKind.csv), isTrue);
      expect(FileKindDetector.isEditableText(FileKind.markdown), isTrue);
      expect(FileKindDetector.isEditableText(FileKind.json), isTrue);

      expect(FileKindDetector.isEditableText(FileKind.image), isFalse);
      expect(FileKindDetector.isEditableText(FileKind.pdf), isFalse);
      expect(FileKindDetector.isEditableText(FileKind.binary), isFalse);
    });
  });
}

