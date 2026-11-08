import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/byte_format.dart';
import '../../data/models/file_entry.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/toast_with_undo.dart';
import '../history/history_page.dart';
import '../viewers/viewer_registry.dart';
import 'action_bar.dart';
import 'document_session.dart';

class WorkspacePage extends ConsumerStatefulWidget {
  final FileEntry entry;

  const WorkspacePage({super.key, required this.entry});

  @override
  ConsumerState<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends ConsumerState<WorkspacePage> {
  late FileEntry _currentEntry;
  DocumentSession? _session;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(fileRepositoryProvider);
      final bytes = await repo.readBytes(_currentEntry);
      await repo.addRecent(_currentEntry);

      _session = DocumentSession(
        entry: _currentEntry,
        initialBytes: bytes,
      );
      _session!.addListener(_onSessionChanged);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session?.removeListener(_onSessionChanged);
    _session?.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_session == null || !_session!.isDirty) {
      return true;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await ConfirmDialog.show(
      context,
      title: l10n.unsavedChangesTitle,
      message: l10n.unsavedChangesMessage,
      confirmLabel: l10n.discard,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
    return discard;
  }

  Future<void> _handleSave() async {
    if (_session == null || !_session!.canSave) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(fileRepositoryProvider);
      final newBytes = _session!.exportBytes();
      await repo.save(_currentEntry, newBytes);
      _session!.markClean();
      if (mounted) {
        ToastWithUndo.showSimple(context, message: l10n.savedSuccessfully);
      }
    } catch (e) {
      if (mounted) {
        ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
      }
    }
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteConfirmTitle,
      message: l10n.deleteConfirmMessage(_currentEntry.name),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      final repo = ref.read(fileRepositoryProvider);
      final recycleItem = await repo.delete(_currentEntry);

      if (mounted) {
        ToastWithUndo.show(
          context,
          message: l10n.movedToRecycleBin(_currentEntry.name),
          undoLabel: l10n.undo,
          onUndo: () async {
            await repo.undoDelete(recycleItem);
          },
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
      }
    }
  }

  Future<void> _handleRename() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _currentEntry.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.fileNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _currentEntry.name) {
      try {
        final repo = ref.read(fileRepositoryProvider);
        final updated = await repo.rename(_currentEntry, newName);
        setState(() {
          _currentEntry = updated;
        });
        if (mounted) {
          ToastWithUndo.showSimple(context, message: 'नाम बदलकर "$newName" किया गया');
        }
      } catch (e) {
        if (mounted) {
          ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
        }
      }
    }
  }

  Future<void> _handleDuplicate() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(fileRepositoryProvider);
      final copy = await repo.duplicate(_currentEntry);
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'कॉपी बनाई गई: ${copy.name}');
      }
    } catch (e) {
      if (mounted) {
        ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
      }
    }
  }

  Future<void> _handleShare() async {
    final repo = ref.read(fileRepositoryProvider);
    await repo.shareFile(_currentEntry);
  }

  void _showProperties() async {
    final repo = ref.read(fileRepositoryProvider);
    String sha = 'गणना जारी है...';
    try {
      sha = await repo.calculateSha256(_currentEntry);
    } catch (_) {}

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'फ़ाइल विवरण (Properties)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: const Text('नाम'),
              subtitle: Text(_currentEntry.name),
            ),
            ListTile(
              dense: true,
              title: const Text('साइज'),
              subtitle: Text(ByteFormat.format(_currentEntry.size)),
            ),
            ListTile(
              dense: true,
              title: const Text('प्रकार (Type)'),
              subtitle: Text(_currentEntry.kind.name.toUpperCase()),
            ),
            ListTile(
              dense: true,
              title: const Text('पाथ'),
              subtitle: Text(_currentEntry.uri),
            ),
            ListTile(
              dense: true,
              title: const Text('SHA-256'),
              subtitle: SelectableText(sha, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory() async {
    final restored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HistoryPage(
          entry: _currentEntry,
          currentText: _session?.currentText ?? '',
        ),
      ),
    );

    if (restored == true && mounted) {
      _loadFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(_session?.isDirty ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentEntry.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    ByteFormat.format(_currentEntry.size),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (_session?.isDirty ?? false) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('बदलाव', style: TextStyle(fontSize: 10, color: Colors.orangeAccent)),
                  ],
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'शेयर करें',
              onPressed: _handleShare,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: _loadFile, child: const Text('पुनः प्रयास करें')),
                        ],
                      ),
                    ),
                  )
                : _session == null
                    ? const SizedBox.shrink()
                    : ViewerRegistry.buildViewer(_session!),
        bottomNavigationBar: _session != null
            ? WorkspaceActionBar(
                session: _session!,
                onToggleMode: () => _session!.toggleMode(),
                onSave: _session!.canSave ? _handleSave : null,
                onDelete: _handleDelete,
                onRename: _handleRename,
                onDuplicate: _handleDuplicate,
                onShare: _handleShare,
                onHistory: _showHistory,
                onProperties: _showProperties,
              )
            : null,
      ),
    );
  }
}
