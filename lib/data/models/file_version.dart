class FileVersion {
  final String versionId;
  final String entryId;
  final String fileName;
  final DateTime createdAt;
  final String backupPath;
  final int size;

  const FileVersion({
    required this.versionId,
    required this.entryId,
    required this.fileName,
    required this.createdAt,
    required this.backupPath,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'versionId': versionId,
        'entryId': entryId,
        'fileName': fileName,
        'createdAt': createdAt.toIso8601String(),
        'backupPath': backupPath,
        'size': size,
      };

  factory FileVersion.fromJson(Map<String, dynamic> json) => FileVersion(
        versionId: json['versionId'] as String,
        entryId: json['entryId'] as String,
        fileName: json['fileName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        backupPath: json['backupPath'] as String,
        size: json['size'] as int? ?? 0,
      );
}

