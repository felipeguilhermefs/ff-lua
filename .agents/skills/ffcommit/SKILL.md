---
name: ffcommit
description: Create well-formatted git commits following conventional commit standards.
---

# Git Commit Skill

When writing a git commit message, you MUST follow the Conventional Commits specification. 

## Format
```
<type>(<scope>): <description>

<body>

```

## Allowed Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

## Instructions
1. Analyze staged changes with `git diff --staged` to determine the primaty `type`.
2. Identify the `scope` if applicable (e.g., mostly changed component).
3. Write a concise `description` in imperative mood (e.g., "add feature" not "added feature").
4. Write a summary of changes in bullet point style in `body`.

## Example
```
feat(auth): add password reset functionality

- Add forgot password form
- Implement email verification flow
- Add password reset endpoint
```

