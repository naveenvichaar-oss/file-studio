import 'dart:typed_data';
import '../models/file_entry.dart';

abstract class FileGateway {
  Future<List<FileEntry>> pickFiles({bool multiple = true});
  Future<FileEntry?> pickDirectory();
  Future<List<FileEntry>> list(FileEntry directory);
  Future<Uint8List> readBytes(FileEntry f);
  Stream<List<int>> readStream(FileEntry f); // For large files (>5 MB)
  Future<void> writeBytes(FileEntry f, Uint8List data); // Overwrite
  Future<FileEntry> create(FileEntry dir, String name, Uint8List data);
  Future<void> delete(FileEntry f);
  Future<FileEntry> rename(FileEntry f, String newName);
  Future<FileEntry> getFileEntryFromPath(String path);
}

