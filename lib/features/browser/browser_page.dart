import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/byte_format.dart';
import '../../data/models/file_entry.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/toast_with_undo.dart';
import '../tools/batch_rename_dialog.dart';
import '../tools/zip_tools.dart';

class BrowserPage extends ConsumerStatefulWidget {
  final FileEntry directory;

  const BrowserPage({super.key, required this.directory});

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  late FileEntry _currentDir;
  List<FileEntry> _entries = [];
  bool _isLoading = true;
  String? _error;

  // Multi-select state
  bool _isMultiSelect = false;
  final Set<String> _selectedUris = {};

  @override
  void initState() {
    super.initState();
    _currentDir = widget.directory;
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedUris.clear();
      _isMultiSelect = false;
    });

    try {
      final gateway = ref.read(fileGatewayProvider);
      final list = await gateway.list(_currentDir);
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _toggleSelect(FileEntry entry) {
    setState(() {
      if (_selectedUris.contains(entry.uri)) {
        _selectedUris.remove(entry.uri);
        if (_selectedUris.isEmpty) {
          _isMultiSelect = false;
        }
      } else {
        _selectedUris.add(entry.uri);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedUris.length == _entries.length) {
        _selectedUris.clear();
        _isMultiSelect = false;
      } else {
        _selectedUris.addAll(_entries.map((e) => e.uri));
      }
    });
  }

  Future<void> _batchDelete() async {
    final count = _selectedUris.length;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'चयनित फ़ाइलें हटाएँ?',
      message: 'क्या आप वाकई इन $count फ़ाइलों/फ़ोल्डर्स को हटाना चाहते हैं? वे रीसायकल बिन में सुरक्षित रहेंगी।',
      confirmLabel: 'हटाएँ',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final repo = ref.read(fileRepositoryProvider);
    final selectedEntries = _entries.where((e) => _selectedUris.contains(e.uri)).toList();

    int deletedCount = 0;
    for (final entry in selectedEntries) {
      if (!entry.isDirectory) {
        try {
          await repo.delete(entry);
          deletedCount++;
        } catch (_) {}
      }
    }

    _loadDirectory();
    if (mounted) {
      ToastWithUndo.showSimple(context, message: '$deletedCount फ़ाइलें रीसायकल बिन में भेजी गईं');
    }
  }

  Future<void> _batchShare() async {
    final selectedEntries = _entries.where((e) => _selectedUris.contains(e.uri) && !e.isDirectory).toList();
    if (selectedEntries.isEmpty) return;

    final files = selectedEntries.map((e) => XFile(e.uri)).toList();
    await SharePlus.instance.share(ShareParams(files: files));
  }

  Future<void> _batchZip() async {
    final selectedPaths = _selectedUris.toList();
    if (selectedPaths.isEmpty) return;

    final zipName = 'archive_${DateTime.now().millisecondsSinceEpoch}.zip';
    final outPath = p.join(_currentDir.uri, zipName);

    try {
      await ZipTools.createZip(filePaths: selectedPaths, outputZipPath: outPath);
      _loadDirectory();
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'ZIP आर्काइव बनाया गया: $zipName');
      }
    } catch (e) {
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'ZIP बनाने में त्रुटि: $e', isError: true);
      }
    }
  }

  Future<void> _batchRename() async {
    final selectedEntries = _entries.where((e) => _selectedUris.contains(e.uri)).toList();
    if (selectedEntries.isEmpty) return;

    final renames = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => BatchRenameDialog(files: selectedEntries),
    );

    if (renames != null && renames.isNotEmpty) {
      final repo = ref.read(fileRepositoryProvider);
      int count = 0;
      for (final entry in selectedEntries) {
        final newName = renames[entry.uri];
        if (newName != null && newName != entry.name) {
          try {
            await repo.rename(entry, newName);
            count++;
          } catch (_) {}
        }
      }
      _loadDirectory();
      if (mounted) {
        ToastWithUndo.showSimple(context, message: '$count फ़ाइलों के नाम बदले गए');
      }
    }
  }

  Future<void> _createNewFile() async {
    final controller = TextEditingController(text: 'untitled.txt');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('नई फ़ाइल बनाएँ'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'फ़ाइल का नाम',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करें')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('बनाएँ'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      try {
        final gateway = ref.read(fileGatewayProvider);
        final created = await gateway.create(_currentDir, name, Uint8List(0));
        _loadDirectory();
        if (mounted) {
          context.push('/workspace', extra: created);
        }
      } catch (e) {
        if (mounted) {
          ToastWithUndo.showSimple(context, message: 'त्रुटि: $e', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isMultiSelect
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMultiSelect = false;
                    _selectedUris.clear();
                  });
                },
              ),
              title: Text('${_selectedUris.length} चयनित'),
              actions: [
                IconButton(
                  icon: Icon(
                    _selectedUris.length == _entries.length
                        ? Icons.select_all
                        : Icons.check_box_outline_blank,
                  ),
                  tooltip: 'सभी चुनें',
                  onPressed: _selectAll,
                ),
                IconButton(
                  icon: const Icon(Icons.drive_file_rename_outline),
                  tooltip: 'बैच नाम बदलें',
                  onPressed: _selectedUris.isNotEmpty ? _batchRename : null,
                ),
                IconButton(
                  icon: const Icon(Icons.folder_zip_outlined),
                  tooltip: 'ZIP बनाएँ',
                  onPressed: _selectedUris.isNotEmpty ? _batchZip : null,
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'शेयर करें',
                  onPressed: _selectedUris.isNotEmpty ? _batchShare : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'हटाएँ',
                  onPressed: _selectedUris.isNotEmpty ? _batchDelete : null,
                ),
              ],
            )
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentDir.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _currentDir.uri,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'खोजें',
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'नई फ़ाइल',
                  onPressed: _createNewFile,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'रिफ्रेश',
                  onPressed: _loadDirectory,
                ),
              ],
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('त्रुटि: $_error'))
              : _entries.isEmpty
                  ? const EmptyState(
                      icon: Icons.folder_open,
                      title: 'यह फ़ोल्डर खाली है',
                      subtitle: 'यहाँ कोई फ़ाइल या फ़ोल्डर नहीं है',
                    )
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        final isSelected = _selectedUris.contains(entry.uri);

                        return ListTile(
                          selected: isSelected,
                          leading: _isMultiSelect
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleSelect(entry),
                                )
                              : CircleAvatar(
                                  backgroundColor: entry.isDirectory
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                                  child: Icon(
                                    entry.isDirectory ? Icons.folder : Icons.insert_drive_file_outlined,
                                    color: entry.isDirectory
                                        ? Colors.amber.shade800
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                          title: Text(
                            entry.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            entry.isDirectory
                                ? 'फ़ोल्डर'
                                : '${ByteFormat.format(entry.size)} · ${entry.kind.name.toUpperCase()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: !_isMultiSelect ? const Icon(Icons.chevron_right, size: 20) : null,
                          onLongPress: () {
                            if (!_isMultiSelect) {
                              setState(() {
                                _isMultiSelect = true;
                                _selectedUris.add(entry.uri);
                              });
                            }
                          },
                          onTap: () {
                            if (_isMultiSelect) {
                              _toggleSelect(entry);
                            } else {
                              if (entry.isDirectory) {
                                setState(() {
                                  _currentDir = entry;
                                });
                                _loadDirectory();
                              } else {
                                context.push('/workspace', extra: entry);
                              }
                            }
                          },
                        );
                      },
                    ),
    );
  }
}
