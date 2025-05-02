#!/bin/bash

set -euo pipefail

echo ">> Starting system bootstrap..."

# --- Functions ---

set_computer_name() {
  local current_name
  current_name=$(scutil --get ComputerName)
  read -r -p ">> Enter the name for this computer [$current_name]: " computer_name
  computer_name=${computer_name:-$current_name}

  echo ">> Setting computer name to '$computer_name'..."
  sudo scutil --set ComputerName "$computer_name"
  sudo scutil --set HostName "$computer_name"
  sudo scutil --set LocalHostName "$computer_name"
}

is_signed_in() {
  local plist_file="$HOME/Library/Preferences/MobileMeAccounts.plist"
  [[ -f "$plist_file" ]] || return 1

  local account_id
  account_id=$(plutil -convert json -o - "$plist_file" 2>/dev/null | jq -r '.Accounts[0].AccountID // empty')
  [[ -n "$account_id" ]]
}

wait_for_icloud_login() {
  echo ">> Checking Apple ID sign-in status..."

  if ! is_signed_in; then
    echo "❌ Not signed in to Apple ID. Please sign in via System Settings > Apple ID."
  fi

  while ! is_signed_in; do
    sleep 3
    printf "."
  done

  echo
  echo "✅ Apple ID is signed in."
}

ensure_sudo_credentials() {
  echo ">> Validating sudo credentials..."
  if ! sudo -v; then
    echo "❌ You must enter valid sudo credentials to run this script."
    exit 1
  fi
}

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo ">> Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  else
    echo ">> Homebrew already installed."
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_chezmoi() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo ">> Installing chezmoi..."
    brew install chezmoi
  else
    echo ">> chezmoi already installed."
  fi
}

apply_dotfiles() {
  if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    echo ">> Initializing chezmoi from dotfiles repo..."
    chezmoi init --apply https://github.com/jcouball/dotfiles
  else
    echo ">> chezmoi already initialized. Skipping apply."
  fi
}

# --- Main ---

set_computer_name
wait_for_icloud_login
ensure_sudo_credentials
install_homebrew
install_chezmoi
apply_dotfiles

echo "✅ Bootstrap complete."
