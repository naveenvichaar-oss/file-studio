import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../../workspace/document_session.dart';

class TextEditor extends StatefulWidget {
  final DocumentSession session;

  const TextEditor({super.key, required this.session});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late final TextEditingController _controller;
  late final ScrollController _textScrollController;
  late final ScrollController _lineScrollController;
  double _fontSize = 14.0;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  int _searchMatchCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.session.currentText);
    _textScrollController = ScrollController();
    _lineScrollController = ScrollController();

    _textScrollController.addListener(() {
      if (_lineScrollController.hasClients &&
          _lineScrollController.offset != _textScrollController.offset) {
        _lineScrollController.jumpTo(_textScrollController.offset);
      }
    });

    widget.session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (_controller.text != widget.session.currentText) {
      final cursor = _controller.selection;
      _controller.text = widget.session.currentText;
      if (cursor.isValid && cursor.end <= _controller.text.length) {
        _controller.selection = cursor;
      }
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _controller.dispose();
    _textScrollController.dispose();
    _lineScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchMatchCount = 0);
      return;
    }
    final text = _controller.text;
    int count = 0;
    int index = 0;
    while ((index = text.toLowerCase().indexOf(query.toLowerCase(), index)) != -1) {
      count++;
      index += query.length;
    }
    setState(() => _searchMatchCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = _controller.text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;

    return Column(
      children: [
        // Top mini-toolbar for Text Editor
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              // Undo/Redo
              if (widget.session.isEditMode) ...[
                IconButton(
                  icon: const Icon(Icons.undo, size: 20),
                  onPressed: widget.session.canUndo ? widget.session.undo : null,
                  tooltip: 'Undo',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: const Icon(Icons.redo, size: 20),
                  onPressed: widget.session.canRedo ? widget.session.redo : null,
                  tooltip: 'Redo',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 8),
              ],

              // Search toggle
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.search_off : Icons.search,
                  size: 20,
                  color: _showSearch ? theme.colorScheme.primary : null,
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      _searchMatchCount = 0;
                    }
                  });
                },
                tooltip: 'खोजें (Search)',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),

              const Spacer(),

              // Font size adjustment
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: _fontSize > 10
                    ? () => setState(() => _fontSize = (_fontSize - 1).clamp(10.0, 32.0))
                    : null,
                tooltip: 'छोटा फ़ॉन्ट',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                '${_fontSize.toInt()}pt',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: _fontSize < 32
                    ? () => setState(() => _fontSize = (_fontSize + 1).clamp(10.0, 32.0))
                    : null,
                tooltip: 'बड़ा फ़ॉन्ट',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),

        // Search Bar when active
        if (_showSearch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'फ़ाइल में ढूँढें...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixText: _searchMatchCount > 0 ? '$_searchMatchCount मिले' : null,
                    ),
                    onChanged: _performSearch,
                  ),
                ),
              ],
            ),
          ),

        // Large file warning notice
        if (widget.session.isLargeFile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.amber.shade100,
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.brown),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'बड़ी फ़ाइल (>5MB) — सुरक्षित स्ट्रीमिंग (सिर्फ़ पढ़ने के लिए)',
                    style: TextStyle(color: Colors.brown, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Editor Area with Line Numbers
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line numbers column
              Container(
                width: 48,
                padding: const EdgeInsets.only(top: 12, right: 8),
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                child: ListView.builder(
                  controller: _lineScrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lineCount,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: _fontSize * 1.5,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.lineNumbers.copyWith(
                          fontSize: _fontSize * 0.85,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main TextField
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextField(
                    controller: _controller,
                    scrollController: _textScrollController,
                    readOnly: widget.session.isReadOnly || widget.session.isLargeFile,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    style: AppTextStyles.code.copyWith(fontSize: _fontSize),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 8, bottom: 8),
                    ),
                    onChanged: (text) {
                      widget.session.updateText(text);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$lineCount पंक्तियाँ · ${_controller.text.length} अक्षर',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                widget.session.encoding.name.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
