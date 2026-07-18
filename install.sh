#!/usr/bin/env bash

set -euo pipefail

MANAGED_START="# >>> terminal-setting >>>"
MANAGED_END="# <<< terminal-setting <<<"
HOMEBREW_START="# >>> terminal-setting homebrew >>>"
HOMEBREW_END="# <<< terminal-setting homebrew <<<"
LEGACY_MISE='eval "$($HOME/.local/bin/mise activate zsh)"'
LEGACY_POSH='eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json)"'
TEMP_FILES=()

cleanup() {
  local file

  for file in "${TEMP_FILES[@]:-}"; do
    if [[ -n "$file" && -f "$file" ]]; then
      rm -f -- "$file"
    fi
  done
}

backup_file() {
  local file="$1"
  local backup

  if [[ ! -s "$file" ]]; then
    return
  fi

  backup="$(mktemp "${file}.terminal-setting.backup.XXXXXX")"
  cp -p "$file" "$backup"
  echo "Backed up $file to $backup"
}

replace_managed_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local config_kind="$4"
  local legacy_brew="$5"
  local temp
  shift 5

  touch "$file"
  temp="$(mktemp "${file}.terminal-setting.tmp.XXXXXX")"
  TEMP_FILES+=("$temp")
  cp -p "$file" "$temp"

  awk \
    -v start="$start_marker" \
    -v end="$end_marker" \
    -v kind="$config_kind" \
    -v legacy_mise="$LEGACY_MISE" \
    -v legacy_posh="$LEGACY_POSH" \
    -v legacy_brew="$legacy_brew" '
      function emit(line) {
        if (line ~ /^[[:space:]]*$/) {
          pending = pending line ORS
        } else {
          printf "%s", pending
          pending = ""
          print line
        }
      }

      $0 == start { in_block = 1; next }
      in_block && $0 == end { in_block = 0; next }
      in_block { next }

      kind == "homebrew" && legacy_brew != "" && $0 == legacy_brew { next }
      kind == "zsh" && $0 == legacy_mise { next }
      kind == "zsh" && $0 == legacy_posh { next }
      kind == "zsh" && $0 ~ /^source .*\/share\/zsh-autosuggestions\/zsh-autosuggestions[.]zsh$/ { next }
      kind == "zsh" && $0 ~ /^source .*\/share\/zsh-syntax-highlighting\/zsh-syntax-highlighting[.]zsh$/ { next }

      { emit($0) }
    ' "$file" > "$temp"

  if [[ -s "$temp" ]]; then
    printf '\n' >> "$temp"
  fi
  printf '%s\n' "$start_marker" >> "$temp"
  printf '%s\n' "$@" >> "$temp"
  printf '%s\n' "$end_marker" >> "$temp"

  if cmp -s "$file" "$temp"; then
    return
  fi

  backup_file "$file"
  if [[ -L "$file" ]]; then
    # Preserve dotfile-manager symlinks while updating their target content.
    awk '{ print }' "$temp" > "$file"
    rm -f -- "$temp"
  else
    mv "$temp" "$file"
  fi
}

download_theme() {
  local theme_file="$1"
  local theme_url="$2"
  local temp

  if [[ -f "$theme_file" ]]; then
    return
  fi

  temp="$(mktemp "${theme_file}.tmp.XXXXXX")"
  TEMP_FILES+=("$temp")
  curl -fsSL "$theme_url" -o "$temp"
  mv "$temp" "$theme_file"
  echo "Saved Oh My Posh theme to $theme_file"
}

install_meslo_font() {
  local marker="$1"

  if [[ -f "$marker" ]]; then
    return
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -r /proc/version ]] && grep -qi microsoft /proc/version; then
    echo "WSL detected: install MesloLGM Nerd Font on the Windows host and select it in your terminal."
    return
  fi

  echo "Installing MesloLGM Nerd Font"
  if oh-my-posh font install meslo --headless; then
    touch "$marker"
  else
    echo "Warning: MesloLGM Nerd Font installation failed. Install it manually with: oh-my-posh font install meslo"
  fi
}

main() {
  local zshrc="$HOME/.zshrc"
  local zprofile="$HOME/.zprofile"
  local brew_bin=""
  local brew_line=""
  local brew_prefix=""
  local zsh_autosuggestions=""
  local zsh_syntax_highlighting=""
  local posh_config_dir="$HOME/.config/oh-my-posh"
  local posh_theme="$posh_config_dir/M365Princess.omp.json"
  local posh_theme_url="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json"
  local mise_line='eval "$($HOME/.local/bin/mise activate zsh)"'
  local posh_line='eval "$(oh-my-posh init zsh --config "$HOME/.config/oh-my-posh/M365Princess.omp.json")"'
  local -a zsh_block

  trap cleanup EXIT
  echo "Start setup"

  # Detect the operating system and install packages.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS detected"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

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
    brew_bin="$(command -v brew)"
    brew_prefix="$(brew --prefix)"
    zsh_autosuggestions="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    zsh_syntax_highlighting="$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux detected"
    sudo apt update
    sudo apt install -y zsh git curl unzip fzf zsh-autosuggestions zsh-syntax-highlighting
    zsh_autosuggestions="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    zsh_syntax_highlighting="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi

  # Install mise in the stable per-user location used by the shell config.
  if [[ ! -x "$HOME/.local/bin/mise" ]]; then
    echo "Installing mise"
    curl -fsSL https://mise.run | sh
  fi

  # Both mise and the Oh My Posh installer use these per-user binary directories.
  export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

  if ! command -v oh-my-posh &> /dev/null; then
    echo "Installing Oh My Posh"
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s
  fi

  mkdir -p "$posh_config_dir"
  download_theme "$posh_theme" "$posh_theme_url"
  install_meslo_font "$posh_config_dir/.meslo-font-installed"

  if [[ ! -f "$zsh_autosuggestions" ]]; then
    echo "Warning: zsh-autosuggestions not found at $zsh_autosuggestions"
  fi
  if [[ ! -f "$zsh_syntax_highlighting" ]]; then
    echo "Warning: zsh-syntax-highlighting not found at $zsh_syntax_highlighting"
  fi

  # Persist Homebrew for future login shells on macOS.
  if [[ -n "$brew_bin" ]]; then
    printf -v brew_line 'eval "$(%s shellenv)"' "$brew_bin"
    replace_managed_block \
      "$zprofile" "$HOMEBREW_START" "$HOMEBREW_END" "homebrew" "$brew_line" \
      "$brew_line"
  fi

  zsh_block=(
    "$mise_line"
    'if command -v fzf >/dev/null 2>&1; then'
    '  if fzf --zsh >/dev/null 2>&1; then'
    '    source <(fzf --zsh)'
    '  else'
    '    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh'
    '    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh'
    '  fi'
    'fi'
  )

  if [[ -f "$zsh_autosuggestions" ]]; then
    zsh_block+=("source $zsh_autosuggestions")
  fi
  zsh_block+=("$posh_line")
  if [[ -f "$zsh_syntax_highlighting" ]]; then
    # This must remain the final executable line in the managed block.
    zsh_block+=("source $zsh_syntax_highlighting")
  fi

  replace_managed_block \
    "$zshrc" "$MANAGED_START" "$MANAGED_END" "zsh" "" \
    "${zsh_block[@]}"

  echo "Setup complete! Restart your terminal and select MesloLGM Nerd Font in its settings."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
