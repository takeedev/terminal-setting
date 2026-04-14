#!/usr/bin/env bash

echo "Start setup"

# detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "mac"
  # check brew
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew update
  brew install zsh git curl unzip fzf zsh-autosuggestions zsh-syntax-highlighting

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "Linux"
  sudo apt update
  sudo apt install -y zsh git curl unzip fzf zsh-autosuggestions zsh-syntax-highlighting

fi

# install mise
if [ ! -f "$HOME/.local/bin/mise" ]; then
  echo 'install mise en place'
  curl https://mise.run | sh
fi

# add mise to zshrc
grep -qxF 'eval "$(~/.local/bin/mise activate zsh)"' ~/.zshrc || \
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

# install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi

# syntax highlight
grep -qxF 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc || \
echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

# auto suggestions
grep -qxF 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc || \
echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

# add oh-my-posh config
grep -qxF 'eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json')"' ~/.zshrc || \
echo 'eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json')"' >> ~/.zshrc

echo '------------------------check zshrc file---------------------------'
cat ~/.zshrc
echo "Setup complete! and Restart terminal"