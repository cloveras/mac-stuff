# RESTORE - rebuild a Mac from this USB

This drive is the offline twin of [mac-stuff](https://github.com/cloveras/mac-stuff):
the full setup repo **plus** the private keys and credentials the public repo
can't hold. Use it to bring a new or wiped Mac back fast.

```
mac-backup/
├── RESTORE.md                      ← you are here
├── latest -> snapshots/<newest>    ← always points at the most recent backup
└── snapshots/
    └── <YYYY-MM-DD-HHMMSS>/        ← 3 most recent kept
        ├── repo/                   ← plaintext copy of mac-stuff
        └── secrets.sparseimage     ← AES-256 encrypted: SSH/git/cloud/AI creds
```

Restore from **`latest/`** (newest backup). Older generations under `snapshots/`
exist as fallbacks if the newest is bad. The passphrase for
`secrets.sparseimage` is in **1Password** (item: "mac-secrets USB").
Lose it and the secrets are unrecoverable - that is by design.

---

## 1. Grant the terminal disk access

Plug in the USB. On a fresh Mac the terminal can't read removable volumes yet:

**System Settings → Privacy & Security → Full Disk Access** → add **iTerm**
(or Terminal) → **quit and reopen the app**. TCC grants apply only after restart.

Verify:
```bash
ls /Volumes/CL256GB/mac-backup/latest && echo OK
```

## 2. Install Xcode Command Line Tools (git, etc.)

```bash
xcode-select --install
```
Wait for it to finish.

## 3. Copy the repo to ~/Dev

```bash
mkdir -p ~/Dev
cp -R /Volumes/CL256GB/mac-backup/latest/repo ~/Dev/mac-stuff
cd ~/Dev/mac-stuff
```

## 4. Run the installer

```bash
bash install.sh
```
Installs Homebrew + everything in `Brewfile`, npm globals, clones repos,
symlinks dotfiles, applies macOS preferences, sets zsh as the shell.
(See repo `README.md` for the per-step detail and Synology/Claude setup.)

## 5. Restore the encrypted secrets

Mount the image (Finder double-click works too - enter the passphrase):
```bash
hdiutil attach /Volumes/CL256GB/mac-backup/latest/secrets.sparseimage
```
It mounts at `/Volumes/mac-secrets`. Copy each category back:

```bash
SRC=/Volumes/mac-secrets

# --- SSH ---
mkdir -p ~/.ssh && chmod 700 ~/.ssh
rsync -a "$SRC/ssh/" ~/.ssh/
chmod 600 ~/.ssh/id_* 2>/dev/null            # private keys
chmod 644 ~/.ssh/*.pub ~/.ssh/known_hosts 2>/dev/null

# --- Git + shell identity ---
[ -f "$SRC/git/.gitconfig" ] && cp "$SRC/git/.gitconfig" ~/.gitconfig
[ -f "$SRC/git/.netrc" ]     && cp "$SRC/git/.netrc" ~/.netrc && chmod 600 ~/.netrc
[ -f "$SRC/git/.npmrc" ]     && cp "$SRC/git/.npmrc" ~/.npmrc

# --- Cloud CLI creds ---
[ -d "$SRC/cloud/aws" ]   && mkdir -p ~/.aws        && rsync -a "$SRC/cloud/aws/" ~/.aws/
[ -d "$SRC/cloud/azure" ] && mkdir -p ~/.azure      && rsync -a "$SRC/cloud/azure/" ~/.azure/
[ -d "$SRC/cloud/gh" ]    && mkdir -p ~/.config/gh  && rsync -a "$SRC/cloud/gh/" ~/.config/gh/
[ -f "$SRC/cloud/docker/config.json" ] && mkdir -p ~/.docker && cp "$SRC/cloud/docker/config.json" ~/.docker/

# --- AI tooling auth (likely stale - re-auth if a CLI rejects it) ---
[ -f "$SRC/ai/.claude.json" ] && cp "$SRC/ai/.claude.json" ~/.claude.json
[ -d "$SRC/ai/mcp-auth" ]     && mkdir -p ~/.mcp-auth && rsync -a "$SRC/ai/mcp-auth/" ~/.mcp-auth/
[ -d "$SRC/ai/codex" ]        && mkdir -p ~/.codex    && rsync -a "$SRC/ai/codex/" ~/.codex/
[ -d "$SRC/ai/gemini" ]       && mkdir -p ~/.gemini   && rsync -a "$SRC/ai/gemini/" ~/.gemini/

hdiutil detach "$SRC"
```

Test SSH:
```bash
ssh -T git@github.com    # expect: "Hi cloveras! You've successfully authenticated"
```

## 6. Finish

- Restart the Mac so trackpad/UI prefs take effect.
- Re-auth any AI/cloud CLI that complains about a stale token
  (`gh auth login`, `az login`, `claude` re-login, etc.).
- Set up Synology Drive so `~/.claude/CLAUDE.md` re-links (see repo `README.md`).

---

## Keeping this USB current

On the working Mac, re-run the backup anytime:
```bash
cd ~/Dev/mac-stuff && bash backup-to-usb.sh
```
Each run writes a new timestamped snapshot under `snapshots/` and keeps the
**3 most recent**, pruning older ones automatically. It refreshes the Brewfile,
npm globals, and public key, re-mirrors the repo, and clones+updates the
encrypted secrets image. Do this after big config changes (new SSH key, new
cloud login, fresh app installs). Monthly is a sane cadence.
