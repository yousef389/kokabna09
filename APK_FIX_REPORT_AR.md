# تقرير إصلاح مشروع كوكبنا للـ APK

## ما تم إصلاحه

1. توحيد Android package/applicationId مع Firebase و MainActivity:
   - `com.onlyus.privateworld`

2. إزالة `com.kokabna.private` لأنها كانت مختلفة عن `google-services.json`، وبها كلمة `private` المحجوزة في Java/Kotlin.

3. تعطيل R8/minify في نسخة release لتقليل أخطاء بناء APK مع إضافات Flutter/Firebase:
   - `minifyEnabled false`
   - `shrinkResources false`

4. إزالة تعريف يدوي غير صحيح لخدمة Firebase Messaging من AndroidManifest؛ إضافة `firebase_messaging` تضيف الخدمة الصحيحة تلقائيًا.

5. توحيد notification channel في Cloud Functions إلى:
   - `kokabna_channel`

6. إضافة GitHub Actions workflow لبناء APK تلقائيًا:
   - `.github/workflows/build-apk.yml`

## ملاحظات مهمة قبل التشغيل الكامل

- لبناء APK من GitHub: ارفع المشروع على GitHub ثم افتح Actions وشغّل workflow باسم `Build Flutter APK`.
- لتشغيل انضمام الشريك والإشعارات السحابية يجب نشر Firebase Functions:

```bash
firebase deploy --only functions,firestore:rules,storage
```

- بناء APK لا يحتاج `android/local.properties` على GitHub Actions، لكنه يحتاجه على جهازك المحلي لو هتبني من الكمبيوتر.
