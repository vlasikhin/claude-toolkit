# Claude Skills Repository

## Skill Structure Rules (from Anthropic's Guide)

### Required
- `SKILL.md` — exact name, case-sensitive. No `skill.md`, no `SKILL.MD`
- No `README.md` inside skill folders

### Folder Naming
- kebab-case only: `my-skill-name`
- No spaces, no underscores, no capitals

### YAML Frontmatter
- `name` (required): kebab-case, must match folder name
- `description` (required): what it does + when to use it + trigger phrases. Under 1024 characters. No XML tags
- `license` (optional): MIT, Apache-2.0, etc.
- `metadata` (optional): author, version, tags

### Progressive Disclosure (3 levels)
1. **Frontmatter** — always loaded in system prompt. Just enough for Claude to know when to use the skill
2. **SKILL.md body** — loaded when Claude thinks the skill is relevant
3. **references/** — additional files Claude loads only as needed

### SKILL.md Body
- Under 5000 words
- Critical instructions at the top
- Specific and actionable, not abstract
- Move detailed docs/examples to `references/` and link to them

### File Structure
```
your-skill-name/
├── SKILL.md          # required
├── scripts/          # optional — executable code
├── references/       # optional — documentation loaded as needed
└── assets/           # optional — templates, fonts, icons
```

### Description Best Practices
- Include WHAT it does + WHEN to use it + trigger phrases
- Trigger phrases = specific things a user might say
- Example: `"Manages sprint planning. Use when user says 'plan sprint', 'create tasks', or 'sprint velocity'"`

### Common Mistakes
- Description too vague ("Helps with projects")
- Missing trigger phrases
- Instructions too verbose — move details to references/
- Not putting critical instructions at the top
