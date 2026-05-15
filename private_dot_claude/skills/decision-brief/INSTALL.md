# Installing the `decision-brief` skill

This skill is authored once but installs differently across surfaces.

## 1. Claude Code (CLI + VS Code extension)

**Already installed** if the source folder lives at `~/.claude/skills/decision-brief/`.

Verify:
```bash
ls ~/.claude/skills/decision-brief/SKILL.md
```

Claude Code auto-loads on next session start. Trigger by asking a decision question matching the description (e.g. "I'm considering X and Y, help me pick").

## 2. Claude Desktop for macOS

The Desktop app does not read `~/.claude/skills/`. You must upload the skill via the GUI:

1. Open Claude Desktop
2. Click **Customize** in the sidebar → **Skills** → **+ Create skill**
3. Upload the ZIP at `~/.claude/skills/decision-brief.zip`
4. Confirm the skill appears in the Skills list

To regenerate the ZIP after edits:
```bash
cd ~/.claude/skills && \
  rm -f decision-brief.zip && \
  zip -r decision-brief.zip decision-brief -x '*.DS_Store'
```

Skills uploaded to Desktop are local to that machine and don't sync to the cloud.

## 3. Claude iOS app (and cloud sync)

iOS-side custom-skill support is **not officially documented** as of 2026-05. The working theory is that skills uploaded via **claude.ai** (the web app) sync to all logged-in clients on Pro/Max plans — including iOS.

To try the cloud-sync path:
1. Open https://claude.ai in a browser, log in
2. Click **Customize** → **Skills** → **+ Create skill**
3. Upload `~/.claude/skills/decision-brief.zip`
4. On iOS, open the Claude app → Settings → confirm skills list shows `decision-brief`

If it doesn't appear on iOS within ~5 min, the cloud-sync feature isn't yet shipped to iOS in your account/region. File feedback via `/feedback` in any Claude surface.

## 4. (Optional) Distribute as a plugin via git

If you want to version-control the skill or share it across machines, package it as a Claude Code plugin:

```bash
mkdir -p ~/Documents/GitHub/claude-skill-decision-brief/skills
cp -r ~/.claude/skills/decision-brief ~/Documents/GitHub/claude-skill-decision-brief/skills/
cd ~/Documents/GitHub/claude-skill-decision-brief
# Create a minimal plugin.json:
cat > plugin.json <<'EOF'
{
  "name": "decision-brief",
  "version": "0.1.0",
  "description": "Adversarial Researcher + Critic + Adviser pipeline for personal/consumer decisions",
  "author": "Jay Zelenkov"
}
EOF
git init && git add . && git commit -m "Initial decision-brief plugin"
gh repo create claude-skill-decision-brief --public --source=. --push
```

Then on any machine:
```bash
claude plugins install gh:jayzelenkov/claude-skill-decision-brief
```

The marketplace publishing path for end-users is not yet documented publicly; for now, git-based install is the portable option for Code.

## Quick re-zip helper

A convenience script lives next to this file. Run after edits:
```bash
~/.claude/skills/decision-brief/repackage.sh
```
