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
- MesloLGM Nerd Font

On macOS, the script installs packages with Homebrew. If Homebrew is not installed, it will install Homebrew first.

On Linux, the script uses `apt`, so it is intended for Debian/Ubuntu-based systems.

The script also updates the package index with `brew update` on macOS or `sudo apt update` on Linux.

## Shell Configuration

The script manages these settings in `~/.zshrc`:

- activates `mise`
- enables `fzf` key bindings and fuzzy completion
- loads `zsh-autosuggestions`
- initializes `oh-my-posh` with a local copy of the `M365Princess` theme
- loads `zsh-syntax-highlighting`

The settings are kept in a managed block so rerunning the installer updates the existing block instead of leaving obsolete lines behind. The syntax-highlighting integration remains the final executable line in that block, as required by the plugin.

On macOS, the script also adds a managed block to `~/.zprofile` so Homebrew remains on `PATH` in future terminal sessions.

The Oh My Posh theme is downloaded once to `~/.config/oh-my-posh/M365Princess.omp.json`. The installer does not overwrite that file on later runs, so local customizations are preserved.

It does not currently:

- install or configure Ghostty
- change your default shell to `zsh`
- create a Ghostty config file
- uninstall packages or remove generated config

The script is safe to run more than once for the shell configuration it manages. Before changing an existing non-empty `~/.zshrc` or `~/.zprofile`, it creates a sibling backup whose name contains `.terminal-setting.backup.`.

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

Oh My Posh requires a Nerd Font for its icons. The script installs MesloLGM Nerd Font, but you still need to select `MesloLGM Nerd Font` in your terminal application's font settings. When running under WSL, install and select the font on the Windows host instead.

Useful `fzf` shortcuts include `Ctrl-R` for command history, `Ctrl-T` for files, and `Alt-C` for directories. On older Debian/Ubuntu `fzf` packages, the script loads the packaged integration files as a fallback.

This script does not change your default shell. If you want to make `zsh` your default shell, run:

```sh
chsh -s "$(which zsh)"
```

## Supported Systems

- macOS with Homebrew
- Debian/Ubuntu Linux with `apt`

Other operating systems are not supported by the script.

## Notes

This script downloads and runs installers from the internet for Homebrew, `mise`, and `oh-my-posh`. It also downloads the Oh My Posh theme and MesloLGM Nerd Font. Review the script before running it on a machine you care about.

The script automatically backs up a non-empty shell configuration before changing it. You can also create your own predictable backup before running it:

```sh
cp ~/.zshrc ~/.zshrc.backup
```

## Rollback

If you created a backup before running the script, restore it with:

```sh
cp ~/.zshrc.backup ~/.zshrc
```

Otherwise, remove the blocks between these markers:

- `# >>> terminal-setting >>>` and `# <<< terminal-setting <<<` in `~/.zshrc`
- `# >>> terminal-setting homebrew >>>` and `# <<< terminal-setting homebrew <<<` in `~/.zprofile` on macOS

The downloaded theme is stored at `~/.config/oh-my-posh/M365Princess.omp.json`. Removing it is optional and does not uninstall Oh My Posh or the font.
