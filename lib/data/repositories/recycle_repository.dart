import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/file_entry.dart';
import '../models/recycle_item.dart';
import '../storage/file_gateway.dart';

class RecycleRepository {
  static const String _prefKey = 'recycle_bin_items';

  Future<Directory> _getRecycleDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, '.file_studio', 'recycle_bin'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<RecycleItem> put(FileEntry f, Uint8List data) async {
    final recycleDir = await _getRecycleDir();
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}_${md5.convert(utf8.encode(f.uri)).toString().substring(0, 8)}';
    final backupFileName = '$id.bin';
    final backupFile = File(p.join(recycleDir.path, backupFileName));

    await backupFile.writeAsBytes(data, flush: true);

    final item = RecycleItem(
      id: id,
      originalUri: f.uri,
      originalName: f.name,
      deletedAt: now,
      backupPath: backupFile.path,
      size: data.length,
      expiresAt: now.add(const Duration(days: AppConstants.recycleBinRetentionDays)),
    );

    await _saveItem(item);
    return item;
  }

  Future<List<RecycleItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    final items = <RecycleItem>[];
    for (final s in raw) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        items.add(RecycleItem.fromJson(map));
      } catch (_) {}
    }
    items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return items;
  }

  Future<void> restore(RecycleItem item, FileGateway gw) async {
    final file = File(item.backupPath);
    if (!await file.exists()) {
      throw Exception('बैकअप फ़ाइल रीसायकल बिन में नहीं मिली');
    }
    final data = await file.readAsBytes();

    // Recreate or overwrite at original path
    final targetFile = File(item.originalUri);
    if (!await targetFile.parent.exists()) {
      await targetFile.parent.create(recursive: true);
    }
    await targetFile.writeAsBytes(data, flush: true);

    // Remove from recycle bin
    await deletePermanently(item);
  }

  Future<void> deletePermanently(RecycleItem item) async {
    final file = File(item.backupPath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    final updated = raw.where((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return map['id'] != item.id;
      } catch (_) {
        return false;
      }
    }).toList();
    await prefs.setStringList(_prefKey, updated);
  }

  Future<void> clearAll() async {
    final items = await getItems();
    for (final item in items) {
      final file = File(item.backupPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<void> _saveItem(RecycleItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    raw.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_prefKey, raw);
  }
}
