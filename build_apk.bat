@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter غير موجود في PATH. ثبت Flutter ثم أعد المحاولة.
  exit /b 1
)
flutter doctor
flutter pub get
flutter analyze
flutter build apk --release
echo تم البناء. ابحث عن APK هنا: build\app\outputs\flutter-apk\app-release.apk
