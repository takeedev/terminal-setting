# terminal-setting

Setup script for a zsh-based terminal environment on macOS and Debian/Ubuntu Linux.

## What It Installs

- `zsh`
- `git`
- `curl`
- `unzip`
- `fzf`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `mise`
- `oh-my-posh`

On macOS, the script installs packages with Homebrew. If Homebrew is not installed, it will install Homebrew first.

On Linux, the script uses `apt`, so it is intended for Debian/Ubuntu-based systems.

## What It Changes

The script appends these settings to `~/.zshrc` if they are not already present:

- activates `mise`
- loads `zsh-autosuggestions`
- initializes `oh-my-posh` with the `M365Princess` theme
- loads `zsh-syntax-highlighting`

It does not currently:

- install or configure Ghostty
- change your default shell to `zsh`
- create a Ghostty config file
- uninstall packages or remove generated config

## Install

Run from this repository:

```sh
bash install.sh
```

Or run directly from GitHub:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/takeedev/terminal-setting/refs/heads/main/install.sh)
```

After installation, restart your terminal.

## Supported Systems

- macOS with Homebrew
- Debian/Ubuntu Linux with `apt`

Other operating systems are not supported by the script.

## Notes

This script downloads and runs installers from the internet for Homebrew, `mise`, and `oh-my-posh`. Review the script before running it on a machine you care about.

The script modifies `~/.zshrc`. If you want an easy rollback path, back up your existing file first:

```sh
cp ~/.zshrc ~/.zshrc.backup
```
