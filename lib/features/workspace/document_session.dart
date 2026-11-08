import 'package:flutter/foundation.dart';

import '../../core/constants.dart';
import '../../core/file_kind.dart';
import '../../core/utils/encoding_detect.dart';
import '../../data/models/file_entry.dart';

enum EditMode { readOnly, edit }

class DocumentSession extends ChangeNotifier {
  final FileEntry entry;
  final FileKind kind;
  final Uint8List initialBytes;

  EditMode _mode = EditMode.readOnly; // Always start in read-only mode
  bool _dirty = false;
  bool _isLargeFile = false;

  // Text / Code editing
  String _originalText = '';
  String _currentText = '';
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  // CSV editing
  List<List<String>> _csvRows = [];
  String _csvDelimiter = ',';

  // Image editing
  int _imageRotationDegrees = 0; // 0, 90, 180, 270
  bool _imageFlippedH = false;
  bool _imageFlippedV = false;
  Uint8List? _editedImageBytes;

  // Encoding
  DetectedEncoding _encoding = DetectedEncoding.utf8;

  DocumentSession({
    required this.entry,
    required this.initialBytes,
  }) : kind = entry.kind {
    _initSession();
  }

  void _initSession() {
    _isLargeFile = entry.size > AppConstants.largeFileSizeThreshold;

    if (FileKindDetector.isEditableText(kind) && !_isLargeFile) {
      _encoding = EncodingDetector.detect(initialBytes);
      _originalText = EncodingDetector.decodeText(initialBytes);
      _currentText = _originalText;

      if (kind == FileKind.csv) {
        _initCsv(_currentText);
      }
    }
  }

  void _initCsv(String raw) {
    if (raw.isEmpty) {
      _csvRows = [[]];
      return;
    }
    // Simple delimiter detection
    final firstLine = raw.split('\n').first;
    if (firstLine.contains('\t')) {
      _csvDelimiter = '\t';
    } else if (firstLine.contains(';')) {
      _csvDelimiter = ';';
    } else {
      _csvDelimiter = ',';
    }

    _csvRows = raw.split('\n').map((line) {
      final trimmed = line.endsWith('\r') ? line.substring(0, line.length - 1) : line;
      return trimmed.split(_csvDelimiter);
    }).toList();
  }

  // Getters
  EditMode get mode => _mode;
  bool get isReadOnly => _mode == EditMode.readOnly;
  bool get isEditMode => _mode == EditMode.edit;
  bool get isDirty => _dirty;
  bool get isLargeFile => _isLargeFile;
  bool get canSave => _mode == EditMode.edit && _dirty;

  String get currentText => _currentText;
  List<List<String>> get csvRows => _csvRows;
  String get csvDelimiter => _csvDelimiter;
  int get imageRotationDegrees => _imageRotationDegrees;
  bool get imageFlippedH => _imageFlippedH;
  bool get imageFlippedV => _imageFlippedV;
  DetectedEncoding get encoding => _encoding;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // Actions
  void toggleMode() {
    if (_mode == EditMode.readOnly) {
      if (_isLargeFile) return; // Cannot edit large files
      _mode = EditMode.edit;
    } else {
      _mode = EditMode.readOnly;
    }
    notifyListeners();
  }

  void setMode(EditMode newMode) {
    if (_isLargeFile && newMode == EditMode.edit) return;
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  // Text mutations
  void updateText(String newText) {
    if (newText == _currentText) return;
    _undoStack.add(_currentText);
    _redoStack.clear();
    _currentText = newText;
    _dirty = _currentText != _originalText;
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_currentText);
    _currentText = _undoStack.removeLast();
    _dirty = _currentText != _originalText;
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_currentText);
    _currentText = _redoStack.removeLast();
    _dirty = _currentText != _originalText;
    notifyListeners();
  }

  // CSV mutations
  void updateCsvCell(int row, int col, String value) {
    if (row < 0 || row >= _csvRows.length) return;
    while (col >= _csvRows[row].length) {
      _csvRows[row].add('');
    }
    _csvRows[row][col] = value;
    _syncCsvToText();
  }

  void addCsvRow() {
    final colCount = _csvRows.isNotEmpty ? _csvRows.first.length : 1;
    _csvRows.add(List.filled(colCount, ''));
    _syncCsvToText();
  }

  void deleteCsvRow(int index) {
    if (index >= 0 && index < _csvRows.length && _csvRows.length > 1) {
      _csvRows.removeAt(index);
      _syncCsvToText();
    }
  }

  void addCsvColumn() {
    for (final row in _csvRows) {
      row.add('');
    }
    _syncCsvToText();
  }

  void deleteCsvColumn(int colIndex) {
    for (final row in _csvRows) {
      if (colIndex >= 0 && colIndex < row.length) {
        row.removeAt(colIndex);
      }
    }
    _syncCsvToText();
  }

  void _syncCsvToText() {
    final buffer = StringBuffer();
    for (int i = 0; i < _csvRows.length; i++) {
      buffer.write(_csvRows[i].join(_csvDelimiter));
      if (i < _csvRows.length - 1) buffer.write('\n');
    }
    _currentText = buffer.toString();
    _dirty = true;
    notifyListeners();
  }

  // Image mutations
  void rotateImageClockwise() {
    _imageRotationDegrees = (_imageRotationDegrees + 90) % 360;
    _dirty = true;
    notifyListeners();
  }

  void flipImageHorizontal() {
    _imageFlippedH = !_imageFlippedH;
    _dirty = true;
    notifyListeners();
  }

  void flipImageVertical() {
    _imageFlippedV = !_imageFlippedV;
    _dirty = true;
    notifyListeners();
  }

  void updateImageBytes(Uint8List newBytes) {
    _editedImageBytes = newBytes;
    _dirty = true;
    notifyListeners();
  }

  Uint8List get activeImageBytes => _editedImageBytes ?? initialBytes;

  // Byte export for save
  Uint8List exportBytes() {
    if (FileKindDetector.isEditableText(kind)) {
      return EncodingDetector.encodeText(_currentText, _encoding);
    }
    if (kind == FileKind.image) {
      return _editedImageBytes ?? initialBytes;
    }
    return initialBytes;
  }

  void markClean() {
    _originalText = _currentText;
    _dirty = false;
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}
