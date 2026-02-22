#!/bin/bash
# Run Tambola app on iOS Simulator. Double-click or: bash run_on_ios.sh

echo "Opening iOS Simulator..."
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

echo "Waiting 20 seconds for Simulator to boot..."
sleep 20

export PATH="$PATH:$HOME/flutter/bin"
cd "$(dirname "$0")"

echo "Running app on iOS..."
flutter run -d ios

read -p "Press Enter to close..."
