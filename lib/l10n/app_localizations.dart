import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल स्टूडियो'**
  String get appTitle;

  /// No description provided for @open.
  ///
  /// In hi, this message translates to:
  /// **'ओपन'**
  String get open;

  /// No description provided for @save.
  ///
  /// In hi, this message translates to:
  /// **'सेव'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In hi, this message translates to:
  /// **'हटाएँ'**
  String get delete;

  /// No description provided for @readOnly.
  ///
  /// In hi, this message translates to:
  /// **'सिर्फ़ देखें'**
  String get readOnly;

  /// No description provided for @editMode.
  ///
  /// In hi, this message translates to:
  /// **'एडिट'**
  String get editMode;

  /// No description provided for @savedSuccessfully.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल सफलतापूर्वक सेव हो गई'**
  String get savedSuccessfully;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल हटाएँ?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In hi, this message translates to:
  /// **'क्या आप वाकई \"{fileName}\" को हटाना चाहते हैं? यह रीसायकल बिन में सुरक्षित रहेगी।'**
  String deleteConfirmMessage(Object fileName);

  /// No description provided for @undo.
  ///
  /// In hi, this message translates to:
  /// **'वापस लाएँ'**
  String get undo;

  /// No description provided for @movedToRecycleBin.
  ///
  /// In hi, this message translates to:
  /// **'\"{fileName}\" रीसायकल बिन में भेज दी गई'**
  String movedToRecycleBin(Object fileName);

  /// No description provided for @restoredFromRecycleBin.
  ///
  /// In hi, this message translates to:
  /// **'\"{fileName}\" वापस आ गई'**
  String restoredFromRecycleBin(Object fileName);

  /// No description provided for @newFile.
  ///
  /// In hi, this message translates to:
  /// **'नई फ़ाइल'**
  String get newFile;

  /// No description provided for @rename.
  ///
  /// In hi, this message translates to:
  /// **'नाम बदलें'**
  String get rename;

  /// No description provided for @duplicate.
  ///
  /// In hi, this message translates to:
  /// **'कॉपी बनाएँ'**
  String get duplicate;

  /// No description provided for @share.
  ///
  /// In hi, this message translates to:
  /// **'शेयर करें'**
  String get share;

  /// No description provided for @properties.
  ///
  /// In hi, this message translates to:
  /// **'विवरण'**
  String get properties;

  /// No description provided for @history.
  ///
  /// In hi, this message translates to:
  /// **'वर्ज़न इतिहास'**
  String get history;

  /// No description provided for @pickFile.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल चुनें'**
  String get pickFile;

  /// No description provided for @pickFolder.
  ///
  /// In hi, this message translates to:
  /// **'फ़ोल्डर चुनें'**
  String get pickFolder;

  /// No description provided for @recents.
  ///
  /// In hi, this message translates to:
  /// **'हाल की फ़ाइलें'**
  String get recents;

  /// No description provided for @favorites.
  ///
  /// In hi, this message translates to:
  /// **'पसंदीदा'**
  String get favorites;

  /// No description provided for @recycleBin.
  ///
  /// In hi, this message translates to:
  /// **'रीसायकल बिन'**
  String get recycleBin;

  /// No description provided for @settings.
  ///
  /// In hi, this message translates to:
  /// **'सेटिंग्स'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In hi, this message translates to:
  /// **'खोजें'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल या फ़ोल्डर खोजें...'**
  String get searchHint;

  /// No description provided for @emptyFolder.
  ///
  /// In hi, this message translates to:
  /// **'यहाँ कोई फ़ाइल नहीं है'**
  String get emptyFolder;

  /// No description provided for @emptyRecents.
  ///
  /// In hi, this message translates to:
  /// **'कोई हालिया फ़ाइल नहीं है'**
  String get emptyRecents;

  /// No description provided for @emptyRecycleBin.
  ///
  /// In hi, this message translates to:
  /// **'रीसायकल बिन खाली है'**
  String get emptyRecycleBin;

  /// No description provided for @theme.
  ///
  /// In hi, this message translates to:
  /// **'थीम'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In hi, this message translates to:
  /// **'भाषा'**
  String get language;

  /// No description provided for @lightTheme.
  ///
  /// In hi, this message translates to:
  /// **'लाइट'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In hi, this message translates to:
  /// **'डार्क'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In hi, this message translates to:
  /// **'सिस्टम डिफ़ॉल्ट'**
  String get systemTheme;

  /// No description provided for @cancel.
  ///
  /// In hi, this message translates to:
  /// **'रद्द करें'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In hi, this message translates to:
  /// **'पुष्टि करें'**
  String get confirm;

  /// No description provided for @create.
  ///
  /// In hi, this message translates to:
  /// **'बनाएँ'**
  String get create;

  /// No description provided for @fileNameLabel.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल का नाम'**
  String get fileNameLabel;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In hi, this message translates to:
  /// **'बदलाव सेव नहीं किए गए'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In hi, this message translates to:
  /// **'आपके द्वारा किए गए बदलाव सेव नहीं हुए हैं। क्या आप बाहर निकलना चाहते हैं?'**
  String get unsavedChangesMessage;

  /// No description provided for @discard.
  ///
  /// In hi, this message translates to:
  /// **'हटाएँ (Discard)'**
  String get discard;

  /// No description provided for @errorOccurred.
  ///
  /// In hi, this message translates to:
  /// **'एक त्रुटि हुई: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @fileNotFound.
  ///
  /// In hi, this message translates to:
  /// **'फ़ाइल नहीं मिली'**
  String get fileNotFound;

  /// No description provided for @fileTooLargeStreaming.
  ///
  /// In hi, this message translates to:
  /// **'बड़ी फ़ाइल (>5MB) — सिर्फ़ पढ़ने के लिए खोली गई'**
  String get fileTooLargeStreaming;

  /// No description provided for @lineCount.
  ///
  /// In hi, this message translates to:
  /// **'{count} पंक्तियाँ'**
  String lineCount(Object count);

  /// No description provided for @fontSize.
  ///
  /// In hi, this message translates to:
  /// **'फ़ॉन्ट साइज़'**
  String get fontSize;

  /// No description provided for @preview.
  ///
  /// In hi, this message translates to:
  /// **'प्रीव्यू'**
  String get preview;

  /// No description provided for @code.
  ///
  /// In hi, this message translates to:
  /// **'कोड'**
  String get code;

  /// No description provided for @addRow.
  ///
  /// In hi, this message translates to:
  /// **'पंक्ति जोड़ें'**
  String get addRow;

  /// No description provided for @addColumn.
  ///
  /// In hi, this message translates to:
  /// **'कॉलम जोड़ें'**
  String get addColumn;

  /// No description provided for @deleteRow.
  ///
  /// In hi, this message translates to:
  /// **'पंक्ति हटाएँ'**
  String get deleteRow;

  /// No description provided for @deleteColumn.
  ///
  /// In hi, this message translates to:
  /// **'कॉलम हटाएँ'**
  String get deleteColumn;

  /// No description provided for @rotate.
  ///
  /// In hi, this message translates to:
  /// **'घुमाएँ'**
  String get rotate;

  /// No description provided for @flip.
  ///
  /// In hi, this message translates to:
  /// **'पलटें'**
  String get flip;

  /// No description provided for @saveChangesPrompt.
  ///
  /// In hi, this message translates to:
  /// **'सेव करें'**
  String get saveChangesPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
