#!/bin/bash

set -euo pipefail

echo ">> Starting system bootstrap..."

# Enter the computer name and set it
echo ">> Enter the name for this computer:"
read -r computer_name
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set HostName "$computer_name"
sudo scutil --set LocalHostName "$computer_name"

# Make sure the user is signed into iCloud
# --- Function to check Apple ID login status ---
is_signed_in() {
  local account_id
  account_id=$(defaults read MobileMeAccounts 2>/dev/null | grep -E '"AccountID"\s*=\s*"[^"]+"' | awk -F'"' '{print $4}')
  [[ -n "$account_id" ]]
}

# --- Check status ---
echo "Checking Apple ID sign-in status..."

if ! is_signed_in; then
  echo "❌ Not signed in to Apple ID. Please sign in via System Settings > Apple ID."
fi

# --- Wait silently until signed in ---
while ! is_signed_in; do
  sleep 5
  echo -n "."
done

echo "✅ Apple ID is signed in. Continuing script..."

# Verify that sudo credentials are available
if ! sudo -v; then
  echo ">> You must enter valid sudo credentials to run this script."
  exit 1
fi

# Install Homebrew (Apple Silicon path: /opt/homebrew)
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

# Install chezmoi via Homebrew
if ! command -v chezmoi >/dev/null 2>&1; then
  echo ">> Installing chezmoi..."
  brew install chezmoi
else
  echo ">> chezmoi already installed."
fi

# Initialize and apply dotfiles
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
  echo ">> Initializing chezmoi from dotfiles repo..."
  chezmoi init --apply https://github.com/jcouball/dotfiles_neuromancer
else
  echo ">> chezmoi already initialized. Skipping apply."
fi

echo ">> Bootstrap complete."
