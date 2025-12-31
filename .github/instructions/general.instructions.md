---
applyTo:
  - "**/*"
---

# General Instructions (All Files)

These instructions apply to all files in the repository.

## General Principles

1. **Consistency**: Follow existing patterns in the codebase
2. **Clarity**: Write self-documenting code; use meaningful names
3. **Simplicity**: Prefer simple solutions over clever ones
4. **Security**: Never commit secrets; validate all inputs
5. **Testing**: Write tests for new functionality and bug fixes
6. **Documentation**: Update docs when changing public APIs

## File Organization

- Group related files together
- Co-locate tests with code where possible
- Use meaningful directory names
- Keep files focused on a single responsibility

## Naming Conventions

- Use descriptive names that reveal intent
- Avoid abbreviations unless they're widely understood
- Be consistent with existing naming patterns in the project

## Comments and Documentation

- Write code that doesn't need comments
- Use comments to explain "why", not "what"
- Keep comments up to date when code changes
- Document public APIs with clear descriptions

## Version Control

- Make atomic commits (one logical change per commit)
- Write clear commit messages in present tense
- Don't commit generated files or dependencies
- Never commit secrets, API keys, or passwords

## Error Handling

- Handle errors appropriately for the context
- Log errors with sufficient context for debugging
- Provide user-friendly error messages
- Don't swallow exceptions silently

## Performance

- Optimize only when necessary (measure first)
- Use async/await for I/O operations
- Be mindful of N+1 queries in database operations
- Cache appropriately when beneficial

## Security

- Validate all user inputs
- Use parameterized queries (never string concatenation for SQL)
- Sanitize data for display (prevent XSS)
- Use HTTPS for external communications
- Follow principle of least privilege

## Accessibility

- Use semantic HTML elements
- Provide alt text for images
- Ensure keyboard navigation works
- Use sufficient color contrast
