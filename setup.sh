#!/usr/bin/env bash
# AI R&D Squad — setup for Linux/macOS
# Deploys agent/skill/CLAUDE.md from repo to ~/.claude/

set -euo pipefail

SQUAD_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SOURCE="$SQUAD_HOME/claude"

if [[ ! -d "$SOURCE" ]]; then
    echo "ERROR: Source dir not found: $SOURCE" >&2
    exit 1
fi

echo ""
echo "=== AI R&D Squad — Setup ==="
echo "Repo (SQUAD_HOME):    $SQUAD_HOME"
echo "Target (CLAUDE_HOME): $CLAUDE_HOME"
echo ""

mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"

deploy_file() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    sed -e "s|{{SQUAD_HOME}}|$SQUAD_HOME|g" \
        -e "s|{{CLAUDE_HOME}}|$CLAUDE_HOME|g" \
        "$src" > "$dest"
}

# CLAUDE.md
deploy_file "$SOURCE/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
echo "[OK] CLAUDE.md"

# Agents
agent_count=0
for f in "$SOURCE"/agents/*.md; do
    [[ -e "$f" ]] || continue
    deploy_file "$f" "$CLAUDE_HOME/agents/$(basename "$f")"
    ((agent_count++)) || true
done
echo "[OK] Agents: $agent_count"

# Skills (recursive)
skill_count=0
while IFS= read -r -d '' f; do
    rel="${f#"$SOURCE/skills/"}"
    deploy_file "$f" "$CLAUDE_HOME/skills/$rel"
    ((skill_count++)) || true
done < <(find "$SOURCE/skills" -type f -print0)
echo "[OK] Skill files: $skill_count"

# Persist SQUAD_HOME for later sessions (best-effort, .bashrc/.zshrc)
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]] && ! grep -q "SQUAD_HOME=" "$rc"; then
        echo "export SQUAD_HOME=\"$SQUAD_HOME\"" >> "$rc"
    fi
done

echo ""
echo "Setup complete. Restart Claude Code if it's running."
echo ""
