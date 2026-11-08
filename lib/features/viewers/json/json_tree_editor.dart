import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../../workspace/document_session.dart';
import '../text/text_editor.dart';

class JsonTreeEditor extends StatefulWidget {
  final DocumentSession session;

  const JsonTreeEditor({super.key, required this.session});

  @override
  State<JsonTreeEditor> createState() => _JsonTreeEditorState();
}

class _JsonTreeEditorState extends State<JsonTreeEditor> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  dynamic _parsedJson;
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _parseJson();
    widget.session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    _parseJson();
  }

  void _parseJson() {
    final text = widget.session.currentText.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedJson = null;
        _parseError = null;
      });
      return;
    }

    try {
      final parsed = jsonDecode(text);
      setState(() {
        _parsedJson = parsed;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _parsedJson = null;
        _parseError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _formatJson() {
    if (_parsedJson != null) {
      final pretty = const JsonEncoder.withIndent('  ').convert(_parsedJson);
      widget.session.updateText(pretty);
    }
  }

  void _minifyJson() {
    if (_parsedJson != null) {
      final compact = jsonEncode(_parsedJson);
      widget.session.updateText(compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tabs & Tools Bar
        Container(
          color: theme.scaffoldBackgroundColor,
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.code, size: 18), text: 'कोड'),
                    Tab(icon: Icon(Icons.account_tree_outlined, size: 18), text: 'ट्री व्यू (Tree)'),
                  ],
                ),
              ),
              if (widget.session.isEditMode) ...[
                IconButton(
                  icon: const Icon(Icons.format_align_left, size: 20),
                  tooltip: 'फॉर्मेट (Prettify)',
                  onPressed: _parsedJson != null ? _formatJson : null,
                ),
                IconButton(
                  icon: const Icon(Icons.compress, size: 20),
                  tooltip: 'मिनिफ़ाई (Minify)',
                  onPressed: _parsedJson != null ? _minifyJson : null,
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),

        // Validation status banner
        if (_parseError != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.red.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'अमान्य JSON: $_parseError',
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

        // Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Code Tab
              TextEditor(session: widget.session),

              // Tree View Tab
              _parsedJson != null
                  ? ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _buildTreeNode('root', _parsedJson, theme),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _parseError != null
                              ? 'ट्री व्यू केवल वैध JSON के लिए उपलब्ध है। कृपया कोड सुधारें।'
                              : 'कोई JSON डेटा नहीं है',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreeNode(String key, dynamic value, ThemeData theme) {
    if (value is Map<String, dynamic>) {
      return ExpansionTile(
        dense: true,
        initiallyExpanded: true,
        leading: Icon(Icons.folder, size: 18, color: theme.colorScheme.primary),
        title: Text(
          '$key {${value.length}}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        children: value.entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildTreeNode(entry.key, entry.value, theme),
                ))
            .toList(),
      );
    } else if (value is List) {
      return ExpansionTile(
        dense: true,
        initiallyExpanded: true,
        leading: const Icon(Icons.data_array, size: 18, color: Colors.orange),
        title: Text(
          '$key [${value.length}]',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        children: value
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildTreeNode('[${entry.key}]', entry.value, theme),
                ))
            .toList(),
      );
    } else {
      // Primitive value
      Color valColor = Colors.green.shade700;
      if (value is num) valColor = Colors.blue.shade700;
      if (value is bool) valColor = Colors.purple.shade700;
      if (value == null) valColor = Colors.grey;

      return ListTile(
        dense: true,
        leading: const Icon(Icons.label_outline, size: 16, color: Colors.grey),
        title: Row(
          children: [
            Text(
              '$key: ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Expanded(
              child: SelectableText(
                '$value',
                style: AppTextStyles.code.copyWith(
                  color: valColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

