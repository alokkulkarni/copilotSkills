# Contributing Guidelines

Thank you for your interest in contributing to the Customer Management API!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Development Setup](#development-setup)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)

## Code of Conduct

By participating in this project, you agree to maintain a welcoming and inclusive environment. Be respectful and constructive in all interactions.

## Development Setup

1. **Prerequisites**:
   - Java 17 or higher
   - Maven 3.6+
   - Git
   - IDE with Java support (IntelliJ IDEA, VS Code, Eclipse)

2. **Clone and build**:
   ```bash
   git clone https://github.com/alokkulkarni/copilotSkills.git
   cd copilotSkills/TestJavaProgrammer
   mvn clean install
   ```

3. **Run tests**:
   ```bash
   mvn test
   ```

## Development Process

1. **Fork the repository** and create your branch from `main`.

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   # or for bugfixes:
   git checkout -b fix/bug-description
   ```

3. **Make your changes** following the coding standards below.

4. **Run tests** to ensure no regressions:
   ```bash
   mvn test
   ```

5. **Commit your changes** with clear, descriptive messages:
   ```bash
   git commit -m "feat: add customer search by email"
   # or
   git commit -m "fix: handle null email validation"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request** targeting the `main` branch.

## Coding Standards

### Java Conventions

- **Naming**: Use CamelCase for classes, camelCase for methods/variables
- **Records**: Use Java Records for immutable data classes
- **Interfaces**: Create interfaces for classes that will be mocked in tests
- **Final**: Use `final` for method parameters and local variables where appropriate

### Code Organization

```
src/main/java/com/example/demo/
├── controller/     # REST endpoints
├── service/        # Business logic + interfaces
├── repository/     # Data access + interfaces
├── model/          # Domain objects (Records)
└── exception/      # Exception handlers
```

### Documentation

- Add Javadoc for all public classes and methods
- Include `@param`, `@return`, and `@throws` tags
- Document non-obvious implementation details

## Testing Requirements

### Test Structure

- Place tests in `src/test/java/` mirroring main source structure
- Use `@DisplayName` for readable test names
- Use `@Nested` classes to group related tests
- Follow AAA pattern (Arrange-Act-Assert)

### Test Data

- Use `CustomerTestBuilder` for creating test data
- Add new factory methods if needed
- Never hardcode test data inline

### Mocking

- Mock interfaces, not concrete classes
- Use `@ExtendWith(MockitoExtension.class)` for unit tests
- Add `verify()` calls for important interactions

### Coverage

- All new features must include tests
- Maintain or improve existing coverage
- Test both positive and negative scenarios

### Example Test

```java
@Nested
@DisplayName("Create Customer Tests")
class CreateCustomerTests {

    @Test
    @DisplayName("Should create customer with generated ID")
    void shouldCreateCustomerWithGeneratedId() {
        // Arrange
        Customer input = CustomerTestBuilder.validCustomerInput();
        when(repository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // Act
        Customer result = service.addCustomer(input);

        // Assert
        assertThat(result.id()).isNotNull();
        verify(repository).save(any());
    }
}
```

## Pull Request Process

1. **Title**: Use conventional commit format (`feat:`, `fix:`, `docs:`, etc.)
2. **Description**: Explain what changes were made and why
3. **Tests**: Ensure all tests pass
4. **Review**: Address all review comments
5. **Squash**: Squash commits before merging if requested

### PR Checklist

- [ ] Tests pass locally (`mvn test`)
- [ ] Code follows project conventions
- [ ] Javadoc added for public APIs
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No unnecessary files included

## Reporting Bugs

Use [GitHub Issues](https://github.com/alokkulkarni/copilotSkills/issues) to report bugs.

### Required Information

- **Description**: Clear summary of the issue
- **Steps to Reproduce**: Numbered steps to trigger the bug
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**:
  - Java version
  - OS and version
  - Maven version

### Bug Report Template

```markdown
## Description
Brief description of the bug.

## Steps to Reproduce
1. Start the application
2. Send POST request to /api/customers with {...}
3. See error

## Expected Behavior
Customer should be created successfully.

## Actual Behavior
500 Internal Server Error returned.

## Environment
- Java: 17.0.9
- OS: macOS 14.0
- Maven: 3.9.5
```

---

Thank you for contributing!
