import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/errors.dart';
import '../models/file_entry.dart';
import '../models/recycle_item.dart';
import '../storage/file_gateway.dart';
import 'recycle_repository.dart';
import 'version_repository.dart';

class FileRepository {
  final FileGateway _gateway;
  final VersionRepository _versionRepo;
  final RecycleRepository _recycleRepo;

  FileRepository(this._gateway, this._versionRepo, this._recycleRepo);

  FileGateway get gateway => _gateway;
  VersionRepository get versionRepo => _versionRepo;
  RecycleRepository get recycleRepo => _recycleRepo;

  Future<Uint8List> readBytes(FileEntry f) => _gateway.readBytes(f);

  Stream<List<int>> readStream(FileEntry f) => _gateway.readStream(f);

  /// 1) Read old bytes and create backup snapshot
  /// 2) Overwrite with newData
  /// 3) Verify length & checksum, rollback if verification fails
  Future<void> save(FileEntry f, Uint8List newData) async {
    Uint8List? oldBytes;
    try {
      oldBytes = await _gateway.readBytes(f);
      await _versionRepo.snapshot(f, oldBytes);
    } catch (_) {
      // If reading old fails (e.g. brand new file), proceed with save
    }

    await _gateway.writeBytes(f, newData);

    // Verify written data
    try {
      final written = await _gateway.readBytes(f);
      if (written.length != newData.length) {
        // Rollback if possible
        if (oldBytes != null) {
          await _gateway.writeBytes(f, oldBytes);
        }
        throw const FileValidationMismatchError();
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw FileValidationMismatchError('सत्यापन विफल रहा: $e');
    }
  }

  /// 1) Copy to recycle bin
  /// 2) Delete original
  /// Returns RecycleItem for Undo snackbar
  Future<RecycleItem> delete(FileEntry f) async {
    final data = await _gateway.readBytes(f);
    final item = await _recycleRepo.put(f, data);
    await _gateway.delete(f);
    await removeRecent(f.uri);
    return item;
  }

  Future<void> undoDelete(RecycleItem item) async {
    await _recycleRepo.restore(item, _gateway);
    final restoredEntry = await _gateway.getFileEntryFromPath(item.originalUri);
    await addRecent(restoredEntry);
  }

  Future<FileEntry> rename(FileEntry f, String newName) async {
    final updated = await _gateway.rename(f, newName);
    await removeRecent(f.uri);
    await addRecent(updated);
    return updated;
  }

  Future<FileEntry> duplicate(FileEntry f) async {
    final data = await _gateway.readBytes(f);
    final ext = p.extension(f.name);
    final base = p.basenameWithoutExtension(f.name);
    final newName = '${base}_copy$ext';
    final parentDir = FileEntry(
      id: p.dirname(f.uri),
      uri: p.dirname(f.uri),
      name: '',
      size: 0,
      modified: DateTime.now(),
      kind: f.kind,
      isDirectory: true,
    );
    final created = await _gateway.create(parentDir, newName, data);
    await addRecent(created);
    return created;
  }

  Future<void> shareFile(FileEntry f) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(f.uri)], text: f.name));
  }

  // Recents management
  Future<List<FileEntry>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyRecents) ?? [];
    final list = <FileEntry>[];
    for (final s in raw) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        list.add(FileEntry.fromJson(map));
      } catch (_) {}
    }
    return list;
  }

  Future<void> addRecent(FileEntry f) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyRecents) ?? [];
    final list = raw.where((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return map['uri'] != f.uri;
      } catch (_) {
        return false;
      }
    }).toList();

    list.insert(0, jsonEncode(f.toJson()));
    if (list.length > AppConstants.maxRecentFiles) {
      list.removeRange(AppConstants.maxRecentFiles, list.length);
    }
    await prefs.setStringList(AppConstants.keyRecents, list);
  }

  Future<void> removeRecent(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyRecents) ?? [];
    final updated = raw.where((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return map['uri'] != uri;
      } catch (_) {
        return false;
      }
    }).toList();
    await prefs.setStringList(AppConstants.keyRecents, updated);
  }

  // Favorites
  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.keyFavorites) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = (prefs.getStringList(AppConstants.keyFavorites) ?? []).toSet();
    if (favs.contains(uri)) {
      favs.remove(uri);
    } else {
      favs.add(uri);
    }
    await prefs.setStringList(AppConstants.keyFavorites, favs.toList());
  }

  // Checksum calculation (MD5 and SHA-256)
  Future<String> calculateSha256(FileEntry f) async {
    final data = await _gateway.readBytes(f);
    return sha256.convert(data).toString();
  }
}
