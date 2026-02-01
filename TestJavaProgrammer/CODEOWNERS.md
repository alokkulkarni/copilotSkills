# Code Owners

This file defines the code owners for the Customer Management API repository.

## Ownership Rules

| Pattern | Owner | Description |
|---------|-------|-------------|
| `*` | @alokkulkarni | Default owner for all files |
| `*.java` | @alokkulkarni | All Java source files |
| `pom.xml` | @alokkulkarni | Maven build configuration |
| `Dockerfile` | @alokkulkarni | Docker configuration |
| `.github/` | @alokkulkarni | CI/CD workflows |
| `docs/` | @alokkulkarni | Documentation |
| `src/test/` | @alokkulkarni | Test files |

## CODEOWNERS File

For GitHub to recognize code owners, create a file at `.github/CODEOWNERS` with:

```
# Default owner for everything
*       @alokkulkarni

# Java source files
*.java  @alokkulkarni

# Build configuration
pom.xml @alokkulkarni
Dockerfile @alokkulkarni

# CI/CD
.github/ @alokkulkarni

# Documentation
docs/ @alokkulkarni
*.md @alokkulkarni

# Test files
src/test/ @alokkulkarni
```

## Contact

For questions about code ownership, contact @alokkulkarni.
