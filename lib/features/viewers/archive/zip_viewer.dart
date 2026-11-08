import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/byte_format.dart';
import '../../workspace/document_session.dart';

class ZipViewer extends StatelessWidget {
  final DocumentSession session;

  const ZipViewer({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<ArchiveFile> archiveFiles = [];
    String? parseError;

    try {
      final archive = ZipDecoder().decodeBytes(session.initialBytes);
      archiveFiles = archive.files;
    } catch (e) {
      parseError = e.toString();
    }

    if (parseError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_zip, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text('ZIP आर्काइव लोड नहीं हो सका: $parseError'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                '${archiveFiles.length} फ़ाइलें एवं फ़ोल्डर्स',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: archiveFiles.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = archiveFiles[index];
              final isDir = !file.isFile;
              return ListTile(
                leading: Icon(
                  isDir ? Icons.folder : Icons.insert_drive_file,
                  color: isDir ? Colors.amber : theme.colorScheme.primary,
                ),
                title: Text(file.name),
                subtitle: isDir ? null : Text(ByteFormat.format(file.size)),
              );
            },
          ),
        ),
      ],
    );
  }
}
