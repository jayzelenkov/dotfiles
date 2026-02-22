# Agents

This is a chezmoi-managed dotfiles repository for macOS.

## Repository layout

- `dot_zshrc` — Zsh configuration, applied to `~/.zshrc`
- `Brewfile` — Homebrew formulae, casks, and Mac App Store apps (not applied to `~`, included inline by the install script)
- `run_once_before_install-packages.sh.tmpl` — Runs once before dotfiles are applied: installs Xcode CLT, Homebrew, and all Brewfile packages
- `run_once_after_setup-mise.sh.tmpl` — Runs once after dotfiles are applied: installs mise runtimes (python, bun), configures Postico license, prints next steps
- `.chezmoiignore` — Lists files that exist in this repo but should not be applied to the home directory (e.g., `Brewfile`, `README.md`, `AGENTS.md`)
- `.gitignore` — Files excluded from version control

## Chezmoi conventions

- Files prefixed with `dot_` are applied with a leading `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- Files ending in `.tmpl` are Go templates, rendered using chezmoi data (e.g., `.chezmoi.os`)
- `run_once_before_*` scripts run before dotfiles are applied, exactly once per machine
- `run_once_after_*` scripts run after dotfiles are applied, exactly once per machine
- Files listed in `.chezmoiignore` are tracked in git but not applied to `~`

## Editing guidelines

- **No hardcoded usernames or paths.** Use `$HOME` or `~` instead of `/Users/<name>`. This repo is designed to be portable across machines and users.
- **Brewfile changes** only take effect when the install script runs. The Brewfile is included inline via `{{ include "Brewfile" }}` in the install template.
- **Secrets** belong in `~/.secrets` (not tracked). The `.zshrc` sources this file if it exists.
- **macOS only.** All run scripts are gated with `{{ if eq .chezmoi.os "darwin" }}`.
- When adding new shell tools, add both the Homebrew formula to `Brewfile` and the shell integration to `dot_zshrc`.
- Keep the Brewfile commented — each formula/cask should have an inline comment explaining what it is.
