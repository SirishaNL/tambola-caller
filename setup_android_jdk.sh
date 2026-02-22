#!/bin/bash
# One-time setup: use a proper JDK for Gradle so jlink works (fixes JdkImageTransform error).
# Run from project root: ./setup_android_jdk.sh

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
GRADLE_PROP="$PROJECT_ROOT/android/gradle.properties"

# If JAVA_HOME is set and has jlink, use it (avoid Android Studio JBR if it fails)
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/jlink" ]; then
  JHOME="$JAVA_HOME"
  echo "Using JAVA_HOME: $JHOME"
  sed -i.bak '/^org.gradle.java.home=/d; /^# Use system JDK for Gradle/d' "$GRADLE_PROP" 2>/dev/null || true
  echo "" >> "$GRADLE_PROP"
  echo "# Use system JDK for Gradle (fixes JdkImageTransform/jlink)" >> "$GRADLE_PROP"
  echo "org.gradle.java.home=$JHOME" >> "$GRADLE_PROP"
  echo "Done. Run: flutter run -d \"sdk gphone64 x86 64\""
  exit 0
fi

# Prefer JDK 17, then 21, then 11 (all have working jlink)
for ver in 17 21 11; do
  if JHOME=$(/usr/libexec/java_home -v "$ver" 2>/dev/null); then
    echo "Using JDK $ver at: $JHOME"
    # Remove existing org.gradle.java.home and comment lines
    sed -i.bak '/^org.gradle.java.home=/d; /^# Use system JDK for Gradle/d' "$GRADLE_PROP" 2>/dev/null || true
    echo "" >> "$GRADLE_PROP"
    echo "# Use system JDK for Gradle (fixes JdkImageTransform/jlink)" >> "$GRADLE_PROP"
    echo "org.gradle.java.home=$JHOME" >> "$GRADLE_PROP"
    echo "Done. Run: flutter run -d \"sdk gphone64 x86 64\""
    exit 0
  fi
done

# Try common install paths (Homebrew, Adoptium)
for candidate in \
  "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" \
  "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home" \
  "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" \
  "/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home" \
  "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"; do
  if [ -x "$candidate/bin/jlink" ]; then
    JHOME="$candidate"
    echo "Using JDK at: $JHOME"
    sed -i.bak '/^org.gradle.java.home=/d; /^# Use system JDK for Gradle/d' "$GRADLE_PROP" 2>/dev/null || true
    echo "" >> "$GRADLE_PROP"
    echo "# Use system JDK for Gradle (fixes JdkImageTransform/jlink)" >> "$GRADLE_PROP"
    echo "org.gradle.java.home=$JHOME" >> "$GRADLE_PROP"
    echo "Done. Run: flutter run -d \"sdk gphone64 x86 64\""
    exit 0
  fi
done

echo "No JDK 11/17/21 with working jlink found."
echo "Install a full JDK (Android Studio's built-in JBR is what's failing), then run this again:"
echo "  brew install openjdk@17"
echo "  # or: https://adoptium.net/"
exit 1
