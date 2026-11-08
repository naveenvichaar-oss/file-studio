import 'package:csv/csv.dart';

class AppCsvCodec {
  /// Detects delimiter automatically (comma, tab, semicolon, pipe)
  static String detectDelimiter(String content) {
    if (content.isEmpty) return ',';
    final lines = content.split('\n');
    final sample = lines.take(5).join('\n');

    final counts = {
      ',': ','.allMatches(sample).length,
      '\t': '\t'.allMatches(sample).length,
      ';': ';'.allMatches(sample).length,
      '|': '|'.allMatches(sample).length,
    };

    var best = ',';
    var maxCount = -1;
    counts.forEach((delim, count) {
      if (count > maxCount) {
        maxCount = count;
        best = delim;
      }
    });

    return maxCount > 0 ? best : ',';
  }

  /// Decode CSV text into 2D List
  static List<List<dynamic>> decode(String content, [String? fieldDelimiter]) {
    final delimiter = fieldDelimiter ?? detectDelimiter(content);
    final parser = Csv(
      fieldDelimiter: delimiter,
      autoDetect: fieldDelimiter == null,
      dynamicTyping: false,
    );
    return parser.decode(content);
  }

  /// Encode 2D List into CSV string
  static String encode(List<List<dynamic>> rows, [String fieldDelimiter = ',']) {
    final parser = Csv(
      fieldDelimiter: fieldDelimiter,
      lineDelimiter: '\n',
    );
    return parser.encode(rows);
  }
}
