#!/usr/bin/env bash
# New Mac setup script
# Run this once after a fresh macOS install.

set -e

echo "=== Mac Setup ==="

# =============================================================================
# Homebrew
# =============================================================================
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing brew packages..."
brew bundle install --file="$(dirname "$0")/Brewfile"

# =============================================================================
# npm globals
# =============================================================================
echo "Installing global npm packages..."
while IFS= read -r pkg; do
  [[ -z "$pkg" ]] && continue
  npm install -g "$pkg"
done < "$(dirname "$0")/npm-globals.txt"

# =============================================================================
# macOS preferences
# =============================================================================
echo "Applying macOS preferences..."
bash "$(dirname "$0")/macos-prefs.sh"

echo ""
echo "All done! Restart your Mac to make sure everything takes effect."
