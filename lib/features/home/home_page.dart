import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/file_kind.dart';
import '../../core/utils/byte_format.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/toast_with_undo.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  IconData _getIconForKind(FileKind kind) {
    switch (kind) {
      case FileKind.text:
      case FileKind.markdown:
      case FileKind.json:
        return Icons.description_outlined;
      case FileKind.html:
        return Icons.html_outlined;
      case FileKind.csv:
        return Icons.table_chart_outlined;
      case FileKind.image:
        return Icons.image_outlined;
      case FileKind.pdf:
        return Icons.picture_as_pdf_outlined;
      case FileKind.audio:
        return Icons.audio_file_outlined;
      case FileKind.video:
        return Icons.video_file_outlined;
      case FileKind.archive:
        return Icons.folder_zip_outlined;
      case FileKind.binary:
        return Icons.data_object_outlined;
    }
  }

  Color _getColorForKind(FileKind kind) {
    switch (kind) {
      case FileKind.text:
      case FileKind.markdown:
      case FileKind.json:
        return Colors.blue;
      case FileKind.html:
        return Colors.orange;
      case FileKind.csv:
        return Colors.green;
      case FileKind.image:
        return Colors.purple;
      case FileKind.pdf:
        return Colors.red;
      case FileKind.audio:
        return Colors.teal;
      case FileKind.video:
        return Colors.deepPurple;
      case FileKind.archive:
        return Colors.amber.shade800;
      case FileKind.binary:
        return Colors.blueGrey;
    }
  }

  Future<void> _pickAndOpenFile(BuildContext context, WidgetRef ref) async {
    final gateway = ref.read(fileGatewayProvider);
    final files = await gateway.pickFiles(multiple: false);
    if (files.isNotEmpty && context.mounted) {
      context.push('/workspace', extra: files.first);
    }
  }

  Future<void> _pickAndOpenFolder(BuildContext context, WidgetRef ref) async {
    final gateway = ref.read(fileGatewayProvider);
    final dir = await gateway.pickDirectory();
    if (dir != null && context.mounted) {
      context.push('/browser', extra: dir);
    }
  }

  Future<void> _createNewFile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: 'new_file.txt');

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newFile),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.fileNameLabel,
            border: const OutlineInputBorder(),
            hintText: 'उदा. notes.txt, data.csv',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.create),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && context.mounted) {
      try {
        final gateway = ref.read(fileGatewayProvider);
        final dir = await gateway.pickDirectory();
        if (dir != null) {
          final created = await gateway.create(dir, name, Uint8List(0));
          if (context.mounted) {
            context.push('/workspace', extra: created);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final recentsAsync = ref.watch(recentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.recycleBin,
            onPressed: () => context.push('/recycle-bin'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Quick action hero cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Open File Card
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickAndOpenFile(context, ref),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary,
                                    child: const Icon(Icons.file_open_rounded, color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.pickFile,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'फ़ाइल देखें या बदलें',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Open Folder Card
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickAndOpenFolder(context, ref),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.secondary,
                                    child: const Icon(Icons.folder_shared_rounded, color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.pickFolder,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'पूरा फ़ोल्डर ब्राउज़ करें',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // New File Quick Button
                    OutlinedButton.icon(
                      onPressed: () => _createNewFile(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.newFile),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section Header: Recent Files
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recents,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(recentsProvider),
                      child: const Text('रिफ्रेश'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Files List
            recentsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('त्रुटि: $err')),
              ),
              data: (files) {
                if (files.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.history,
                      title: l10n.emptyRecents,
                      subtitle: 'जब आप फ़ाइलें खोलेंगे, वे यहाँ दिखाई देंगी।',
                      action: FilledButton.icon(
                        onPressed: () => _pickAndOpenFile(context, ref),
                        icon: const Icon(Icons.file_open),
                        label: Text(l10n.pickFile),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final file = files[index];
                      final kindColor = _getColorForKind(file.kind);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kindColor.withValues(alpha: 0.12),
                          child: Icon(_getIconForKind(file.kind), color: kindColor),
                        ),
                        title: Text(
                          file.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${ByteFormat.format(file.size)} · ${file.kind.name.toUpperCase()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          context.push('/workspace', extra: file);
                        },
                      );
                    },
                    childCount: files.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
