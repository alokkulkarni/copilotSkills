# Generic Code Review Guidelines

## Purpose
This document provides language-agnostic code review guidelines to ensure code quality, security, maintainability, and adherence to best practices across all repositories.

---

## 1. Security Review

### 1.1 Credentials and Secrets
- **CRITICAL**: No hardcoded credentials, API keys, passwords, tokens, or secrets in code
- Check for:
  - Database connection strings with embedded passwords
  - API keys (AWS, Azure, Google Cloud, third-party services)
  - Private keys, certificates, or cryptographic secrets
  - OAuth tokens or session secrets
  - Email/SMTP credentials
- **Action**: Use environment variables, secret management services, or secure vaults
- Verify `.gitignore` excludes sensitive files (`.env`, `credentials.json`, `*.key`, `*.pem`)

### 1.2 Input Validation and Sanitization
- All user inputs must be validated and sanitized
- Check for proper validation of:
  - File uploads (type, size, content validation)
  - Query parameters and form data
  - API request payloads
  - Command-line arguments
- Prevent injection attacks (SQL, command, code injection)

### 1.3 Authentication and Authorization
- Verify proper authentication checks are in place
- Ensure authorization is validated before accessing resources
- Check for privilege escalation vulnerabilities
- Verify session management is secure (timeouts, secure flags)

### 1.4 Data Exposure
- No sensitive data in logs, error messages, or debug output
- Verify proper data encryption for sensitive information
- Check API responses don't leak internal system information
- Ensure proper handling of Personally Identifiable Information (PII)

### 1.5 Dependencies and Vulnerabilities
- Review third-party dependencies for known vulnerabilities
- Check for outdated or deprecated dependencies
- Verify dependency sources are trusted

### 1.6 Cryptography
- Use industry-standard cryptographic libraries
- No custom/weak encryption implementations
- Verify proper key management
- Check for weak hashing algorithms (MD5, SHA-1)

---

## 2. Code Quality and Maintainability

### 2.1 Code Clarity and Readability
- Code should be self-documenting with clear intent
- Complex logic requires explanatory comments
- Avoid overly clever or obscure implementations
- Functions/methods should do one thing well (Single Responsibility)

### 2.2 Code Duplication
- Identify and flag duplicated code blocks
- Suggest extracting common logic into reusable functions/modules
- Check for copy-paste programming patterns

### 2.3 Error Handling
- All error cases must be handled appropriately
- No silent failures or swallowed exceptions
- Error messages should be meaningful and actionable
- Verify proper cleanup in error paths (resource deallocation)

### 2.4 Resource Management
- Verify proper cleanup of resources (files, connections, memory)
- Check for resource leaks (unclosed streams, connections)
- Validate proper disposal patterns are used
- Review timeout and retry logic for external calls

### 2.5 Performance Considerations
- Flag obvious performance issues (N+1 queries, nested loops)
- Check for inefficient data structures or algorithms
- Verify bulk operations are used where appropriate
- Review caching strategies

---

## 3. Naming Conventions

### 3.1 General Naming Principles
- Names should be descriptive and reveal intent
- Avoid abbreviations unless widely understood
- Use consistent naming throughout the codebase
- Avoid single-letter variables except for loops and mathematical contexts

### 3.2 File and Directory Naming
- Use consistent casing convention (kebab-case, snake_case, or PascalCase)
- File names should reflect their content/purpose
- Avoid spaces and special characters in file names
- Group related files logically in directories

### 3.3 Functions and Methods
- Use verb phrases for functions/methods (`getUserById`, `calculateTotal`)
- Names should describe what the function does
- Boolean functions should use prefixes like `is`, `has`, `can`, `should`
- Keep names concise but not cryptic

### 3.4 Variables and Constants
- Use nouns or noun phrases for variables
- Constants should be clearly identifiable (UPPER_CASE convention common)
- Boolean variables should use descriptive names (`isActive`, `hasPermission`)
- Avoid negated boolean names (`isNotActive` → prefer `isInactive`)

### 3.5 Classes and Modules
- Use nouns or noun phrases
- Names should represent the entity or concept
- Avoid generic names (`Manager`, `Helper`, `Util` without context)

---

## 4. Architecture and Design

### 4.1 Separation of Concerns
- Verify proper separation between layers (presentation, business, data)
- Check for tight coupling between components
- Validate dependency flow (avoid circular dependencies)

### 4.2 Modularity and Reusability
- Code should be modular and composable
- Functions should be small and focused
- Verify proper abstraction levels
- Check for opportunities to extract reusable components

### 4.3 Configuration Management
- Configuration should be externalized (not hardcoded)
- Environment-specific settings should be separate
- Verify configuration validation on startup

### 4.4 Parameterization and Externalization
- **CRITICAL**: No hardcoded values - all should be parameterized
- Check for:
  - Hardcoded file paths (absolute or relative)
  - Hardcoded URLs, endpoints, or hostnames
  - Hardcoded port numbers
  - Hardcoded database names or connection details
  - Hardcoded text/messages (should support i18n/localization)
  - Hardcoded timeouts, thresholds, or limits
  - Hardcoded feature flags or business rules
  - Hardcoded email addresses or usernames
- **Action**: Use configuration files, environment variables, or property files
- Values should be:
  - Externalized to configuration/property files
  - Configurable per environment (dev, test, prod)
  - Documented with default values and acceptable ranges
  - Validated at startup or runtime
- Magic strings and numbers should be extracted to named constants

### 4.5 API Design
- APIs should be consistent and intuitive
- Check for proper versioning strategy
- Verify backward compatibility considerations
- Validate proper HTTP methods and status codes

---

## 5. Testing and Quality Assurance

### 5.1 Test Coverage
- Critical paths should have test coverage
- Edge cases and error conditions should be tested
- Verify tests are meaningful (not just for coverage metrics)

### 5.2 Test Quality
- Tests should be independent and isolated
- Test names should clearly describe what is being tested
- Tests should be maintainable and not brittle
- Avoid test duplication

---

## 6. Documentation

### 6.1 Code Documentation Standards

**Class-Level Documentation**:
- [ ] Every public class has comprehensive documentation
- [ ] Class purpose and responsibilities clearly explained
- [ ] Public methods and their purposes documented
- [ ] Usage examples provided for complex classes
- [ ] Dependencies and relationships documented
- [ ] Thread-safety and concurrency considerations noted (if applicable)

**Method/Function Documentation**:
- [ ] All public methods have complete documentation
- [ ] Method purpose clearly stated
- [ ] Parameters documented (name, type, purpose, constraints)
- [ ] Return values documented (type, possible values, meaning)
- [ ] Exceptions/errors documented (when thrown, why, how to handle)
- [ ] Side effects clearly noted
- [ ] Examples provided for non-obvious usage
- [ ] Preconditions and postconditions stated (if applicable)

**Code Comments**:
- [ ] Complex algorithms have explanatory comments
- [ ] Non-obvious business logic explained
- [ ] "Why" is documented, not just "what"
- [ ] TODOs include ticket reference and assignee
- [ ] FIXMEs explained with context
- [ ] Magic numbers extracted to named constants with documentation
- [ ] Workarounds and hacks explained with reasoning

**Documentation Completeness**:
- [ ] No undocumented public APIs
- [ ] All configuration options documented
- [ ] Default values and their reasoning documented
- [ ] Deprecated features marked with alternatives provided
- [ ] Version information included where relevant

### 6.2 README Documentation

**README.md Requirements**:
- [ ] Project overview and purpose clearly stated
- [ ] Prerequisites and dependencies listed
- [ ] Installation instructions complete and tested
- [ ] Configuration instructions provided
- [ ] Usage examples included
- [ ] Common use cases demonstrated
- [ ] Troubleshooting section (if applicable)
- [ ] Link to detailed documentation
- [ ] Contact information or support channels
- [ ] License information

**Setup and Getting Started**:
- [ ] Step-by-step setup instructions
- [ ] Environment setup documented
- [ ] Database setup (if applicable)
- [ ] Required environment variables listed
- [ ] Sample configuration files provided
- [ ] First-run instructions clear
- [ ] Verification steps included

**Architecture Documentation**:
- [ ] High-level architecture overview
- [ ] Component relationships explained
- [ ] Data flow documented
- [ ] Key design decisions recorded
- [ ] Technology stack listed with versions
- [ ] External dependencies documented

### 6.3 API Documentation

**For Libraries and APIs**:
- [ ] API reference complete
- [ ] Authentication/authorization documented
- [ ] Request/response formats specified
- [ ] Error codes and messages documented
- [ ] Rate limits and quotas specified (if applicable)
- [ ] Versioning strategy documented
- [ ] Migration guides for breaking changes
- [ ] Interactive examples or playground links

### 6.4 Change Documentation

**CHANGELOG.md**:
- [ ] All notable changes documented
- [ ] Organized by version
- [ ] Release dates included
- [ ] Changes categorized (Added, Changed, Deprecated, Removed, Fixed, Security)
- [ ] Breaking changes clearly marked

**Migration Guides**:
- [ ] Breaking changes have migration instructions
- [ ] Code examples showing before/after
- [ ] Timeline for deprecations
- [ ] Support for upgrade path

### 6.5 Contributing Guidelines

**CONTRIBUTING.md** (if open source or team project):
- [ ] Code style guidelines
- [ ] Branch naming conventions
- [ ] Commit message format
- [ ] Pull request process
- [ ] Testing requirements
- [ ] Code review process
- [ ] Communication channels

### 6.6 Documentation Quality Checklist

**Review Criteria**:
- [ ] Documentation is accurate (matches implementation)
- [ ] Documentation is up-to-date
- [ ] Examples actually work
- [ ] No broken links
- [ ] Consistent formatting and style
- [ ] Clear and concise language
- [ ] Appropriate level of detail
- [ ] No assumed knowledge (or clearly stated)
- [ ] Diagrams and visuals where helpful
- [ ] Searchable and well-organized

---

## 7. Version Control and Git Practices

### 7.1 Commit Quality
- Commits should be atomic (one logical change)
- Commit messages should be clear and descriptive
- Avoid committing commented-out code
- Check for accidentally committed files (build artifacts, IDE configs)

### 7.2 Branch Strategy
- Verify changes are on appropriate branch
- Check for merge conflicts or improper merges

---

## 8. Accessibility and Inclusivity

### 8.1 User Interface Considerations
- Check for accessibility features where applicable
- Verify responsive design considerations
- Validate keyboard navigation support

### 8.2 Inclusive Language
- Use inclusive and professional language in code and comments
- Avoid slang, profanity, or culturally insensitive terms
- Use industry-standard terminology

---

## 9. Compliance and Legal

### 9.1 Licensing
- Verify proper license headers if required
- Check third-party dependency licenses are compatible
- Ensure no copyrighted code is included without permission

### 9.2 Data Privacy
- Verify GDPR/CCPA compliance where applicable
- Check for proper consent mechanisms
- Validate data retention policies are followed

---

## 10. Review Checklist Summary

### Critical (Must Fix)
- [ ] No hardcoded secrets or credentials
- [ ] No hardcoded paths, URLs, or configuration values
- [ ] No security vulnerabilities (injection, XSS, etc.)
- [ ] Proper error handling in place
- [ ] No resource leaks
- [ ] Breaking changes are documented
- [ ] All values properly parameterized and externalized

### High Priority (Should Fix)
- [ ] Code duplication is minimized
- [ ] Naming conventions are clear and consistent
- [ ] Proper input validation
- [ ] Test coverage for critical paths
- [ ] Documentation for complex logic
- [ ] **All public classes have comprehensive documentation**
- [ ] **All public methods/functions documented**
- [ ] **README.md is up-to-date and complete**
- [ ] **Class-level documentation explains purpose and usage**

### Medium Priority (Consider Fixing)
- [ ] Performance optimizations identified
- [ ] Code simplification opportunities
- [ ] Better abstraction opportunities
- [ ] Additional edge case testing

### Low Priority (Nice to Have)
- [ ] Minor style improvements
- [ ] Additional documentation
- [ ] Refactoring opportunities

---

## Review Process

1. **Security First**: Always start with security review
2. **Functionality**: Verify the code does what it's supposed to do
3. **Quality**: Assess code quality, maintainability, and design
4. **Tests**: Review test coverage and quality
5. **Documentation**: Verify adequate documentation exists
6. **Best Practices**: Ensure adherence to coding standards

## Review Tone and Approach

- Be constructive and specific in feedback
- Explain the "why" behind suggestions
- Distinguish between blocking issues vs. suggestions
- Recognize good practices when present
- Ask questions to understand intent when unclear

---

**Note**: These guidelines should be adapted based on team standards, project requirements, and specific compliance needs.
