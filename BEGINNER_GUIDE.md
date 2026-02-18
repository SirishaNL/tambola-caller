# Tambola / Housie Caller App — Beginner's Guide

You are a QA engineer with no coding experience. This guide explains everything step-by-step **before** you run any code.

---

## Part 1: Which Framework? (Flutter vs React Native)

We use **Flutter** for this app. Here’s why, in simple terms:

| | Flutter | React Native |
|---|--------|--------------|
| **Language** | Dart (simpler, one way to do things) | JavaScript (many styles, can confuse beginners) |
| **Learning curve** | Easier for first-time coders | Needs JS + React ideas |
| **Single codebase** | ✅ One project → Android + iOS | ✅ Same |
| **UI** | Draws its own UI → same look on both platforms | Uses native widgets → can look different |
| **Hot reload** | ✅ Change code, see result in ~1 sec | ✅ Similar |
| **Tambola fit** | TTS, timers, big numbers are straightforward | Same, but setup is heavier |

**Summary:** Flutter is recommended because it’s beginner-friendly, one codebase for Android and iOS, and fits this app’s needs (numbers, timers, voice, TV-friendly UI) with simple packages.

---

## Part 2: Concepts You’ll Use (Short Explanations)

- **App / project**  
  A folder with code and config files. This project is `tambola_caller`.

- **Dart**  
  The language Flutter uses. You’ll mostly edit numbers, text, and simple logic.

- **Widget**  
  Everything on screen (button, text, layout) is a “widget”. Widgets are combined like building blocks.

- **State**  
  Data that can change (e.g. current number, list of called numbers). When state changes, the UI updates.

- **pubspec.yaml**  
  File that lists “packages” (libraries) the app uses (e.g. TTS, saving data).

- **lib/**  
  Folder where the main app code lives. `main.dart` is the entry point.

- **Build / Run**  
  “Build” = turn your code into an app. “Run” = build and launch on a device or emulator.

---

## Part 3: Folder Structure (What Each Part Does)

```
tambola_caller/
├── lib/
│   ├── main.dart                 ← App entry; theme (dark/light), initial screen
│   ├── app.dart                  ← Main app widget and routing
│   ├── models/
│   │   └── game_state.dart       ← What we save: called numbers, mode, timer, etc.
│   ├── services/
│   │   ├── game_service.dart     ← Logic: next number, shuffle, persist
│   │   └── tts_service.dart     ← Text-to-speech for calling numbers
│   ├── screens/
│   │   ├── home_screen.dart      ← Start / New Game / Resume
│   │   └── game_screen.dart      ← Big number, grid, last 5, controls
│   └── widgets/
│       └── number_grid.dart      ← 1–90 grid with called numbers highlighted
├── pubspec.yaml                  ← Dependencies (packages)
├── README.md                     ← How to open, run, test
├── BEGINNER_GUIDE.md             ← This file
└── QA_TESTING_CHECKLIST.md       ← What to test and how
```

- **models** = data shapes (e.g. “game state”).
- **services** = logic (game rules, TTS, saving).
- **screens** = full screens (home, game).
- **widgets** = reusable pieces (e.g. the 1–90 grid).

---

## Part 4: Setup Steps (Do This Once)

### Step 4.1: Install Flutter

1. **Download Flutter**
   - Go to: https://docs.flutter.dev/get-started/install/windows  
   - Download the Flutter SDK zip for Windows.
   - Extract it to a folder, e.g. `C:\flutter` (avoid spaces and special characters).

2. **Add Flutter to PATH**
   - Search “Environment Variables” in Windows.
   - Open “Edit the system environment variables” → “Environment Variables”.
   - Under “User variables”, select “Path” → “Edit” → “New”.
   - Add the path to the `bin` folder inside Flutter, e.g. `C:\flutter\bin`.
   - OK out of all dialogs.

3. **Check installation**
   - Open a **new** Command Prompt or PowerShell.
   - Run: `flutter doctor`
   - Fix any issues it reports (e.g. “Android toolchain” or “Android Studio”).

### Step 4.2: Install Android Studio (for Android)

1. Download from: https://developer.android.com/studio  
2. During setup, ensure “Android SDK” and “Android SDK Platform” are selected.  
3. Open Android Studio → More Actions → “Virtual Device Manager” → create an Android emulator (e.g. Pixel 5, API 33).  
4. Run `flutter doctor` again; “Android toolchain” should be OK.

### Step 4.3: For iOS (Mac only)

- Install Xcode from the Mac App Store.  
- Run: `flutter doctor`  
- Accept Xcode license if asked.

*(On Windows you can only build and run for Android; iOS needs a Mac.)*

### Step 4.4: Editor (Cursor / VS Code)

- Install the “Flutter” and “Dart” extensions.  
- Open the folder `tambola_caller` in the editor.

---

## Part 5: Required Installations (Summary)

| What | Why |
|------|-----|
| Flutter SDK | To build and run the app |
| Android Studio + SDK + Emulator | To run on Android (or use a real device) |
| Xcode (Mac only) | To run on iOS |
| Cursor/VS Code + Flutter & Dart extensions | To edit and run easily |

---

## Part 6: Commands to Run the App

Open a terminal in the project folder: `tambola_caller`.

1. **Get packages (first time and after pubspec changes)**  
   ```bash
   flutter pub get
   ```

2. **Run on default device (emulator or connected phone)**  
   ```bash
   flutter run
   ```

3. **Run on a specific device**  
   ```bash
   flutter devices
   flutter run -d <device_id>
   ```

4. **Build APK (Android install file)**  
   ```bash
   flutter build apk
   ```  
   APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

We keep implementation **simple and safe**: one main game service, one place for saved state, and clear separation between UI and logic so you can test step-by-step using the QA checklist.

---

## Part 7: What the App Does (Feature Map)

- **Number system:** 1–90, random order, no duplicates; called numbers marked and stored.  
- **Manual mode:** “Next Number” button only; no timer.  
- **Auto mode:** Choose 3 / 5 / 7 seconds; countdown; Pause/Resume.  
- **State:** Resume game, Start New Game; state saved so it survives app close.  
- **Casting:** Big number, clear layout, suitable for Chromecast / AirPlay / TV.  
- **UI:** Current number (large), last 5 called, full 1–90 grid, minimal.  
- **Safety:** Confirm on back/exit during game.  
- **Voice:** TTS for each number; speed control; sound ON/OFF.  
- **Dark mode:** Toggle in app.

Next: open **README.md** for quick start, and **QA_TESTING_CHECKLIST.md** for what to test and how.
