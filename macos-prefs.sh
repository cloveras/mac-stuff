#!/usr/bin/env bash
# macOS system preferences
# Run once on a new Mac. Some changes require logout/restart to take effect.
#
# NOTE: "Add Fingerprint" for Touch ID must be done manually in:
#   System Settings > Touch ID & Password

echo "Applying macOS preferences..."

# =============================================================================
# Locale / Region
# =============================================================================
defaults write NSGlobalDomain AppleLocale -string "no_NO"                          # Region: Norway
defaults write NSGlobalDomain AppleLanguages -array "en-US" "nb-NO"               # Languages: English (primary), Norwegian Bokmål
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"               # Temperature in Celsius
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"          # Metric measurements
defaults write NSGlobalDomain AppleMetricUnits -int 1                              # Use metric system
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2             # Week starts on Monday
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 "yyyy-MM-dd"       # Date format: YYYY-MM-DD
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true                   # 24-hour clock

# =============================================================================
# Sound
# =============================================================================
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0     # Disable UI sound effects
sudo nvram StartupMute=%01                                                         # Disable startup chime

# =============================================================================
# UI / Appearance
# =============================================================================
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"                  # Dark mode

# =============================================================================
# Dock
# =============================================================================
defaults write com.apple.dock tilesize -int 44                                    # Icon size: 44px
defaults write com.apple.dock autohide -bool true                                 # Auto-hide the Dock
defaults write com.apple.dock autohide-delay -float 0                             # No delay before hiding
defaults write com.apple.dock show-recents -bool false                            # Hide recent apps
defaults write com.apple.dock wvous-br-corner -int 13                             # Bottom-right hot corner: Lock Screen

# =============================================================================
# Finder
# =============================================================================
defaults write com.apple.finder ShowStatusBar -bool true                          # Status bar at bottom
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"               # Default view: List
defaults write com.apple.finder FXRemoveOldTrashItems -bool true                  # Remove items from Trash after 30 days
defaults write com.apple.finder AppleShowAllFiles -bool true                      # Show hidden files
defaults write NSGlobalDomain com.apple.springing.enabled -bool true              # Spring-loading for folders
defaults write NSGlobalDomain com.apple.springing.delay -float 0.5               # Spring-loading delay: 0.5s

# =============================================================================
# Trackpad
# =============================================================================
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false   # Tap to click: off (BT trackpad)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false                    # Tap to click: off (built-in)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false                 # Natural scrolling: off
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false  # Three-finger drag: off (BT)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false     # Three-finger drag: off (built-in)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1 # Two-finger double-tap: Smart Zoom

# =============================================================================
# Keyboard
# =============================================================================
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true         # Auto-capitalization: on
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true     # Double-space to period: on

# =============================================================================
# Screenshots
# =============================================================================
defaults write com.apple.screencapture location -string "$HOME/Downloads/Screenshots"  # Save screenshots here
mkdir -p "$HOME/Downloads/Screenshots"

# =============================================================================
# Screen Lock
# =============================================================================
# Screen saver password is managed via System Settings > Lock Screen

# =============================================================================
# Menu Bar / Control Center
# =============================================================================
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true   # Show battery percentage
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1                  # Hide Spotlight menu bar icon

# =============================================================================
# Safari
# =============================================================================
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true               # Restore previous session on launch
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true              # Show full URL in address bar
defaults write com.apple.Safari IncludeDevelopMenu -bool true                         # Show Develop menu
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true  # Enable WebKit developer extras
defaults write com.apple.Safari ShowStatusBarByDefault -bool true                     # Show status bar
defaults write com.apple.Safari NewTabBehavior -int 1                                 # New tabs open with: Empty Page
defaults write com.apple.Safari NewWindowBehavior -int 1                              # New windows open with: Empty Page

# =============================================================================
# Restart affected apps
# =============================================================================
killall Dock Finder Safari SystemUIServer 2>/dev/null

echo "Done. You may need to log out and back in for all changes to take effect."
