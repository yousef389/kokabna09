#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter غير موجود في PATH. ثبّت Flutter ثم أعد المحاولة."
  exit 1
fi

flutter doctor
flutter pub get
flutter analyze
flutter build apk --release

echo "تم البناء. ابحث عن APK هنا: build/app/outputs/flutter-apk/app-release.apk"
