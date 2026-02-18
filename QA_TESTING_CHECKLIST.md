# QA Testing Checklist — Tambola Caller App

Use this as a QA engineer to test the app systematically. Check off each item when done.

---

## 1. Installation & First Run

- [ ] `flutter pub get` runs without errors.
- [ ] `flutter run` launches the app on emulator or device.
- [ ] App opens to Home screen (New Game / Resume if a game was saved).
- [ ] No crash on cold start.

---

## 2. Number System (1–90, Random, No Duplicates)

- [ ] **Range:** Only numbers 1–90 ever appear.
- [ ] **No duplicates:** Same number never appears twice in one game.
- [ ] **Randomness:** Run 3–5 full games; order of numbers is different each time.
- [ ] **Visual “called” state:** Called numbers are clearly highlighted (e.g. different color) in the grid.
- [ ] **Last number:** After 90 numbers, “Game Over” or similar; no 91st number.

**How to verify randomness:**  
Note the first 10 numbers in Game 1. Start a new game and note the first 10 again. They should be different (order, not just that they’re from 1–90).

---

## 3. Manual Mode

- [ ] Manual mode can be selected (e.g. from home or game setup).
- [ ] “Next Number” button is visible; timer options are **not** visible.
- [ ] Each tap on “Next Number” calls exactly one new number.
- [ ] Number updates on screen and in “last 5” list.
- [ ] Grid updates so the new number is marked as called.
- [ ] After 90 calls, no more numbers; game ends or shows “Game Over”.

---

## 4. Automatic Mode

- [ ] Auto mode can be selected.
- [ ] Timer options (e.g. 3s, 5s, 7s) are visible when Auto is selected.
- [ ] Selecting 3s: next number every ~3 seconds (use stopwatch).
- [ ] Selecting 5s: next number every ~5 seconds.
- [ ] Selecting 7s: next number every ~7 seconds.
- [ ] Countdown (e.g. 3, 2, 1) is visible before the next number (if implemented).
- [ ] Pause: auto-calling stops; same number stays on screen.
- [ ] Resume: next number appears after one full interval.
- [ ] When Manual is selected, timer options are hidden.

---

## 5. Game State (Resume / New Game / Persist)

- [ ] **Start New Game:** Clears previous game; numbers 1–90 available again; no old “called” state.
- [ ] **Resume:** If a game was in progress, “Resume” loads it; called numbers and current number match.
- [ ] **Persist:** Start a game, call a few numbers, **close app completely**, reopen → “Resume” available; resume shows same state (same called numbers, same current number).
- [ ] After “Game Over”, starting a new game does not show old data.

---

## 6. UI (Display & Casting-Friendly)

- [ ] **Current number:** Shown large and readable (easy to read from a distance / on TV).
- [ ] **Last 5 called:** Shows the 5 most recently called numbers in order (e.g. newest first or last).
- [ ] **Full 1–90 grid:** All numbers 1–90 visible; called numbers clearly highlighted.
- [ ] Layout is clean and minimal; no critical text cut off on different screen sizes.
- [ ] Test on tablet or with casting: number and grid still readable.

---

## 7. Safety (Confirmations)

- [ ] **Back / Exit during game:** Pressing device back (or exit) shows a confirmation dialog (e.g. “Exit game? Progress is saved”).
- [ ] “Cancel” keeps the game; “Exit” or “Yes” leaves and saves state (resumable later).
- [ ] No accidental exit without confirmation when a game is in progress.

---

## 8. Voice (TTS) & Sound

- [ ] **Voice ON:** Each called number is announced (text-to-speech).
- [ ] **Voice OFF:** When sound is off, no TTS when numbers are called.
- [ ] **Speed control:** Changing speed (e.g. slow / normal / fast) changes how fast the voice speaks; no crash.
- [ ] Toggle persists (or at least works for the session) so you don’t have to turn off every time.

---

## 9. Dark Mode

- [ ] Dark mode can be toggled (e.g. in settings or on home/game screen).
- [ ] In dark mode: background dark, text light; all screens that support it switch.
- [ ] In light mode: background light, text dark.
- [ ] No unreadable text (e.g. white on white, black on black).

---

## 10. Edge Cases & Common Bugs

- [ ] **Rapid tap:** In Manual mode, rapid taps on “Next Number” don’t skip numbers or duplicate; one tap = one number.
- [ ] **Timer at game end:** In Auto mode, when the 90th number is called, timer stops; no attempt to call a 91st.
- [ ] **Pause at 90th:** If paused at last number, resume doesn’t call another number.
- [ ] **Rotation:** Rotate device; app doesn’t crash; state (current number, called list) is preserved.
- [ ] **Low storage:** If device is low on space, app may not save state; at least it doesn’t crash on save.
- [ ] **No TTS engine:** On a device without TTS, app doesn’t crash; voice can be off or gracefully disabled.

---

## 11. Platforms

- [ ] **Android:** Install and run full checklist on at least one Android version (e.g. API 30+).
- [ ] **iOS (if you have Mac):** Same on iOS device or simulator.

---

## Quick “Smoke” Test (5 minutes)

1. Open app → New Game → Manual → tap “Next Number” 5 times.  
2. Check: current number, last 5, grid highlight.  
3. Close app, reopen → Resume → confirm same state.  
4. New Game → Auto 5s → let 3 numbers call → Pause → Resume.  
5. Toggle sound and dark mode; confirm they work.

If all pass, you can do a full run of the checklist above.
