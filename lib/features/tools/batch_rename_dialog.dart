import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../data/models/file_entry.dart';

enum RenameMode { prefix, suffix, numbering, replace }

class BatchRenameDialog extends StatefulWidget {
  final List<FileEntry> files;

  const BatchRenameDialog({super.key, required this.files});

  @override
  State<BatchRenameDialog> createState() => _BatchRenameDialogState();
}

class _BatchRenameDialogState extends State<BatchRenameDialog> {
  RenameMode _mode = RenameMode.numbering;
  final TextEditingController _textController = TextEditingController(text: 'item');
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _findController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  String _computeNewName(FileEntry entry, int index) {
    final ext = p.extension(entry.name);
    final base = p.basenameWithoutExtension(entry.name);

    switch (_mode) {
      case RenameMode.prefix:
        return '${_textController.text}_$base$ext';
      case RenameMode.suffix:
        return '${base}_${_textController.text}$ext';
      case RenameMode.numbering:
        final numStr = '${index + 1}'.padLeft(2, '0');
        final prefix = _textController.text.trim();
        return prefix.isNotEmpty ? '${prefix}_$numStr$ext' : '$numStr$ext';
      case RenameMode.replace:
        final find = _findController.text;
        final repl = _replaceController.text;
        if (find.isEmpty) return entry.name;
        return '${base.replaceAll(find, repl)}$ext';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('${widget.files.length} फ़ाइलों का बैच नाम बदलें'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rename mode selection
              SegmentedButton<RenameMode>(
                segments: const [
                  ButtonSegment(value: RenameMode.numbering, label: Text('क्रमांक')),
                  ButtonSegment(value: RenameMode.prefix, label: Text('आगे जोड़ें')),
                  ButtonSegment(value: RenameMode.suffix, label: Text('पीछे जोड़ें')),
                  ButtonSegment(value: RenameMode.replace, label: Text('बदलें')),
                ],
                selected: {_mode},
                onSelectionChanged: (set) => setState(() => _mode = set.first),
              ),
              const SizedBox(height: 16),

              if (_mode == RenameMode.replace) ...[
                TextField(
                  controller: _findController,
                  decoration: const InputDecoration(
                    labelText: 'ढूँढें (Find)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _replaceController,
                  decoration: const InputDecoration(
                    labelText: 'इससे बदलें (Replace with)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ] else ...[
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: _mode == RenameMode.numbering
                        ? 'आधार नाम (Base name)'
                        : 'टेक्स्ट',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],

              const SizedBox(height: 16),
              const Text('प्रीव्यू (पहला 5):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.files.take(5).toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final f = entry.value;
                    final newName = _computeNewName(f, idx);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${f.name}  ➔  $newName',
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
        FilledButton(
          onPressed: () {
            final renames = <String, String>{};
            for (int i = 0; i < widget.files.length; i++) {
              renames[widget.files[i].uri] = _computeNewName(widget.files[i], i);
            }
            Navigator.pop(context, renames);
          },
          child: const Text('नाम बदलें'),
        ),
      ],
    );
  }
}

