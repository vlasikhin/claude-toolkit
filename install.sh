#!/bin/bash
# Links all skills from this repo to ~/.claude/skills/
# Safe: skips existing entries, ignores _template and non-skill dirs.

SKILL_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILL_DIR"

for skill in "$REPO_DIR"/*/; do
    name=$(basename "$skill")
    [[ "$name" == _* ]] && continue
    [[ "$name" == .* ]] && continue
    [[ ! -f "$skill/SKILL.md" ]] && continue

    if [ ! -e "$SKILL_DIR/$name" ]; then
        ln -s "$skill" "$SKILL_DIR/$name"
        echo "✓ linked: $name"
    else
        echo "· exists: $name (skipped)"
    fi
done

echo ""
echo "Done. Skills available in $SKILL_DIR"
