# Dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap a new Mac

On a fresh macOS install, run:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
```

This single command will:

1. Install chezmoi
2. Clone this repo
3. Install Xcode Command Line Tools
4. Install Homebrew
5. Install all packages from the Brewfile (formulae, casks, App Store apps)
6. Apply dotfiles (`~/.zshrc`)
7. Install global runtimes via mise (python, bun)
8. Configure Postico license (if available)

## What's included

### Shell (`dot_zshrc` → `~/.zshrc`)

- **[mise](https://mise.jdx.dev/)** — runtime version manager (python, node, bun)
- **[starship](https://starship.rs/)** — cross-shell prompt
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder with shell keybindings
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smart `cd` with frecency
- **[eza](https://github.com/eza-community/eza)** — modern `ls` with icons and git status
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** — fast recursive search (`grep` is aliased to `rg`)
- Git helpers (`gc`, `gcp`, `glola`, etc.)
- `awt` — creates git worktree sandboxes for AI coding agents
- TypeID/UUID conversion helpers

### Brewfile

All Homebrew formulae, casks, and Mac App Store apps. See inline comments in `Brewfile` for what each package does.

### Secrets

Machine-local secrets go in `~/.secrets` (sourced by `.zshrc`, not tracked by git):

```bash
# ~/.secrets
export GITHUB_TOKEN="ghp_..."
export POSTICO_LICENSE_KEY="..."
```

## Structure

```
~/.local/share/chezmoi/
├── .chezmoiignore                           # Files to keep in repo but not apply to ~
├── .gitignore                               # Files excluded from git
├── AGENTS.md                                # Instructions for AI coding agents
├── README.md                                # This file
├── Brewfile                                 # Homebrew packages (included in install script)
├── dot_zshrc                                # → ~/.zshrc
├── run_once_before_install-packages.sh.tmpl # Xcode CLT + Homebrew + brew bundle
└── run_once_after_setup-mise.sh.tmpl        # mise runtimes + Postico license + next steps
```

## Day-to-day usage

```bash
# Edit a managed dotfile
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Pull and apply on another machine
chezmoi update

# Add a new dotfile
chezmoi add ~/.config/starship.toml

# See what would change
chezmoi diff
```

## Re-running bootstrap scripts

The `run_once` scripts only execute once per machine. To force a re-run:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```
