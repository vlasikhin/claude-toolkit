---
name: markdown-docs
description: README and project documentation structure. Use when writing README.md, CHANGELOG, CONTRIBUTING, or any project-level documentation. Use when user asks to "write a README", "create project docs", "document this project", or "add a CHANGELOG".
license: MIT
metadata:
  author: vlasikhin
  version: 1.0.0
---

# Markdown Docs

## README Structure

Minimal viable README in this order:

```
# Project Name

One-sentence description of what it does.

## Installation

## Usage

## License
```

Extended README — add sections as needed:

```
# Project Name

One-sentence description.

Badges (CI, version, license) — one line, no clutter.

## Installation

## Quick Start

## Usage

## Configuration

## API / Reference

## Development

## Contributing

## License
```

## Section Rules

### Project Name
- H1 = project name, not "README" or "Documentation"
- First paragraph: what it does and why, in 1-2 sentences
- No lengthy introductions

### Installation
- Shortest path to working setup
- Package manager command first: `gem install`, `go get`, `npm install`
- Build from source — second, if needed

### Usage
- Start with simplest example that does something useful
- Progress from simple to advanced
- Real-world examples over abstract ones
- Every code block should be copy-pasteable and runnable

### Configuration
- Table or list of options with defaults:

```
| Option    | Default | Description          |
|-----------|---------|----------------------|
| `timeout` | `10`    | Request timeout (sec)|
```

- Environment variables listed explicitly: `MYAPP_API_KEY`

### API / Reference
- One subsection per public method/endpoint
- Signature, params, return value, short example
- Link to full docs if separate site exists

### Development
- How to set up dev environment
- How to run tests
- How to build

## CHANGELOG

Follow [Keep a Changelog](https://keepachangelog.com):

```
## [1.2.0] - 2025-03-15

### Added
- New feature X

### Fixed
- Bug in Y

### Changed
- Updated Z behavior
```

- Categories: Added, Changed, Deprecated, Removed, Fixed, Security
- Newest version first
- Link version headers to git diffs

## General Rules

- Write for someone who has never seen the project
- No "obvious" or "simply" — if it were obvious, it wouldn't need docs
- Keep examples up to date with actual code
- Prefer showing over explaining
- English for public projects, match team language for internal
