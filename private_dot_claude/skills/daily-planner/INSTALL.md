# Installing the `daily-planner` skill

This skill is authored once in the dotfiles repo (`private_dot_claude/skills/daily-planner/`) and installed across multiple Claude surfaces.

## Prerequisites

- **Fastmail MCP** must already be wired up as a Custom Connector on every Claude surface you want this skill on. See [fastmail-mcp-setup memory](../../../../.claude/projects/-Users-jzelenkov-Documents-JZ/memory/fastmail_mcp_setup.md). Without it, the calendar gather step fails.
- **Mac-only steps (Reminders + Obsidian write)**: no extra deps. `osascript` ships with macOS; the Obsidian vault lives at `~/Documents/JZ/`.

## 1. Claude Code (CLI + VS Code extension)

After editing in dotfiles, materialize via chezmoi:

```bash
chezmoi apply
ls ~/.claude/skills/daily-planner/SKILL.md   # verify
```

Claude Code auto-loads on next session start. Trigger by asking the planner to do its job ("plan my day", "what should I focus on today", or dumping a goal list).

## 2. Claude Desktop for macOS

The Desktop app does not read `~/.claude/skills/`. Upload the ZIP via GUI:

1. Build the ZIP:
   ```bash
   ~/.claude/skills/daily-planner/repackage.sh
   ```
2. Open Claude Desktop → **Customize** → **Skills** → **+ Create skill**
3. Upload `~/.claude/skills/daily-planner.zip`
4. Confirm it appears in the Skills list

To regenerate after edits: re-run `chezmoi apply` then `repackage.sh`, then re-upload.

Skills uploaded to Desktop are local to that machine.

## 3. Claude.ai web (and iOS cloud sync)

iOS-side custom-skill support is **not officially documented** as of 2026-05. The working theory is that skills uploaded via claude.ai (the web app) sync to all logged-in Pro/Max clients including iOS.

1. Open https://claude.ai → **Customize** → **Skills** → **+ Create skill**
2. Upload `~/.claude/skills/daily-planner.zip`
3. On iOS, open Claude → Settings → confirm `daily-planner` is in the Skills list

If the iOS app doesn't show it within ~5 min, cloud sync isn't yet shipped to your account/region.

**Surface caveat:** On web and iOS this skill operates in *degraded mode* — calendar only. Habits + errands + daily-note write require Mac + Claude Code. The skill detects this and tells you in the chat summary.

## 4. (Optional) Distribute as a Claude Code plugin via git

Same pattern as decision-brief — create a standalone repo and `claude plugins install gh:jayzelenkov/claude-skill-daily-planner`. Skip unless you want to share with others; the dotfiles+chezmoi path is sufficient for a single user.

## Quick re-zip helper

```bash
~/.claude/skills/daily-planner/repackage.sh
```

## Edit workflow

1. Edit files in `~/Documents/GitHub/dotfiles/private_dot_claude/skills/daily-planner/`
2. `chezmoi apply` to materialize to `~/.claude/skills/daily-planner/`
3. `~/.claude/skills/daily-planner/repackage.sh` to rebuild the ZIP
4. Re-upload to Desktop / web if you want those surfaces in sync
5. Commit the dotfiles change

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| "I can't access your calendar" | Fastmail MCP not authenticated on this surface. Re-run OAuth via `/mcp` (Code) or Connectors (Desktop/web). |
| Habits not pulled | Wrong path or surface lacks FS access. Verify `~/Documents/JZ/03-areas/_Habits.md` exists. |
| Errands not pulled | `osascript` requires macOS Automation permissions. Grant Claude Code / Terminal access to Reminders in System Settings → Privacy & Security → Automation. |
| Daily note created with wrong template | Skill expects `90-templates/daily-notes-template.md` to define the scaffold. If you've restructured the template, update SKILL.md step 4. |
| Plan overwrote existing `## Plan` | Should not happen — the skill prompts before replacing. If it did, the user picked "Replace" in the dialog. |
