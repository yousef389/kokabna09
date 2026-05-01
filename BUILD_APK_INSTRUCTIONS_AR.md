# طريقة بناء APK لتطبيق كوكبنا

## المتطلبات

- Flutter SDK حديث.
- Android Studio أو Android SDK.
- Java 17.
- اتصال Firebase مضبوط داخل `android/app/google-services.json` و `lib/firebase_options.dart`.

## تحقق من البيئة

```bash
flutter doctor
```

أي علامة حمراء يجب إصلاحها قبل البناء.

## تثبيت الحزم

من داخل مجلد المشروع:

```bash
flutter pub get
```

## تجربة التطبيق

```bash
flutter run
```

## بناء نسخة APK

```bash
flutter build apk --release
```

ستجد الملف هنا غالبًا:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## بناء نسخة debug سريعة

```bash
flutter build apk --debug
```

المسار المتوقع:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## لو ظهر خطأ عن `flutter.sdk`

أنشئ الملف التالي:

```text
android/local.properties
```

واكتب داخله مسار Flutter وAndroid SDK عندك، مثال:

```properties
flutter.sdk=C:\\src\\flutter
sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
```

على macOS أو Linux قد يكون المثال:

```properties
flutter.sdk=/Users/yourname/development/flutter
sdk.dir=/Users/yourname/Library/Android/sdk
```

## لو أردت إعادة توليد ملفات Android الأصلية

```bash
flutter create --platforms=android .
flutter pub get
flutter build apk --release
```

بعدها تأكد أن هذه الملفات لم تتغير بشكل خاطئ:

```text
android/app/google-services.json
android/app/build.gradle
android/app/src/main/AndroidManifest.xml
```

## بناء APK من GitHub Actions

تمت إضافة workflow جاهز هنا:

```text
.github/workflows/build-apk.yml
```

الخطوات:

1. ارفع المشروع على GitHub.
2. افتح تبويب Actions.
3. اختر `Build Flutter APK`.
4. اضغط `Run workflow`.
5. بعد انتهاء البناء حمّل artifact باسم `kokabna-release-apk`.

> ملاحظة: الـ package النهائي مضبوط على `com.onlyus.privateworld` لأنه هو نفس الموجود في Firebase `google-services.json`.
