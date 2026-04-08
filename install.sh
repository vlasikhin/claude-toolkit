#!/bin/bash
# Links skills and agents from this repo to ~/.claude/
# Usage:
#   ./install.sh            # create new symlinks, skip existing
#   ./install.sh --update   # remove old symlinks from this repo, recreate all

SKILL_DIR="$HOME/.claude/skills"
AGENT_DIR="$HOME/.claude/agents"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
UPDATE=false

[[ "$1" == "--update" ]] && UPDATE=true

# --- Clean old symlinks on --update ---
if $UPDATE; then
    echo "Cleaning old symlinks..."
    # Remove symlinks pointing anywhere inside this repo (handles both old and new paths)
    for link in "$SKILL_DIR"/* "$AGENT_DIR"/*; do
        [ -L "$link" ] || continue
        target=$(readlink "$link")
        case "$target" in
            "$REPO_DIR"/*|*claude-skills*|*claude-toolkit*)
                rm "$link"
                echo "  ✗ removed: $(basename "$link")"
                ;;
        esac
    done
    # Also remove broken symlinks (from renamed/moved repo)
    find "$SKILL_DIR" -maxdepth 1 -xtype l -delete 2>/dev/null
    find "$AGENT_DIR" -maxdepth 1 -xtype l -delete 2>/dev/null
    echo ""
fi

# --- Skills ---
mkdir -p "$SKILL_DIR"
echo "Skills:"

for skill in "$REPO_DIR"/skills/*/; do
    name=$(basename "$skill")
    [[ "$name" == _* ]] && continue
    [[ ! -f "$skill/SKILL.md" ]] && continue

    if [ -L "$SKILL_DIR/$name" ] || [ -e "$SKILL_DIR/$name" ]; then
        echo "  · exists: $name (skipped)"
    else
        ln -s "$skill" "$SKILL_DIR/$name"
        echo "  ✓ linked: $name"
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

        if [ -L "$AGENT_DIR/$name" ] || [ -e "$AGENT_DIR/$name" ]; then
            echo "  · exists: $name (skipped)"
        else
            ln -s "$agent" "$AGENT_DIR/$name"
            echo "  ✓ linked: $name"
        fi
    done
fi

echo ""
echo "Done. Skills in $SKILL_DIR, agents in $AGENT_DIR"
