import 'package:flutter/material.dart';
import '../../core/theme/text_styles.dart';

enum DiffLineType { unchanged, added, deleted }

class DiffLine {
  final DiffLineType type;
  final String text;
  final int? oldLineNumber;
  final int? newLineNumber;

  const DiffLine({
    required this.type,
    required this.text,
    this.oldLineNumber,
    this.newLineNumber,
  });
}

class DiffEngine {
  /// Simple and robust LCS-based line differ
  static List<DiffLine> computeDiff(String oldText, String newText) {
    final oldLines = oldText.isEmpty ? <String>[] : oldText.split('\n');
    final newLines = newText.isEmpty ? <String>[] : newText.split('\n');

    final n = oldLines.length;
    final m = newLines.length;

    // LCS dynamic programming table
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m; j++) {
        if (oldLines[i] == newLines[j]) {
          dp[i + 1][j + 1] = dp[i][j] + 1;
        } else {
          dp[i + 1][j + 1] = dp[i + 1][j] > dp[i][j + 1] ? dp[i + 1][j] : dp[i + 1][j + 1];
        }
      }
    }

    // Backtrack to build diff
    final result = <DiffLine>[];
    int i = n;
    int j = m;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && oldLines[i - 1] == newLines[j - 1]) {
        result.add(DiffLine(
          type: DiffLineType.unchanged,
          text: oldLines[i - 1],
          oldLineNumber: i,
          newLineNumber: j,
        ));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        result.add(DiffLine(
          type: DiffLineType.added,
          text: newLines[j - 1],
          oldLineNumber: null,
          newLineNumber: j,
        ));
        j--;
      } else if (i > 0) {
        result.add(DiffLine(
          type: DiffLineType.deleted,
          text: oldLines[i - 1],
          oldLineNumber: i,
          newLineNumber: null,
        ));
        i--;
      }
    }

    return result.reversed.toList();
  }
}

class DiffView extends StatelessWidget {
  final String oldTitle;
  final String newTitle;
  final String oldText;
  final String newText;

  const DiffView({
    super.key,
    required this.oldTitle,
    required this.newTitle,
    required this.oldText,
    required this.newText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffLines = DiffEngine.computeDiff(oldText, newText);

    final additions = diffLines.where((l) => l.type == DiffLineType.added).length;
    final deletions = diffLines.where((l) => l.type == DiffLineType.deleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('फ़ाइल अंतर (Diff View)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '+$additions जोड़े गए  -$deletions हटाए गए',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'पुराना: $oldTitle',
                    style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'नया: $newTitle',
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Diff lines list
          Expanded(
            child: ListView.builder(
              itemCount: diffLines.length,
              itemBuilder: (context, index) {
                final line = diffLines[index];
                Color bgColor;
                Color textColor;
                String prefix;

                switch (line.type) {
                  case DiffLineType.added:
                    bgColor = Colors.green.withValues(alpha: 0.12);
                    textColor = Colors.green.shade800;
                    prefix = '+';
                    break;
                  case DiffLineType.deleted:
                    bgColor = Colors.red.withValues(alpha: 0.12);
                    textColor = Colors.red.shade800;
                    prefix = '-';
                    break;
                  case DiffLineType.unchanged:
                    bgColor = Colors.transparent;
                    textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
                    prefix = ' ';
                    break;
                }

                return Container(
                  color: bgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Old line number
                      SizedBox(
                        width: 32,
                        child: Text(
                          line.oldLineNumber?.toString() ?? '',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.lineNumbers.copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // New line number
                      SizedBox(
                        width: 32,
                        child: Text(
                          line.newLineNumber?.toString() ?? '',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.lineNumbers.copyWith(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Diff marker (+ / - / space)
                      Text(
                        prefix,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Line text
                      Expanded(
                        child: Text(
                          line.text,
                          style: AppTextStyles.code.copyWith(
                            color: textColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

