# تقرير تجهيز المشروع

## ما تم تنفيذه

- ضبط مشروع Flutter كامل باسم `kokabna_private_app`.
- تعريب الواجهة واتجاه RTL.
- تجهيز شاشات: الدخول، الرئيسية، الشات، المكالمات، القصص، الألبومات، الملاحظات، الملفات، الصفحات، الذكريات، الإعدادات، ولوحة الإدارة.
- تجهيز خدمات Firebase: المصادقة، Firestore، Storage، Cloud Functions، وFCM tokens.
- تحسين معاينة الملفات داخل التطبيق للصور والفيديو والصوت.
- تنظيف أسماء الملفات ومسارات التخزين قبل الرفع.
- إضافة ملفات Android الضرورية للتشغيل والبناء.
- إصلاح موارد Android المتكررة حتى لا تسبب أخطاء duplicate resources.
- إضافة قواعد Firestore وStorage وفهارس Firestore المطلوبة للاستعلامات المركّبة.
- إضافة سكربتات بناء: `build_apk.sh` و `build_apk.bat`.

## اختبار البيئة

لم يتم إنتاج APK داخل هذه البيئة لأن Flutter وDart وGradle غير مثبتين هنا. للبناء على جهازك استخدم:

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

## مكان APK بعد البناء

```text
build/app/outputs/flutter-apk/app-release.apk
```
