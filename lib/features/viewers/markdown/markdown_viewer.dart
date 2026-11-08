import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../workspace/document_session.dart';
import '../text/text_editor.dart';

class MarkdownViewer extends StatefulWidget {
  final DocumentSession session;

  const MarkdownViewer({super.key, required this.session});

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> with SingleTickerProviderStateMixin {
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
              Tab(icon: Icon(Icons.edit_note, size: 20), text: 'मार्कडाउन एडिटर'),
              Tab(icon: Icon(Icons.preview_outlined, size: 20), text: 'लाइव प्रीव्यू'),
            ],
          ),
        ),

        // Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Text / Code Editor
              TextEditor(session: widget.session),

              // 2. Rendered Markdown Preview
              AnimatedBuilder(
                animation: widget.session,
                builder: (context, _) {
                  final text = widget.session.currentText;
                  if (text.isEmpty) {
                    return const Center(child: Text('प्रीव्यू के लिए कोई टेक्स्ट नहीं है'));
                  }
                  return Markdown(
                    data: text,
                    selectable: true,
                    padding: const EdgeInsets.all(16),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

