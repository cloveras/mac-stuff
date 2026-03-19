# mac-stuff

macOS setup for a new machine.

## What's included

| File/Folder | What it does |
|---|---|
| `Brewfile` | All Homebrew formulae, casks, and App Store apps |
| `npm-globals.txt` | Global npm packages |
| `dotfiles/` | `.bash_profile` and `.bashrc`, symlinked into `~/` |
| `ssh/id_rsa.pub` | Public SSH key (private key must be added manually) |
| `macos-prefs.sh` | Key system preferences via `defaults write` |
| `symlink.sh` | Symlinks dotfiles into `~/` |
| `install.sh` | Runs everything in order |

## Setup on a new Mac

**1. Clone this repo**
```bash
git clone https://github.com/cloveras/mac-stuff.git ~/mac-stuff
cd ~/mac-stuff
```

**2. Add your private SSH key**

Copy `id_rsa` from your old machine or 1Password to `~/.ssh/id_rsa`, then:
```bash
chmod 600 ~/.ssh/id_rsa
```

**3. Run the install script**
```bash
bash install.sh
```

This will:
- Install Homebrew (if not already installed)
- Install all brew packages, casks, and App Store apps from `Brewfile`
- Install global npm packages
- Symlink dotfiles (`.bash_profile`, `.bashrc`) into `~/`
- Copy the public SSH key to `~/.ssh/`
- Apply macOS system preferences

**4. Restart**

Some preferences (trackpad, UI) require a restart to fully apply.

---

## Keeping it up to date

When you install new brew packages, update the Brewfile:
```bash
brew bundle dump --force
```

Then commit and push.
