#!/usr/bin/env bash
# macOS system preferences
# Run once on a new Mac. Some changes require logout/restart to take effect.

echo "Applying macOS preferences..."

# =============================================================================
# Dock
# =============================================================================
defaults write com.apple.dock tilesize -int 44           # Icon size
defaults write com.apple.dock autohide -bool true        # Auto-hide
defaults write com.apple.dock autohide-delay -float 0    # No delay before hiding
defaults write com.apple.dock show-recents -bool true    # Show recent apps

# =============================================================================
# Finder
# =============================================================================
defaults write com.apple.finder ShowPathbar -bool true   # Path bar at bottom
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"  # List view
defaults write com.apple.finder AppleShowAllFiles -bool true         # Show hidden files

# =============================================================================
# Trackpad
# =============================================================================
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false  # Tap to click: off
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false  # Natural scrolling: off

# =============================================================================
# Screenshots
# =============================================================================
defaults write com.apple.screencapture location -string "$HOME/Downloads/Screenshots"
mkdir -p "$HOME/Downloads/Screenshots"

# =============================================================================
# UI
# =============================================================================
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"              # Dark mode
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true # Auto-correct on

# =============================================================================
# Restart affected apps
# =============================================================================
killall Dock Finder 2>/dev/null

echo "Done. You may need to log out and back in for all changes to take effect."
