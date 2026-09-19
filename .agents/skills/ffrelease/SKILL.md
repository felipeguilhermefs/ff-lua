---
name: ffrelease
description: Generate a commit message that summarizes the changes since the most recent git tag.
---

# Git Commit Skill

When writing a git commit message, you MUST follow the Conventional Commits specification.

## Format
```
release(<scope>): <description>

<body>

```

## Instructions
1. Analyze the commit messages since the most recent git tagstaged changes with `git describe --tags --abbrev=0`.
2. Identify the `scope` if applicable (e.g., mostly changed component).
3. Write a `description` using the new version you take from the *.rockspec file. (e.g., "version 0.24").
4. Write a summary of changes in bullet point style in `body`.

## Example
```
release(auth): version 0.23

- Add forgot password form
- Implement email verification flow
- Add password reset endpoint
```

