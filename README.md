# mac-stuff

macOS setup for a new machine.

## What's included

| File | What it does |
|---|---|
| `Brewfile` | All Homebrew formulae and casks |
| `npm-globals.txt` | Global npm packages |
| `macos-prefs.sh` | Key system preferences via `defaults write` |
| `install.sh` | Runs everything in order |

## Setup on a new Mac

**1. Clone this repo**
```bash
git clone https://github.com/cloveras/mac-stuff.git ~/mac-stuff
cd ~/mac-stuff
```

**2. Run the install script**
```bash
bash install.sh
```

This will:
- Install Homebrew (if not already installed)
- Install all brew packages and casks from `Brewfile`
- Install global npm packages
- Apply macOS system preferences

**3. Restart**

Some preferences (trackpad, UI) require a restart to fully apply.

---

## Keeping it up to date

When you install new brew packages, update the Brewfile:
```bash
brew bundle dump --force
```

Then commit and push.
