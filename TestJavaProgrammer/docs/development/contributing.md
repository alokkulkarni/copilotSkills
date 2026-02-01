# Contributing to Customer Management API

Thank you for your interest in contributing to the Customer Management API! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Workflow](#contribution-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Requirements](#documentation-requirements)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

### Our Standards

We are committed to providing a welcoming and inspiring community for all. Expected behaviors include:

- ✅ Using welcoming and inclusive language
- ✅ Being respectful of differing viewpoints and experiences
- ✅ Gracefully accepting constructive criticism
- ✅ Focusing on what is best for the community
- ✅ Showing empathy towards other community members

### Unacceptable Behavior

- ❌ Harassment, trolling, or discriminatory comments
- ❌ Personal or political attacks
- ❌ Publishing others' private information without consent
- ❌ Other conduct inappropriate in a professional setting

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- Java JDK 17 or higher
- Maven 3.6+
- Git
- A GitHub account
- An IDE (IntelliJ IDEA, VS Code, or Eclipse)

See [Installation Guide](../getting-started/installation.md) for detailed setup.

### Find an Issue

1. Check [GitHub Issues](https://github.com/alokkulkarni/copilotSkills/issues)
2. Look for issues labeled:
   - `good first issue` - Good for beginners
   - `help wanted` - Contributions welcome
   - `bug` - Bug fixes needed
   - `enhancement` - New features

3. Comment on the issue to express interest
4. Wait for maintainer approval before starting work

### Not Finding an Issue?

If you want to work on something not listed:

1. Open a new issue describing your proposal
2. Wait for feedback from maintainers
3. Once approved, proceed with implementation

## Development Setup

### 1. Fork the Repository

Click the "Fork" button on GitHub to create your own copy.

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/copilotSkills.git
cd copilotSkills/TestJavaProgrammer
```

### 3. Add Upstream Remote

```bash
git remote add upstream https://github.com/alokkulkarni/copilotSkills.git
```

### 4. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test improvements

### 5. Make Changes

Implement your changes following the coding standards below.

### 6. Test Your Changes

```bash
mvn clean test
```

Ensure all tests pass before committing.

## Coding Standards

### Java Code Style

Follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html):

#### Formatting

```java
// Good - proper formatting
public class CustomerService {
    
    private final CustomerRepository repository;
    
    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }
    
    public Customer createCustomer(Customer customer) {
        validateCustomer(customer);
        return repository.save(customer);
    }
}
```

#### Naming Conventions

- **Classes**: PascalCase (`CustomerController`, `CustomerService`)
- **Methods**: camelCase (`createCustomer`, `findById`)
- **Variables**: camelCase (`customer`, `customerId`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_PAGE_SIZE`, `DEFAULT_PORT`)
- **Packages**: lowercase (`com.example.demo.controller`)

#### Best Practices

- ✅ Use meaningful variable names
- ✅ Keep methods small and focused (< 20 lines)
- ✅ Add comments for complex logic
- ✅ Use appropriate access modifiers
- ✅ Prefer composition over inheritance
- ✅ Follow SOLID principles

### Spring Boot Conventions

```java
@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    
    private final CustomerService service;
    
    // Constructor injection (preferred)
    public CustomerController(CustomerService service) {
        this.service = service;
    }
    
    @PostMapping
    public ResponseEntity<Customer> createCustomer(
            @Valid @RequestBody Customer customer) {
        Customer created = service.createCustomer(customer);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
}
```

### Error Handling

```java
// Good - specific exception handling
@ExceptionHandler(CustomerNotFoundException.class)
public ResponseEntity<ErrorResponse> handleCustomerNotFound(
        CustomerNotFoundException ex) {
    ErrorResponse error = new ErrorResponse(
        LocalDateTime.now(),
        HttpStatus.NOT_FOUND.value(),
        ex.getMessage()
    );
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
}
```

## Testing Requirements

### Test Coverage

- **Minimum**: 80% code coverage
- **Target**: 90%+ coverage
- All new code must have tests

### Types of Tests

#### 1. Unit Tests

Test individual components in isolation:

```java
@Test
void shouldCreateCustomerSuccessfully() {
    // Given
    Customer customer = new Customer("John Doe", "john@example.com");
    when(repository.save(any(Customer.class))).thenReturn(customer);
    
    // When
    Customer result = service.createCustomer(customer);
    
    // Then
    assertThat(result).isNotNull();
    assertThat(result.getName()).isEqualTo("John Doe");
    verify(repository).save(customer);
}
```

#### 2. Integration Tests

Test components working together:

```java
@SpringBootTest
@AutoConfigureMockMvc
class CustomerControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    void shouldCreateCustomerViaAPI() throws Exception {
        mockMvc.perform(post("/api/customers")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "name": "John Doe",
                        "email": "john@example.com"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("John Doe"));
    }
}
```

#### 3. Test Naming

Use descriptive test names:

```java
// Good
@Test
void shouldReturnNotFoundWhenCustomerDoesNotExist() { }

@Test
void shouldThrowExceptionWhenEmailIsInvalid() { }

// Bad
@Test
void test1() { }

@Test
void testCustomer() { }
```

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=CustomerServiceTest

# Run with coverage
mvn clean test jacoco:report
```

## Documentation Requirements

### Code Documentation

#### Javadoc for Public APIs

```java
/**
 * Creates a new customer in the system.
 * 
 * @param customer the customer to create (must not be null)
 * @return the created customer with generated ID
 * @throws IllegalArgumentException if customer is null or invalid
 */
public Customer createCustomer(Customer customer) {
    // Implementation
}
```

#### Inline Comments

```java
// Complex logic needs explanation
// Calculate the total with tax (8.5% rate)
BigDecimal total = subtotal.multiply(new BigDecimal("1.085"));
```

### API Documentation

Update Swagger annotations:

```java
@Operation(summary = "Create a new customer", 
           description = "Creates a new customer record with validation")
@ApiResponses(value = {
    @ApiResponse(responseCode = "201", description = "Customer created"),
    @ApiResponse(responseCode = "400", description = "Invalid input")
})
@PostMapping
public ResponseEntity<Customer> createCustomer(
        @Valid @RequestBody Customer customer) {
    // Implementation
}
```

### README and Guides

- Update README.md if changing functionality
- Add examples for new features
- Update relevant documentation pages

## Pull Request Process

### 1. Ensure Quality

Before submitting:

- [ ] All tests pass (`mvn clean test`)
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] No unnecessary files committed
- [ ] Commit messages are clear

### 2. Commit Message Format

```
type(scope): Short description

Longer description if needed.

Fixes #123
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(api): Add pagination support to customer list endpoint

Implements pagination using Spring Data's Pageable interface.
Adds page, size, and sort parameters.

Fixes #45
```

```
fix(validation): Correct email validation regex

Previous regex didn't handle plus signs in email addresses.

Fixes #67
```

### 3. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 4. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Fill out the PR template:
   - **Title**: Clear, concise description
   - **Description**: What changed and why
   - **Related Issue**: Link to issue number
   - **Testing**: How you tested the changes

### 5. Code Review

- Respond to feedback promptly
- Make requested changes in new commits
- Keep discussions professional and constructive

### 6. Merge

Once approved:
- Maintainer will merge your PR
- Your changes will be in the next release!

## Reporting Issues

### Bug Reports

Use the bug report template and include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**:
   ```
   1. Start application
   2. Send POST request to /api/customers
   3. Observe error
   ```
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**:
   - OS: macOS 13.5
   - Java: 17.0.8
   - Maven: 3.9.4
6. **Logs**: Include relevant log output
7. **Screenshots**: If applicable

### Feature Requests

Include:

1. **Problem**: What problem does this solve?
2. **Solution**: Proposed solution
3. **Alternatives**: Other solutions considered
4. **Additional Context**: Any other relevant info

## Development Tips

### IDE Setup

#### IntelliJ IDEA

1. Import as Maven project
2. Enable annotation processing
3. Install Google Java Format plugin
4. Configure code style (Settings → Editor → Code Style → Java)

#### VS Code

1. Install Java Extension Pack
2. Install Spring Boot Extension Pack
3. Configure formatting (Ctrl+Shift+P → Format Document)

### Useful Commands

```bash
# Clean build
mvn clean package

# Skip tests (for faster builds during development)
mvn package -DskipTests

# Run application
mvn spring-boot:run

# Debug (port 5005)
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### Debugging Tips

- Use IDE debugger instead of print statements
- Set breakpoints in exception handlers
- Use conditional breakpoints for loops
- Check application logs in `logs/` directory

## Communication

### Channels

- **GitHub Issues**: Bug reports, feature requests
- **Pull Requests**: Code discussions
- **Discussions**: General questions and ideas

### Response Times

- Issues: Within 48 hours
- Pull Requests: Within 1 week
- Security Issues: Within 24 hours

## Recognition

Contributors will be:
- Listed in release notes
- Credited in CHANGELOG.md
- Acknowledged in README.md (for significant contributions)

## Questions?

If you have questions:

1. Check [FAQ](../reference/faq.md)
2. Search existing [GitHub Issues](https://github.com/alokkulkarni/copilotSkills/issues)
3. Open a new issue with the "question" label

---

Thank you for contributing to Customer Management API! 🎉
