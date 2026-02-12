#!/bin/bash
set -e

# Install Flutter (stable channel, pinned to current version)
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.38.9 ~/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Build
flutter precache --web
flutter build web --release
