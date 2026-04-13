# mac-stuff

macOS setup for a new machine.

## What's included

| File/Folder | What it does |
|---|---|
| `Brewfile` | All Homebrew formulae, casks, and App Store apps |
| `npm-globals.txt` | Global npm packages |
| `dotfiles/` | `.zshrc`, `.emacs`, and Claude settings (`.claude/`), symlinked into `~/` |
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

**4. Set up Synology Drive**

Install Synology Drive Client and sync `~/SynologyDrive/`. The Claude context files live at `~/SynologyDrive/Claude/` — `symlink.sh` will link `~/.claude/CLAUDE.md` to that file automatically. If Synology Drive isn't set up yet, the symlink step will warn you and you can re-run `symlink.sh` afterwards.

**5. Run the install script**
```bash
bash install.sh
```

This will:
- Install Homebrew (if not already installed)
- Install all brew packages, casks, and App Store apps from `Brewfile`
- Install global npm packages
- Create `~/Dev` and clone all repos
- Symlink dotfiles (`.zshrc`, Claude settings) into `~/` and set zsh as default shell
- Link `~/.claude/CLAUDE.md` → `~/SynologyDrive/Claude/CLAUDE.md`
- Copy the public SSH key to `~/.ssh/`
- Apply macOS system preferences

**6. Install Claude Code slash commands**

```bash
curl -sO --output-dir ~/.claude/commands \
  https://raw.githubusercontent.com/cloveras/claude-stuff/main/commands/prd-create.md \
  https://raw.githubusercontent.com/cloveras/claude-stuff/main/commands/prd-search.md
```

See [claude-stuff](https://github.com/cloveras/claude-stuff) for details.

**7. Set up Cowork**

Open the Cowork desktop app and connect `~/SynologyDrive/Claude/` as your workspace folder. This gives Cowork access to your `CLAUDE.md` and `memory/` files automatically.

**8. Import iTerm2 settings**

Open iTerm2, then go to **General → Preferences → Load preferences from a custom folder or URL**, point it at this repo, or use **File → Import AI Config / Restore State** and select `iTerm2 State.itermexport`.

**9. Restart**

Some preferences (trackpad, UI) require a restart to fully apply.

---

## Claude / AI setup

Claude context is split across two places:

| What | Where | Purpose |
|---|---|---|
| Personal context + behavior rules | `~/SynologyDrive/Claude/CLAUDE.md` | Read by both Claude Code and Cowork via symlink |
| Memory files (projects, people, etc.) | `~/SynologyDrive/Claude/memory/` | Topic-specific context Cowork reads when relevant |
| Slash commands | `~/.claude/commands/` (from `claude-stuff`) | Reusable Claude Code workflows like `/prd-create` |
| Claude Code settings | `dotfiles/.claude/settings.json` | Symlinked to `~/.claude/settings.json` |

`~/.claude/CLAUDE.md` is a symlink to `~/SynologyDrive/Claude/CLAUDE.md`. Edit the Synology file — both tools pick up the change automatically, and Synology Drive keeps it synced across machines.

---

## Keeping it up to date

When you install new brew packages, update the Brewfile:
```bash
brew bundle dump --force
```

Then commit and push.
