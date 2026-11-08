import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/file_kind.dart';
import '../../../core/utils/byte_format.dart';
import '../../workspace/document_session.dart';

class MediaPlayerView extends StatelessWidget {
  final DocumentSession session;

  const MediaPlayerView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVideo = session.kind == FileKind.video;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.audiotrack,
                  size: 72,
                  color: isVideo ? Colors.deepPurple : Colors.teal,
                ),
                const SizedBox(height: 16),
                Text(
                  session.entry.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isVideo ? 'वीडियो' : 'ऑडियो'} फ़ाइल · ${ByteFormat.format(session.entry.size)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    OpenFilex.open(session.entry.uri);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text('मीडिया प्लेयर में चलाएँ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

