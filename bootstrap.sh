#!/bin/bash

set -euo pipefail

echo ">> Starting system bootstrap..."

# Get the current computer name
current_name=$(scutil --get ComputerName)

# Prompt the user with the current name as the default
read -r -p ">> Enter the name for this computer [$current_name]: " computer_name
computer_name=${computer_name:-$current_name}

# Set the new computer name
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set HostName "$computer_name"
sudo scutil --set LocalHostName "$computer_name"

# Make sure the user is signed into iCloud
# --- Function to check Apple ID login status ---
is_signed_in() {
  local plist_file="$HOME/Library/Preferences/MobileMeAccounts.plist"
  local account_id

  if [[ ! -f "$plist_file" ]]; then
    return 1
  fi

  account_id=$(plutil -convert json -o - "$plist_file" 2>/dev/null | jq -r '.Accounts[0].AccountID // empty')

  [[ -n "$account_id" ]]
}

# --- Check status ---
echo "Checking Apple ID sign-in status..."

if ! is_signed_in; then
  echo "❌ Not signed in to Apple ID. Please sign in via System Settings > Apple ID."
fi

# --- Wait silently until signed in ---
while ! is_signed_in; do
  sleep 3
  printf "%s"  "."
done

echo "✅ Apple ID is signed in."

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
