import 'dart:convert';

enum FileKind {
  text,
  html,
  csv,
  markdown,
  json,
  image,
  pdf,
  audio,
  video,
  archive,
  binary,
}

class FileKindDetector {
  static const Map<String, FileKind> _extensionMap = {
    // Text / Code
    'txt': FileKind.text,
    'log': FileKind.text,
    'xml': FileKind.text,
    'css': FileKind.text,
    'js': FileKind.text,
    'ts': FileKind.text,
    'dart': FileKind.text,
    'py': FileKind.text,
    'yaml': FileKind.text,
    'yml': FileKind.text,
    'ini': FileKind.text,
    'env': FileKind.text,
    'sh': FileKind.text,
    'bat': FileKind.text,
    'ps1': FileKind.text,
    'sql': FileKind.text,
    'c': FileKind.text,
    'cpp': FileKind.text,
    'h': FileKind.text,
    'java': FileKind.text,
    'kt': FileKind.text,
    'swift': FileKind.text,

    // HTML / Web
    'html': FileKind.html,
    'htm': FileKind.html,
    'svg': FileKind.html,

    // CSV / Data
    'csv': FileKind.csv,
    'tsv': FileKind.csv,

    // Markdown
    'md': FileKind.markdown,
    'markdown': FileKind.markdown,

    // JSON
    'json': FileKind.json,

    // Images
    'jpg': FileKind.image,
    'jpeg': FileKind.image,
    'png': FileKind.image,
    'webp': FileKind.image,
    'gif': FileKind.image,
    'bmp': FileKind.image,
    'ico': FileKind.image,

    // PDF
    'pdf': FileKind.pdf,

    // Audio
    'mp3': FileKind.audio,
    'wav': FileKind.audio,
    'm4a': FileKind.audio,
    'ogg': FileKind.audio,
    'aac': FileKind.audio,
    'flac': FileKind.audio,

    // Video
    'mp4': FileKind.video,
    'webm': FileKind.video,
    'mkv': FileKind.video,
    'mov': FileKind.video,
    'avi': FileKind.video,

    // Archives
    'zip': FileKind.archive,
    'tar': FileKind.archive,
    'gz': FileKind.archive,
    'rar': FileKind.archive,
    '7z': FileKind.archive,
  };

  /// 1) Extension 2) Magic bytes 3) Printable text heuristic 4) Binary
  static FileKind detect(String name, [List<int>? firstBytes]) {
    final cleanName = name.trim();
    if (cleanName.contains('.')) {
      final ext = cleanName.split('.').last.toLowerCase();
      final byExt = _extensionMap[ext];
      if (byExt != null) return byExt;
    }

    if (firstBytes != null && firstBytes.isNotEmpty) {
      final magicMatch = _detectFromMagicBytes(firstBytes);
      if (magicMatch != null) return magicMatch;

      if (_isPrintableText(firstBytes)) {
        return FileKind.text;
      }
    }

    return FileKind.binary;
  }

  static FileKind? _detectFromMagicBytes(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return FileKind.image; // JPEG
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return FileKind.image; // PNG
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return FileKind.image; // GIF
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return FileKind.image; // WEBP
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return FileKind.pdf; // %PDF
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04) {
      return FileKind.archive; // PK.. (ZIP)
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x49 &&
        bytes[1] == 0x44 &&
        bytes[2] == 0x33) {
      return FileKind.audio; // ID3 (MP3)
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
      return FileKind.audio; // MP3 sync
    }
    if (bytes.length >= 8 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      return FileKind.video; // ftyp (MP4)
    }
    return null;
  }

  static bool _isPrintableText(List<int> bytes) {
    // Check first 512 bytes for null byte (0x00) or high control chars
    final sample = bytes.take(512).toList();
    if (sample.contains(0x00)) return false;

    try {
      utf8.decode(sample);
      return true;
    } catch (_) {
      // Check ASCII printable chars
      int nonPrintable = 0;
      for (final b in sample) {
        if (b < 9 || (b > 13 && b < 32)) {
          nonPrintable++;
        }
      }
      return nonPrintable / sample.length < 0.1;
    }
  }

  static bool isEditableText(FileKind k) => const {
        FileKind.text,
        FileKind.html,
        FileKind.csv,
        FileKind.markdown,
        FileKind.json,
      }.contains(k);

  static String getDisplayName(FileKind kind) {
    switch (kind) {
      case FileKind.text:
        return 'Text';
      case FileKind.html:
        return 'HTML';
      case FileKind.csv:
        return 'CSV';
      case FileKind.markdown:
        return 'Markdown';
      case FileKind.json:
        return 'JSON';
      case FileKind.image:
        return 'Image';
      case FileKind.pdf:
        return 'PDF';
      case FileKind.audio:
        return 'Audio';
      case FileKind.video:
        return 'Video';
      case FileKind.archive:
        return 'Archive';
      case FileKind.binary:
        return 'Binary';
    }
  }
}

