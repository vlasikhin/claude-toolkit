# claude-skills

Personal Claude Code skills and agents collection. Syncs across machines via git + symlinks.

## Structure

```
skill-name/
└── SKILL.md              # required entrypoint
└── references/           # optional supplementary docs

agents/
└── agent-name.md         # agent definition with YAML frontmatter
```

Skills are flat (no nesting by language). Prefixes provide grouping:
- `ruby-*` — Ruby language conventions
- `rails-*` — Rails framework patterns
- `go-*` — Go language conventions
- No prefix — language-agnostic or cross-cutting skills

## Skills

### Language & Framework

| Skill | Description |
|---|---|
| `ruby-style` | Ruby code style and idioms |
| `ruby-gem-writer` | Gem authoring patterns |
| `rails-conventions` | Rails framework conventions |
| `dry-rb-patterns` | dry-rb ecosystem patterns |
| `go-style` | Go code style and idioms |
| `rspec` | RSpec testing conventions |
| `minitest` | Minitest testing conventions |

### Process & Quality

| Skill | Description |
|---|---|
| `rails-code-review` | Detailed Rails code review with 10-category rulebook |
| `tdd-workflow` | Test-driven development process (Red/Green/Refactor) |
| `verification-loop` | Pre-commit 6-phase quality gate |
| `security-review` | Security review checklist for Rails |
| `git-workflow` | Branching, commits, merge conventions |

### Architecture & API

| Skill | Description |
|---|---|
| `api-design` | REST API design conventions |
| `database-migrations` | Safe migration patterns for production |

### Infrastructure

| Skill | Description |
|---|---|
| `deployment-patterns` | Deploy strategies, CI/CD, production readiness |
| `docker-patterns` | Docker and Compose for dev and production |

### Documentation

| Skill | Description |
|---|---|
| `markdown-style` | Markdown formatting conventions |
| `markdown-docs` | Project documentation structure |

## Agents

| Agent | Role | Color |
|---|---|---|
| `code-reviewer` | Code quality and Rails conventions review | cyan |
| `security-reviewer` | OWASP Top 10 and Rails security audit | red |
| `database-reviewer` | PostgreSQL and ActiveRecord optimization | yellow |
| `tdd-guide` | Red-Green-Refactor TDD enforcement | green |
| `planner` | Feature decomposition into phased steps | cyan |
| `architect` | System design and trade-off analysis | cyan |
| `harness-optimizer` | Claude Code config audit and token optimization | yellow |

## Installation

```bash
git clone https://github.com/vlasikhin/claude-skills.git ~/.claude-skills && ~/.claude-skills/install.sh
```

Or link individually:

```bash
ln -s ~/.claude-skills/ruby-style ~/.claude/skills/ruby-style
ln -s ~/.claude-skills/agents/code-reviewer.md ~/.claude/agents/code-reviewer.md
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
