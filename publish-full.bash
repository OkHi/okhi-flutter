#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Format your dart files
dart format .

# Check for static analysis issues
flutter analyze

# Run the test suite
flutter test

# Run a pre-publishing simulation
flutter pub publish --dry-run

# Publish for real
flutter pub publish
