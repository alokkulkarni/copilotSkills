# Pull Request Review Guidelines

## Purpose
This document provides industry-standard guidelines for reviewing pull requests (PRs) to ensure code quality, maintainability, and adherence to best practices across all projects.

---

## PR Description Requirements

### 1. **Title Standards**
- **Clear and Concise**: Use imperative mood (e.g., "Add user authentication", not "Added user authentication")
- **Ticket Reference**: Include ticket/issue number (e.g., "[JIRA-123] Add user authentication")
- **Type Prefix**: Use conventional commit prefixes:
  - `feat:` - New feature
  - `fix:` - Bug fix
  - `refactor:` - Code refactoring
  - `docs:` - Documentation changes
  - `test:` - Test additions/modifications
  - `chore:` - Build/tooling changes
  - `perf:` - Performance improvements
  - `style:` - Code style changes
  - `ci:` - CI/CD changes

### 2. **Description Content (Mandatory)**

#### **Summary**
- Brief overview of what the PR does (2-3 sentences)
- Clear explanation of the problem being solved
- Context for why this change is needed

#### **Changes Made**
- Bullet-point list of key changes
- Mention files/modules affected
- Highlight architectural or design decisions
- Note any breaking changes

#### **Type of Change**
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Refactoring (no functional changes)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Security fix

#### **Related Issues/Tickets**
- Link to Jira, GitHub Issues, or other tracking systems
- Use keywords: `Fixes #123`, `Closes #456`, `Relates to #789`
- Include Confluence/documentation links if applicable

#### **Testing Performed**
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] Test coverage percentage (if applicable)
- Describe test scenarios and edge cases covered
- Include steps to reproduce/test the changes

#### **Dependencies**
- List any new dependencies added
- Note version upgrades or downgrades
- Mention if PR depends on other PRs
- Highlight potential conflicts with other work

#### **Deployment Notes**
- Environment variables changes
- Configuration updates required
- Database migrations needed
- Infrastructure changes
- Feature flags or toggles
- Rollback procedures

#### **Screenshots/Videos** (if UI changes)
- Before/after comparisons
- Multiple viewports (desktop, tablet, mobile)
- Different browsers (if applicable)
- Accessibility testing screenshots

#### **Performance Impact**
- Expected performance improvements/degradations
- Benchmark results (if applicable)
- Resource usage changes (memory, CPU)

#### **Security Considerations**
- Security implications of changes
- Vulnerability fixes
- Authentication/authorization changes
- Data privacy impacts

#### **Documentation Updates**
- [ ] README updated
- [ ] API documentation updated
- [ ] Inline code comments added
- [ ] Architecture diagrams updated
- [ ] Changelog updated

---

## PR Review Checklist

### **Code Quality** 🔴 RED (Critical)
- [ ] Code follows project coding standards
- [ ] No hardcoded credentials, API keys, or secrets
- [ ] No sensitive data exposed in logs or responses
- [ ] Error handling is comprehensive and appropriate
- [ ] Input validation is performed
- [ ] No SQL injection or XSS vulnerabilities
- [ ] Proper exception handling (no empty catch blocks)
- [ ] No memory leaks or resource leaks
- [ ] Thread-safety considered for concurrent code
- [ ] No use of deprecated APIs or libraries

### **Functionality** 🔴 RED (Critical)
- [ ] Code does what the PR description claims
- [ ] All acceptance criteria met
- [ ] Edge cases handled appropriately
- [ ] No regression introduced
- [ ] Breaking changes are documented and justified
- [ ] Feature flags used for risky changes (if applicable)

### **Testing** 🔴 RED (Critical)
- [ ] Unit tests included and passing
- [ ] Integration tests included (if applicable)
- [ ] Test coverage meets project standards (typically >80%)
- [ ] Tests cover happy path and error scenarios
- [ ] No flaky tests introduced
- [ ] Existing tests still passing
- [ ] Manual testing evidence provided

### **Security** 🔴 RED (Critical)
- [ ] No hardcoded passwords, tokens, or keys
- [ ] Secrets managed through secure vaults/managers
- [ ] Authentication and authorization properly implemented
- [ ] Input sanitization and validation present
- [ ] No exposure of sensitive data in logs
- [ ] HTTPS/TLS used for sensitive communications
- [ ] Proper CORS configuration
- [ ] Rate limiting considered (if API)
- [ ] SQL injection prevention
- [ ] XSS prevention

### **Performance** 🟡 AMBER (Important)
- [ ] No N+1 query problems
- [ ] Database queries optimized (indexes, projections)
- [ ] Caching strategy considered
- [ ] Pagination implemented for large datasets
- [ ] No unnecessary API calls
- [ ] Asynchronous processing for long-running tasks
- [ ] Resource cleanup (connections, files, streams)
- [ ] No performance regression

### **Maintainability** 🟡 AMBER (Important)
- [ ] Code is readable and self-explanatory
- [ ] Appropriate comments for complex logic
- [ ] No code duplication (DRY principle)
- [ ] Functions/methods have single responsibility
- [ ] Proper separation of concerns
- [ ] Magic numbers replaced with named constants
- [ ] Consistent naming conventions
- [ ] Appropriate use of design patterns
- [ ] Code complexity is reasonable (cyclomatic complexity)

### **Documentation** 🟡 AMBER (Important)
- [ ] README updated if needed
- [ ] API documentation updated
- [ ] Public methods/classes documented
- [ ] Inline comments for complex logic
- [ ] CHANGELOG updated
- [ ] Architecture documentation updated
- [ ] Deployment guide updated
- [ ] Migration guide for breaking changes

### **Configuration & Dependencies** 🟡 AMBER (Important)
- [ ] No unnecessary dependencies added
- [ ] Dependencies use latest stable versions
- [ ] No security vulnerabilities in dependencies
- [ ] Configuration changes documented
- [ ] Environment variables documented
- [ ] Default values provided for configurations
- [ ] Backward compatibility maintained

### **Git Hygiene** 🟢 GREEN (Best Practice)
- [ ] Commits are logical and atomic
- [ ] Commit messages follow conventional commits
- [ ] No merge conflicts
- [ ] Branch up to date with target branch
- [ ] No unnecessary files committed (logs, IDE files)
- [ ] .gitignore properly configured
- [ ] Commit history is clean (no WIP commits)

### **Code Style** 🟢 GREEN (Best Practice)
- [ ] Consistent indentation
- [ ] Line length within limits
- [ ] Linter rules passing
- [ ] Formatter applied
- [ ] No commented-out code
- [ ] No TODO/FIXME without tickets
- [ ] Consistent brace/bracket style

### **Accessibility** 🟢 GREEN (Best Practice - if UI)
- [ ] Semantic HTML used
- [ ] ARIA labels present where needed
- [ ] Keyboard navigation supported
- [ ] Color contrast meets WCAG standards
- [ ] Screen reader compatible
- [ ] Focus indicators visible

### **Internationalization** 🟢 GREEN (Best Practice)
- [ ] No hardcoded strings (use i18n)
- [ ] Date/time formatting localized
- [ ] Currency formatting localized
- [ ] Number formatting localized
- [ ] RTL support considered

---

## Review Severity Levels

### 🔴 **RED - Critical (Must Fix)**
Issues that **MUST** be resolved before merging:
- Security vulnerabilities
- Data loss or corruption risks
- Breaking changes without proper justification
- Missing critical functionality
- Test failures
- Production incidents likely
- Legal/compliance violations

### 🟡 **AMBER - Important (Should Fix)**
Issues that **SHOULD** be resolved but may be deferred with justification:
- Performance concerns
- Maintainability issues
- Missing documentation
- Incomplete test coverage
- Technical debt
- Code smells
- Non-critical bugs

### 🟢 **GREEN - Nice to Have (Optional)**
Suggestions for improvement (author's discretion):
- Code style preferences
- Alternative implementations
- Future enhancements
- Minor optimizations
- Naming suggestions
- Additional tests

---

## Review Best Practices

### **For Reviewers**
1. **Be Constructive**: Provide actionable feedback, not just criticism
2. **Be Specific**: Reference specific lines and provide examples
3. **Ask Questions**: Seek to understand before judging
4. **Acknowledge Good Work**: Praise good solutions and patterns
5. **Review Promptly**: Respond within 24 hours when possible
6. **Test Locally**: Pull and test changes when feasible
7. **Focus on Impact**: Prioritize critical issues over style
8. **Suggest, Don't Demand**: Use "Consider..." or "What about..."
9. **Be Respectful**: Critique code, not people
10. **Check for Patterns**: Look for systemic issues, not just symptoms

### **For Authors**
1. **Self-Review First**: Review your own PR before requesting reviews
2. **Keep PRs Small**: Aim for <400 lines changed
3. **Single Responsibility**: One feature/fix per PR
4. **Provide Context**: Write clear descriptions and comments
5. **Respond Timely**: Address feedback within 24-48 hours
6. **Ask for Clarification**: If feedback is unclear, ask
7. **Accept Feedback Gracefully**: It's about code quality, not personal
8. **Mark Conversations Resolved**: Once addressed
9. **Run All Tests**: Before requesting review
10. **Update Based on Feedback**: Don't merge with unresolved critical issues

---

## PR Size Guidelines

| Size | Lines Changed | Review Time | Recommendation |
|------|---------------|-------------|----------------|
| Tiny | 0-50 | <15 min | ✅ Ideal |
| Small | 51-200 | 15-30 min | ✅ Good |
| Medium | 201-400 | 30-60 min | ⚠️ Acceptable |
| Large | 401-800 | 1-2 hours | ⚠️ Consider splitting |
| Huge | 800+ | 2+ hours | 🔴 Must split |

**Exception**: Generated code, migrations, test data, documentation may exceed limits.

---

## Automated Checks (Should Pass Before Review)

- [ ] CI/CD pipeline passes
- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Linting rules passing
- [ ] Code formatting applied
- [ ] Security scanning passed
- [ ] Dependency vulnerability scanning passed
- [ ] Code coverage threshold met
- [ ] Build succeeds
- [ ] No merge conflicts

---

## Special Review Considerations

### **Database Changes**
- [ ] Migration scripts tested (up and down)
- [ ] Index strategy reviewed
- [ ] Backward compatibility ensured
- [ ] Rollback plan documented
- [ ] Performance impact assessed

### **API Changes**
- [ ] API versioning used if breaking
- [ ] OpenAPI/Swagger documentation updated
- [ ] Backward compatibility maintained
- [ ] Rate limiting reviewed
- [ ] Error responses standardized

### **Configuration Changes**
- [ ] Environment-specific configurations externalized
- [ ] Secrets not hardcoded
- [ ] Default values sensible
- [ ] Documentation updated

### **Third-Party Integrations**
- [ ] Error handling for external failures
- [ ] Timeouts configured
- [ ] Retry logic implemented
- [ ] Circuit breaker pattern considered
- [ ] Fallback behavior defined

---

## Review Time SLA

| Priority | Initial Response | Final Review |
|----------|------------------|--------------|
| Critical/Hotfix | 2 hours | 4 hours |
| High | 8 hours | 24 hours |
| Medium | 24 hours | 48 hours |
| Low | 48 hours | 72 hours |

---

## Post-Review Actions

### **Before Merging**
- [ ] All critical feedback addressed
- [ ] All conversations resolved
- [ ] Required approvals obtained (typically 2+)
- [ ] CI/CD passing
- [ ] Branch up to date with target
- [ ] Squash/rebase if needed

### **After Merging**
- [ ] Delete feature branch
- [ ] Update related tickets
- [ ] Monitor deployment
- [ ] Update documentation
- [ ] Notify stakeholders
- [ ] Close related issues

---

## Common Anti-Patterns to Avoid

### 🚫 **In PRs**
- Mixing refactoring with feature work
- Including unrelated changes
- Large PRs (>800 lines)
- No description or context
- "Fix" as PR title
- Committing directly to main/master
- Force pushing after review started

### 🚫 **In Reviews**
- Nitpicking style instead of using linters
- Bikeshedding (debating trivial details)
- Scope creep ("Why not also add...")
- Requesting changes without explanation
- Ignoring architectural concerns
- Rubber-stamping without reading
- Personal attacks or unconstructive criticism

---

## Templates

### **PR Description Template**
```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Refactoring

## Related Issues
Fixes #123

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Unit tests added
- [ ] Manual testing performed

## Deployment Notes
None

## Screenshots
N/A
```

### **Review Comment Template**
```markdown
**Severity**: 🔴 RED / 🟡 AMBER / 🟢 GREEN

**Issue**: [Describe the issue]

**Reason**: [Explain why it's a problem]

**Suggestion**: [Provide actionable fix]

**Example**: [Show code example if helpful]
```

---

## Tools for PR Reviews

### **Recommended Tools**
- GitHub Actions / GitLab CI for automation
- SonarQube / CodeClimate for code quality
- Snyk / Dependabot for security scanning
- CodeCov for coverage tracking
- Danger for automated review comments
- Prettier / ESLint for code formatting
- Conventional Commits for commit standards

---

## Metrics to Track

- Average PR size (lines changed)
- Time to first review
- Time to merge
- Number of review cycles
- Defects found in review vs production
- Review participation rate
- Code coverage trends

---

## References

- [Google's Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [GitHub's PR Best Practices](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)

---

## Checklist Summary

✅ **Use this checklist for every PR review to ensure comprehensive coverage**

**Critical (Must Fix)**: Security, functionality, testing
**Important (Should Fix)**: Performance, maintainability, documentation  
**Nice to Have (Optional)**: Style preferences, optimizations

**Goal**: Ship high-quality, secure, maintainable code that delivers value
