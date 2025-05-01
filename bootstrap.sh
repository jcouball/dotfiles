#!/bin/bash

set -euo pipefail

echo ">> Starting system bootstrap..."

# 1. Install Homebrew (Apple Silicon path: /opt/homebrew)
if ! command -v brew >/dev/null 2>&1; then
  echo ">> Homebrew not found. Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo ">> Configuring shell to use Homebrew (Apple Silicon)..."
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo ">> Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install chezmoi via Homebrew
if ! command -v chezmoi >/dev/null 2>&1; then
  echo ">> Installing chezmoi..."
  brew install chezmoi
else
  echo ">> chezmoi already installed."
fi

# 3. Initialize and apply dotfiles
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
  echo ">> Initializing chezmoi from dotfiles repo..."
  chezmoi init --apply https://github.com/jcouball/dotfiles_neuromancer
else
  echo ">> chezmoi already initialized. Skipping apply."
fi

echo ">> Bootstrap complete."
