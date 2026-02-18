# Tambola / Housie Number Caller App

Cross-platform (Android & iOS) number caller with manual/auto modes, voice, dark mode, and persistent game state.

## Quick start

1. **Install Flutter** (see [BEGINNER_GUIDE.md](BEGINNER_GUIDE.md) for step-by-step setup).
2. **Open this folder** in a terminal (e.g. `cd tambola_caller`).
3. **Create platform folders** (if you created the project manually and don’t have `android/` and `ios/` yet):
   ```bash
   flutter create .
   ```
   Answer **n** when asked to overwrite existing files, so your `lib/` and `pubspec.yaml` are kept.
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```
5. **Run the app:**
   ```bash
   flutter run
   ```
   Use an Android emulator, iOS simulator, or a connected device.

## Commands summary

| Command | Purpose |
|--------|---------|
| `flutter pub get` | Install packages (run after changing `pubspec.yaml`). |
| `flutter run` | Build and run on the default device. |
| `flutter devices` | List available devices. |
| `flutter run -d <id>` | Run on a specific device. |
| `flutter build apk` | Build an Android APK (output in `build/app/outputs/flutter-apk/`). |

## Features

- **Numbers 1–90** at random, no duplicates; called numbers highlighted.
- **Manual mode:** “Next Number” button to call each number.
- **Automatic mode:** 3 / 5 / 7 second interval, countdown, Pause/Resume.
- **Resume:** Game state is saved; you can close the app and resume later.
- **Voice:** Text-to-speech for each number; speed control in the game menu (⋮).
- **Sound toggle:** Turn voice on/off (app bar).
- **Dark mode:** Toggle in app bar (home and game).
- **Exit confirmation:** Back button asks before exiting so progress isn’t lost by mistake.

## QA and testing

See **[QA_TESTING_CHECKLIST.md](QA_TESTING_CHECKLIST.md)** for a full testing checklist, edge cases, and how to verify randomness.

## Project layout

See **[BEGINNER_GUIDE.md](BEGINNER_GUIDE.md)** for framework choice, concepts, folder structure, and setup in detail.
