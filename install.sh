#!/usr/bin/env bash
# install.sh — symlink dotfiles from this repo into $HOME.
#
# Safe to run repeatedly. Existing files are backed up to <path>.bak
# (only on the FIRST run — subsequent runs replace stale symlinks in place).
#
# Usage:
#   ./install.sh            # interactive
#   ./install.sh --force    # overwrite existing symlinks without prompting
#   ./install.sh --dry-run  # print what would happen, change nothing

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

say()    { printf '  %s\n' "$*"; }
header() { printf '\n\033[1m%s\033[0m\n' "$*"; }

# link <source-in-repo> <target-in-home>
link() {
  local src="$1" dst="$2"

  if [ ! -e "$src" ]; then
    say "skip (missing in repo): $src"
    return
  fi

  # If the destination is already the correct symlink, do nothing.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "ok:   $dst"
    return
  fi

  # If something else is there, back it up (unless it's a stale symlink and --force).
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ $FORCE -eq 1 ]; then
      [ $DRY_RUN -eq 1 ] || rm "$dst"
      say "replace symlink: $dst"
    else
      local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
      [ $DRY_RUN -eq 1 ] || mv "$dst" "$bak"
      say "backup: $dst -> $bak"
    fi
  fi

  [ $DRY_RUN -eq 1 ] || { mkdir -p "$(dirname "$dst")"; ln -s "$src" "$dst"; }
  say "link: $dst -> $src"
}

header "Linking home dotfiles"
for f in "$REPO"/home/.*; do
  name="$(basename "$f")"
  # skip ., .., and the local.example template
  case "$name" in
    .|..|.zshrc.local.example) continue ;;
  esac
  link "$f" "$HOME/$name"
done

header "Linking ~/.config entries"
mkdir -p "$HOME/.config"
for d in "$REPO"/config/*; do
  [ -e "$d" ] || continue
  link "$d" "$HOME/.config/$(basename "$d")"
done

header ".zshrc.local"
if [ ! -e "$HOME/.zshrc.local" ]; then
  if [ $DRY_RUN -eq 1 ]; then
    say "would create: $HOME/.zshrc.local (from .zshrc.local.example)"
  else
    cp "$REPO/home/.zshrc.local.example" "$HOME/.zshrc.local"
    say "created $HOME/.zshrc.local — fill in your secrets there"
  fi
else
  say "exists: $HOME/.zshrc.local (left untouched)"
fi

header "Done"
say "Open a new shell or 'source ~/.zshrc' to pick up changes."
if [ $DRY_RUN -eq 1 ]; then
  say "(dry-run: no changes were made)"
fi
