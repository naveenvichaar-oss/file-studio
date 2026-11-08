// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'फ़ाइल स्टूडियो';

  @override
  String get open => 'ओपन';

  @override
  String get save => 'सेव';

  @override
  String get delete => 'हटाएँ';

  @override
  String get readOnly => 'सिर्फ़ देखें';

  @override
  String get editMode => 'एडिट';

  @override
  String get savedSuccessfully => 'फ़ाइल सफलतापूर्वक सेव हो गई';

  @override
  String get deleteConfirmTitle => 'फ़ाइल हटाएँ?';

  @override
  String deleteConfirmMessage(Object fileName) {
    return 'क्या आप वाकई \"$fileName\" को हटाना चाहते हैं? यह रीसायकल बिन में सुरक्षित रहेगी।';
  }

  @override
  String get undo => 'वापस लाएँ';

  @override
  String movedToRecycleBin(Object fileName) {
    return '\"$fileName\" रीसायकल बिन में भेज दी गई';
  }

  @override
  String restoredFromRecycleBin(Object fileName) {
    return '\"$fileName\" वापस आ गई';
  }

  @override
  String get newFile => 'नई फ़ाइल';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get duplicate => 'कॉपी बनाएँ';

  @override
  String get share => 'शेयर करें';

  @override
  String get properties => 'विवरण';

  @override
  String get history => 'वर्ज़न इतिहास';

  @override
  String get pickFile => 'फ़ाइल चुनें';

  @override
  String get pickFolder => 'फ़ोल्डर चुनें';

  @override
  String get recents => 'हाल की फ़ाइलें';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get recycleBin => 'रीसायकल बिन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get search => 'खोजें';

  @override
  String get searchHint => 'फ़ाइल या फ़ोल्डर खोजें...';

  @override
  String get emptyFolder => 'यहाँ कोई फ़ाइल नहीं है';

  @override
  String get emptyRecents => 'कोई हालिया फ़ाइल नहीं है';

  @override
  String get emptyRecycleBin => 'रीसायकल बिन खाली है';

  @override
  String get theme => 'थीम';

  @override
  String get language => 'भाषा';

  @override
  String get lightTheme => 'लाइट';

  @override
  String get darkTheme => 'डार्क';

  @override
  String get systemTheme => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get create => 'बनाएँ';

  @override
  String get fileNameLabel => 'फ़ाइल का नाम';

  @override
  String get unsavedChangesTitle => 'बदलाव सेव नहीं किए गए';

  @override
  String get unsavedChangesMessage =>
      'आपके द्वारा किए गए बदलाव सेव नहीं हुए हैं। क्या आप बाहर निकलना चाहते हैं?';

  @override
  String get discard => 'हटाएँ (Discard)';

  @override
  String errorOccurred(Object error) {
    return 'एक त्रुटि हुई: $error';
  }

  @override
  String get fileNotFound => 'फ़ाइल नहीं मिली';

  @override
  String get fileTooLargeStreaming =>
      'बड़ी फ़ाइल (>5MB) — सिर्फ़ पढ़ने के लिए खोली गई';

  @override
  String lineCount(Object count) {
    return '$count पंक्तियाँ';
  }

  @override
  String get fontSize => 'फ़ॉन्ट साइज़';

  @override
  String get preview => 'प्रीव्यू';

  @override
  String get code => 'कोड';

  @override
  String get addRow => 'पंक्ति जोड़ें';

  @override
  String get addColumn => 'कॉलम जोड़ें';

  @override
  String get deleteRow => 'पंक्ति हटाएँ';

  @override
  String get deleteColumn => 'कॉलम हटाएँ';

  @override
  String get rotate => 'घुमाएँ';

  @override
  String get flip => 'पलटें';

  @override
  String get saveChangesPrompt => 'सेव करें';
}
