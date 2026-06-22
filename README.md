# Terminal-Setting

Setup script for a zsh-based terminal environment on macOS and Debian/Ubuntu Linux.

## Prerequisites

- macOS or Debian/Ubuntu Linux
- internet access
- `sudo` access on Linux
- permission to install Homebrew on macOS if it is not already installed

## Installed Tools

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

The script also updates the package index with `brew update` on macOS or `sudo apt update` on Linux.

## Shell Configuration

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

The script is safe to run more than once for the `~/.zshrc` entries it manages. It only appends a line when that exact line is not already present.

## Install

Run from this repository:

```sh
bash install.sh
```

Or run directly from GitHub:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/takeedev/terminal-setting/refs/heads/main/install.sh)
```

The direct GitHub command requires a shell that supports process substitution, such as `bash` or `zsh`.

## After Install

Restart your terminal after installation.

This script does not change your default shell. If you want to make `zsh` your default shell, run:

```sh
chsh -s "$(which zsh)"
```

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

## Rollback

If you created a backup before running the script, restore it with:

```sh
cp ~/.zshrc.backup ~/.zshrc
```

Otherwise, remove the lines added by this script from `~/.zshrc`:

- `eval "$($HOME/.local/bin/mise activate zsh)"`
- `source .../zsh-autosuggestions.zsh`
- `eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json)"`
- `source .../zsh-syntax-highlighting.zsh`
