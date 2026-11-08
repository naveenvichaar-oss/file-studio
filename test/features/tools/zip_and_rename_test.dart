import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_studio/core/file_kind.dart';
import 'package:file_studio/data/models/file_entry.dart';
import 'package:file_studio/features/tools/zip_tools.dart';

void main() {
  group('Phase 3: Zip & Batch Tools Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('file_studio_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Creates and extracts a valid ZIP file', () async {
      // 1. Create two test files
      final file1 = File('${tempDir.path}/hello.txt');
      await file1.writeAsString('Hello Antigravity');

      final file2 = File('${tempDir.path}/data.csv');
      await file2.writeAsString('a,b,c\n1,2,3');

      final zipPath = '${tempDir.path}/output.zip';

      // 2. Compress
      final zipFile = await ZipTools.createZip(
        filePaths: [file1.path, file2.path],
        outputZipPath: zipPath,
      );

      expect(await zipFile.exists(), isTrue);
      expect(await zipFile.length(), greaterThan(0));

      // 3. Extract to subfolder
      final extractDir = '${tempDir.path}/extracted';
      await ZipTools.extractZip(zipPath: zipPath, targetDirPath: extractDir);

      final extracted1 = File('$extractDir/hello.txt');
      final extracted2 = File('$extractDir/data.csv');

      expect(await extracted1.exists(), isTrue);
      expect(await extracted1.readAsString(), equals('Hello Antigravity'));
      expect(await extracted2.exists(), isTrue);
    });

    test('FileEntry creation with attributes', () {
      final entry = FileEntry(
        id: '1',
        uri: '/path/doc.pdf',
        name: 'doc.pdf',
        size: 1024,
        modified: DateTime.now(),
        kind: FileKind.pdf,
        isWritable: true,
      );

      expect(entry.name, equals('doc.pdf'));
      expect(entry.kind, equals(FileKind.pdf));
      expect(entry.isDirectory, isFalse);
    });
  });
}

