import 'package:flutter/material.dart';
import '../../workspace/document_session.dart';
import 'csv_codec.dart';

class CsvGridEditor extends StatefulWidget {
  final DocumentSession session;

  const CsvGridEditor({super.key, required this.session});

  @override
  State<CsvGridEditor> createState() => _CsvGridEditorState();
}

class _CsvGridEditorState extends State<CsvGridEditor> {
  late List<List<String>> _tableData;
  late String _delimiter;

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.session.addListener(_onSessionChanged);
  }

  void _loadData() {
    _delimiter = AppCsvCodec.detectDelimiter(widget.session.currentText);
    final raw = AppCsvCodec.decode(widget.session.currentText, _delimiter);
    _tableData = raw.map((row) => row.map((c) => c.toString()).toList()).toList();
    if (_tableData.isEmpty) {
      _tableData = [['']];
    }
  }

  void _onSessionChanged() {
    // If not dirty and changed from outside, reload
    if (!widget.session.isDirty) {
      setState(() {
        _loadData();
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _syncChanges() {
    final encoded = AppCsvCodec.encode(_tableData, _delimiter);
    widget.session.updateText(encoded);
  }

  void _editCell(int rowIndex, int colIndex) async {
    if (widget.session.isReadOnly) return;

    final currentVal = _tableData[rowIndex][colIndex];
    final controller = TextEditingController(text: currentVal);

    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('सेल एडिट करें (R${rowIndex + 1}, C${colIndex + 1})'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'मान (Value)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('रद्द करें'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );

    if (updated != null && updated != currentVal) {
      setState(() {
        _tableData[rowIndex][colIndex] = updated;
      });
      _syncChanges();
    }
  }

  void _addRow() {
    final colCount = _tableData.isNotEmpty ? _tableData.first.length : 1;
    setState(() {
      _tableData.add(List.filled(colCount, ''));
    });
    _syncChanges();
  }

  void _deleteRow(int index) {
    if (_tableData.length <= 1) return;
    setState(() {
      _tableData.removeAt(index);
    });
    _syncChanges();
  }

  void _addColumn() {
    setState(() {
      for (final row in _tableData) {
        row.add('');
      }
    });
    _syncChanges();
  }

  void _deleteColumn(int colIndex) {
    if (_tableData.isEmpty || _tableData.first.length <= 1) return;
    setState(() {
      for (final row in _tableData) {
        if (colIndex < row.length) {
          row.removeAt(colIndex);
        }
      }
    });
    _syncChanges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowCount = _tableData.length;
    final colCount = _tableData.isNotEmpty ? _tableData.first.length : 0;

    return Column(
      children: [
        // CSV Toolbar (Add Row, Add Column, etc.)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                '$rowCount पंक्तियाँ × $colCount कॉलम',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              if (widget.session.isEditMode) ...[
                OutlinedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ पंक्ति'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _addColumn,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+ कॉलम'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Grid Area with horizontal and vertical scroll
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
                columns: [
                  const DataColumn(
                    label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  for (int c = 0; c < colCount; c++)
                    DataColumn(
                      label: Row(
                        children: [
                          Text(
                            'कॉलम ${c + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (widget.session.isEditMode && colCount > 1) ...[
                            IconButton(
                              icon: const Icon(Icons.close, size: 14),
                              tooltip: 'कॉलम हटाएँ',
                              onPressed: () => _deleteColumn(c),
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
                rows: [
                  for (int r = 0; r < rowCount; r++)
                    DataRow(
                      cells: [
                        // Row Number and Delete
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${r + 1}'),
                              if (widget.session.isEditMode && rowCount > 1) ...[
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                  tooltip: 'पंक्ति हटाएँ',
                                  onPressed: () => _deleteRow(r),
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Cells
                        for (int c = 0; c < colCount; c++)
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(minWidth: 60, maxWidth: 200),
                              child: Text(
                                c < _tableData[r].length ? _tableData[r][c] : '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: widget.session.isEditMode
                                ? () => _editCell(r, c)
                                : null,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
