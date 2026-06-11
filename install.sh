#!/usr/bin/env bash

set -euo pipefail

echo "Start setup"

ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

append_once() {
  local line="$1"

  grep -qxF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
}

# detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "mac"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  # check brew
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  brew update
  brew install zsh git curl unzip fzf zsh-autosuggestions zsh-syntax-highlighting

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Linux"
  sudo apt update
  sudo apt install -y zsh git curl unzip fzf zsh-autosuggestions zsh-syntax-highlighting

else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

# install mise
if [ ! -f "$HOME/.local/bin/mise" ]; then
  echo 'install mise en place'
  curl -fsSL https://mise.run | sh
fi

# add mise to zshrc
append_once 'eval "$($HOME/.local/bin/mise activate zsh)"'

# install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
  curl -fsSL https://ohmyposh.dev/install.sh | bash -s
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  BREW_PREFIX="$(brew --prefix)"
  ZSH_AUTOSUGGESTIONS="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_SYNTAX_HIGHLIGHTING="$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  ZSH_AUTOSUGGESTIONS="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_SYNTAX_HIGHLIGHTING="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# auto suggestions
if [[ -f "$ZSH_AUTOSUGGESTIONS" ]]; then
  append_once "source $ZSH_AUTOSUGGESTIONS"
else
  echo "Warning: zsh-autosuggestions not found at $ZSH_AUTOSUGGESTIONS"
fi

# add oh-my-posh config
append_once 'eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json)"'

# syntax highlight should be sourced near the end of zshrc
if [[ -f "$ZSH_SYNTAX_HIGHLIGHTING" ]]; then
  append_once "source $ZSH_SYNTAX_HIGHLIGHTING"
else
  echo "Warning: zsh-syntax-highlighting not found at $ZSH_SYNTAX_HIGHLIGHTING"
fi

echo "Setup complete! and Restart terminal"
