import 'package:flutter_test/flutter_test.dart';
import 'package:file_studio/features/history/diff_view.dart';

void main() {
  group('DiffEngine Tests', () {
    test('Identifies unchanged lines when texts are identical', () {
      const text = 'Line 1\nLine 2\nLine 3';
      final diff = DiffEngine.computeDiff(text, text);

      expect(diff.length, equals(3));
      expect(diff.every((l) => l.type == DiffLineType.unchanged), isTrue);
    });

    test('Identifies added and deleted lines correctly', () {
      const oldText = 'Apple\nBanana\nCherry';
      const newText = 'Apple\nBlueberry\nCherry\nDate';

      final diff = DiffEngine.computeDiff(oldText, newText);

      // Should have:
      // Apple (unchanged)
      // Banana (deleted)
      // Blueberry (added)
      // Cherry (unchanged)
      // Date (added)
      final added = diff.where((l) => l.type == DiffLineType.added).map((l) => l.text).toList();
      final deleted = diff.where((l) => l.type == DiffLineType.deleted).map((l) => l.text).toList();

      expect(added, contains('Blueberry'));
      expect(added, contains('Date'));
      expect(deleted, contains('Banana'));
    });
  });
}

