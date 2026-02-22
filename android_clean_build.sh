#!/bin/bash
# One-time clean for Android build issues. Run from project root.
set -e
echo "Cleaning Gradle caches and build..."
rm -rf ~/.gradle/caches/transforms-3
rm -rf ~/.gradle/caches/transforms-4
cd "$(dirname "$0")"
export PATH="$PATH:$HOME/flutter/bin"
flutter clean
cd android && ./gradlew clean --no-daemon && cd ..
echo "Done. Run: flutter run -d \"sdk gphone64 x86 64\""
