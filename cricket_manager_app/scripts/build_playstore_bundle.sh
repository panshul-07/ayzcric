#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f android/key.properties ]]; then
  echo "android/key.properties not found."
  echo "Create it from android/key.properties.example first."
  exit 1
fi

flutter pub get
flutter test
flutter analyze
flutter build appbundle --release

echo "\nAAB created at: build/app/outputs/bundle/release/app-release.aab"
