import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/byte_format.dart';
import '../../core/utils/encoding_detect.dart';
import '../../data/models/file_entry.dart';
import '../../data/models/file_version.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/toast_with_undo.dart';
import 'diff_view.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final FileEntry entry;
  final String currentText;

  const HistoryPage({
    super.key,
    required this.entry,
    required this.currentText,
  });

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  List<FileVersion> _versions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() => _isLoading = true);
    final repo = ref.read(fileRepositoryProvider);
    final list = await repo.versionRepo.getVersions(widget.entry.uri);
    setState(() {
      _versions = list;
      _isLoading = false;
    });
  }

  Future<void> _showDiffWithCurrent(FileVersion version) async {
    final repo = ref.read(fileRepositoryProvider);
    final bytes = await repo.versionRepo.readVersionData(version);
    if (bytes == null || !mounted) return;

    final oldText = EncodingDetector.decodeText(bytes);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiffView(
          oldTitle: 'वर्ज़न ${version.createdAt.toLocal().toString().split('.').first}',
          newTitle: 'वर्तमान फ़ाइल',
          oldText: oldText,
          newText: widget.currentText,
        ),
      ),
    );
  }

  Future<void> _restoreVersion(FileVersion version) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'वर्ज़न रीस्टोर करें?',
      message: 'क्या आप इस फ़ाइल को ${version.createdAt.toLocal().toString().split('.').first} के वर्ज़न पर वापस लाना चाहते हैं? वर्तमान फ़ाइल का एक नया बैकअप अपने आप बन जाएगा।',
      confirmLabel: 'रीस्टोर करें',
    );

    if (!confirmed || !mounted) return;

    final repo = ref.read(fileRepositoryProvider);
    final data = await repo.versionRepo.readVersionData(version);
    if (data != null) {
      await repo.save(widget.entry, data);
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'वर्ज़न सफलतापूर्वक रीस्टोर हो गया');
        Navigator.of(context).pop(true); // Return true to indicate restore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('वर्ज़न इतिहास (Version History)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.entry.name, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _versions.isEmpty
              ? const EmptyState(
                  icon: Icons.history_toggle_off,
                  title: 'कोई पुराना वर्ज़न नहीं मिला',
                  subtitle: 'जब आप फ़ाइल में बदलाव करके सेव करेंगे, तो हर सेव का स्नैपशॉट यहाँ सुरक्षित रहेगा।',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _versions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final v = _versions[index];
                    final dateStr = v.createdAt.toLocal().toString().split('.').first;

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.history, size: 20),
                      ),
                      title: Text(
                        dateStr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'साइज: ${ByteFormat.format(v.size)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.difference_outlined, size: 16),
                            label: const Text('Diff'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onPressed: () => _showDiffWithCurrent(v),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.restore, size: 16),
                            label: const Text('रीस्टोर'),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onPressed: () => _restoreVersion(v),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

