# كوكبنا 💕 — النسخة 2.0

تطبيق Flutter + Firebase خاص لشخصين فقط، بواجهة عربية كاملة RTL.

---

## ✨ مميزات النسخة 2.0

| الميزة | الوصف |
|--------|-------|
| 🌍 **عربي 100%** | واجهة RTL كاملة بخط Cairo |
| 💕 **عداد الأيام** | كم يوم مضى عليكم معًا |
| 🎨 **6 ثيمات** | وردي · داكن · بنفسجي · أبيض · ذهبي · تيل |
| 🧭 **شريط تنقل سفلي** | الرئيسية · الشات · الألبومات · الذكريات |
| 💬 **دردشة محسّنة** | توقيت الرسائل · 15 ملصق · ردود الفعل |
| 📅 **تواريخ الذكريات** | عرض تاريخ كل ذكرى بالعربي |
| 🔐 **زر عرض كلمة المرور** | في شاشة الدخول |
| 📋 **نسخ كود الدعوة** | اضغط مطولاً للنسخ |
| 👑 **لوحة إدارة** | شارة حالة الشريك · كود الدعوة |
| 🌅 **تحية الوقت** | صباح النور / مساء الخير / طبتِ ليلاً |
| 🏗️ **GitHub Actions** | بناء APK تلقائي |

---

## 📁 هيكل المشروع

```
lib/
├── main.dart                  ← نقطة البداية
├── app.dart                   ← MaterialApp + RTL
├── models/models.dart         ← نماذج البيانات
├── services/
│   ├── app_state.dart         ← حالة التطبيق
│   ├── auth_service.dart      ← المصادقة
│   ├── chat_service.dart      ← الدردشة
│   ├── content_service.dart   ← المحتوى
│   ├── notification_service.dart
│   ├── call_service.dart
│   ├── page_service.dart
│   └── storage_service.dart
├── screens/                   ← 18 شاشة
├── theme/app_theme.dart       ← 6 ثيمات + Cairo font
└── widgets/love_widgets.dart  ← مكونات مخصصة
```

---

## 🚀 بناء الـ APK

### الطريقة 1 — GitHub Actions (مجاني 100%)

1. ارفع المشروع على GitHub
2. روح **Actions** → **بناء APK كوكبنا** → **Run workflow**
3. بعد 5-8 دقائق حمّل الـ APK من **Artifacts**

### الطريقة 2 — على جهازك

```bash
# تثبيت الحزم
flutter pub get

# APK للتجربة
flutter build apk --debug

# APK للنشر
flutter build apk --release

# الملف في:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ إعداد Firebase

> **مهم:** استبدل `android/app/google-services.json` بملفك الحقيقي من Firebase Console.

1. روح [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروع جديد
3. أضف تطبيق Android → Package: `com.onlyus.privateworld`
4. حمّل `google-services.json` وضعه في `android/app/`
5. فعّل: Authentication · Firestore · Storage · Messaging

---

## 🏠 أول تشغيل

1. **الأدمن:** افتح التطبيق → تبويب "أدمن جديد" → سجّل
2. **دعوة الشريك:** الإدارة → "توليد كود دعوة" → شارك الكود
3. **الشريك:** تبويب "انضمام" → أدخل الكود

---

بُني بالحب ❤️
