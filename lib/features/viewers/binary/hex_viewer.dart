import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/byte_format.dart';
import '../../workspace/document_session.dart';

class HexViewer extends StatefulWidget {
  final DocumentSession session;

  const HexViewer({super.key, required this.session});

  @override
  State<HexViewer> createState() => _HexViewerState();
}

class _HexViewerState extends State<HexViewer> {
  static const int _bytesPerRow = 16;
  static const int _rowsPerPage = 100; // 1.6 KB per page
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = widget.session.initialBytes;
    final totalRows = (bytes.length / _bytesPerRow).ceil();
    final totalPages = math.max(1, (totalRows / _rowsPerPage).ceil());

    final startRow = _currentPage * _rowsPerPage;
    final endRow = math.min(startRow + _rowsPerPage, totalRows);
    final displayedRowCount = math.max(0, endRow - startRow);

    return Column(
      children: [
        // Top Hex Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                'बाइनरी फ़ाइल · ${ByteFormat.format(bytes.length)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              if (totalPages > 1) ...[
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Text('पेज ${_currentPage + 1} / $totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ],
          ),
        ),

        // Hex Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          child: const Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('OFFSET', style: AppTextStyles.hexHeader),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '00 01 02 03 04 05 06 07  08 09 0A 0B 0C 0D 0E 0F',
                  style: AppTextStyles.hexHeader,
                ),
              ),
              SizedBox(
                width: 120,
                child: Text('ASCII', style: AppTextStyles.hexHeader),
              ),
            ],
          ),
        ),

        // Hex Rows List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: displayedRowCount,
            itemBuilder: (context, index) {
              final rowIndex = startRow + index;
              final offset = rowIndex * _bytesPerRow;
              final endOffset = math.min(offset + _bytesPerRow, bytes.length);
              final rowBytes = bytes.sublist(offset, endOffset);

              // 1. Offset String
              final offsetHex = offset.toRadixString(16).padLeft(8, '0').toUpperCase();

              // 2. Hex Bytes String
              final hexBuffer = StringBuffer();
              for (int i = 0; i < _bytesPerRow; i++) {
                if (i < rowBytes.length) {
                  hexBuffer.write(rowBytes[i].toRadixString(16).padLeft(2, '0').toUpperCase());
                } else {
                  hexBuffer.write('  ');
                }
                if (i == 7) {
                  hexBuffer.write('  ');
                } else {
                  hexBuffer.write(' ');
                }
              }

              // 3. ASCII String
              final asciiBuffer = StringBuffer();
              for (final b in rowBytes) {
                if (b >= 32 && b <= 126) {
                  asciiBuffer.write(String.fromCharCode(b));
                } else {
                  asciiBuffer.write('.');
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        offsetHex,
                        style: AppTextStyles.hexBytes.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        hexBuffer.toString(),
                        style: AppTextStyles.hexBytes,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        asciiBuffer.toString(),
                        style: AppTextStyles.hexBytes.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
    );
  }
}
