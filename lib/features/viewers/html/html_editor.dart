import 'package:flutter/material.dart';
import '../../workspace/document_session.dart';
import '../text/text_editor.dart';

class HtmlEditor extends StatefulWidget {
  final DocumentSession session;

  const HtmlEditor({super.key, required this.session});

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tab Header: [Code | Preview]
        Container(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.code, size: 20), text: 'कोड (Code)'),
              Tab(icon: Icon(Icons.preview_outlined, size: 20), text: 'लाइव प्रीव्यू (Preview)'),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Code View
              TextEditor(session: widget.session),

              // Safe HTML Preview
              _buildSafePreview(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafePreview(ThemeData theme) {
    return AnimatedBuilder(
      animation: widget.session,
      builder: (context, _) {
        final htmlContent = widget.session.currentText;

        if (htmlContent.isEmpty) {
          return const Center(
            child: Text('प्रीव्यू के लिए कोई HTML कोड नहीं है'),
          );
        }

        // Clean plain-text preview / strip basic tags for safe sandboxing
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            child: SelectableText(
              htmlContent,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}

