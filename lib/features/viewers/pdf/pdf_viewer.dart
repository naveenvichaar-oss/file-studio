import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/utils/byte_format.dart';
import '../../workspace/document_session.dart';

class PdfViewer extends StatelessWidget {
  final DocumentSession session;

  const PdfViewer({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, size: 72, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  session.entry.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF दस्तावेज़ · ${ByteFormat.format(session.entry.size)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    OpenFilex.open(session.entry.uri);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('सिस्टम PDF रीडर में खोलें'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

