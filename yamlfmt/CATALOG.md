---
title: yamlfmt
description: An extensible command-line tool and library to format YAML files
keywords: yamlfmt,yaml,formatter,format,lint,ci,pre-commit,google
---

# yamlfmt

yamlfmt formats YAML files. Point it at files or directories and it rewrites
them in place with consistent indentation, spacing and line breaks; run it with
`-lint` or `-dry` to check without touching anything, which makes it a drop-in
CI gate that exits non-zero when a file is not already formatted.

Behaviour is configured by a `.yamlfmt` file (or `-conf`) — indentation,
retained blank lines, line-length wrapping, document-start markers and more —
and the formatter is built on a fork of `yaml.v3` that preserves comments.

## What's included

- **yamlfmt** — the single static binary (format, `-lint`, `-dry`, `-diff`,
  `-gitignore_excludes`). No runtime dependencies.

## Links

- [yamlfmt on GitHub](https://github.com/google/yamlfmt)
- [Documentation](https://github.com/google/yamlfmt/tree/main/docs)
