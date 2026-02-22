#!/bin/bash
# Install Flutter on macOS (Intel) - run this in Terminal: bash install_flutter_mac.sh

set -e
INSTALL_DIR="$HOME/flutter"
ARCH=$(uname -m)

echo "=== Flutter installer for macOS ==="
echo "Architecture: $ARCH"
echo "Install directory: $INSTALL_DIR"
echo ""

if [ -d "$INSTALL_DIR" ]; then
  echo "Folder $INSTALL_DIR already exists."
  read -p "Remove and reinstall? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Exiting. Add to PATH manually: export PATH=\"\$PATH:$INSTALL_DIR/bin\""
    exit 0
  fi
  rm -rf "$INSTALL_DIR"
fi

# On macOS 13.x, current Flutter stable requires macOS 14+. Use older Flutter for macOS 13.
MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)
FLUTTER_BRANCH="stable"
if [ "$(uname)" = "Darwin" ] && [ -n "$MACOS_VERSION" ] && [ "$MACOS_VERSION" -lt 14 ]; then
  echo "macOS $MACOS_VERSION detected. Using Flutter 3.16.2 (supports macOS 13)."
  FLUTTER_BRANCH="3.16.2"
fi

echo "Cloning Flutter ($FLUTTER_BRANCH). This may take a few minutes..."
cd "$HOME"
if ! command -v git &>/dev/null; then
  echo "Error: git is not installed. Install Xcode Command Line Tools: xcode-select --install"
  exit 1
fi
git clone https://github.com/flutter/flutter.git -b "$FLUTTER_BRANCH"
# git clone creates $HOME/flutter = INSTALL_DIR
if [ ! -d "$INSTALL_DIR/bin" ]; then
  echo "Unexpected structure; checking..."
  ls -la "$INSTALL_DIR"
  exit 1
fi

echo ""
echo "Adding Flutter to PATH..."

# Detect shell config file
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
  PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
  PROFILE="$HOME/.bash_profile"
else
  PROFILE="$HOME/.bashrc"
fi

LINE="export PATH=\"\$PATH:$INSTALL_DIR/bin\""
if grep -q "flutter/bin" "$PROFILE" 2>/dev/null; then
  echo "Flutter PATH already in $PROFILE"
else
  echo "" >> "$PROFILE"
  echo "# Flutter" >> "$PROFILE"
  echo "$LINE" >> "$PROFILE"
  echo "Added to $PROFILE"
fi

export PATH="$PATH:$INSTALL_DIR/bin"
echo ""
echo "Running flutter doctor..."
"$INSTALL_DIR/bin/flutter" doctor -v

echo ""
echo "=== Done ==="
echo "Flutter is installed at: $INSTALL_DIR"
echo "Run this so the current terminal picks it up:"
echo "  export PATH=\"\$PATH:$INSTALL_DIR/bin\""
echo "Or close and reopen Terminal, then run: flutter doctor -v"
