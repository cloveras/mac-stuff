#!/usr/bin/env bash
# Creates ~/Dev and clones all repos.
# Safe to re-run — skips repos that already exist.

DEV="$HOME/Dev"
mkdir -p "$DEV"

clone() {
  local url="$1"
  local name="${url##*/}"
  name="${name%.git}"
  if [ -d "$DEV/$name" ]; then
    echo "  Skipping $name (already exists)"
  else
    echo "  Cloning $name..."
    git clone "$url" "$DEV/$name"
  fi
}

echo "Cloning repos into $DEV..."

clone git@github.com:cloveras/mac-stuff.git
clone git@github.com:cloveras/claude-stuff.git
clone git@github.com:cloveras/webcam.git
clone git@github.com:cloveras/lovdata2.git
clone git@github.com:cloveras/kommune.git
clone git@github.com:cloveras/2026.git
clone git@github.com:cloveras/lilleviklofoten.git
clone git@github.com:cloveras/redocusaurus.git
clone git@github.com:cloveras/devstuff.git
clone git@github.com:cloveras/slate.git
clone git@github.com:cloveras/mac.git
clone git@github.com:cloveras/shins.git
clone git@github.com:cloveras/hacks.git

echo "Done."
