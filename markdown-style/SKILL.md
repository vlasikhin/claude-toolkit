---
name: markdown-style
description: Markdown formatting conventions. Use when writing or editing any markdown files — notes, docs, articles, comments. Use when user asks to "format markdown", "fix markdown style", "write markdown", or "review .md file".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Markdown Style

## Headings

- Single `#` per file (document title)
- No skipping levels: `##` → `###` → `####`
- Blank line before and after headings
- No trailing punctuation in headings

## Text

- One sentence per line (easier diffs and reviews)
- Blank line between paragraphs
- No trailing whitespace
- No hard line wraps at 80 chars — let the renderer wrap

## Emphasis

- `**bold**` for strong emphasis
- `_italic_` for mild emphasis (single underscore)
- Never combine bold and italic unless absolutely necessary
- No emphasis in headings

## Lists

- `-` for unordered lists (not `*`)
- Blank line before and after list blocks
- No blank lines between list items unless items are multi-paragraph
- Nested lists: 2 space indent
- Numbered lists only when order matters: `1.`, `2.`, `3.`

## Code

- Inline: single backtick for code references: `variable`, `function()`
- Fenced blocks with language tag:

````
```ruby
def hello
  puts "hi"
end
```
````

- No indented code blocks (use fenced always)

## Links and Images

- Inline links: `[text](url)`
- Reference links for repeated URLs:

```
[Claude Code][cc]

[cc]: https://claude.com/claude-code
```

- Images with alt text: `![description](path)`

## Tables

- Use only when data is truly tabular
- Align separators for readability:

```
| Name  | Role    |
|-------|---------|
| Alice | Backend |
| Bob   | Frontend|
```

- Prefer lists over single-column tables

## Misc

- Horizontal rules: `---` with blank lines around
- No HTML in markdown unless absolutely unavoidable
- UTF-8 encoding
- File ends with single newline
