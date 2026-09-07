# 🕌 تطبيق المؤذن ومواقيت الصلاة (Muezzin Flutter)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20BLoC-blueviolet?style=for-the-badge" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge" alt="Platforms" />
</p>

---

## 📖 نبذة عن المشروع (About)

**مؤذن (Muezzin Flutter)** هو تطبيق إسلامي مفتوح المصدر ومبني باستخدام إطار العمل **Flutter**، يهدف إلى مساعدة المسلمين في مختلف أنحاء العالم على معرفة مواقيت الصلاة بدقة عالية، مع إمكانية التنبيه بالأذان، وتحديد الموقع الجغرافي تلقائياً، والعمل بكفاءة دون الحاجة للاتصال الدائم بالإنترنت عبر التخزين المؤقت الذكي.

---

## ✨ المميزات الرئيسية (Key Features)

- ⏱️ **حساب دقيق لمواقيت الصلاة**: جلب المواقيت اليومية والشهرية بالاعتماد على واجهة **Aladhan API** (وفق طريقة رابطة العالم الإسلامي).
- 🧭 **تحديد الموقع الجغرافي**:
  - جلب الإحداثيات تلقائياً عبر الـ GPS باستخدام حزمة `geolocator`.
  - إمكانية الإدخال اليدوي للإحداثيات ومطابقتها.
- ⏳ **عد تنازلي دقيق وساعة رقمية حية**:
  - ساعة رقمية في رأس الشاشة تتحدث كل ثانية بدون إعادة بناء كامل الشاشة.
  - إبراز الصلاة القادمة تلقائياً مع عرض الوقت المتبقي بالساعات والدقائق.
- 📅 **التقويم الهجري والميلادي**: عرض التاريخ الهجري والتاريخ الميلادي بدقة لليوم الحالي.
- 🔔 **تنبيهات الأذان عبر الإشعارات**:
  - جدولة أوقات الصلوات مسبقاً باستخدام `awesome_notifications`.
  - تشغيل صوت الأذان (بصوت الشيخ أحمد الكردي) عند حلول موعد الصلاة.
  - جدولة ذكية تحافظ على موارد الجهاز والبطارية وتتوافق مع سياسات النظام.
- 💾 **العمل بدون إنترنت (Offline Caching)**: تخزين مواقيت الشهر والموقع محلياً عبر `shared_preferences` لتوفير البيانات والعمل في حال انقطاع الشبكة.
- 🎨 **تصميم إسلامي عصري وجذاب**:
  - واجهة مستخدم متناسقة بتدرجات لونية هادئة (الأخضر والذهبي الداكن).
  - دعم كامل للغة العربية والاتجاه من اليمين إلى اليسار (RTL).
  - خط طباعي عربي متميز وأنيق (`Cairo`).

---

## 🏗️ البنية المعمارية (Architecture & Tech Stack)

تم بناء التطبيق باتباع مبادئ **Clean Architecture** ونمط إدارة الحالة **BLoC Pattern** لضمان قابلية التوسع والصيانة العالية وفصل طبقات العمل:

```
lib/
├── core/                       # المكونات الأساسية والمشتركة
│   ├── cache/                  # التخزين المؤقت (AppCache)
│   ├── errors/                 # معالجة الأخطاء والاستثناءات (Failures & Exceptions)
│   ├── services/               # الخدمات الخارجية (Notifications, Location)
│   ├── theme/                  # السمات والألوان والخطوط (MuezzinTheme, AppTextTheme)
│   └── utils/                  # التوابع المساعدة والإضافات (Extensions, Toast)
├── injection_container.dart    # حقن الاعتماديات (Dependency Injection via GetIt)
├── main.dart                   # نقطة انطلاق التطبيق وإعداداته
└── src/                        # منطق وميزات التطبيق
    ├── api/                    # مصادر البيانات عن بُعد (Remote Data Sources - Dio)
    ├── logic/                  # إدارة الحالة (BLoC: MuezzinBloc, HomeBloc)
    ├── model/                  # نماذج البيانات (PrayerTimesModels)
    ├── repositories/           # مستودعات البيانات (MuezzinRepository)
    └── view/                   # واجهات المستخدم (Screens & Widgets)
```

### 🛠️ الحزم والتقنيات المستخدمة (Dependencies)

| الحزمة | الاستخدام |
| :--- | :--- |
| **`flutter_bloc`** / **`bloc`** | إدارة حالة التطبيق وفصل طبقة المنطق عن واجهة المستخدم |
| **`get_it`** | حقن الاعتماديات (Service Locator / Dependency Injection) |
| **`dio`** | تنفيذ طلبات الشبكة للـ API مع وسيط تسجيل البيانات (`LogInterceptor`) |
| **`awesome_notifications`** | جدولة إشعارات الأذان وتشغيل الملفات الصوتية |
| **`geolocator`** | الوصول إلى إحداثيات الموقع عبر نظام تحديد المواقع (GPS) |
| **`shared_preferences`** | التخزين المحلي الدائم لمواقيت الصلاة والموقع |
| **`dartz`** | البرمجة الوظيفية ومعالجة الأخطاء باستخدام `Either` |
| **`freezed`** & **`json_serializable`** | توليد نماذج البيانات غير القابلة للتعديل والتحويل من/إلى JSON |
| **`connectivity_plus`** | فحص حالة الاتصال بالإنترنت |
| **`toastification`** | عرض التنبيهات المنبثقة بشكل أنيق |

---

## 🚀 البدء وتثبيت المشروع (Getting Started)

### المتطلبات الأساسية (Prerequisites)
- تثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) (الإصدار 3.8.1 أو أحدث).
- تثبيت بيئة التطوير (Android Studio / VS Code).
- جهاز حقيقي أو محاكي (Emulator / Simulator).

### خطوات التثبيت والتشغيل (Setup)

1. **استنساخ المستودع (Clone the repo):**
   ```bash
   git clone https://github.com/mohamad-hadi-said/muezzin_flutter.git
   cd muezzin_flutter
   ```

2. **تثبيت الحزم (Install dependencies):**
   ```bash
   flutter pub get
   ```

3. **توليد ملفات الكود المساعد (Generate Models/Freezed):**
   *(اختياري في حال تعديل أي نماذج بيانات)*
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **تشغيل التطبيق (Run the app):**
   ```bash
   flutter run
   ```

---

## 📱 أذونات التطبيق (Permissions)

يتطلب التطبيق بعض الأذونات الأساسية ليعمل بشكل صحيح:
- **الموقع الجغرافي (`ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`)**: لتحديد إحداثيات مدينتك وحساب المواقيت بدقة.
- **الإشعارات والمنبهات الدقيقة (`POST_NOTIFICATIONS` / `SCHEDULE_EXACT_ALARM`)**: لإرسال تنبيهات الأذان وجدولتها في موعدها الدقيق في الخلفية.

---

## 🌐 مصدر البيانات (API Reference)

يعتمد التطبيق على واجهة [Aladhan API](https://aladhan.com/prayer-times-api) لحساب أوقات الصلاة والتقويم الهجري:
- **نقطة النهاية للتقويم الشهري:** `/calendar/{year}/{month}`
- **طريقة الحساب الافتراضية:** رابطة العالم الإسلامي (Muslim World League - Method 3).

---

## 🤝 المساهمة (Contributing)

المساهمات مرحب بها دائماً! إذا كان لديك أي فكرة أو تحسين أو واجهت مشكلة:
1. قم بفتح **Issue** لمناقشة التعديل.
2. أنشئ فرعاً جديداً (`git checkout -b feature/AmazingFeature`).
3. سجّل التعديلات (`git commit -m 'feat: Add AmazingFeature'`).
4. ارفع الفرع (`git push origin feature/AmazingFeature`).
5. أنشئ **Pull Request**.

---

<p align="center">
  صُنع بـ ❤️ لخدمة المسلمين وتسهيل المحافظة على الصلاة
</p>
