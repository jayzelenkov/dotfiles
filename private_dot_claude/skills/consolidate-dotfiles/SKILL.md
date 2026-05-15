---
name: consolidate-dotfiles
description: Consolidate live changes back into the chezmoi-managed dotfiles repo at ~/Documents/GitHub/dotfiles. Use when the user says /consolidate-dotfiles, or asks to "sync dotfiles", "bring live changes into repo", "apply dotfile updates", "reconcile dotfiles", "check what's installed that's missing from Brewfile", etc. Handles Brewfile drift (installed formulae/casks not tracked), chezmoi drift (live dotfiles diverged from source), and new untracked dotfiles under ~/.config.
---

# Consolidate Dotfiles

This skill reconciles live system state with the chezmoi-managed dotfiles repo at `~/Documents/GitHub/dotfiles/`, then commits and pushes.

## Important context

- Primary repo: `~/Documents/GitHub/dotfiles/` (chezmoi source)
- Remote: github.com/jayzelenkov/dotfiles
- User's shell aliases `grep` to `rg` (ripgrep) — **always use `command grep`** in Bash commands, never bare `grep`.
- Chezmoi uses `dot_` prefix for dotfiles, `private_` prefix when the source dir is 700-permissioned.
- A `run_once_before_install-packages.sh.tmpl` bootstrap script will always show as `R` in `chezmoi status`. **Skip it.** It's a first-machine bootstrap, not drift.
- `~/.claude/skills/` is tracked under `private_dot_claude/skills/`. Plugin cache (`~/.claude/plugins/cache`), conversation history (`~/.claude/projects`), and skill `.zip` archives are excluded via `.chezmoiignore` — do not track them.

## Execution order

Run these in order. Do not skip steps unless explicitly asked.

### 1. Inspect state (parallel)

Run these in parallel to build the picture:

```bash
# Chezmoi drift
chezmoi status

# Formulae installed but not in Brewfile (filter to on-request = user-installed, not transitive deps)
comm -23 \
  <(brew list --formula 2>/dev/null | sort) \
  <(command grep '^brew "' ~/Documents/GitHub/dotfiles/Brewfile | sed 's/brew "//;s/".*//' | sort) \
  | while read pkg; do
      if brew info "$pkg" 2>/dev/null | command grep -q "Installed .* (on request)"; then
        echo "$pkg"
      fi
    done

# Casks installed but not in Brewfile
comm -23 \
  <(brew list --cask 2>/dev/null | sort) \
  <(command grep '^cask "' ~/Documents/GitHub/dotfiles/Brewfile | sed 's/cask "//;s/".*//' | sort)
```

### 2. Classify chezmoi drift

For each file that `chezmoi status` flags (ignoring the `R install-packages.sh` bootstrap), look at `chezmoi diff <path>` and decide the direction:

- **Live → Source** (update repo): The live edit is intentional and worth keeping. Examples: a new shell alias in `~/.zshrc`, a new permanent Claude permission the user wants. Update the chezmoi source file to match live.
- **Source → Live** (discard drift): The live drift is session-specific noise. Examples: one-off Claude `Bash(...)` permissions approved during a single session, ephemeral tool permissions. Run `chezmoi apply --include=files --force` to wipe these.

The `settings.json` template is at `private_dot_claude/settings.json.tmpl`. If the user has approved useful **permanent** permissions (e.g., new MCP tools, commonly-used CLI tools), add them there. If they're one-off session artifacts (specific project paths, one-shot debug commands), discard via `--force`.

When in doubt, show the diff to the user and ask.

### 3. Scan for untracked dotfiles

Check `~/.config/` for directories not yet managed by chezmoi that the user has populated. Known candidates worth tracking if present and non-default:

- `~/.config/jj/config.toml` (Jujutsu VCS)
- `~/.config/mise/config.toml`
- `~/.config/starship.toml`
- `~/.config/htop/htoprc`
- `~/Library/Application Support/com.mitchellh.ghostty/config` (only if modified from default template)

Also check `~/.claude/skills/` for any new skill directory not yet under `private_dot_claude/skills/`. Run `chezmoi add ~/.claude/skills/<skill-name>` for each new one. Live edits to existing tracked skills appear in `chezmoi status` and resolve via the standard live↔source classification in step 2 — for skills, edits are nearly always intentional, so propagate **live → source**.

Compare against `chezmoi managed` to find untracked ones. Use `chezmoi add <path>` to bring a file into the source. Chezmoi will auto-apply the correct `dot_` / `private_` prefixes based on directory permissions.

**Do NOT track**:
- `~/.config/gcloud/`, `~/.config/gh/`, `~/.config/github-copilot/` — contain auth tokens
- `~/.config/op/` — 1Password CLI session state
- Project-specific configs (`~/.config/amazon-cart/`, etc.)
- Directory backups (`~/.config/karabiner-orig/`)

### 4. Update Brewfile

For each missing formula/cask, add to the appropriate section in `~/Documents/GitHub/dotfiles/Brewfile`:

- Shell & terminal tools → top section
- Dev tools → alphabetized under "Dev tools"
- Infrastructure & services → under that heading
- Libraries & utilities → under that heading
- Window management → under that heading
- Apps (casks) → in the relevant category: "AI & productivity", "Communication", "Dev tools", "Media & entertainment", "macOS utilities", "Hardware"

Include a short comment explaining the tool's purpose, matching existing style (`brew "name"                    # Description`).

**Skip transitive dependencies** (lib*, *-cli sub-formulae brought in as deps). The `(on request)` filter handles this, but double-check — something like `python@3.14` may appear if the user explicitly installed it vs. got it as a dep.

**Do NOT remove** entries from Brewfile that are not installed (e.g., `cheatsheet`, `sf-symbols` may be Brewfile-only for fresh installs). Out of scope unless user explicitly asks.

### 5. Deploy config changes

If you changed any `dot_*` file in the source (like `dot_aerospace.toml`, `dot_zshrc`), also deploy it:

```bash
# For aerospace:
cp ~/Documents/GitHub/dotfiles/dot_aerospace.toml ~/.aerospace.toml
/opt/homebrew/bin/aerospace reload-config

# For sketchybar plugins:
cp ~/Documents/GitHub/dotfiles/dot_config/sketchybar/plugins/executable_*.sh ~/.config/sketchybar/plugins/
sketchybar --reload

# For zshrc:
cp ~/Documents/GitHub/dotfiles/dot_zshrc ~/.zshrc
```

### 6. Apply chezmoi

After source updates, run `chezmoi apply --include=files --force` to sync any remaining source→live drift. The `--include=files` flag skips the `run_once` bootstrap script.

Verify clean state: `chezmoi status` should show only `R install-packages.sh` (expected).

### 7. Commit and push

Review all changes: `git status && git diff`.

Commit with a descriptive message following this repo's style — summary line + optional bullet list of what changed. Use a heredoc and always include the Co-Authored-By trailer:

```bash
git add <files> && git commit -m "$(cat <<'EOF'
<Summary line>

- <Bullet point if multiple distinct changes>
- <Another bullet>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)" && git push
```

Do **not** use `git commit -am` or `git add .` — stage files explicitly to avoid accidentally committing untracked noise.

## Summary to return

After completing, report back to the user with:

1. Brew formulae added (if any)
2. Casks added (if any)
3. New dotfiles tracked via `chezmoi add` (if any)
4. Files that had drift resolved (live → source or source → live)
5. Commit SHA pushed

Keep the summary brief — one line per change.

## Common pitfalls

- **`grep` aliased to `rg`**: Always `command grep` in Bash.
- **`chezmoi apply` prompts for TTY on conflicts**: Use `--force` to skip prompts.
- **Never skip hooks or sign off**: No `--no-verify`, no unauthorized `--force` on pushes.
- **Deploying aerospace changes**: AeroSpace reads `~/.aerospace.toml`, not the source file. Always `cp` to live location + `reload-config`.
- **Settings.json `MM` status**: Means modified in both source and destination. Decide direction based on the diff before running `--force`.
