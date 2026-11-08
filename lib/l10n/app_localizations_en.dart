// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'File Studio';

  @override
  String get open => 'Open';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get readOnly => 'Read Only';

  @override
  String get editMode => 'Edit';

  @override
  String get savedSuccessfully => 'File saved successfully';

  @override
  String get deleteConfirmTitle => 'Delete File?';

  @override
  String deleteConfirmMessage(Object fileName) {
    return 'Are you sure you want to delete \"$fileName\"? It will be moved to the Recycle Bin.';
  }

  @override
  String get undo => 'Undo';

  @override
  String movedToRecycleBin(Object fileName) {
    return '\"$fileName\" moved to Recycle Bin';
  }

  @override
  String restoredFromRecycleBin(Object fileName) {
    return '\"$fileName\" restored';
  }

  @override
  String get newFile => 'New File';

  @override
  String get rename => 'Rename';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get share => 'Share';

  @override
  String get properties => 'Properties';

  @override
  String get history => 'Version History';

  @override
  String get pickFile => 'Pick File';

  @override
  String get pickFolder => 'Pick Folder';

  @override
  String get recents => 'Recent Files';

  @override
  String get favorites => 'Favorites';

  @override
  String get recycleBin => 'Recycle Bin';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search files or folders...';

  @override
  String get emptyFolder => 'No files found here';

  @override
  String get emptyRecents => 'No recent files';

  @override
  String get emptyRecycleBin => 'Recycle Bin is empty';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System Default';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get create => 'Create';

  @override
  String get fileNameLabel => 'File Name';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you really want to exit?';

  @override
  String get discard => 'Discard';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get fileNotFound => 'File not found';

  @override
  String get fileTooLargeStreaming =>
      'Large file (>5MB) — opened in read-only streaming mode';

  @override
  String lineCount(Object count) {
    return '$count lines';
  }

  @override
  String get fontSize => 'Font Size';

  @override
  String get preview => 'Preview';

  @override
  String get code => 'Code';

  @override
  String get addRow => 'Add Row';

  @override
  String get addColumn => 'Add Column';

  @override
  String get deleteRow => 'Delete Row';

  @override
  String get deleteColumn => 'Delete Column';

  @override
  String get rotate => 'Rotate';

  @override
  String get flip => 'Flip';

  @override
  String get saveChangesPrompt => 'Save Changes';
}
