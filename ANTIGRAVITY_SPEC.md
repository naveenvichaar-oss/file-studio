# फाइल स्टूडियो (Mobile) — Antigravity IDE के लिए पूरा स्पेसिफिकेशन

> **इस्तेमाल कैसे करें:** पूरी फाइल Antigravity के एजेंट में पेस्ट करें (या प्रोजेक्ट रूट में `SPEC.md` नाम से रखकर कहें: "Read SPEC.md and build the app phase by phase. Run `flutter analyze` after every phase.").
> एक बार में सब कुछ बनवाने की जगह **फेज़ 1 → 2 → 3** के क्रम में बनवाएँ, हर फेज़ के बाद फोन/एमुलेटर पर टेस्ट करें।

---

## 0. मास्टर प्रॉम्प्ट (एजेंट को यही दें)

```
You are building "File Studio", a cross-platform mobile file manager + editor
(Android first, iOS second) using Flutter (Dart 3, null-safety).

Goal: open, view, edit, update (save), and delete almost any file type.
Three core actions must always be clearly available:
  1. OPEN (read-only, default mode)
  2. SAVE (only enabled in Edit mode)
  3. DELETE (with confirm + undo via in-app Recycle Bin)

Follow the folder structure, feature list, and phases in SPEC.md exactly.
Rules:
- Feature-first architecture, Riverpod for state, go_router for navigation.
- UI language: Hindi by default, English switchable (use flutter_localizations + ARB).
- Never write to a file without an explicit user Save action (except opt-in autosave).
- Before every overwrite, make a backup copy (version history).
- Handle Android scoped storage (SAF) properly; do NOT request MANAGE_EXTERNAL_STORAGE.
- Large files (>5 MB text) must open in a streaming/read-only viewer, not crash.
- After each phase: run `flutter analyze`, fix all warnings, run unit tests, and
  summarize what was built and what is left.
- Verify every package name/version on pub.dev before adding it; if one is
  deprecated, pick the maintained alternative and tell me.
```

---

## 1. टेक्नोलॉजी स्टैक

| ज़रूरत | चुनाव |
|---|---|
| फ्रेमवर्क | Flutter (Android + iOS एक ही कोड) |
| स्टेट मैनेजमेंट | `flutter_riverpod` |
| नेविगेशन | `go_router` |
| फाइल चुनना/सेव | `file_picker`, `path_provider`, `share_plus`, `open_filex` |
| Android SAF (फोल्डर एक्सेस, डिलीट) | `saf_util` + `saf_stream` (या `shared_storage`) — पैकेज की स्थिति pub.dev पर जाँच लें |
| परमिशन | `permission_handler` |
| टेक्स्ट/कोड एडिटर | `re_editor` या `flutter_code_editor` (syntax highlight) |
| HTML प्रीव्यू | `webview_flutter` |
| CSV | `csv` + खुद की `DataTable`/`two_dimensional_scrollables` ग्रिड |
| इमेज देखना/ज़ूम | `photo_view` |
| इमेज एडिट | `image` (decode/rotate/crop/resize/encode) + `crop_your_image` |
| PDF | `pdfrx` या `syncfusion_flutter_pdfviewer` (लाइसेंस जाँचें) |
| ऑडियो/वीडियो | `just_audio`, `video_player` + `chewie` |
| Markdown | `flutter_markdown` |
| JSON/XML ट्री | खुद का वीडियो-फ्री `TreeView` या `flutter_json_view` |
| लोकल डेटा (हिस्ट्री, बिन, सेटिंग) | `isar` या `drift` + `shared_preferences` |
| लॉक | `local_auth` (फिंगरप्रिंट/फेस) |
| हैश/चेकसम | `crypto` |
| ज़िप | `archive` |
| OCR (बाद में) | `google_mlkit_text_recognition` |
| टेस्ट | `flutter_test`, `mocktail`, `integration_test` |

> **विकल्प:** अगर आप JavaScript पसंद करते हैं तो React Native + Expo (`expo-document-picker`, `expo-file-system`, `expo-image-manipulator`) से भी यही बन सकता है। नीचे का स्ट्रक्चर Flutter के लिए है।

---

## 2. फोल्डर स्ट्रक्चर

```
file_studio/
├─ pubspec.yaml
├─ analysis_options.yaml
├─ l10n.yaml
├─ android/                      # AndroidManifest, intent-filters (नीचे §6)
├─ ios/                          # Info.plist (UTI declarations)
├─ assets/
│  ├─ icons/
│  └─ l10n/ (app_hi.arb, app_en.arb)
├─ test/
│  ├─ core/file_kind_test.dart
│  ├─ features/csv/csv_codec_test.dart
│  └─ features/files/file_repository_test.dart
├─ integration_test/
│  └─ open_edit_save_delete_test.dart
└─ lib/
   ├─ main.dart
   ├─ app.dart                   # MaterialApp.router, theme, locale
   ├─ router.dart
   ├─ core/
   │  ├─ constants.dart
   │  ├─ file_kind.dart          # एक्सटेंशन + MIME + magic-bytes से टाइप पहचान
   │  ├─ result.dart             # Result<T, AppError>
   │  ├─ errors.dart
   │  ├─ utils/
   │  │  ├─ byte_format.dart
   │  │  ├─ debouncer.dart
   │  │  └─ encoding_detect.dart # UTF-8 / UTF-16 / Windows-1252 पहचान
   │  └─ theme/
   │     ├─ app_theme.dart       # light / dark / AMOLED black
   │     └─ text_styles.dart     # Noto Sans Devanagari
   ├─ data/
   │  ├─ models/
   │  │  ├─ file_entry.dart      # id, uri, name, size, modified, kind, isWritable
   │  │  ├─ file_version.dart    # versionId, entryId, createdAt, backupPath
   │  │  ├─ recycle_item.dart    # deletedAt, originalUri, backupPath, expiresAt
   │  │  └─ app_settings.dart
   │  ├─ db/
   │  │  └─ app_database.dart    # isar/drift: versions, recycle, recents, favorites
   │  ├─ storage/
   │  │  ├─ file_gateway.dart    # abstract: pick, read, write, delete, list, create
   │  │  ├─ android_saf_gateway.dart
   │  │  ├─ ios_gateway.dart
   │  │  └─ app_sandbox_gateway.dart  # ऐप की अपनी फोल्डर (fallback)
   │  └─ repositories/
   │     ├─ file_repository.dart      # gateway + versioning + recycle bin जोड़ता है
   │     ├─ version_repository.dart
   │     └─ recycle_repository.dart
   ├─ features/
   │  ├─ home/                  # रीसेंट, फेवरिट, फोल्डर्स, स्टोरेज सारांश
   │  │  ├─ home_page.dart
   │  │  └─ widgets/
   │  ├─ browser/               # फोल्डर ब्राउज़, सर्च, सॉर्ट, मल्टी-सिलेक्ट
   │  │  ├─ browser_page.dart
   │  │  ├─ browser_controller.dart
   │  │  └─ widgets/file_tile.dart
   │  ├─ workspace/             # खुली फाइल का स्क्रीन (टैब + एक्शन बार)
   │  │  ├─ workspace_page.dart
   │  │  ├─ document_session.dart     # mode(readOnly/edit), dirty, undo stack
   │  │  ├─ action_bar.dart           # Open / Save / Delete बटन
   │  │  └─ tabs_controller.dart
   │  ├─ viewers/               # हर टाइप का व्यूअर/एडिटर
   │  │  ├─ viewer_registry.dart      # FileKind → Viewer मैपिंग
   │  │  ├─ text/text_editor.dart
   │  │  ├─ html/html_editor.dart     # कोड | प्रीव्यू (split / tabs)
   │  │  ├─ csv/csv_grid_editor.dart
   │  │  ├─ csv/csv_codec.dart
   │  │  ├─ image/image_viewer.dart
   │  │  ├─ image/image_editor.dart   # rotate, flip, crop, resize, brightness, convert
   │  │  ├─ pdf/pdf_viewer.dart
   │  │  ├─ media/audio_player.dart
   │  │  ├─ media/video_player.dart
   │  │  ├─ markdown/markdown_viewer.dart
   │  │  ├─ json/json_tree_editor.dart
   │  │  ├─ archive/zip_viewer.dart
   │  │  └─ binary/hex_viewer.dart    # बाकी सब फाइलों के लिए fallback
   │  ├─ history/               # वर्ज़न हिस्ट्री + diff
   │  │  ├─ history_page.dart
   │  │  └─ diff_view.dart
   │  ├─ recycle_bin/
   │  │  └─ recycle_bin_page.dart
   │  ├─ search/                # फाइल-नाम + फाइल-के-अंदर खोज
   │  │  └─ search_page.dart
   │  ├─ tools/                 # compare, zip बनाना, rename-batch, hash, share
   │  └─ settings/
   │     ├─ settings_page.dart
   │     └─ app_lock_page.dart
   └─ shared/
      ├─ widgets/ (confirm_dialog, empty_state, toast_with_undo, bottom_sheets)
      └─ providers.dart
```

---

## 3. फीचर सूची (अधिकतम) — फेज़ के हिसाब से

### फेज़ 1 — कोर (MVP, ज़रूर बनना चाहिए)
- [ ] **फाइल ओपन:** पिकर से एक/कई फाइलें, फोल्डर खोलना, दूसरी ऐप से "Open with / Share to" से आना
- [ ] **टाइप पहचान:** एक्सटेंशन → MIME → magic bytes (क्रम में)
- [ ] **मोड:** डिफ़ॉल्ट *सिर्फ़ ओपन (Read-only)*; एक टैप में *एडिट मोड*
- [ ] **सेव:** एडिट मोड में ही सक्रिय; बदलाव होने पर ● निशान; सेव से पहले बैकअप
- [ ] **डिलीट:** कन्फर्म डायलॉग → ऐप के रीसायकल बिन में कॉपी → मूल फाइल हटे → "वापस लाएँ" स्नैकबार
- [ ] **टेक्स्ट एडिटर:** लाइन नंबर, undo/redo, खोज/बदलें, वर्ड-रैप, फॉन्ट साइज़
- [ ] **HTML:** कोड + लाइव प्रीव्यू (WebView, JS चालू पर फाइल-सिस्टम एक्सेस बंद)
- [ ] **CSV:** ग्रिड एडिटर (सेल एडिट, पंक्ति/कॉलम जोड़ना-हटाना, डिलिमिटर ऑटो-डिटेक्ट)
- [ ] **इमेज (JPG/PNG/WebP/GIF/BMP):** ज़ूम-पैन व्यूअर; JPG/PNG/WebP में rotate/flip/brightness
- [ ] **PDF, ऑडियो, वीडियो:** व्यूअर/प्लेयर
- [ ] **बाकी फाइलें:** हेक्स व्यूअर + "नई फाइल से बदलें (Replace)" + Share/Open-with
- [ ] **नई फाइल बनाना**, **Rename**, **Duplicate**, **Share**
- [ ] डार्क/लाइट थीम, हिंदी/अंग्रेज़ी

### फेज़ 2 — पावर फीचर
- [ ] **वर्ज़न हिस्ट्री:** हर सेव का स्नैपशॉट, किसी भी पुराने वर्ज़न पर Restore, दो वर्ज़न का diff
- [ ] **रीसायकल बिन:** 30 दिन तक रखना, Restore / हमेशा के लिए हटाना, ऑटो-क्लीन
- [ ] **ऑटो-सेव (वैकल्पिक सेटिंग)** + क्रैश से बचाव के लिए ड्राफ्ट रिकवरी
- [ ] **मल्टी-टैब**, **मल्टी-सिलेक्ट** (बैच डिलीट/शेयर/कॉपी/मूव)
- [ ] **सर्च:** फाइल-नाम, टाइप, तारीख, साइज़; फोल्डर के अंदर टेक्स्ट-खोज
- [ ] **रीसेंट + फेवरिट + पिन**
- [ ] **इमेज एडिटर पूरा:** crop, resize, फॉर्मेट बदलना (JPG↔PNG↔WebP), क्वालिटी स्लाइडर, कंप्रेस
- [ ] **JSON/XML ट्री व्यू** + फॉर्मेट/वैलिडेट/मिनिफ़ाई
- [ ] **Markdown** लाइव प्रीव्यू, **CSV** में सॉर्ट/फ़िल्टर/कॉलम-स्टैट्स, CSV→JSON/Excel-सेफ़ एक्सपोर्ट
- [ ] **एन्कोडिंग चयन** (UTF-8, UTF-16, Windows-1252…) और लाइन-एंडिंग (LF/CRLF)

### फेज़ 3 — एक्स्ट्रा
- [ ] **ऐप लॉक** (PIN / फिंगरप्रिंट), निजी फाइलों का "सेफ़ फोल्डर"
- [ ] **फाइल कंप्रेस/एक्सट्रैक्ट (ZIP)**, ZIP के अंदर की फाइलें देखना
- [ ] **हैश (MD5/SHA-256)**, फाइल प्रॉपर्टीज़, डुप्लिकेट खोजना
- [ ] **बैच रिनेम** (पैटर्न, नंबरिंग, तारीख)
- [ ] **OCR** (इमेज/स्कैन से टेक्स्ट) और **दस्तावेज़ स्कैनर**
- [ ] **PDF टूल:** मर्ज, स्प्लिट, पेज घुमाना, इमेज→PDF
- [ ] **क्लाउड सिंक (वैकल्पिक):** Google Drive / Dropbox / WebDAV
- [ ] **Wi-Fi ट्रांसफर** (पीसी से फोन पर ब्राउज़र द्वारा फाइल भेजना)
- [ ] **होम-स्क्रीन विजेट / शॉर्टकट**, **टेक्स्ट-टू-स्पीच** से टेक्स्ट सुनना
- [ ] **टेम्पलेट्स** (नई HTML/CSV/MD फाइल के स्टार्टर)

---

## 4. मुख्य कोड-स्केलेटन (एजेंट इसे आधार बनाए)

### 4.1 `core/file_kind.dart`
```dart
enum FileKind { text, html, csv, markdown, json, image, pdf, audio, video, archive, binary }

class FileKindDetector {
  static const _ext = <String, FileKind>{
    'txt': FileKind.text, 'log': FileKind.text, 'xml': FileKind.text, 'css': FileKind.text,
    'js': FileKind.text, 'dart': FileKind.text, 'py': FileKind.text, 'yaml': FileKind.text,
    'html': FileKind.html, 'htm': FileKind.html, 'svg': FileKind.html,
    'csv': FileKind.csv, 'tsv': FileKind.csv,
    'md': FileKind.markdown, 'json': FileKind.json,
    'jpg': FileKind.image, 'jpeg': FileKind.image, 'png': FileKind.image,
    'webp': FileKind.image, 'gif': FileKind.image, 'bmp': FileKind.image,
    'pdf': FileKind.pdf,
    'mp3': FileKind.audio, 'wav': FileKind.audio, 'm4a': FileKind.audio, 'ogg': FileKind.audio,
    'mp4': FileKind.video, 'webm': FileKind.video, 'mkv': FileKind.video,
    'zip': FileKind.archive,
  };

  /// 1) extension  2) magic bytes  3) printable-text heuristic  4) binary
  static FileKind detect(String name, List<int> firstBytes) {
    final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    final byExt = _ext[e];
    if (byExt != null) return byExt;
    // TODO: magic bytes (FF D8 FF = JPEG, 89 50 4E 47 = PNG, 25 50 44 46 = PDF, 50 4B 03 04 = ZIP …)
    // TODO: अगर 0x00 नहीं है और UTF-8 decode सफल है → text
    return FileKind.binary;
  }

  static bool isEditableText(FileKind k) =>
      const {FileKind.text, FileKind.html, FileKind.csv, FileKind.markdown, FileKind.json}.contains(k);
}
```

### 4.2 `data/storage/file_gateway.dart`
```dart
abstract class FileGateway {
  Future<List<FileEntry>> pickFiles({bool multiple = true});
  Future<FileEntry?> pickDirectory();
  Future<List<FileEntry>> list(FileEntry directory);
  Future<Uint8List> readBytes(FileEntry f);
  Stream<List<int>> readStream(FileEntry f);          // बड़ी फाइलों के लिए
  Future<void> writeBytes(FileEntry f, Uint8List data);// overwrite
  Future<FileEntry> create(FileEntry dir, String name, Uint8List data);
  Future<void> delete(FileEntry f);
  Future<FileEntry> rename(FileEntry f, String newName);
}
```
> Android पर `android_saf_gateway.dart` SAF URIs (`content://…`) पर काम करे; सीधा `File(path)` तभी इस्तेमाल हो जब पाथ ऐप की अपनी डायरेक्टरी में हो। iOS पर security-scoped bookmarks सहेजें ताकि दोबारा एक्सेस मिले।

### 4.3 `data/repositories/file_repository.dart` — सेव और डिलीट का नियम
```dart
class FileRepository {
  FileRepository(this._gw, this._versions, this._recycle);
  final FileGateway _gw; final VersionRepository _versions; final RecycleRepository _recycle;

  Future<void> save(FileEntry f, Uint8List newData) async {
    final old = await _gw.readBytes(f);
    await _versions.snapshot(f, old);     // 1) पहले बैकअप
    await _gw.writeBytes(f, newData);     // 2) फिर overwrite
    // 3) वेरिफाई: दोबारा पढ़कर लंबाई/हैश मिलाएँ; न मिले तो बैकअप से रोलबैक
  }

  Future<RecycleItem> delete(FileEntry f) async {
    final data = await _gw.readBytes(f);
    final item = await _recycle.put(f, data);  // 1) बिन में कॉपी
    await _gw.delete(f);                       // 2) फिर मूल हटाएँ
    return item;                               // UI "वापस लाएँ" दिखाए
  }

  Future<void> undoDelete(RecycleItem item) => _recycle.restore(item, _gw);
}
```

### 4.4 `features/workspace/document_session.dart`
```dart
enum EditMode { readOnly, edit }

class DocumentSession {
  DocumentSession(this.entry, this.kind);
  final FileEntry entry; final FileKind kind;
  EditMode mode = EditMode.readOnly;        // हमेशा read-only से शुरू
  bool get canSave => mode == EditMode.edit && dirty;
  bool dirty = false;
  // text: String current/original, undo/redo stack
  // image: rotation, flip, brightness, crop rect  (non-destructive; सेव पर encode)
  // csv: List<List<String>> + delimiter
}
```

### 4.5 `features/workspace/action_bar.dart` — तीन मुख्य विकल्प
- **ओपन/व्यू** टॉगल: `👁 सिर्फ़ ओपन` ↔ `✏️ एडिट`
- **💾 सेव**: `session.canSave == false` हो तो disabled; सेव सफल होने पर टोस्ट
- **🗑 डिलीट**: `ConfirmDialog` → `repo.delete()` → `ToastWithUndo`
- ओवरफ़्लो मेनू: Rename, Duplicate, Share, Open with…, History, Properties

### 4.6 `viewers/viewer_registry.dart`
```dart
Widget buildViewer(DocumentSession s) => switch (s.kind) {
  FileKind.text     => TextEditor(session: s),
  FileKind.html     => HtmlEditor(session: s),
  FileKind.csv      => CsvGridEditor(session: s),
  FileKind.markdown => MarkdownViewer(session: s),
  FileKind.json     => JsonTreeEditor(session: s),
  FileKind.image    => ImageViewer(session: s),   // एडिट मोड में ImageEditor
  FileKind.pdf      => PdfViewer(session: s),
  FileKind.audio    => AudioPlayer(session: s),
  FileKind.video    => VideoPlayerView(session: s),
  FileKind.archive  => ZipViewer(session: s),
  FileKind.binary   => HexViewer(session: s),
};
```

---

## 5. स्क्रीन फ़्लो

```
Home ──► Browser ──► Workspace (tabs)
 │         │             ├─ Viewer/Editor (टाइप के हिसाब से)
 │         │             ├─ Action bar: [👁/✏️] [💾 सेव] [🗑 डिलीट]
 │         │             └─ History / Properties / Share
 ├─ Recents / Favorites
 ├─ Search
 ├─ Recycle Bin
 └─ Settings (थीम, भाषा, ऑटो-सेव, लॉक, बिन-अवधि, एन्कोडिंग)
```
- नीचे नेविगेशन बार: **होम · फाइलें · खोज · बिन · सेटिंग**
- एक हाथ से उपयोग: एक्शन बार स्क्रीन के नीचे, बड़े टच-टारगेट (≥48dp)

---

## 6. प्लेटफ़ॉर्म सेटअप

**Android (`AndroidManifest.xml`)**
- `MANAGE_EXTERNAL_STORAGE` **न** माँगें। SAF (Storage Access Framework) से यूज़र फाइल/फोल्डर चुने और `takePersistableUriPermission` से अनुमति याद रखें।
- `READ_MEDIA_IMAGES/VIDEO/AUDIO` सिर्फ़ तब जब गैलरी ब्राउज़िंग चाहिए।
- इंटेंट-फ़िल्टर: `ACTION_VIEW`, `ACTION_EDIT`, `ACTION_SEND` (text/*, image/*, application/pdf, `*/*`) ताकि दूसरी ऐप से "Open with File Studio" दिखे।
- `minSdk 24+`, `targetSdk` नवीनतम।

**iOS (`Info.plist`)**
- `UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace` = true
- `CFBundleDocumentTypes` में सपोर्टेड UTIs
- iOS सैंडबॉक्स की वजह से बाहरी फाइल डिलीट कभी-कभी सीमित हो सकती है — UI में साफ़ संदेश दिखाएँ।

---

## 7. सुरक्षा और भरोसेमंद व्यवहार (ज़रूरी नियम)
1. **डेटा-हानि शून्य:** हर overwrite से पहले बैकअप; लिखने के बाद वेरिफ़िकेशन।
2. **डिलीट हमेशा पलटने-योग्य** (बिन) जब तक यूज़र "हमेशा के लिए हटाएँ" न चुने।
3. HTML प्रीव्यू में `file://` एक्सेस बंद, बाहरी नेविगेशन ब्लॉक, JS सैंडबॉक्स।
4. बड़ी फाइलें: 5 MB+ टेक्स्ट → read-only स्ट्रीमिंग व्यूअर; इमेज डिकोड के लिए `compute()`/isolate।
5. एक्सेप्शन पर क्रैश नहीं — `Result<T>` से साफ़ हिंदी त्रुटि संदेश।
6. बिना सेव बदलाव पर बैक दबाने से चेतावनी; ऐप बंद होने पर ड्राफ्ट रिकवरी।
7. कोई एनालिटिक्स/नेटवर्क कॉल डिफ़ॉल्ट में नहीं (ऑफ़लाइन-फ़र्स्ट)।

---

## 8. टेस्ट और स्वीकृति-मानदंड (Definition of Done)
- [ ] `flutter analyze` में 0 warnings; यूनिट टेस्ट पास
- [ ] `.html` खोलो → कोड बदलो → सेव → फाइल में बदलाव दिखे; प्रीव्यू सही
- [ ] `.csv` खोलो → सेल/पंक्ति बदलो → सेव → क्वोट/कॉमा सही बचे (round-trip टेस्ट)
- [ ] `.jpg/.png` खोलो → rotate → सेव → नई इमेज सही दिशा में, फाइल खुलने योग्य
- [ ] Read-only मोड में Save बटन disabled; कोई कीस्ट्रोक फाइल नहीं बदलता
- [ ] डिलीट → बिन में दिखे → Restore → फाइल वापस, बाइट-दर-बाइट समान
- [ ] 50 MB की टेक्स्ट फाइल बिना क्रैश के खुले
- [ ] हिंदी (देवनागरी) टेक्स्ट UTF-8 में खोलने/सेव करने पर खराब न हो
- [ ] 2 सेव के बाद History में 2 वर्ज़न; पुराने पर Restore काम करे
- [ ] Android 10, 13, 14+ पर टेस्ट (SAF व्यवहार अलग-अलग होता है)

---

## 9. Antigravity में चलाने का सुझाव (फेज़ वाले प्रॉम्प्ट)

**प्रॉम्प्ट 1:** "Create the Flutter project skeleton exactly as in SPEC.md §2, set up Riverpod, go_router, theme (light/dark), Hindi/English localization, and the `core/` + `data/models/` files. Build and run on the emulator."

**प्रॉम्प्ट 2:** "Implement Phase 1: FileGateway (Android SAF + sandbox fallback), FileRepository with backup-before-save and recycle-on-delete, Workspace page with the Open/Save/Delete action bar, and Text, HTML, CSV, Image viewers/editors. Add the tests from §8."

**प्रॉम्प्ट 3:** "Add PDF, audio, video, hex viewers, new-file/rename/duplicate/share, recents and search."

**प्रॉम्प्ट 4:** "Implement Phase 2: version history with diff, recycle bin page, multi-tab, multi-select, JSON tree, Markdown, full image editor."

**प्रॉम्प्ट 5:** "Implement Phase 3 features one by one, starting with app lock and ZIP. Run the full acceptance checklist in §8 and report failures."

---

### नोट
पैकेज के नाम और वर्ज़न समय के साथ बदलते हैं; एजेंट को हमेशा pub.dev पर ताज़ा स्थिति जाँचने को कहें। Play Store पर डालने से पहले स्टोरेज-परमिशन पॉलिसी (SAF का उपयोग) और प्राइवेसी पॉलिसी तैयार रखें।
