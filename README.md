# claude-skills

Personal Claude Code skills collection. Syncs across machines via git + symlinks.

## Structure

```
skill-name/
└── SKILL.md              # required entrypoint
└── references/           # optional supplementary docs
```

Skills are flat (no nesting by language). Prefixes provide grouping:
- `ruby-*` — Ruby language conventions
- `rails-*` — Rails framework patterns
- `go-*` — Go language conventions
- No prefix — language-agnostic tools

## Installation

```bash
git clone https://github.com/vlasikhin/claude-skills.git ~/.claude-skills && ~/.claude-skills/install.sh
```

Or link individual skills:

```bash
ln -s ~/.claude-skills/ruby-style ~/.claude/skills/ruby-style
```

## Creating a new skill

Copy `_template/` and customize:

```bash
cp -r _template my-new-skill
```

## Updating

```bash
cd ~/.claude-skills && git pull
```

Symlinks point to the repo, so pulling updates existing skills automatically.

If new skills were added, run install to create their symlinks:

```bash
./install.sh
```
