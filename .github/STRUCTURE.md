# GitHub Copilot Skills - Repository Structure

## Overview
This document provides a complete map of the repository structure and file relationships.

## Directory Tree

```
copilotSkills/
├── .github/
│   ├── agents/                           # 15 Custom Copilot Agents
│   │   ├── README.md                     # Agent documentation hub
│   │   │
│   │   ├── Code Review Agents (4)
│   │   ├── javareviewagent.md            # Java PR review (Spring, Jakarta EE)
│   │   ├── swiftreviewagent.md           # Swift PR review (iOS, macOS, watchOS, tvOS)
│   │   ├── kotlinreviewagent.md          # Kotlin PR review (Android, Spring)
│   │   └── pythonreviewagent.md          # Python PR review (Flask, FastAPI, Django)
│   │   │
│   │   ├── Infrastructure & DevOps Agents (4)
│   │   ├── terraform-generator.md        # Generate Terraform (AWS, Azure, GCP, OpenShift)
│   │   ├── terraform-reviewer.md         # Review Terraform configurations
│   │   ├── workflowgeneratoragent.md     # Generate GitHub Actions workflows
│   │   └── workflowsreviewagent.md       # Review GitHub Actions workflows
│   │   │
│   │   ├── Documentation & API Agents (2)
│   │   ├── documentagent.md              # Review/update documentation files
│   │   └── openapiagent.md               # Generate OpenAPI specifications
│   │   │
│   │   ├── Testing Agents (3)
│   │   ├── testgenerationagent.md        # Generate unit/integration/BDD tests
│   │   ├── test-review-agent.md          # Review test code quality
│   │   └── accessibilityauditor.md       # Audit accessibility (mobile & web)
│   │   │
│   │   └── Development Agents (1)
│   │       └── java-pair-programmer.md   # AI pair programmer for Java
│   │
│   ├── copilot/                          # 10 Instruction Files
│   │   ├── README.md                     # Instructions documentation hub
│   │   ├── INDEX.md                      # Complete navigation index
│   │   ├── SUMMARY.md                    # Quick reference guide
│   │   │
│   │   ├── Language-Specific Instructions (4)
│   │   ├── java-review-instructions.md   # Java coding standards
│   │   ├── swift-review-instructions.md  # Swift coding standards
│   │   ├── kotlin-review-instructions.md # Kotlin coding standards
│   │   └── python-review-instructions.md # Python coding standards
│   │   │
│   │   ├── Generic Instructions (3)
│   │   ├── code-review-instructions.md   # Generic review guidelines
│   │   ├── api-review-instructions.md    # API design standards
│   │   └── generic-testing-instructions.md # Testing standards
│   │   │
│   │   └── Specialized Instructions (3)
│   │       ├── bdd-testing-instructions.md # BDD testing standards
│   │       ├── github-actions-instructions.md # Workflow standards
│   │       └── terraform-coding-instructions.md # Terraform standards
│   │
│   └── STRUCTURE.md                      # This file
│
├── README.md                             # Repository overview and quick start
├── VALIDATION.md                         # Complete validation checklist
└── reviews/                              # Auto-generated review reports
    └── (timestamped report files)

```

## File Relationships

### Agent → Instruction Mappings

| Agent | Primary Instructions | Additional Instructions |
|-------|---------------------|------------------------|
| **javareviewagent** | java-review-instructions.md | code-review-instructions.md, api-review-instructions.md, generic-testing-instructions.md |
| **swiftreviewagent** | swift-review-instructions.md | code-review-instructions.md, generic-testing-instructions.md |
| **kotlinreviewagent** | kotlin-review-instructions.md | code-review-instructions.md, api-review-instructions.md, generic-testing-instructions.md |
| **pythonreviewagent** | python-review-instructions.md | code-review-instructions.md, api-review-instructions.md, generic-testing-instructions.md |
| **terraform-generator** | terraform-coding-instructions.md | - |
| **terraform-reviewer** | terraform-coding-instructions.md | - |
| **workflowgeneratoragent** | github-actions-instructions.md | - |
| **workflowsreviewagent** | github-actions-instructions.md | - |
| **testgenerationagent** | generic-testing-instructions.md | bdd-testing-instructions.md, language-specific instructions |
| **test-review-agent** | generic-testing-instructions.md | bdd-testing-instructions.md |
| **openapiagent** | api-review-instructions.md | - |
| **documentagent** | code-review-instructions.md (docs section) | - |
| **accessibilityauditor** | (built-in WCAG standards) | - |
| **java-pair-programmer** | java-review-instructions.md | code-review-instructions.md, api-review-instructions.md |

### Instruction File Dependencies

```
code-review-instructions.md (Generic Foundation)
├── java-review-instructions.md (Java-specific delta)
├── swift-review-instructions.md (Swift-specific delta)
├── kotlin-review-instructions.md (Kotlin-specific delta)
└── python-review-instructions.md (Python-specific delta)

api-review-instructions.md (API Standards)
└── Used by: Java, Kotlin, Python review agents + OpenAPI agent

generic-testing-instructions.md (Testing Foundation)
├── bdd-testing-instructions.md (BDD-specific)
└── Used by: All review agents, test generation, test review

github-actions-instructions.md (Workflow Standards)
└── Used by: Workflow generator, workflow reviewer

terraform-coding-instructions.md (Infrastructure Standards)
└── Used by: Terraform generator, Terraform reviewer
```

## Agent Categories by Function

### 1. Review & Quality Assurance (8 agents)
- Code Review: Java, Swift, Kotlin, Python
- Infrastructure Review: Terraform
- Workflow Review: GitHub Actions
- Test Review: Test code
- Documentation Review: Documentation files

### 2. Generation & Automation (4 agents)
- Code Generation: Java pair programmer
- Test Generation: Unit/Integration/BDD
- Infrastructure Generation: Terraform
- Workflow Generation: GitHub Actions

### 3. Documentation & Specification (2 agents)
- Documentation Management: Document agent
- API Specification: OpenAPI agent

### 4. Specialized Auditing (1 agent)
- Accessibility Auditing: Mobile & Web

## Key Features by Agent Type

### Review Agents
- ✅ RAG (Red-Amber-Green) categorized reporting
- ✅ Report storage in `<working-directory>/reviews/`
- ✅ Integration with Jira/Confluence
- ✅ Context retention across reviews
- ✅ Timestamp-based report naming

### Generator Agents
- ✅ Think-Plan-Execute-Reflect pattern
- ✅ Requirements analysis from Jira/Confluence
- ✅ Latest stable versions
- ✅ Validation of generated artifacts
- ✅ Comprehensive documentation

### All Agents
- ✅ YAML frontmatter configuration
- ✅ Clear scope definition (what it does/doesn't do)
- ✅ Reference to instruction files
- ✅ Context management
- ✅ Usage examples

## Instruction File Organization

### Hierarchy
1. **Generic** (code-review-instructions.md) - Foundation for all
2. **Language-Specific** - Delta from generic
3. **Domain-Specific** - API, Testing, Infrastructure
4. **Specialized** - BDD, Workflows, Terraform

### Content Structure
Each instruction file includes:
- Purpose and scope
- Standards checklist
- Best practices
- Security requirements
- Anti-patterns
- Examples

## Usage Patterns

### For Code Review
1. Developer creates PR
2. Invoke language-specific review agent
3. Agent loads relevant instructions
4. Agent performs analysis
5. Agent generates RAG report
6. Report saved to `reviews/` folder

### For Test Generation
1. Requirements available in Jira/Confluence
2. Invoke test generation agent
3. Agent analyzes code and requirements
4. Agent generates tests (unit/integration/BDD)
5. Agent provides coverage report

### For Infrastructure
1. Define infrastructure requirements
2. Invoke Terraform generator
3. Agent generates modular Terraform code
4. Invoke Terraform reviewer for validation
5. Apply after review passes

### For Workflows
1. Define CI/CD requirements
2. Invoke workflow generator
3. Agent generates GitHub Actions workflow
4. Invoke workflow reviewer for validation
5. Commit workflow after review

## Integration Points

### External Tools
- **Jira**: Requirements and story tracking
- **Confluence**: Documentation and specifications
- **GitHub**: PR reviews, workflows, actions

### MCP Servers
- `@atlassian/jiramcpserver` - Jira integration
- `@atlassian/confluencemcpserver` - Confluence integration

### File Systems
- **Input**: Source code, configurations, documentation
- **Output**: Review reports in `reviews/` folder
- **Context**: Instruction files in `.github/copilot/`

## Maintenance Guidelines

### Adding New Agents
1. Create agent file in `.github/agents/`
2. Add YAML frontmatter
3. Define scope and responsibilities
4. Reference relevant instruction files
5. Update `.github/agents/README.md`
6. Update main `README.md`

### Adding New Instructions
1. Create instruction file in `.github/copilot/`
2. Follow checklist format
3. Define delta from generic (if language-specific)
4. Update `.github/copilot/README.md`
5. Update `.github/copilot/INDEX.md`
6. Link from relevant agents

### Updating Existing Content
1. Maintain backward compatibility
2. Update version information
3. Update all related READMEs
4. Validate with test cases
5. Document changes

## Version Information

- **Structure Version**: 1.0
- **Last Updated**: 2026-02-01
- **Total Agents**: 15
- **Total Instructions**: 10
- **Total Documentation**: 6

---

For detailed information on specific agents or instructions, refer to:
- `.github/agents/README.md` - Complete agent documentation
- `.github/copilot/README.md` - Complete instructions documentation
- `.github/copilot/INDEX.md` - Navigation index
- `README.md` - Repository overview
