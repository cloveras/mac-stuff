# mac-stuff

macOS setup for a new machine.

## What's included

| File/Folder | What it does |
|---|---|
| `Brewfile` | All Homebrew formulae, casks, and App Store apps |
| `npm-globals.txt` | Global npm packages |
| `dotfiles/` | `.zshrc` and `.emacs`, symlinked into `~/` |
| `ssh/id_rsa.pub` | Public SSH key (private key must be added manually) |
| `macos-prefs.sh` | Key system preferences via `defaults write` |
| `clone-repos.sh` | Creates `~/Dev` and clones all repos |
| `symlink.sh` | Symlinks dotfiles into `~/` |
| `install.sh` | Runs everything in order |
| `iTerm2 State.itermexport` | iTerm2 profile and settings export |

## Setup on a new Mac

**1. Install Xcode Command Line Tools** (includes git)
```bash
xcode-select --install
```
Wait for the installation to complete before continuing.

**2. Clone this repo**
```bash
git clone https://github.com/cloveras/mac-stuff.git ~/mac-stuff
cd ~/mac-stuff
```

**3. Add your private SSH key**

Copy `id_rsa` from your old machine or 1Password to `~/.ssh/id_rsa`, then:
```bash
chmod 600 ~/.ssh/id_rsa
```

**4. Run the install script**
```bash
bash install.sh
```

This will:
- Install Homebrew (if not already installed)
- Install all brew packages, casks, and App Store apps from `Brewfile`
- Install global npm packages
- Create `~/Dev` and clone all repos
- Symlink dotfiles (`.zshrc`) into `~/` and set zsh as default shell
- Copy the public SSH key to `~/.ssh/`
- Apply macOS system preferences

**5. Import iTerm2 settings**

Open iTerm2, then go to **General → Preferences → Load preferences from a custom folder or URL**, point it at this repo, or use **File → Import AI Config / Restore State** and select `iTerm2 State.itermexport`.

**6. Restart**

Some preferences (trackpad, UI) require a restart to fully apply.

---

## Keeping it up to date

When you install new brew packages, update the Brewfile:
```bash
brew bundle dump --force
```

Then commit and push.
