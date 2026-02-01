# Code Review Skill for GitHub Copilot

This directory contains generic code review guidelines and instructions for GitHub Copilot to perform comprehensive code reviews across any programming language.

## Structure

```
.github/copilot/
├── code-review-instructions.md      # Generic review guidelines
├── java-review-instructions.md      # Java-specific review guidelines
├── swift-review-instructions.md     # Swift-specific review guidelines
├── kotlin-review-instructions.md    # Kotlin-specific review guidelines
├── python-review-instructions.md    # Python-specific review guidelines
├── api-review-instructions.md       # API design and review guidelines
├── bdd-testing-instructions.md      # BDD functional testing guidelines
├── generic-testing-instructions.md  # Unit/Integration/Exploratory testing
├── README.md                         # This file
├── SUMMARY.md                        # Quick reference
└── INDEX.md                          # Complete navigation
```

## Purpose

The `code-review-instructions.md` file provides language-agnostic code review guidelines that cover:

- **Security**: Credentials, secrets, vulnerabilities, authentication
- **Code Quality**: Clarity, duplication, error handling, performance
- **Naming Conventions**: Files, functions, variables, classes
- **Architecture**: Separation of concerns, modularity, API design
- **Testing**: Coverage and quality standards
- **Documentation**: Code comments, README, setup guides
- **Version Control**: Commit quality and git practices
- **Accessibility**: UI considerations and inclusive language
- **Compliance**: Licensing, data privacy

The `java-review-instructions.md` file provides Java-specific guidelines covering:

- **Java Language Standards**: Modern Java features, version-specific syntax
- **OOP Principles**: Encapsulation, inheritance, polymorphism, SOLID
- **Core Features**: Generics, annotations, enums, exceptions
- **Collections & Streams**: Collection framework, Stream API, Optional
- **Concurrency**: Thread safety, executors, virtual threads
- **Standard Library**: String handling, Date/Time API, I/O, NIO
- **Frameworks**: Spring, Spring Boot, JPA/Hibernate, Lombok
- **Performance**: Memory management, JVM optimization, database tuning
- **Java Security**: Serialization, reflection, cryptography
- **Build Tools**: Maven, Gradle, dependency management
- **Code Quality**: Static analysis, formatting, Javadoc
- **Testing**: JUnit 5, Mockito, test containers
- **Anti-Patterns**: Java-specific code smells and patterns to avoid

The `swift-review-instructions.md` file provides Swift-specific guidelines covering:

- **Swift Language Standards**: Modern Swift features (5.5+, async/await, actors)
- **Core Features**: Optionals, protocols, enums, properties, closures, generics
- **Memory Management**: ARC, weak/unowned references, retain cycles
- **Error Handling**: Throwing functions, do-catch, Result type
- **Concurrency**: Async/await, actors, GCD, Task, @MainActor
- **SwiftUI**: State management, view composition, property wrappers
- **UIKit**: View controllers, Auto Layout, delegation patterns
- **iOS/macOS Frameworks**: Foundation, networking, data persistence
- **Package Management**: SPM, CocoaPods, Carthage
- **Code Quality**: SwiftLint, documentation, code organization
- **Security**: Keychain, encryption, biometric auth, privacy
- **Testing**: XCTest, UI testing, performance testing
- **Architecture**: MVC, MVVM, VIPER, Clean Architecture patterns
- **Anti-Patterns**: Force unwrapping, retain cycles, massive view controllers

The `kotlin-review-instructions.md` file provides Kotlin-specific guidelines covering:

- **Kotlin Language Standards**: Modern features (1.7+, coroutines, Flow)
- **Core Features**: Null safety, data classes, sealed classes, properties
- **Collections**: Immutable collections, sequences, operations
- **Coroutines**: Suspend functions, structured concurrency, Flow, channels
- **Java Interoperability**: Calling Java from Kotlin and vice versa, @Jvm annotations
- **Spring Framework**: Spring Boot, dependency injection, WebFlux, Data JPA
- **Android Development**: Activities, ViewModels, Jetpack Compose, Room
- **Functional Programming**: Higher-order functions, operators, Arrow library
- **DSLs**: Type-safe builders, domain-specific languages
- **Error Handling**: Try-catch expressions, Result type, validation functions
- **Performance**: Inline functions, value classes, sequences, optimization
- **Testing**: JUnit 5, Kotest, MockK, coroutine testing, Turbine
- **Build Tools**: Gradle Kotlin DSL, compiler plugins, dependency management
- **Code Quality**: Detekt, Ktlint, SonarQube, static analysis
- **Anti-Patterns**: Excessive `!!`, lateinit abuse, scope function misuse

The `python-review-instructions.md` file provides Python-specific guidelines covering:

- **Python Language Standards**: Modern features (3.8+, 3.10+), PEP standards
- **Core Features**: Type hints, Zen of Python, Pythonic code patterns
- **Data Classes**: @dataclass decorator, immutability, validation
- **Properties & Decorators**: @property, @classmethod, @staticmethod, custom decorators
- **Exception Handling**: EAFP vs LBYL, exception chaining, context managers
- **OOP**: Classes, inheritance, ABC, magic methods, mixins
- **Functional Programming**: Lambda, map/filter/reduce, functools, itertools
- **Async Programming**: asyncio, async/await, async context managers, async iterators
- **Standard Library**: collections, pathlib, datetime, enum
- **Testing**: unittest, pytest, mocking, fixtures, parametrized tests
- **Web Frameworks**: Flask, FastAPI, Django best practices
- **Database/ORM**: SQLAlchemy patterns, connection management
- **Package Management**: venv, Poetry, requirements, pyproject.toml
- **Code Quality**: Black, Flake8, Pylint, mypy, isort, bandit
- **Documentation**: PEP 257 docstrings, Sphinx, type hints in docs
- **Performance**: Profiling, generators, __slots__, optimization
- **Security**: Input validation, SQL injection prevention, secrets, cryptography
- **Modern Patterns**: Pattern matching (3.10+), protocols, context variables

The `bdd-testing-instructions.md` file provides comprehensive BDD testing guidelines covering:

- **BDD Fundamentals**: Principles, Three Amigos, specification by example
- **Gherkin Language**: Feature, Scenario, Given-When-Then syntax
- **Writing Scenarios**: Declarative style, independence, naming conventions
- **Given-When-Then**: Best practices for each step type
- **Background**: Shared preconditions across scenarios
- **Scenario Outlines**: Data-driven testing with examples
- **Tags & Organization**: Categorization, filtering, test execution control
- **Test Data**: Management strategies, realistic data, isolation
- **Patterns & Anti-Patterns**: Common pitfalls and best practices
- **Step Definitions**: Reusability, abstraction, implementation guidelines
- **Testing Layers**: UI/E2E, API/Service, Component/Unit testing
- **BDD Tools**: Cucumber, SpecFlow, Behave, Gauge frameworks
- **Different Contexts**: Web, mobile, APIs, batch jobs
- **Workflow**: Three Amigos sessions, Example Mapping, Agile integration
- **CI/CD Integration**: Pipeline stages, parallel execution, failure handling
- **Metrics & Reporting**: Coverage, quality metrics, living documentation
- **Common Challenges**: Slow tests, flaky tests, maintenance solutions
- **Language-Specific**: Java, JavaScript, C#, Python, Ruby considerations

The `generic-testing-instructions.md` file provides comprehensive testing standards covering:

- **Testing Fundamentals**: Principles, test categories, when NOT to write tests
- **Unit Testing**: What to test, structure (AAA/Given-When-Then), naming conventions
- **Positive Tests**: Valid inputs, requirement coverage, avoiding over-testing
- **Negative Tests**: Error handling, invalid inputs, boundary conditions
- **Integration Testing**: Component interactions, database, APIs, external services
- **Exploratory Testing**: Session-based testing, heuristics, documentation
- **Test Coverage Strategy**: Requirement mapping, test pyramid, prioritization
- **Duplication Detection**: Identifying and preventing duplicate tests
- **Hallucination Prevention**: Avoiding invented scenarios not in requirements
- **Test Design Techniques**: Equivalence partitioning, boundary analysis, decision tables
- **Test Data Strategies**: Realistic data, builders, management patterns
- **Assertion Strategies**: Effective assertions, common patterns
- **Test Maintenance**: When to update, refactoring, removing tests
- **Test Reporting**: Execution reports, creation reports, "NOT created" reports
- **Coverage Reporting**: Requirement coverage, code coverage, gap identification
- **Anti-Patterns**: Common mistakes, hallucination examples, over-engineering
- **Test Review Checklists**: Before, during, and after writing tests
- **CI/CD Integration**: Pipeline stages, test failure handling

The `api-review-instructions.md` file provides comprehensive API guidelines covering:

- **API Design Principles**: REST, GraphQL, gRPC design patterns
- **Endpoint Design**: URL structure, HTTP methods, query parameters
- **Request/Response**: Body standards, status codes, error handling
- **API Versioning**: Strategies, breaking changes, deprecation
- **Authentication**: OAuth 2.0, JWT, API keys, security best practices
- **Authorization**: RBAC, ABAC, scope-based authorization
- **Rate Limiting**: Strategies, implementation, best practices
- **Error Handling**: Error codes, response structure, security considerations
- **API Documentation**: OpenAPI/Swagger, documentation standards
- **Performance**: Response times, caching, pagination, optimization
- **API Security**: OWASP API Security Top 10, security checklist
- **API Testing**: Unit, integration, contract, performance, security testing
- **Monitoring**: Logging, metrics, distributed tracing, health checks
- **API Deprecation**: Process, migration guides, communication
- **Production Readiness**: Complete checklist for production deployment
- **GraphQL-Specific**: Schema design, security, query optimization
- **gRPC-Specific**: Proto file design, streaming, best practices

## Usage

### For GitHub Copilot Agent

When performing code reviews, the agent will reference these guidelines to provide:

1. Security vulnerability detection
2. Code quality assessment
3. Best practice recommendations
4. Naming convention validation
5. Architecture and design feedback

### For Developers
- Self-review checklist before PRs
- Language-specific coding standards
- Best practices reference
- Architecture patterns
- Unit and integration test writing

### For QA/Test Engineers
- BDD test writing guidelines
- Test automation standards
- Scenario organization patterns
- Test data management
- Unit/integration test standards
- Exploratory testing approach
- Test reporting templates

### For GitHub Copilot Agents
- Code review automation
- Security vulnerability detection
- BDD test scenario generation
- Unit/integration test generation
- Test coverage analysis
- Duplication and hallucination prevention
- Best practice suggestions

## Customization

While these guidelines are generic and language-agnostic, teams should:

1. Add language-specific guidelines in separate files if needed
2. Customize priority levels based on project needs
3. Add project-specific compliance requirements
4. Extend with domain-specific best practices

## Integration with GitHub Copilot

GitHub Copilot can use these instructions when:

- Reviewing pull requests
- Providing inline code suggestions
- Answering code review questions
- Validating security practices
- Writing BDD test scenarios
- Generating functional tests
- Providing test automation guidance

Simply reference these files when asking Copilot for help:

```bash
# Example usage for code review
"Review my code changes according to the guidelines in .github/copilot/code-review-instructions.md"

# Example usage for Java review
"Review this Java class following .github/copilot/java-review-instructions.md"

# Example usage for BDD testing
"Write BDD scenarios for this feature following .github/copilot/bdd-testing-instructions.md"
```

## Feedback and Updates

These guidelines should evolve with:

- New security threats and best practices
- Team learnings and retrospectives
- Industry standards and compliance requirements
- Tool and framework updates

## License

These guidelines are provided as-is for use within your organization. Adapt as needed for your specific requirements.
