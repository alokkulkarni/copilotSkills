# GitHub Copilot Skills - Instructions Summary

## Overview
This directory contains comprehensive guidelines and instructions for GitHub Copilot agents to perform code reviews and write BDD tests following industry standards.

## Statistics
- **Total Files**: 6 (5 instruction files + 1 README + 1 summary)
- **Total Lines**: 3,858 lines of guidelines
- **Total Size**: 144KB
- **Languages Covered**: Java, Kotlin, Swift, and language-agnostic patterns
- **Coverage**: Code review, testing, security, architecture, and best practices

## Files Overview

### 1. Generic Guidelines
**File**: `code-review-instructions.md` (267 lines, 8.7KB)
- Language-agnostic code review standards
- Security, quality, naming, architecture
- Testing, documentation, version control
- Accessibility and compliance

### 2. Java-Specific Guidelines
**File**: `java-review-instructions.md` (532 lines, 22KB)
- Java 8-21 features and best practices
- OOP principles, generics, annotations
- Spring Framework, JPA/Hibernate
- JVM performance, build tools, testing

### 3. Swift-Specific Guidelines
**File**: `swift-review-instructions.md` (618 lines, 25KB)
- Swift 5.5+ features (async/await, actors)
- iOS/macOS development patterns
- SwiftUI and UIKit best practices
- Memory management (ARC), concurrency

### 4. Kotlin-Specific Guidelines
**File**: `kotlin-review-instructions.md` (1,043 lines, 34KB)
- Kotlin 1.7+ features, coroutines, Flow
- Java interoperability patterns
- Spring Framework with Kotlin
- Android development (Jetpack Compose)
- Null safety, functional programming

### 5. BDD Testing Guidelines
**File**: `bdd-testing-instructions.md` (1,223 lines, 32KB)
- Behavior-Driven Development principles
- Gherkin syntax and best practices
- Given-When-Then patterns
- Test organization and data management
- CI/CD integration, living documentation
- Language-specific considerations

## Usage by Role

### For Developers
- Self-review checklist before PRs
- Language-specific coding standards
- Best practices reference
- Architecture patterns

### For QA/Test Engineers
- BDD test writing guidelines
- Test automation standards
- Scenario organization patterns
- Test data management

### For GitHub Copilot Agents
- Code review automation
- Security vulnerability detection
- Test scenario generation
- Best practice suggestions

### For Team Leads
- Code review standards
- Team training material
- Quality benchmarks
- Documentation standards

## Key Features

### Comprehensive Coverage
- ✅ 4 programming languages (Java, Kotlin, Swift + Generic)
- ✅ Multiple frameworks (Spring, Android, iOS/macOS)
- ✅ Security best practices across all languages
- ✅ Testing strategies (BDD, unit, integration, E2E)
- ✅ Architecture patterns (MVC, MVVM, VIPER, Clean)

### Industry Standards
- ✅ Based on industry best practices
- ✅ Modern language features (async/await, coroutines, etc.)
- ✅ Framework-specific patterns (Spring, SwiftUI, Jetpack Compose)
- ✅ CI/CD integration guidelines
- ✅ Living documentation approach

### Practical Checklists
- ✅ Prioritized review items (Critical, High, Medium, Low)
- ✅ Language-specific anti-patterns
- ✅ Security vulnerability checks
- ✅ Performance optimization guidelines
- ✅ Test quality metrics

## Integration Examples

### Code Review
```bash
# Generic review
gh copilot "Review this code using .github/copilot/code-review-instructions.md"

# Language-specific review
gh copilot "Review this Java class following .github/copilot/java-review-instructions.md"

# Security focus
gh copilot "Check for security issues per .github/copilot/code-review-instructions.md"
```

### BDD Test Generation
```bash
# Generate BDD scenarios
gh copilot "Write BDD scenarios for user registration following .github/copilot/bdd-testing-instructions.md"

# Review existing scenarios
gh copilot "Review this feature file using .github/copilot/bdd-testing-instructions.md"
```

### Multi-Language Projects
```bash
# Review polyglot repository
gh copilot "Review backend (Java) using java-review-instructions.md and mobile (Swift) using swift-review-instructions.md"
```

## Maintenance

### Regular Updates
- Review guidelines quarterly
- Update for new language versions
- Incorporate team feedback
- Add new patterns as discovered

### Continuous Improvement
- Track metrics on review effectiveness
- Gather developer feedback
- Update based on industry trends
- Add project-specific extensions

## Contributing

### Adding New Languages
1. Create `{language}-review-instructions.md`
2. Follow existing structure (20+ sections)
3. Include language-specific features
4. Add framework integration patterns
5. Provide comprehensive checklists
6. Update README.md

### Extending Existing Guidelines
1. Follow established format
2. Add concrete examples
3. Include code snippets
4. Document rationale for guidelines
5. Update relevant checklists

## Version History

| Version | Date       | Changes                                    |
|---------|------------|--------------------------------------------|
| 1.0     | 2026-01-31 | Initial release with 5 instruction files   |
|         |            | - Generic code review guidelines           |
|         |            | - Java-specific guidelines                 |
|         |            | - Swift-specific guidelines                |
|         |            | - Kotlin-specific guidelines               |
|         |            | - BDD testing guidelines                   |

## License
These guidelines are provided for use within your organization. Adapt as needed for your specific requirements and team standards.

---

**Generated**: 2026-01-31  
**Total Coverage**: 3,858 lines of comprehensive guidelines  
**Supported By**: GitHub Copilot CLI
