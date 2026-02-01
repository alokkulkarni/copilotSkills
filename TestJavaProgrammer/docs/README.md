# Documentation

This directory contains the MkDocs documentation for the Customer Management API.

## Building the Documentation

### Prerequisites

Install MkDocs and required plugins:

```bash
pip install mkdocs-material
pip install mkdocs-git-revision-date-localized-plugin
pip install mkdocs-minify-plugin
```

### Build and Serve Locally

```bash
# From the project root (TestJavaProgrammer/)
mkdocs serve
```

Then open your browser to **http://127.0.0.1:8000**

### Build Static Site

```bash
mkdocs build
```

This creates a `site/` directory with the static HTML documentation.

## Documentation Structure

```
docs/
├── index.md                    # Home page
├── getting-started/
│   ├── installation.md         # Installation guide
│   ├── quick-start.md          # Quick start tutorial
│   └── docker.md               # Docker setup
├── user-guide/
│   ├── configuration.md        # Configuration options
│   ├── api-usage.md            # API usage examples
│   ├── pagination.md           # Pagination guide
│   └── error-handling.md       # Error handling
├── api-reference/
│   ├── overview.md             # API overview
│   ├── endpoints.md            # Endpoint documentation
│   ├── models.md               # Data models
│   └── openapi.md              # OpenAPI specification
├── development/
│   ├── architecture.md         # Architecture overview
│   ├── project-structure.md    # Project organization
│   ├── testing.md              # Testing guide
│   └── contributing.md         # Contribution guidelines
├── deployment/
│   ├── docker.md               # Docker deployment
│   └── ci-cd.md                # CI/CD pipeline
├── reference/
│   ├── changelog.md            # Version history
│   ├── faq.md                  # FAQ
│   ├── security.md             # Security guidelines
│   └── license.md              # License information
└── assets/
    ├── stylesheets/
    │   └── extra.css           # Custom CSS
    ├── javascripts/
    │   └── extra.js            # Custom JavaScript
    └── images/                 # Images and diagrams
```

## Contributing to Documentation

When adding or updating documentation:

1. Follow the existing structure and style
2. Use proper Markdown formatting
3. Include code examples where appropriate
4. Add cross-references to related pages
5. Update the navigation in `mkdocs.yml` if adding new pages
6. Test locally with `mkdocs serve` before committing
7. Check for broken links

## Documentation Standards

### Markdown Style

- Use ATX-style headers (`#` prefix)
- Use fenced code blocks with language specification
- Use tables for structured data
- Use admonitions for notes, warnings, and tips
- Use relative links for internal references

### Code Examples

Always specify the language for syntax highlighting:

````markdown
```bash
mvn spring-boot:run
```
````

### Admonitions

Use MkDocs Material admonitions:

```markdown
!!! note "Optional Title"
    This is a note.

!!! warning
    This is a warning.

!!! tip
    This is a tip.
```

### Cross-References

Use relative links:

```markdown
See the [Installation Guide](../getting-started/installation.md)
```

## Deploying Documentation

### GitHub Pages

```bash
mkdocs gh-deploy
```

This builds and deploys to the `gh-pages` branch.

### Read the Docs

Connect your GitHub repository to Read the Docs for automatic builds.

### Custom Server

Copy the `site/` directory to your web server after building.

## Troubleshooting

### MkDocs Not Found

Install MkDocs:
```bash
pip install mkdocs-material
```

### Theme Not Found

Install the Material theme:
```bash
pip install mkdocs-material
```

### Plugin Errors

Install missing plugins:
```bash
pip install mkdocs-git-revision-date-localized-plugin
pip install mkdocs-minify-plugin
```

## License

Documentation is licensed under the same terms as the project (MIT License).
