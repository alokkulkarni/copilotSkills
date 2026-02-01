# GitHub Copilot Skills - Custom Agents & Instructions

A comprehensive collection of custom GitHub Copilot agents and coding instruction files designed to automate code reviews, test generation, infrastructure management, and development workflows across multiple programming languages and platforms.

## 🎯 Overview

This repository provides a complete ecosystem of specialized AI agents and standardized coding instructions that integrate seamlessly with GitHub Copilot to enhance development workflows, maintain code quality, and accelerate software delivery.

## 📁 Repository Structure

```
copilotSkills/
├── .github/
│   ├── agents/                    # Custom Copilot Agents
│   │   ├── README.md              # Agents documentation
│   │   ├── documentagent.md       # Documentation agent
│   │   ├── openapiagent.md        # OpenAPI spec generator
│   │   ├── javareviewagent.md     # Java code review
│   │   ├── swiftreviewagent.md    # Swift code review
│   │   ├── kotlinreviewagent.md   # Kotlin code review
│   │   ├── pythonreviewagent.md   # Python code review
│   │   ├── testgenerationagent.md # Test generation
│   │   ├── accessibilityauditor.md # Accessibility auditing
│   │   ├── workflowsreviewagent.md # Workflow review
│   │   ├── workflowgeneratoragent.md # Workflow generation
│   │   ├── terraform-generator.md  # Terraform code generation
│   │   ├── terraform-reviewer.md   # Terraform code review
│   │   ├── test-review-agent.md    # Test code review
│   │   └── java-pair-programmer.md # Java pair programmer
│   │
│   └── copilot/                   # Instruction Files
│       ├── README.md              # Instructions documentation
│       ├── INDEX.md               # Complete index
│       ├── SUMMARY.md             # Quick reference
│       ├── code-review-instructions.md       # Generic review
│       ├── java-review-instructions.md       # Java standards
│       ├── swift-review-instructions.md      # Swift standards
│       ├── kotlin-review-instructions.md     # Kotlin standards
│       ├── python-review-instructions.md     # Python standards
│       ├── api-review-instructions.md        # API standards
│       ├── bdd-testing-instructions.md       # BDD testing
│       ├── generic-testing-instructions.md   # Testing standards
│       ├── github-actions-instructions.md    # Workflow standards
│       └── terraform-coding-instructions.md  # Terraform standards
│
└── README.md                      # This file
```

## 🤖 Available Agents

### Code Review Agents
| Agent | Purpose | Languages/Tech |
|-------|---------|----------------|
| **javareviewagent** | Comprehensive Java code review with RAG reporting | Java, Spring Boot, Jakarta EE |
| **swiftreviewagent** | Swift application review for iOS/macOS/watchOS/tvOS | Swift, SwiftUI, UIKit |
| **kotlinreviewagent** | Kotlin review for Android and Spring applications | Kotlin, Android, Spring |
| **pythonreviewagent** | Python code review for apps/APIs/scripts | Python, Flask, FastAPI, Django |

### Infrastructure & DevOps Agents
| Agent | Purpose | Tech Stack |
|-------|---------|------------|
| **terraform-generator** | Generate Terraform infrastructure code | AWS, Azure, GCP, OpenShift |
| **terraform-reviewer** | Review Terraform configurations | All Terraform providers |
| **workflowgeneratoragent** | Create GitHub Actions workflows | GitHub Actions |
| **workflowsreviewagent** | Review GitHub Actions workflows | GitHub Actions |

### Documentation & API Agents
| Agent | Purpose | Scope |
|-------|---------|-------|
| **documentagent** | Review and update project documentation | README, CONTRIBUTING, LICENSE, CODEOWNERS |
| **openapiagent** | Generate OpenAPI specifications | REST, GraphQL, gRPC APIs |

### Testing Agents
| Agent | Purpose | Testing Types |
|-------|---------|---------------|
| **testgenerationagent** | Generate comprehensive test suites | Unit, Integration, BDD |
| **test-review-agent** | Review test code quality and coverage | All test types |
| **accessibilityauditor** | Audit accessibility compliance | Mobile (iOS/Android), Web |

### Development Agents
| Agent | Purpose | Technology |
|-------|---------|------------|
| **java-pair-programmer** | AI pair programmer for Java development | Java, Spring Boot, frameworks |

## 📋 Instruction Files

### Language-Specific Standards
- **`java-review-instructions.md`** - Java coding standards, OOP, Spring Boot, JPA
- **`swift-review-instructions.md`** - Swift standards, SwiftUI, UIKit, memory management
- **`kotlin-review-instructions.md`** - Kotlin standards, coroutines, Java interop
- **`python-review-instructions.md`** - Python standards, PEP compliance, async patterns

### Generic Standards
- **`code-review-instructions.md`** - Language-agnostic review guidelines
- **`api-review-instructions.md`** - REST/GraphQL/gRPC API design standards
- **`generic-testing-instructions.md`** - Unit/Integration/Exploratory testing
- **`bdd-testing-instructions.md`** - BDD and Gherkin standards

### Infrastructure & Workflow Standards
- **`terraform-coding-instructions.md`** - Terraform best practices
- **`github-actions-instructions.md`** - GitHub Actions workflow standards

## 🚀 Quick Start

### Using Agents

Reference agents in GitHub Copilot Chat:

```bash
# Code Review
@javareviewagent review PR #123
@swiftreviewagent review PR #456 with requirements from JIRA-789

# Test Generation
@testgenerationagent generate tests for feature X
@testgenerationagent create unit tests for service classes

# Infrastructure
@terraform-generator create AWS infrastructure for microservices
@terraform-reviewer review infrastructure code

# Documentation
@documentagent Review all documentation files
@openapiagent Generate OpenAPI specification

# Workflows
@workflowgeneratoragent create CI workflow for Java project
@workflowsreviewagent review workflows

# Pair Programming
@java-pair-programmer implement feature from JIRA-123
```

### Using Instructions

Reference instruction files in prompts:

```bash
# Code Review
"Review this code following .github/copilot/java-review-instructions.md"

# Testing
"Generate tests following .github/copilot/bdd-testing-instructions.md"

# Infrastructure
"Create Terraform modules following .github/copilot/terraform-coding-instructions.md"
```

## 🎨 Key Features

### RAG (Red-Amber-Green) Reporting
All review agents provide categorized findings:
- 🔴 **RED**: Critical issues - **MUST FIX** (security, crashes, data loss)
- 🟠 **AMBER**: Important issues - **SHOULD FIX** (quality, performance, standards)
- 🟢 **GREEN**: Suggestions - **NICE TO HAVE** (style, optimizations)

### Context Awareness
- Agents maintain context across multiple review iterations
- Integration with Jira/Confluence for requirements tracking
- Automatic report generation in `<working-directory>/reviews/` folder

### Think-Plan-Execute-Reflect Pattern
Generator agents follow a structured approach:
1. **Think**: Analyze requirements and constraints
2. **Plan**: Design solution architecture
3. **Execute**: Generate code/configurations
4. **Reflect**: Validate and refine output

### Production-Ready Standards
- Latest stable versions of languages and frameworks
- Security best practices built-in
- Comprehensive validation and error handling
- Industry-standard patterns and conventions

## 📊 Use Cases

### Development Teams
- **Code Review Automation**: Consistent, comprehensive PR reviews
- **Test Coverage**: Automated test generation and coverage analysis
- **Pair Programming**: AI-assisted feature development
- **Standards Compliance**: Enforce coding standards across team

### DevOps/Platform Teams
- **Infrastructure as Code**: Generate and review Terraform configurations
- **CI/CD Pipelines**: Create and validate GitHub Actions workflows
- **Security**: Automated security scanning and best practice validation

### QA/Test Engineers
- **Test Automation**: Generate BDD scenarios and test suites
- **Test Review**: Validate test quality and coverage
- **Accessibility**: Comprehensive accessibility auditing

### Technical Writers
- **Documentation**: Automated documentation review and updates
- **API Specs**: Generate OpenAPI specifications from code
- **Compliance**: Ensure CONTRIBUTING, LICENSE, CODEOWNERS are up-to-date

## 🔧 Configuration

### Agent YAML Frontmatter
All agents use standardized YAML configuration:

```yaml
---
name: agent-name
description: Brief description of agent purpose
tools: ["read", "search", "edit", "github"]
mcp_servers: ["@atlassian/jiramcpserver"]
---
```

### Instruction File Structure
Instructions follow a checklist-based approach:
- ✅ Standards and best practices
- ✅ Security requirements
- ✅ Performance considerations
- ✅ Common anti-patterns to avoid
- ✅ Language/framework-specific guidelines

## 📈 Benefits

### Quality Improvements
- Consistent code review standards
- Reduced security vulnerabilities
- Better test coverage
- Improved documentation quality

### Productivity Gains
- Faster code reviews (automated initial pass)
- Accelerated test creation
- Quick infrastructure provisioning
- Automated workflow generation

### Knowledge Sharing
- Codified best practices
- Onboarding aid for new developers
- Standardized team conventions
- Living documentation

## 🛠️ Best Practices

### Using Review Agents
1. Run agent reviews before human reviews
2. Address RED issues immediately
3. Plan AMBER fixes in backlog
4. Consider GREEN suggestions for refactoring sprints
5. Store review reports for audit trails

### Using Generator Agents
1. Provide clear requirements from Jira/Confluence
2. Review generated code/configs before committing
3. Validate executability of generated artifacts
4. Maintain generated code as you would hand-written code

### Maintaining Standards
1. Keep instruction files up-to-date with latest practices
2. Review and update agent configurations regularly
3. Collect feedback from team members
4. Iterate based on real-world usage

## 🔒 Security Considerations

All agents follow security best practices:
- No hardcoded credentials or secrets
- Parameterized and externalized configurations
- Latest stable versions with security patches
- Validation of inputs and outputs
- Proper exception handling
- Secrets management through secure channels

## 📝 Contributing

To add or improve agents and instructions:

1. **Test Thoroughly**: Validate with diverse scenarios
2. **Document Changes**: Update relevant README files
3. **Follow Standards**: Align with existing patterns
4. **Review Process**: Have changes reviewed by team
5. **Version Control**: Use semantic versioning for major updates

## 📚 Documentation

- **[Agents README](.github/agents/README.md)** - Detailed agent documentation
- **[Instructions README](.github/copilot/README.md)** - Instruction file details
- **[Instructions INDEX](.github/copilot/INDEX.md)** - Complete navigation guide
- **[Instructions SUMMARY](.github/copilot/SUMMARY.md)** - Quick reference

## 🔗 Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Custom Agents Tutorial](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents)
- [Custom Instructions Guide](https://docs.github.com/en/copilot/customizing-copilot/creating-custom-instructions-for-github-copilot)

## 📄 License

These guidelines and agents are provided as-is for use within your organization. Adapt as needed for your specific requirements.

## 🤝 Support

For issues or questions:
1. Check relevant README files in `.github/agents/` or `.github/copilot/`
2. Review GitHub Copilot documentation
3. Test with simpler prompts first
4. Validate agent configurations and file patterns

---

**Version**: 1.0  
**Last Updated**: 2026-02-01  
**Framework**: GitHub Copilot Skills  
**Maintained By**: Development Team
