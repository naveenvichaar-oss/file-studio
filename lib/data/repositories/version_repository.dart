import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/file_entry.dart';
import '../models/file_version.dart';

class VersionRepository {
  static const String _prefKey = 'file_versions_index';

  Future<Directory> _getVersionsDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, '.file_studio', 'versions'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<FileVersion> snapshot(FileEntry f, Uint8List currentData) async {
    final versionsDir = await _getVersionsDir();
    final entryHash = md5.convert(utf8.encode(f.uri)).toString();
    final timestamp = DateTime.now();
    final versionId = '${timestamp.millisecondsSinceEpoch}';
    final backupFileName = '${entryHash}_$versionId.bak';
    final backupFile = File(p.join(versionsDir.path, backupFileName));

    await backupFile.writeAsBytes(currentData, flush: true);

    final version = FileVersion(
      versionId: versionId,
      entryId: f.uri,
      fileName: f.name,
      createdAt: timestamp,
      backupPath: backupFile.path,
      size: currentData.length,
    );

    await _saveVersionIndex(version);
    return version;
  }

  Future<List<FileVersion>> getVersions(String entryUri) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    final list = <FileVersion>[];
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        final v = FileVersion.fromJson(map);
        if (v.entryId == entryUri) {
          list.add(v);
        }
      } catch (_) {}
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<Uint8List?> readVersionData(FileVersion version) async {
    final file = File(version.backupPath);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<void> _saveVersionIndex(FileVersion version) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey) ?? [];
    list.add(jsonEncode(version.toJson()));
    await prefs.setStringList(_prefKey, list);
  }
}

