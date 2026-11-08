import 'package:flutter_test/flutter_test.dart';
import 'package:file_studio/features/viewers/csv/csv_codec.dart';

void main() {
  group('AppCsvCodec Tests', () {
    test('Auto-detects comma, semicolon and tab delimiters', () {
      expect(AppCsvCodec.detectDelimiter('name,age,city\nJohn,25,Delhi'), equals(','));
      expect(AppCsvCodec.detectDelimiter('name;age;city\nJohn;25;Delhi'), equals(';'));
      expect(AppCsvCodec.detectDelimiter('name\tage\tcity\nJohn\t25\tDelhi'), equals('\t'));
    });

    test('Round-trip preserves commas, quotes and special characters', () {
      final input = [
        ['ID', 'Name', 'Notes', 'Amount'],
        ['1', 'Ramesh Kumar', 'Special, with comma', '100.50'],
        ['2', 'Priya "Queen" Sharma', 'Multiline Note', '250.00'],
      ];

      final encoded = AppCsvCodec.encode(input, ',');
      final decoded = AppCsvCodec.decode(encoded, ',');

      expect(decoded.length, equals(3));
      expect(decoded[0], equals(['ID', 'Name', 'Notes', 'Amount']));
      expect(decoded[1][2], equals('Special, with comma'));
      expect(decoded[2][1], equals('Priya "Queen" Sharma'));
    });
  });
}
