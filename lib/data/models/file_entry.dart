import '../../core/file_kind.dart';

class FileEntry {
  final String id;
  final String uri; // File path or content:// URI
  final String name;
  final int size;
  final DateTime modified;
  final FileKind kind;
  final bool isWritable;
  final bool isDirectory;

  const FileEntry({
    required this.id,
    required this.uri,
    required this.name,
    required this.size,
    required this.modified,
    required this.kind,
    this.isWritable = true,
    this.isDirectory = false,
  });

  FileEntry copyWith({
    String? id,
    String? uri,
    String? name,
    int? size,
    DateTime? modified,
    FileKind? kind,
    bool? isWritable,
    bool? isDirectory,
  }) {
    return FileEntry(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      name: name ?? this.name,
      size: size ?? this.size,
      modified: modified ?? this.modified,
      kind: kind ?? this.kind,
      isWritable: isWritable ?? this.isWritable,
      isDirectory: isDirectory ?? this.isDirectory,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uri': uri,
        'name': name,
        'size': size,
        'modified': modified.toIso8601String(),
        'kind': kind.name,
        'isWritable': isWritable,
        'isDirectory': isDirectory,
      };

  factory FileEntry.fromJson(Map<String, dynamic> json) => FileEntry(
        id: json['id'] as String,
        uri: json['uri'] as String,
        name: json['name'] as String,
        size: json['size'] as int? ?? 0,
        modified: DateTime.parse(json['modified'] as String),
        kind: FileKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => FileKind.binary,
        ),
        isWritable: json['isWritable'] as bool? ?? true,
        isDirectory: json['isDirectory'] as bool? ?? false,
      );
}

