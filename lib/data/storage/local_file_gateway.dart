import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors.dart';
import '../../core/file_kind.dart';
import '../models/file_entry.dart';
import 'file_gateway.dart';

class LocalFileGateway implements FileGateway {
  @override
  Future<List<FileEntry>> pickFiles({bool multiple = true}) async {
    final List<PlatformFile> files;
    if (multiple) {
      files = await FilePicker.pickFiles();
    } else {
      final single = await FilePicker.pickFile();
      files = single != null ? [single] : [];
    }

    if (files.isEmpty) {
      return [];
    }

    final entries = <FileEntry>[];
    for (final file in files) {
      if (file.path != null) {
        final ioFile = File(file.path!);
        if (await ioFile.exists()) {
          final stat = await ioFile.stat();
          final name = file.name;
          List<int>? header;
          try {
            final raf = await ioFile.open(mode: FileMode.read);
            header = await raf.read(64);
            await raf.close();
          } catch (_) {}

          final kind = FileKindDetector.detect(name, header);
          entries.add(FileEntry(
            id: file.path!,
            uri: file.path!,
            name: name,
            size: stat.size,
            modified: stat.modified,
            kind: kind,
            isWritable: true,
          ));
        }
      }
    }
    return entries;
  }

  @override
  Future<FileEntry?> pickDirectory() async {
    final dirPath = await FilePicker.getDirectoryPath();
    if (dirPath == null) return null;

    final dir = Directory(dirPath);
    if (!await dir.exists()) return null;

    final stat = await dir.stat();
    final name = p.basename(dirPath);

    return FileEntry(
      id: dirPath,
      uri: dirPath,
      name: name.isEmpty ? dirPath : name,
      size: 0,
      modified: stat.modified,
      kind: FileKind.binary,
      isDirectory: true,
      isWritable: true,
    );
  }

  @override
  Future<List<FileEntry>> list(FileEntry directory) async {
    final dir = Directory(directory.uri);
    if (!await dir.exists()) {
      throw FileNotFoundAppError('फ़ोल्डर नहीं मिला: ${directory.uri}');
    }

    final entries = <FileEntry>[];
    await for (final entity in dir.list(followLinks: false)) {
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      final isDir = entity is Directory;

      FileKind kind = FileKind.binary;
      if (!isDir) {
        List<int>? header;
        try {
          final file = File(entity.path);
          final raf = await file.open(mode: FileMode.read);
          header = await raf.read(64);
          await raf.close();
        } catch (_) {}
        kind = FileKindDetector.detect(name, header);
      }

      entries.add(FileEntry(
        id: entity.path,
        uri: entity.path,
        name: name,
        size: isDir ? 0 : stat.size,
        modified: stat.modified,
        kind: kind,
        isDirectory: isDir,
        isWritable: true,
      ));
    }

    entries.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  @override
  Future<Uint8List> readBytes(FileEntry f) async {
    final file = File(f.uri);
    if (!await file.exists()) {
      throw FileNotFoundAppError(f.uri);
    }
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw FileReadError(f.uri, e);
    }
  }

  @override
  Stream<List<int>> readStream(FileEntry f) {
    final file = File(f.uri);
    return file.openRead();
  }

  @override
  Future<void> writeBytes(FileEntry f, Uint8List data) async {
    final file = File(f.uri);
    try {
      await file.writeAsBytes(data, flush: true);
    } catch (e) {
      throw FileWriteError(f.uri, e);
    }
  }

  @override
  Future<FileEntry> create(FileEntry dir, String name, Uint8List data) async {
    final targetPath = p.join(dir.uri, name);
    final file = File(targetPath);
    try {
      await file.writeAsBytes(data, flush: true);
      final stat = await file.stat();
      final kind = FileKindDetector.detect(name, data.take(64).toList());
      return FileEntry(
        id: targetPath,
        uri: targetPath,
        name: name,
        size: stat.size,
        modified: stat.modified,
        kind: kind,
        isWritable: true,
      );
    } catch (e) {
      throw FileWriteError(targetPath, e);
    }
  }

  @override
  Future<void> delete(FileEntry f) async {
    final file = File(f.uri);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        throw FileDeleteError(f.uri, e);
      }
    }
  }

  @override
  Future<FileEntry> rename(FileEntry f, String newName) async {
    final file = File(f.uri);
    final newPath = p.join(p.dirname(f.uri), newName);
    try {
      final renamed = await file.rename(newPath);
      final stat = await renamed.stat();
      final kind = FileKindDetector.detect(newName);
      return f.copyWith(
        id: newPath,
        uri: newPath,
        name: newName,
        size: stat.size,
        modified: stat.modified,
        kind: kind,
      );
    } catch (e) {
      throw FileWriteError(newPath, e);
    }
  }

  @override
  Future<FileEntry> getFileEntryFromPath(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileNotFoundAppError(path);
    }
    final stat = await file.stat();
    final name = p.basename(path);
    List<int>? header;
    try {
      final raf = await file.open(mode: FileMode.read);
      header = await raf.read(64);
      await raf.close();
    } catch (_) {}

    final kind = FileKindDetector.detect(name, header);
    return FileEntry(
      id: path,
      uri: path,
      name: name,
      size: stat.size,
      modified: stat.modified,
      kind: kind,
      isWritable: true,
    );
  }

  Future<FileEntry> getAppDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final stat = await dir.stat();
    return FileEntry(
      id: dir.path,
      uri: dir.path,
      name: 'App Documents',
      size: 0,
      modified: stat.modified,
      kind: FileKind.binary,
      isDirectory: true,
    );
  }
}
