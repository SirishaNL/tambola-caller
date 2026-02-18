# Publish Tambola Caller to the App Store

This guide walks you through submitting **Tambola Caller** to the Apple App Store. Do this on a **Mac with Xcode** installed.

---

## 1. Prerequisites

- **Apple Developer account** – Enroll at [developer.apple.com](https://developer.apple.com) ($99/year).
- **Mac** with **Xcode** (latest from Mac App Store).
- **Flutter** installed and working (`flutter doctor` shows no blocking issues).

---

## 2. Project settings (already done)

The project is already configured for App Store submission:

| Item | Value |
|-----|--------|
| **Bundle ID** | `com.tambolacaller.app` |
| **App name (display)** | Tambola Caller |
| **Version** | From `pubspec.yaml`: 1.0.0 (build 1) |
| **Minimum iOS** | 13.0 |

To change the bundle ID (e.g. to your own domain), update it in Xcode: select the **Runner** target → **Signing & Capabilities** → and in the project’s **General** tab set **Bundle Identifier**. Use the same value when creating the app in App Store Connect (step 4).

---

## 3. App icons (optional but recommended)

Replace the default Flutter icons in:

- **iOS:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

You need all sizes listed in `Contents.json` (e.g. 1024×1024, 60×60@2x, etc.). Use a 1024×1024 PNG and generate other sizes with a tool, or use [App Icon Generator](https://appicon.co/).

If you keep the default icon, the app will still build and submit; you can replace it in a later update.

---

## 4. Create the app in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com) and sign in with your Apple Developer account.
2. Click **My Apps** → **+** → **New App**.
3. Fill in:
   - **Platforms:** iOS
   - **Name:** Tambola Caller
   - **Primary Language:** e.g. English (U.S.)
   - **Bundle ID:** Select **com.tambolacaller.app** (you must have registered it in the Developer account, see below if it’s missing).
   - **SKU:** e.g. `tambola-caller-1` (any unique string).
   - **User Access:** Full Access (or as needed).
4. Click **Create**.

**If the bundle ID is not in the list:**

- Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → **+**.
- Choose **App IDs** → **App** → Next.
- Description: e.g. **Tambola Caller**.
- Bundle ID: **Explicit** → `com.tambolacaller.app`.
- Register. Then it will appear in App Store Connect when creating the app.

---

## 5. Configure signing in Xcode

1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   (Use the `.xcworkspace`, not the `.xcodeproj`.)

2. In the left sidebar, select the **Runner** project (blue icon), then the **Runner** target.

3. Open the **Signing & Capabilities** tab.

4. Check **Automatically manage signing**.

5. **Team:** Select your Apple Developer team. If none appears, add your Apple ID in **Xcode → Settings → Accounts**.

6. Xcode will create a provisioning profile. Ensure there are no red errors (e.g. “Failed to register bundle ID” usually means the Bundle ID is already taken or not created under your account).

---

## 6. Build and archive

1. In Xcode’s scheme selector (top left), choose **Runner** and **Any iOS Device (arm64)** (do not select a simulator).

2. Menu: **Product → Archive**.

3. Wait for the archive to finish. The **Organizer** window will open with your archive.

4. Click **Distribute App** → **App Store Connect** → **Upload** → Next.

5. Keep the default options (e.g. “Upload your app’s symbols”, “Manage Version and Build Number” if offered) → Next.

6. Select the correct **Distribution certificate** and **Provisioning profile** (usually automatic) → Next.

7. Review and click **Upload**. Wait until the upload completes.

---

## 7. Fill in the App Store listing

Back in [App Store Connect](https://appstoreconnect.apple.com) → **My Apps** → **Tambola Caller**:

1. Wait until the build appears under **TestFlight** and then under the app’s **iOS App** version (can take 5–30 minutes). If you don’t see it, open the version (e.g. 1.0.0) and in the **Build** section click **+** and select the build.

2. Under the version (e.g. **1.0.0**), fill in:

   - **What’s New in This Version** (e.g. “Initial release of Tambola Caller.”)
   - **Promotional Text** (optional).
   - **Description** – e.g.:
     ```
     Tambola Caller (Housie) helps you run a game of Tambola with clear number calling and a simple, easy-to-use layout.

     • Call numbers 1–90 in random order with no repeats
     • Manual or automatic calling (3, 5, or 7 second intervals)
     • Voice announcement for each number
     • Number history and grid to track called numbers
     • Themes and dark mode
     • Progress saved so you can resume later
     ```
   - **Keywords** – e.g. `tambola,housie,bingo,caller,number game,party game`
   - **Support URL** – A webpage or your email (e.g. `https://example.com` or `mailto:you@example.com`).
   - **Marketing URL** (optional).
   - **Privacy Policy URL** – Required if you collect user data. This app only stores settings and game state on device; a short “We don’t collect personal data” page is enough, or use a generator.

3. **Screenshots** (required):
   - iPhone 6.7" (e.g. iPhone 15 Pro Max): at least one screenshot.
   - iPhone 6.5" (e.g. iPhone 14 Plus): at least one.
   - Other sizes as required by the form (iPad if you support it).

   Take screenshots on the simulator: **File → New Simulator**; run the app; **Cmd+S** to save screenshot, or use **xcrun simctl io booted screenshot screenshot.png**. Resize/crop to exact sizes if needed (App Store Connect shows required dimensions).

4. **App Review Information** (in the version or in App Review section):
   - Contact email and phone for Apple to reach you.
   - **Notes** (optional): e.g. “Tambola/Housie number caller. No login required. Voice uses device TTS.”

5. **Version** and **Copyright** (e.g. `2025 Your Name`).

6. **Pricing:** Free (or set a price).

7. Click **Add for Review** (or **Submit for Review**). Accept any export compliance / content rights questions (this app doesn’t use encryption beyond standard HTTPS; no special content rights).

---

## 8. Submit for review

1. In App Store Connect, open the version and confirm the build and all required fields (screenshots, description, etc.) are set.
2. Click **Submit for Review**.
3. Answer the questionnaire (e.g. encryption: “No” for standard use; advertising: “No” if you don’t use ads; etc.).
4. Submit. Review usually takes 24–48 hours. You’ll get an email when the status changes.

---

## 9. After approval

- If **Approved**, the app will go **Live** (immediately or on the date you chose).
- If **Rejected**, read the resolution center message, fix the issues, upload a new build if needed, and resubmit.

---

## 10. Updating the app later

1. Bump version in `pubspec.yaml`, e.g. `version: 1.0.1+2` (name 1.0.1, build 2).
2. In Xcode, create a new **Archive** and upload as in step 6.
3. In App Store Connect, create a new version (e.g. 1.0.1), select the new build, update “What’s New” and submit for review.

---

## Quick checklist

- [ ] Apple Developer account and app created in App Store Connect
- [ ] Bundle ID `com.tambolacaller.app` registered under your account
- [ ] Xcode: open `ios/Runner.xcworkspace`, set Team, signing OK
- [ ] Product → Archive → Distribute to App Store Connect
- [ ] Build appears in App Store Connect
- [ ] Description, keywords, support URL, privacy policy URL filled
- [ ] Screenshots added for required device sizes
- [ ] Submit for Review

For Play Store (Android) later, use the separate **PUBLISH_PLAYSTORE.md** guide (to be added when you’re ready).
