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

**4. Configure git identity**
```bash
git config --global user.name "Christian Løverås"
git config --global user.email "cl@superelectric.net"
```

**5. Set up Synology Drive**

Install Synology Drive Client and sync `~/SynologyDrive/`. The Claude context files live at `~/SynologyDrive/Claude/` - `symlink.sh` will link `~/.claude/CLAUDE.md` to that file automatically. If Synology Drive isn't set up yet, the symlink step will warn you and you can re-run `symlink.sh` afterwards.

**6. Run the install script**
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

**7. Install Claude Code slash commands**

```bash
curl -sO --output-dir ~/.claude/commands \
  https://raw.githubusercontent.com/cloveras/claude-stuff/main/commands/prd-create.md \
  https://raw.githubusercontent.com/cloveras/claude-stuff/main/commands/prd-search.md
```

See [claude-stuff](https://github.com/cloveras/claude-stuff) for details.

**8. Set up Cowork**

Open the Cowork desktop app and connect `~/SynologyDrive/Claude/` as your workspace folder. This gives Cowork access to your `CLAUDE.md` and `memory/` files automatically.

**9. Import iTerm2 settings**

Open iTerm2, then go to **General → Preferences → Load preferences from a custom folder or URL**, point it at this repo, or use **File → Import AI Config / Restore State** and select `iTerm2 State.itermexport`.

**10. Restart**

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

`~/.claude/CLAUDE.md` is a symlink to `~/SynologyDrive/Claude/CLAUDE.md`. Edit the Synology file - both tools pick up the change automatically, and Synology Drive keeps it synced across machines.

---

## Tailscale alongside Azure VPN

Tailscale and Azure VPN Client run fine at the same time: Tailscale routes `100.64.0.0/10`, the Azure point-to-site profile routes its VNet range, and they don't overlap. Only DNS collides.

**The problem:** with "Use Tailscale DNS" on, the Tailscale app makes `100.100.100.100` the default resolver and forwards everything outside the tailnet to the LAN's DNS (1.1.1.1 etc.), bypassing the DNS server the Azure VPN pushes. Azure private endpoints (`*.database.windows.net`, `*.blob.core.windows.net`, ...) then resolve to their public IPs instead of the private 10.x addresses.

**The fix:** turn Tailscale DNS off, and send only the tailnet domain to Tailscale's resolver with a macOS per-domain resolver file. Everything else keeps using the Azure DNS while the VPN is up.

1. Install Tailscale (`cask "tailscale"` in the Brewfile) and log in. The `tailscale` CLI alias is in `dotfiles/.zshrc`.

2. Turn off Tailscale DNS (or untick **Use Tailscale DNS** in the menu bar app):
   ```bash
   tailscale set --accept-dns=false
   ```

3. Point the tailnet domain at Tailscale's resolver. The `search` line makes bare names like `ssh uranus` work:
   ```bash
   TAILNET=$(tailscale status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["MagicDNSSuffix"])')
   sudo mkdir -p /etc/resolver
   printf 'nameserver 100.100.100.100\nsearch %s\n' "$TAILNET" | sudo tee "/etc/resolver/$TAILNET"
   ```

4. Check, with the Azure VPN connected:
   ```bash
   dscacheutil -q host -a name <host>.$TAILNET                  # 100.x address
   dscacheutil -q host -a name <host>                           # same, via the search line
   dscacheutil -q host -a name <server>.database.windows.net    # private 10.x address, not public
   ```
   Use `dscacheutil`, `ping` or `ssh` to test. `dig` and `nslookup` read `/etc/resolv.conf` directly and ignore `/etc/resolver/`.

Don't solve this with Split DNS in the Tailscale admin console: it applies to every device in the tailnet, and the ones without the Azure VPN would lose `*.windows.net` lookups.

To undo: `sudo rm "/etc/resolver/$TAILNET"` and `tailscale set --accept-dns=true`.

---

## Keeping it up to date

When you install new brew packages, update the Brewfile:
```bash
brew bundle dump --force
```

Then commit and push.
