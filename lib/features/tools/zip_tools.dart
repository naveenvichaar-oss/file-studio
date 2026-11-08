import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class ZipTools {
  /// Compresses a list of file paths into a single .zip file
  static Future<File> createZip({
    required List<String> filePaths,
    required String outputZipPath,
  }) async {
    final archive = Archive();

    for (final path in filePaths) {
      final file = File(path);
      if (await file.exists()) {
        final data = await file.readAsBytes();
        archive.addFile(ArchiveFile(p.basename(path), data.length, data));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    final outFile = File(outputZipPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsBytes(zipData, flush: true);
    return outFile;
  }

  /// Extracts a .zip file into target directory
  static Future<void> extractZip({
    required String zipPath,
    required String targetDirPath,
  }) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      final outPath = p.join(targetDirPath, file.name);
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>, flush: true);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
  }
}
