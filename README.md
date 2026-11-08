# फ़ाइल स्टूडियो (File Studio) 📱📁

> **आधुनिक, सुरक्षित और बहुभाषी मोबाइल फ़ाइल प्रबंधक एवं बहु-प्रारूप संपादक**  
> *Modern, zero-loss, cross-platform mobile file manager and multi-format editor built with Flutter.*

[![Flutter CI](https://github.com/naveenvichaar-oss/file-studio/actions/workflows/ci.yml/badge.svg)](https://github.com/naveenvichaar-oss/file-studio/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey.svg)](https://flutter.dev)
[![Code Style](https://img.shields.io/badge/style-pedantic-brightgreen.svg)](https://dart.dev)

---

## 🌟 मुख्य विशेषताएँ (Key Highlights)

### 1. 🛡️ Three Core Actions Architecture
- **👁 OPEN (देखें)**: डिफ़ॉल्ट केवल-पढ़ने (Read-only) मोड। फाइल कभी अनजाने में परिवर्तित नहीं होती।
- **💾 SAVE (सुरक्षित सहेजें)**:
  - केवल एडिट मोड में सक्रिय।
  - बदलाव होने पर विज़ुअल इंडिकेटर (Dirty State indicator)।
  - ओवरराइट करने से पहले स्वचालित वर्ज़न बैकअप (Version History Snapshot)।
- **🗑 DELETE (हटाएँ)**:
  - स्पष्ट पुष्टि डायलॉग (Confirmation Modal)।
  - इन-ऐप रीसायकल बिन में 30-दिवसीय सुरक्षित बैकअप।
  - त्वरित रीस्टोर और तात्कालिक "वापस लाएँ" (Undo Toast) सपोर्ट।

---

## 📂 समर्थित फ़ाइल प्रारूप (Supported Formats)

| श्रेणी (Category) | प्रारूप (Formats) | क्षमताएँ (Capabilities) |
|---|---|---|
| **टेक्स्ट एवं कोड** | `.txt`, `.log`, `.md`, `.json`, `.xml`, `.yaml`, `.html`, `.css`, `.js`, `.dart`, `.py`, `.c`, `.cpp`, `.java`, आदि | लाइन नंबर, रीड/एडिट टॉगल, फॉन्ट रिसाइज़िंग, इन-फाइल सर्च, UTF-8 / UTF-16 / Latin1 ऑटो-डिटेक्शन |
| **मार्कडाउन** | `.md`, `.markdown` | सिंटैक्स हाइलाइटिंग एडिटर + लाइव GitHub Flavored Markdown (GFM) प्रीव्यू टैब |
| **JSON** | `.json` | सिंटैक्स वैलिडेशन, 2-स्पेस इंडेंट प्रीटिफायर, मिनिफ़ायर एवं विज़ुअल ट्री व्यू |
| **स्प्रेडशीट** | `.csv`, `.tsv` | इंटरैक्टिव ग्रिड एडिटर, रो/कॉलम इंसर्ट व डिलीट, सेल-बाय-सेल एडिटिंग |
| **छवियाँ (Images)**| `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.bmp` | ज़ूम/पैन, रोटेशन (90°/180°/270°), हॉरिजॉन्टल/वर्टिकल फ्लिप, पिक्सेल रिसाइज़, कंप्रेसन क्वालिटी, फॉर्मेट कन्वर्जन |
| **दस्तावेज़ (Docs)** | `.pdf` | सुरक्षित इन-ऐप एवं सिस्टम व्यूअर इंटीग्रेशन |
| **मीडिया (Media)** | `.mp3`, `.wav`, `.m4a`, `.mp4`, `.mkv`, `.webm` | ऑडियो एवं वीडियो प्लेयर, प्ले/पॉज़, सीक, वॉल्यूम कंट्रोल्स |
| **आर्काइव (Archive)**| `.zip` | ज़िप आर्काइव का पूर्वावलोकन, फाइलों का कंप्रेसन एवं सीधे अनज़िप (Extract) करना |
| **बाइनरी / अन्य** | किसी भी प्रकार की अज्ञात या बाइनरी फाइलें | 16-बाइट हेक्स डंप (Hex Viewer) ऑफसेट और ASCII डिकोडिंग के साथ |

---

## 🚀 पावर फीचर्स (Power Features)

- 🔄 **वर्ज़न हिस्ट्री व Diff व्यू**:
  - प्रत्येक सेव से पहले स्वचालित स्नैपशॉट।
  - दो वर्जनों के बीच रंगीन साइड-बाय-साइड और लाइन-बाय-लाइन विज़ुअल Diff (जोड़े गए व हटाए गए अंश)।
  - किसी भी पिछले वर्ज़न पर वन-क्लिक सेफ रीस्टोर।
- 🔍 **डीप सर्च (Deep Content Search)**:
  - फाइल नाम, फाइल एक्सटेंशन और फोल्डर के भीतर टेक्स्ट फाइलों की सामग्री में सर्च।
  - हाइलाइटेड मैच स्निपेट्स।
- 📦 **बैच ऑपरेशन्स (Multi-Select & Batch)**:
  - लॉन्ग प्रेस पर मल्टी-सिलेक्ट मोड।
  - एक साथ कई फाइलों को डिलीट, शेयर या ZIP में कंप्रेस करना।
- 🏷️ **बैच रिनेम (Batch Rename)**:
  - प्रीफ़िक्स, सफ़िक्स, अनुक्रमिक नंबरिंग (Sequential 001, 002...), और फाइंड-एंड-रिप्लेस विथ लाइव प्रीव्यू।
- 🔐 **सुरक्षा एवं ऐप लॉक**:
  - SHA-256 एन्क्रिप्टेड 4-अंकीय PIN लॉक।
  - संवेदनशील फाइलों तक अनधिकृत पहुंच पर तुरंत रोक।
- 🌐 **द्विभाषी इंटरफ़ेस (Localization)**:
  - पूर्णतः हिंदी UI (डिफ़ॉल्ट) और अंग्रेज़ी स्विच करने का सहज विकल्प।

---

## 🏗️ वास्तुकला (Project Architecture)

ऐप साफ़-सुथरे लेयर्ड आर्किटेक्चर और **Riverpod** स्टेट मैनेजमेंट पर आधारित है:

```
lib/
├── core/                  # फाउंडेशन लेयर
│   ├── constants.dart     # ऐप कॉन्स्टेंट्स और रूट्स
│   ├── errors.dart        # टाइप-सेफ अपवाद और विफलताएँ
│   ├── file_kind.dart     # मैजिक बाइट्स व एक्सटेंशन डिटेक्टर
│   ├── result.dart        # Result<T, E> फंक्शनल एरर हैंडलिंग
│   ├── theme/             # Light, Dark और AMOLED थीम्स
│   └── utils/             # ByteFormat, Debouncer, EncodingDetect
├── data/                  # रिपॉजिटरी और डेटा मॉडल्स
│   ├── models/            # FileEntry, FileVersion, RecycleItem, AppSettings
│   ├── storage/           # FileGateway और LocalFileGateway
│   └── repositories/      # FileRepository, VersionRepository, RecycleRepository
├── features/              # UI स्क्रीन व लॉजिक (Feature-driven)
│   ├── browser/           # फाइल ब्राउज़र, मल्टी-सिलेक्ट व बैच टूल्स
│   ├── history/           # वर्ज़न हिस्ट्री और साइड-बाय-साइड Diff इंजन
│   ├── home/              # हाल की फाइलें, पसंदीदा और क्विक ऐक्सेस
│   ├── recycle_bin/       # 30-दिवसीय रीसायकल बिन व रीस्टोर
│   ├── search/            # डीप टेक्स्ट सर्च व फ़िल्टरिंग
│   ├── settings/          # सेटिंग्स और 4-डिजिट PIN लॉक
│   ├── tools/             # ZIP आर्काइवर और बैच रिनेम डायलॉग
│   ├── viewers/           # 10+ प्रारूप व्यूअर्स व एडिटर्स
│   └── workspace/         # डॉक्यूमेंट सेशन (Dirty state, Undo/Redo)
├── l10n/                  # स्थानीयकरण (app_hi.arb, app_en.arb)
├── shared/                # साझा विजेट्स (ConfirmDialog, ToastWithUndo, आदि)
├── app.dart               # MaterialApp कॉन्फ़िगरेशन
├── router.dart            # GoRouter राउट डेफिनिशन
└── main.dart              # ऐप एंट्री पॉइंट
```

---

## 🛠️ प्रोजेक्ट सेटअप और रन (Setup & Running)

### आवश्यकताएँ:
- Flutter SDK (>= 3.7.0)
- Dart SDK (>= 3.0.0)

### 1. क्लोन करें (Clone Repository):
```bash
git clone https://github.com/naveenvichaar-oss/file-studio.git
cd file-studio
```

### 2. निर्भरताएँ इंस्टॉल करें (Install Dependencies):
```bash
flutter pub get
```

### 3. विश्लेषण व परीक्षण (Analyze & Test):
```bash
# स्टेटिक कोड एनालिसिस (0 issues)
flutter analyze

# यूनिट और लॉजिक टेस्ट्स चलाएँ (16/16 pass)
flutter test
```

### 4. ऐप चलाएँ (Run Application):
```bash
# कनेक्टेड डिवाइस या एमुलेटर पर चलाएँ
flutter run
```

---

## 📄 लाइसेंस (License)

यह प्रोजेक्ट [MIT License](LICENSE) के अंतर्गत ओपन सोर्स है।

---

## 🤝 योगदान (Contributing)

यदि आप कोई नई सुविधा जोड़ना चाहते हैं या बग रिपोर्ट करना चाहते हैं, तो कृपया [Issues](https://github.com/naveenvichaar-oss/file-studio/issues) में टिकट बनाएँ या Pull Request सबमिट करें।
