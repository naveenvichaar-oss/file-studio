import 'package:flutter/material.dart';
import '../../core/file_kind.dart';
import '../workspace/document_session.dart';
import 'archive/zip_viewer.dart';
import 'binary/hex_viewer.dart';
import 'csv/csv_grid_editor.dart';
import 'html/html_editor.dart';
import 'image/image_viewer.dart';
import 'json/json_tree_editor.dart';
import 'markdown/markdown_viewer.dart';
import 'media/media_player.dart';
import 'pdf/pdf_viewer.dart';
import 'text/text_editor.dart';

class ViewerRegistry {
  static Widget buildViewer(DocumentSession session) {
    switch (session.kind) {
      case FileKind.text:
        return TextEditor(session: session);
      case FileKind.markdown:
        return MarkdownViewer(session: session);
      case FileKind.json:
        return JsonTreeEditor(session: session);
      case FileKind.html:
        return HtmlEditor(session: session);
      case FileKind.csv:
        return CsvGridEditor(session: session);
      case FileKind.image:
        return ImageViewer(session: session);
      case FileKind.pdf:
        return PdfViewer(session: session);
      case FileKind.audio:
      case FileKind.video:
        return MediaPlayerView(session: session);
      case FileKind.archive:
        return ZipViewer(session: session);
      case FileKind.binary:
        return HexViewer(session: session);
    }
  }
}
