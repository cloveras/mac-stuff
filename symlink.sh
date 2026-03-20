#!/usr/bin/env bash
# Symlinks dotfiles from this repo into ~/
# Safe to re-run — skips if symlink already exists.

REPO="$(dirname "$0")"

link() {
  local src="$REPO/dotfiles/$1"
  local dst="$HOME/$1"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up existing $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  Linked $dst"
}

echo "Symlinking dotfiles..."
link .zshrc
link .emacs

echo "Copying SSH public key..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp "$REPO/ssh/id_rsa.pub" ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/id_rsa.pub
echo "  Note: add your private key (id_rsa) manually — never stored in this repo."

echo "Done."
