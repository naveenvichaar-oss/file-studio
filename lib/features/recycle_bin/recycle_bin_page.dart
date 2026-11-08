import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/byte_format.dart';
import '../../data/models/recycle_item.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/toast_with_undo.dart';

class RecycleBinPage extends ConsumerWidget {
  const RecycleBinPage({super.key});

  Future<void> _restoreItem(BuildContext context, WidgetRef ref, RecycleItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(fileRepositoryProvider);
    try {
      await repo.undoDelete(item);
      ref.invalidate(recycleBinProvider);
      ref.invalidate(recentsProvider);
      if (context.mounted) {
        ToastWithUndo.showSimple(context, message: l10n.restoredFromRecycleBin(item.originalName));
      }
    } catch (e) {
      if (context.mounted) {
        ToastWithUndo.showSimple(context, message: l10n.errorOccurred(e.toString()), isError: true);
      }
    }
  }

  Future<void> _deletePermanently(BuildContext context, WidgetRef ref, RecycleItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'हमेशा के लिए हटाएँ?',
      message: 'क्या आप वाकई "${item.originalName}" को हमेशा के लिए हटाना चाहते हैं? इसे वापस नहीं लाया जा सकेगा।',
      confirmLabel: 'हमेशा के लिए हटाएँ',
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(recycleRepositoryProvider);
      await repo.deletePermanently(item);
      ref.invalidate(recycleBinProvider);
      if (context.mounted) {
        ToastWithUndo.showSimple(context, message: 'फ़ाइल हमेशा के लिए हटा दी गई');
      }
    }
  }

  Future<void> _emptyAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'रीसायकल बिन खाली करें?',
      message: 'रीसायकल बिन की सभी फ़ाइलें हमेशा के लिए हटा दी जाएँगी। क्या आप आगे बढ़ना चाहते हैं?',
      confirmLabel: 'खाली करें',
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed) {
      final repo = ref.read(recycleRepositoryProvider);
      await repo.clearAll();
      ref.invalidate(recycleBinProvider);
      if (context.mounted) {
        ToastWithUndo.showSimple(context, message: 'रीसायकल बिन खाली कर दिया गया');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(recycleBinProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recycleBin),
        actions: [
          itemsAsync.maybeWhen(
            data: (items) => items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'बिन खाली करें',
                    onPressed: () => _emptyAll(context, ref),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('त्रुटि: $err')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.delete_outline,
              title: l10n.emptyRecycleBin,
              subtitle: 'यहाँ कोई हटाई गई फ़ाइल नहीं है। हटाए गए आइटम 30 दिनों तक सुरक्षित रहते हैं।',
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final daysLeft = item.expiresAt.difference(DateTime.now()).inDays;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.delete, color: Colors.white, size: 20),
                ),
                title: Text(item.originalName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${ByteFormat.format(item.size)} · $daysLeft दिन शेष',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore, color: Colors.blue),
                      tooltip: l10n.undo,
                      onPressed: () => _restoreItem(context, ref, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'हमेशा के लिए हटाएँ',
                      onPressed: () => _deletePermanently(context, ref, item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
