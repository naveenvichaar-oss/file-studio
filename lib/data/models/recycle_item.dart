class RecycleItem {
  final String id;
  final String originalUri;
  final String originalName;
  final DateTime deletedAt;
  final String backupPath;
  final int size;
  final DateTime expiresAt;

  const RecycleItem({
    required this.id,
    required this.originalUri,
    required this.originalName,
    required this.deletedAt,
    required this.backupPath,
    required this.size,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalUri': originalUri,
        'originalName': originalName,
        'deletedAt': deletedAt.toIso8601String(),
        'backupPath': backupPath,
        'size': size,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory RecycleItem.fromJson(Map<String, dynamic> json) => RecycleItem(
        id: json['id'] as String,
        originalUri: json['originalUri'] as String,
        originalName: json['originalName'] as String,
        deletedAt: DateTime.parse(json['deletedAt'] as String),
        backupPath: json['backupPath'] as String,
        size: json['size'] as int? ?? 0,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}

