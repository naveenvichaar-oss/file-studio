import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_studio/core/file_kind.dart';
import 'package:file_studio/core/utils/encoding_detect.dart';
import 'package:file_studio/data/models/file_entry.dart';
import 'package:file_studio/features/workspace/document_session.dart';

void main() {
  group('DocumentSession & File Integrity Tests', () {
    test('Default mode is readOnly and canSave is false initially', () {
      final initialData = utf8.encode('Hello World');
      final entry = FileEntry(
        id: 'test.txt',
        uri: 'test.txt',
        name: 'test.txt',
        size: initialData.length,
        modified: DateTime.now(),
        kind: FileKind.text,
      );

      final session = DocumentSession(
        entry: entry,
        initialBytes: Uint8List.fromList(initialData),
      );

      expect(session.mode, equals(EditMode.readOnly));
      expect(session.canSave, isFalse);
      expect(session.isDirty, isFalse);

      // Switching to Edit mode
      session.toggleMode();
      expect(session.mode, equals(EditMode.edit));
      expect(session.canSave, isFalse); // Still false because not dirty

      // Mutating text makes it dirty and canSave true
      session.updateText('Hello Modified World');
      expect(session.isDirty, isTrue);
      expect(session.canSave, isTrue);

      // Toggling back to readOnly makes canSave false
      session.toggleMode();
      expect(session.mode, equals(EditMode.readOnly));
      expect(session.canSave, isFalse);
    });

    test('Hindi (Devanagari) UTF-8 text round-trip preservation without corruption', () {
      const hindiOriginal = 'फ़ाइल स्टूडियो — सुरक्षित मोबाइल फ़ाइल मैनेजर एवं एडिटर (UTF-8 परीक्षण)';
      final encodedBytes = EncodingDetector.encodeText(hindiOriginal);
      final decodedText = EncodingDetector.decodeText(encodedBytes);

      expect(decodedText, equals(hindiOriginal));
    });

    test('Undo and Redo stack works correctly in DocumentSession', () {
      final initialData = utf8.encode('Line 1');
      final entry = FileEntry(
        id: 'notes.txt',
        uri: 'notes.txt',
        name: 'notes.txt',
        size: initialData.length,
        modified: DateTime.now(),
        kind: FileKind.text,
      );

      final session = DocumentSession(
        entry: entry,
        initialBytes: Uint8List.fromList(initialData),
      );

      session.toggleMode(); // To Edit mode
      expect(session.canUndo, isFalse);

      session.updateText('Line 1 + Line 2');
      expect(session.canUndo, isTrue);

      session.undo();
      expect(session.currentText, equals('Line 1'));
      expect(session.canRedo, isTrue);

      session.redo();
      expect(session.currentText, equals('Line 1 + Line 2'));
    });
  });
}

