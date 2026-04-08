#!/bin/bash
# Links skills and agents from this repo to ~/.claude/
# Safe: skips existing entries, ignores _template and non-skill dirs.

SKILL_DIR="$HOME/.claude/skills"
AGENT_DIR="$HOME/.claude/agents"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Skills ---
mkdir -p "$SKILL_DIR"
echo "Skills:"

for skill in "$REPO_DIR"/*/; do
    name=$(basename "$skill")
    [[ "$name" == _* ]] && continue
    [[ "$name" == .* ]] && continue
    [[ "$name" == "agents" ]] && continue
    [[ ! -f "$skill/SKILL.md" ]] && continue

    if [ ! -e "$SKILL_DIR/$name" ]; then
        ln -s "$skill" "$SKILL_DIR/$name"
        echo "  ✓ linked: $name"
    else
        echo "  · exists: $name (skipped)"
    fi
done

# --- Agents ---
if [ -d "$REPO_DIR/agents" ]; then
    mkdir -p "$AGENT_DIR"
    echo ""
    echo "Agents:"

    for agent in "$REPO_DIR"/agents/*.md; do
        [ -f "$agent" ] || continue
        name=$(basename "$agent")

        if [ ! -e "$AGENT_DIR/$name" ]; then
            ln -s "$agent" "$AGENT_DIR/$name"
            echo "  ✓ linked: $name"
        else
            echo "  · exists: $name (skipped)"
        fi
    done
fi

echo ""
echo "Done. Skills in $SKILL_DIR, agents in $AGENT_DIR"
