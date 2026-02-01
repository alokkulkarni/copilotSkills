# Security Policy

## Supported Versions

The following versions of this project are currently being supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please follow responsible disclosure practices.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities.
2. Send an email to **alok@example.com** with:
   - A detailed description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Any suggested fixes (if available)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: 60 days

### Scope

The following are in scope for security reports:

- Authentication/Authorization bypasses
- Data exposure vulnerabilities
- Injection vulnerabilities (SQL, command, etc.)
- Cross-site scripting (XSS)
- Denial of service vulnerabilities
- Dependency vulnerabilities (CVEs)

### Out of Scope

- Issues in dependencies without a known CVE
- Social engineering attacks
- Physical security issues
- Issues requiring physical access

## Security Best Practices

This project follows these security practices:

- ✅ Input validation using Jakarta Bean Validation
- ✅ Non-root user in Docker containers
- ✅ No hardcoded credentials
- ✅ Dependency scanning via CodeQL
- ✅ Regular dependency updates
