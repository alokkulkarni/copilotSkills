# GitHub Copilot Custom Agents

This directory contains custom GitHub Copilot agents with specialized skills for different aspects of software development.

## Available Agents

### 📝 Documentation Agent (`documentagent.md`)

**Purpose**: Specialized agent focused exclusively on reviewing, updating, and maintaining project documentation.

**What it does**:
- ✅ Reviews README.md, CONTRIBUTING.md, LICENSE, CHANGELOG.md
- ✅ Validates documentation completeness and accuracy
- ✅ Checks project metadata in configuration files
- ✅ Identifies broken links and outdated information
- ✅ Suggests improvements and missing sections
- ✅ Creates missing documentation files

**What it doesn't do**:
- ❌ Never modifies source code files
- ❌ Never analyzes code quality
- ❌ Never writes or modifies tests
- ❌ Never changes build configurations (only metadata)

**Usage**:
```bash
@documentagent Review all documentation files in this project
@documentagent Check if README.md is complete and up-to-date
@documentagent Validate CONTRIBUTING.md and LICENSE files
@documentagent Create missing SECURITY.md file
```

**File Patterns**:
- Includes: `*.md`, `*.txt`, `*.rst`, README, LICENSE, docs/
- Excludes: All source code files (`.java`, `.py`, `.js`, etc.)

---

### 🔌 OpenAPI Agent (`openapiagent.md`)

**Purpose**: Automatically generates and maintains OpenAPI 3.0+ specification documentation by analyzing API endpoints across any language or framework.

**What it does**:
- ✅ Analyzes REST/GraphQL/gRPC API endpoints and controllers
- ✅ Extracts request/response schemas from DTOs and models
- ✅ Documents authentication and security mechanisms
- ✅ Generates complete OpenAPI 3.0+ YAML specifications
- ✅ Includes realistic examples for all schemas
- ✅ Documents all error responses and status codes
- ✅ Creates Postman collections (optional)
- ✅ Validates specifications against OpenAPI standards

**What it doesn't do**:
- ❌ Never modifies source code files
- ❌ Never changes API implementations
- ❌ Never alters business logic
- ❌ Never modifies test files
- ❌ Never changes authentication/authorization logic

**Supported Frameworks**:
- **Java**: Spring Boot, JAX-RS, Micronaut, Quarkus
- **Python**: FastAPI, Django REST, Flask-RESTX
- **JavaScript/TypeScript**: Express, NestJS, Fastify
- **C#**: ASP.NET Core
- **Go**: Gin, Echo, Chi
- **Kotlin**: Spring Boot, Ktor
- **Swift**: Vapor
- **Ruby**: Rails, Sinatra

**Usage**:
```bash
@openapiagent Generate OpenAPI specification for all API endpoints
@openapiagent Create OpenAPI spec from REST controllers
@openapiagent Document authentication in OpenAPI format
@openapiagent Generate Swagger docs with request/response examples
@openapiagent Update openapi.yaml with new endpoints
```

**File Patterns**:
- Creates: `openapi.yaml`, `swagger.json`, `docs/api/**`
- Analyzes: Controllers, routes, DTOs, models, entities
- Excludes: Test files, build outputs, node_modules

**Reference Documentation**:
- Uses standards from `.github/copilot/api-review-instructions.md`
- Compatible with OpenAPI 3.0.3 and 3.1.0

---

### ☕ Java Review Agent (`javareviewagent.md`)

**Purpose**: Comprehensive code review agent specialized for Java applications and APIs with RAG (Red-Amber-Green) categorized reporting.

**What it does**:
- ✅ Performs production-ready code reviews of Java PRs
- ✅ Validates against generic and Java-specific coding standards
- ✅ Reviews API design and implementation quality
- ✅ Checks test coverage (unit, integration, BDD)
- ✅ Detects security vulnerabilities and best practice violations
- ✅ Integrates requirements from Jira/Confluence
- ✅ Generates detailed RAG categorized reports
- ✅ Maintains context across multiple review iterations

**What it doesn't do**:
- ❌ Never makes code changes without explicit approval
- ❌ Never approves PRs with RED (critical) issues
- ❌ Never ignores security vulnerabilities
- ❌ Never reviews non-Java files as Java code

**Supported Technologies**:
- **Frameworks**: Spring Boot, Jakarta EE, Micronaut, Quarkus
- **Build Tools**: Maven, Gradle
- **Testing**: JUnit, TestNG, Mockito, AssertJ
- **Java Versions**: 8, 11, 17, 21+

**Usage**:
```bash
@javareviewagent review PR #123
@javareviewagent review PR #456 with requirements from JIRA-789
@javareviewagent review changes in src/main/java/com/example/service/
@javareviewagent re-review PR #123 (previous review: [link])
```

**RAG Categorization**:
- 🔴 **RED**: Critical issues (security, crashes, data loss) - **MUST FIX**
- 🟠 **AMBER**: Important issues (quality, performance, standards) - **SHOULD FIX**
- 🟢 **GREEN**: Suggestions (style, minor optimizations) - **NICE TO HAVE**

**Reference Standards**:
- `.github/copilot/code-review-instructions.md` (Generic)
- `.github/copilot/java-review-instructions.md` (Java-specific)
- `.github/copilot/api-review-instructions.md` (API review)
- `.github/copilot/generic-testing-instructions.md` (Testing)
- `.github/copilot/bdd-testing-instructions.md` (BDD)

---

### 🍎 Swift Review Agent (`swiftreviewagent.md`)

**Purpose**: Comprehensive code review agent specialized for Swift applications (iOS, macOS, watchOS, tvOS) with RAG (Red-Amber-Green) categorized reporting.

**What it does**:
- ✅ Performs production-ready code reviews of Swift PRs
- ✅ Validates against generic and Swift-specific coding standards
- ✅ Reviews SwiftUI, UIKit, and Combine code patterns
- ✅ Checks memory management and retain cycles
- ✅ Validates concurrency (async/await, actors)
- ✅ Checks test coverage (XCTest, UI tests)
- ✅ Detects security vulnerabilities and Swift best practices
- ✅ Integrates requirements from Jira/Confluence
- ✅ Generates detailed RAG categorized reports
- ✅ Maintains context across multiple review iterations

**What it doesn't do**:
- ❌ Never makes code changes without explicit approval
- ❌ Never approves PRs with RED (critical) issues
- ❌ Never ignores memory leaks or retain cycles
- ❌ Never reviews non-Swift files as Swift code

**Supported Technologies**:
- **UI Frameworks**: SwiftUI, UIKit, AppKit
- **Architectures**: MVVM, MVC, TCA, VIPER
- **Reactive**: Combine, async/await
- **Persistence**: Core Data, SwiftData, Realm
- **Testing**: XCTest, Quick/Nimble
- **Platforms**: iOS, macOS, watchOS, tvOS

**Usage**:
```bash
@swiftreviewagent review PR #123
@swiftreviewagent review PR #456 with requirements from JIRA-789
@swiftreviewagent review changes in Sources/MyApp/Features/
@swiftreviewagent re-review PR #123 (previous review: [link])
@swiftreviewagent review PR #789 for iOS and watchOS
```

**RAG Categorization**:
- 🔴 **RED**: Critical issues (security, crashes, memory leaks, force unwraps) - **MUST FIX**
- 🟠 **AMBER**: Important issues (quality, performance, standards, architecture) - **SHOULD FIX**
- 🟢 **GREEN**: Suggestions (style, idiomatic Swift, minor optimizations) - **NICE TO HAVE**

**Reference Standards**:
- `.github/copilot/code-review-instructions.md` (Generic)
- `.github/copilot/swift-review-instructions.md` (Swift-specific)
- `.github/copilot/generic-testing-instructions.md` (Testing)
- `.github/copilot/bdd-testing-instructions.md` (BDD)

---

### 🎯 Kotlin Review Agent (`kotlinreviewagent.md`)

**Purpose**: Comprehensive code review agent specialized for Kotlin applications and APIs with RAG (Red-Amber-Green) categorized reporting.

**What it does**:
- ✅ Performs production-ready code reviews of Kotlin PRs
- ✅ Validates against generic and Kotlin-specific coding standards
- ✅ Reviews Spring Boot, Android, and multiplatform code
- ✅ Checks coroutines, Flow, and concurrency patterns
- ✅ Validates Java interoperability and framework integration
- ✅ Checks test coverage (JUnit, Kotest, MockK)
- ✅ Detects security vulnerabilities and Kotlin best practices
- ✅ Integrates requirements from Jira/Confluence
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@kotlinreviewagent review PR #123
@kotlinreviewagent review PR #456 with requirements from JIRA-789
```

**Reference Standards**:
- `.github/copilot/code-review-instructions.md` (Generic)
- `.github/copilot/kotlin-review-instructions.md` (Kotlin-specific)
- `.github/copilot/api-review-instructions.md` (API review)
- `.github/copilot/generic-testing-instructions.md` (Testing)

---

### 🐍 Python Review Agent (`pythonreviewagent.md`)

**Purpose**: Comprehensive code review agent specialized for Python applications, APIs, and scripts with RAG categorized reporting.

**What it does**:
- ✅ Performs production-ready code reviews of Python PRs
- ✅ Validates against PEP standards and Python-specific best practices
- ✅ Reviews Flask, FastAPI, Django applications
- ✅ Checks async/await patterns and type hints
- ✅ Validates test coverage (pytest, unittest)
- ✅ Detects security vulnerabilities
- ✅ Integrates requirements from Jira/Confluence
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@pythonreviewagent review PR #123
@pythonreviewagent review PR #456 with requirements from JIRA-789
```

**Reference Standards**:
- `.github/copilot/code-review-instructions.md` (Generic)
- `.github/copilot/python-review-instructions.md` (Python-specific)
- `.github/copilot/api-review-instructions.md` (API review)
- `.github/copilot/generic-testing-instructions.md` (Testing)

---

### 🧪 Test Generation Agent (`testgenerationagent.md`)

**Purpose**: Intelligent test generation agent that creates unit, integration, and BDD tests based on code analysis and requirements.

**What it does**:
- ✅ Analyzes code language and generates appropriate tests
- ✅ Creates unit tests with comprehensive coverage
- ✅ Generates integration/functional tests
- ✅ Writes BDD scenarios following Gherkin standards
- ✅ Integrates requirements from Jira/Confluence
- ✅ Provides detailed coverage reports
- ✅ Generates test creation summary reports
- ✅ Maintains context across multiple executions

**Usage**:
```bash
@testgenerationagent generate tests for feature X
@testgenerationagent create unit tests for service classes
@testgenerationagent write BDD scenarios for JIRA-123
```

**Reference Standards**:
- `.github/copilot/generic-testing-instructions.md`
- `.github/copilot/bdd-testing-instructions.md`
- Language-specific testing conventions

---

### ♿ Accessibility Auditor (`accessibilityauditor.md`)

**Purpose**: Comprehensive accessibility auditor for mobile (iOS/Android) and web applications with RAG categorized reporting.

**What it does**:
- ✅ Audits mobile app screens (iOS and Android)
- ✅ Audits web application accessibility
- ✅ Validates WCAG 2.1/2.2 AA/AAA compliance
- ✅ Checks screen readers, keyboard navigation, color contrast
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@accessibilityauditor audit iOS app screens
@accessibilityauditor review web accessibility
@accessibilityauditor check WCAG compliance
```

**RAG Categorization**:
- 🔴 **RED**: Critical (WCAG A/AA violations, unusable) - **MUST FIX**
- 🟠 **AMBER**: Important (WCAG AAA, usability issues) - **SHOULD FIX**
- 🟢 **GREEN**: Suggestions (enhancements) - **NICE TO HAVE**

---

### 🔄 Workflows Review Agent (`workflowsreviewagent.md`)

**Purpose**: GitHub Actions workflow review agent that validates workflows against best practices.

**What it does**:
- ✅ Reviews GitHub Actions workflow files
- ✅ Validates workflow syntax and structure
- ✅ Checks action versions (uses latest stable)
- ✅ Reviews security best practices
- ✅ Validates secrets management
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@workflowsreviewagent review workflows
@workflowsreviewagent audit .github/workflows/
```

**Reference Standards**:
- `.github/copilot/github-actions-instructions.md`

---

### ⚙️ Workflow Generator Agent (`workflowgeneratoragent.md`)

**Purpose**: Intelligent GitHub Actions workflow generator that creates production-ready workflow files.

**What it does**:
- ✅ Generates GitHub Actions workflows based on project needs
- ✅ Creates CI/CD pipelines for various languages
- ✅ Follows think-plan-execute-reflect pattern
- ✅ Uses latest stable action versions
- ✅ Implements security best practices
- ✅ Generates executable, well-documented workflows

**Usage**:
```bash
@workflowgeneratoragent create CI workflow for Java project
@workflowgeneratoragent generate deployment workflow
```

**Reference Standards**:
- `.github/copilot/github-actions-instructions.md`

---

### 🏗️ Terraform Generator (`terraform-generator.md`)

**Purpose**: Intelligent Terraform code generator for AWS, Azure, GCP, and OpenShift infrastructure.

**What it does**:
- ✅ Generates Terraform configurations (AWS, Azure, GCP, OpenShift)
- ✅ Creates modular, parameterized infrastructure code
- ✅ Follows think-plan-execute-reflect pattern
- ✅ Uses latest stable provider versions
- ✅ Implements best practices and security standards
- ✅ Generates well-documented, executable code

**Usage**:
```bash
@terraform-generator create AWS infrastructure for microservices
@terraform-generator generate Azure resources
```

**Reference Standards**:
- `.github/copilot/terraform-coding-instructions.md`

---

### 🔍 Terraform Reviewer (`terraform-reviewer.md`)

**Purpose**: Comprehensive Terraform code review agent with RAG categorized reporting.

**What it does**:
- ✅ Reviews Terraform code against best practices
- ✅ Validates security, cost optimization, compliance
- ✅ Checks provider versions and module structure
- ✅ Never generates or modifies code (review only)
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@terraform-reviewer review infrastructure code
@terraform-reviewer audit terraform/
```

**Reference Standards**:
- `.github/copilot/terraform-coding-instructions.md`

---

### ✅ Test Review Agent (`test-review-agent.md`)

**Purpose**: Specialized test code review agent that validates unit, integration, and functional tests.

**What it does**:
- ✅ Reviews test code quality and coverage
- ✅ Validates test structure and patterns
- ✅ Analyzes code and test language compatibility
- ✅ Checks coverage metrics (unit, integration, functional)
- ✅ Generates detailed RAG categorized reports
- ✅ Saves reports to `<working-directory>/reviews/` folder

**Usage**:
```bash
@test-review-agent review test files
@test-review-agent analyze test coverage
```

**Reference Standards**:
- `.github/copilot/generic-testing-instructions.md`
- `.github/copilot/bdd-testing-instructions.md`

---

### 👨‍💻 Java Pair Programmer (`java-pair-programmer.md`)

**Purpose**: AI pair programmer specialized in Java development with think-plan-execute-reflect methodology.

**What it does**:
- ✅ Analyzes requirements from Jira/Confluence
- ✅ Develops Java applications and APIs (Spring Boot, etc.)
- ✅ Follows generic and Java coding standards
- ✅ Uses latest Java versions and stable frameworks
- ✅ Validates input, handles exceptions properly
- ✅ Uses proper HTTP status codes for APIs
- ✅ Never uses Lombok with Java 17+
- ✅ Works as interactive pair programmer

**Usage**:
```bash
@java-pair-programmer implement feature from JIRA-123
@java-pair-programmer create REST API for user management
@java-pair-programmer refactor service layer
```

**Reference Standards**:
- `.github/copilot/code-review-instructions.md`
- `.github/copilot/java-review-instructions.md`
- `.github/copilot/api-review-instructions.md`

---

## How to Use Custom Agents

### Method 1: Direct Mention
```bash
# Mention the agent in your Copilot chat
@documentagent Review documentation for this project
```

### Method 2: Via GitHub Copilot Chat
1. Open GitHub Copilot chat
2. Type `@` followed by the agent name
3. Provide your request

### Method 3: In Pull Requests
```bash
# In PR comments
@documentagent Review changes to documentation files
```

## Agent Configuration

All agents are configured using YAML frontmatter with the following structure:

```yaml
name: agentname
description: Brief description of agent purpose
instructions: Detailed instructions for agent behavior
conversation_starters: List of example prompts
tools: List of tools agent can use
file_patterns:
  include: List of file patterns to include
  exclude: List of file patterns to exclude
reference_instructions: Links to reference documentation
```

## Adding New Agents

To add a new custom agent:

1. Create a new markdown file in `.github/agents/`
2. Use descriptive name: `<agent-purpose>agent.md`
3. Follow the YAML configuration structure
4. Include clear instructions and scope
5. Define file patterns (include/exclude)
6. Provide usage examples
7. Update this README with agent information

## Agent Best Practices

### DO:
✅ Clearly define agent scope and responsibilities  
✅ Specify what agent DOES and DOESN'T do  
✅ Provide specific file patterns  
✅ Include conversation starters  
✅ Reference existing documentation standards  
✅ Keep agents focused on single domain  

### DON'T:
❌ Create overlapping agent responsibilities  
❌ Make agents too broad in scope  
❌ Allow agents to modify unrelated files  
❌ Forget to specify exclusions  
❌ Leave instructions ambiguous  

## Agent Guidelines

### Specialization
Each agent should focus on a **single domain**:
- Documentation Agent → Documentation files only
- Test Agent → Test files only (future)
- Security Agent → Security scanning only (future)
- Review Agent → Code review only (future)

### Clear Boundaries
Define clear boundaries using:
- **File patterns**: What files can the agent access
- **Instructions**: What actions the agent can/cannot take
- **Exclusions**: What files/actions are prohibited

### Reference Standards
All agents should reference existing standards:
- Code review standards in `.github/copilot/`
- Testing standards in `.github/copilot/`
- Language-specific standards (Java, Kotlin, Swift, Python)

## Integration with Copilot Skills

Custom agents work alongside the comprehensive guidelines in `.github/copilot/`:

```
.github/
├── copilot/                           # Comprehensive guidelines
│   ├── code-review-instructions.md    # Generic review standards
│   ├── java-review-instructions.md    # Java-specific standards
│   ├── kotlin-review-instructions.md  # Kotlin-specific standards
│   ├── swift-review-instructions.md   # Swift-specific standards
│   ├── python-review-instructions.md  # Python-specific standards
│   ├── bdd-testing-instructions.md    # BDD testing standards
│   └── generic-testing-instructions.md # Testing standards
│
└── agents/                            # Specialized agents
    ├── documentagent.md               # Documentation agent
    └── README.md                      # This file
```

Agents **reference** the comprehensive guidelines but are **specialized** for specific tasks.

## Future Agents (Ideas)

### 🧪 Test Agent
- Focus: Writing and reviewing test files
- Scope: Unit tests, integration tests, test data
- References: `generic-testing-instructions.md`, `bdd-testing-instructions.md`

### 🔒 Security Agent
- Focus: Security scanning and vulnerability detection
- Scope: Security issues, dependency scanning, secrets detection
- References: Security sections from all review instructions

### 📊 Review Agent
- Focus: Code review and quality checks
- Scope: Code files for specific language
- References: Language-specific review instructions

### 🏗️ Architecture Agent
- Focus: Architecture documentation and design decisions
- Scope: Architecture diagrams, ADRs, design docs
- References: Architecture sections from review instructions

### 🌐 API Agent
- Focus: API documentation and OpenAPI specs
- Scope: API docs, swagger/openapi files, endpoint documentation
- References: API documentation standards

## Troubleshooting

### Agent Not Responding
- Ensure agent name is correct (`@documentagent`)
- Check file is in `.github/agents/` directory
- Verify YAML frontmatter is valid
- Check GitHub Copilot extension is up to date

### Agent Modifying Wrong Files
- Review `file_patterns.exclude` section
- Ensure exclusions are comprehensive
- Update instructions to be more specific
- Add explicit restrictions in instructions

### Agent Not Following Standards
- Verify `reference_instructions` points to correct files
- Ensure referenced standards exist
- Update agent instructions to be more explicit
- Provide more specific examples

## Contributing

To improve custom agents:

1. **Test Thoroughly**: Test agent with various prompts
2. **Document Changes**: Update README and agent documentation
3. **Follow Standards**: Align with existing Copilot Skills guidelines
4. **Get Feedback**: Have others test the agent
5. **Iterate**: Refine based on usage and feedback

## Resources

- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents)
- [Your First Custom Agent Tutorial](https://docs.github.com/en/copilot/tutorials/customization-library/custom-agents/your-first-custom-agent)
- [Agent Configuration Reference](https://docs.github.com/en/copilot/customizing-copilot/creating-custom-instructions-for-github-copilot)

## Support

For issues or questions about custom agents:
1. Check GitHub Copilot documentation
2. Review agent instructions and configuration
3. Verify file patterns and exclusions
4. Test with simpler prompts first

---

**Version**: 1.0  
**Last Updated**: 2026-01-31  
**Framework**: GitHub Copilot Skills
