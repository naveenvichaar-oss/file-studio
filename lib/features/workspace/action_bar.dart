import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

import 'document_session.dart';

class WorkspaceActionBar extends StatelessWidget {
  final DocumentSession session;
  final VoidCallback onToggleMode;
  final VoidCallback? onSave;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onHistory;
  final VoidCallback onProperties;

  const WorkspaceActionBar({
    super.key,
    required this.session,
    required this.onToggleMode,
    required this.onSave,
    required this.onDelete,
    required this.onRename,
    required this.onDuplicate,
    required this.onShare,
    required this.onHistory,
    required this.onProperties,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 1. OPEN / VIEW vs EDIT Toggle
            Expanded(
              child: OutlinedButton.icon(
                onPressed: session.isLargeFile ? null : onToggleMode,
                icon: Icon(
                  session.isEditMode ? Icons.edit_note : Icons.visibility_outlined,
                  size: 20,
                  color: session.isEditMode ? theme.colorScheme.primary : null,
                ),
                label: Text(
                  session.isEditMode ? l10n.editMode : l10n.readOnly,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: session.isEditMode ? theme.colorScheme.primary : null,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  side: session.isEditMode
                      ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 2. SAVE BUTTON
            Expanded(
              child: FilledButton.icon(
                onPressed: session.canSave ? onSave : null,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (session.isDirty) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 3. DELETE BUTTON
            IconButton.filledTonal(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: l10n.delete,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
            ),
            const SizedBox(width: 4),

            // 4. OVERFLOW MENU (Rename, Duplicate, Share, History, Properties)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'अतिरिक्त विकल्प',
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    onRename();
                    break;
                  case 'duplicate':
                    onDuplicate();
                    break;
                  case 'share':
                    onShare();
                    break;
                  case 'history':
                    onHistory();
                    break;
                  case 'properties':
                    onProperties();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.drive_file_rename_outline),
                    title: Text(l10n.rename),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.copy_outlined),
                    title: Text(l10n.duplicate),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.share_outlined),
                    title: Text(l10n.share),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_outlined),
                    title: Text(l10n.history),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'properties',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.properties),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
