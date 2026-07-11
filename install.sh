#!/bin/sh

# Install .zshrc symlink
# Usage: run from the repo root, or adjust paths accordingly

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$SCRIPT_DIR/core.zsh" "$HOME/.zshrc"

echo "Symlinked $SCRIPT_DIR/core.zsh → $HOME/.zshrc"
