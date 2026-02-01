# Java-Specific Code Review Guidelines

## Purpose
This document provides comprehensive Java-specific code review guidelines to ensure adherence to Java best practices, language features, frameworks, and ecosystem standards.

---

## 1. Java Language Standards and Best Practices

### 1.1 Java Version and Features
- **Current Java Version**: Verify project uses supported Java version (LTS preferred: 11, 17, 21)
- **Modern Java Features**: Encourage use of modern Java features appropriate for target version
  - Java 8+: Lambda expressions, Stream API, Optional, new Date/Time API
  - Java 9+: Modules, private interface methods, try-with-resources enhancement
  - Java 10+: `var` for local variables (where it improves readability)
  - Java 11+: String methods (`isBlank()`, `lines()`, `strip()`), HTTP Client API
  - Java 14+: Switch expressions, records (preview/stable)
  - Java 15+: Text blocks for multi-line strings
  - Java 16+: Pattern matching for instanceof, records (finalized)
  - Java 17+: Sealed classes
  - Java 21+: Virtual threads, sequenced collections, pattern matching enhancements
- **Deprecated Features**: Flag usage of deprecated Java features and suggest alternatives

### 1.2 Code Structure and Organization
- **Package Naming**: Lowercase, reverse domain notation (`com.company.project.module`)
- **Class Organization Order**:
  1. Static fields (public → private)
  2. Instance fields (public → private)
  3. Constructors
  4. Static methods
  5. Instance methods (public → private)
  6. Nested classes/interfaces
- **One Top-Level Class Per File**: Each public class in its own file
- **File Name**: Must match public class name exactly

### 1.3 Naming Conventions (Java-Specific)
- **Classes/Interfaces**: PascalCase (`UserService`, `PaymentProcessor`)
- **Methods/Variables**: camelCase (`calculateTotal`, `userId`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`)
- **Packages**: lowercase, no underscores (`com.example.service`)
- **Type Parameters**: Single uppercase letter or descriptive name (`T`, `E`, `K`, `V`, `RequestType`)
- **Test Classes**: Suffix with `Test` or `Tests` (`UserServiceTest`)
- **Interface Naming**: 
  - Don't prefix with `I` (use `UserService`, not `IUserService`)
  - Use adjectives for behavioral interfaces (`Runnable`, `Serializable`, `Comparable`)

---

## 2. Java Core Language Features

### 2.1 Object-Oriented Principles
- **Encapsulation**: Fields should be private with appropriate getters/setters
- **Inheritance**:
  - Favor composition over inheritance
  - Use `@Override` annotation consistently
  - Don't override `equals()` without overriding `hashCode()` and vice versa
  - Use `super()` appropriately in constructors
- **Polymorphism**: Use interfaces and abstract classes effectively
- **SOLID Principles**: Verify adherence to SOLID design principles

### 2.2 Classes and Objects
- **Immutability**: Favor immutable objects where possible
  - Use `final` fields
  - No setter methods
  - Defensive copying in constructors/getters for mutable objects
  - Consider using Java records (Java 14+)
- **Final Keyword**:
  - Mark classes `final` if not designed for inheritance
  - Mark methods `final` if shouldn't be overridden
  - Use `final` for method parameters and local variables where appropriate
- **Static Members**: Don't access static members through instance references
- **Constructors**:
  - Validate constructor parameters
  - Don't call overridable methods in constructors
  - Consider builder pattern for classes with many parameters

### 2.3 Interfaces and Abstract Classes
- **Interface Default Methods**: Use judiciously (Java 8+)
- **Functional Interfaces**: Use `@FunctionalInterface` annotation
- **Marker Interfaces**: Avoid unless truly needed (prefer annotations)
- **Interface Segregation**: Keep interfaces focused and cohesive

### 2.4 Enums
- **Use Enums** instead of int/String constants for fixed sets
- **Enum Best Practices**:
  - Add private constructors and fields for enum data
  - Implement methods for behavior rather than switch statements
  - Use `EnumSet` and `EnumMap` for collections
  - Override `toString()` if enum name isn't user-friendly

### 2.5 Generics
- **Type Safety**: Use generics to ensure compile-time type safety
- **Raw Types**: Never use raw types (e.g., `List` instead of `List<String>`)
- **Wildcards**: Use appropriately
  - `? extends T` for read-only (consumer)
  - `? super T` for write-only (producer)
  - PECS principle: Producer Extends, Consumer Super
- **Generic Methods**: Prefer generic methods over generic classes when possible
- **Type Erasure**: Be aware of type erasure limitations

### 2.6 Annotations
- **Standard Annotations**: Use appropriately
  - `@Override`: Always use when overriding
  - `@Deprecated`: Document with `@deprecated` javadoc and provide alternative
  - `@SuppressWarnings`: Use sparingly with narrow scope and justification
  - `@FunctionalInterface`: Mark functional interfaces
- **Custom Annotations**: Follow retention and target policies correctly
- **Null Safety**: Use `@NonNull`, `@Nullable` annotations (JSR-305, Checker Framework)

---

## 3. Exception Handling (Java-Specific)

### 3.1 Exception Hierarchy
- **Checked Exceptions**: Use for recoverable conditions
- **Unchecked Exceptions**: Use for programming errors
- **Never Catch**:
  - `Throwable`, `Error` (except in framework code)
  - `NullPointerException`, `IllegalStateException` (fix the cause)
  - Generic `Exception` without re-throwing

### 3.2 Exception Best Practices
- **Custom Exceptions**: Extend appropriate base exception class
- **Exception Messages**: Provide detailed, actionable messages
- **Exception Wrapping**: Preserve original exception as cause
- **Try-with-Resources**: Always use for `AutoCloseable` resources (Java 7+)
- **Multi-catch**: Use for identical handling (Java 7+)
- **Don't Swallow**: Never catch and ignore exceptions
- **Finally Blocks**: Avoid using with try-with-resources; don't return in finally

### 3.3 Resource Management
- **AutoCloseable**: Implement for custom resource classes
- **Try-with-Resources**: Verify all resources are properly closed
- **Connection Pooling**: Use for database connections, HTTP clients
- **File Handling**: Use NIO.2 (`java.nio.file`) for modern file operations

---

## 4. Collections and Data Structures

### 4.1 Collection Framework
- **Interface Types**: Declare with interface types (`List`, `Set`, `Map`)
- **Implementation Selection**:
  - `ArrayList` for random access, `LinkedList` for frequent insertions/deletions
  - `HashSet` for uniqueness, `TreeSet` for sorted order
  - `HashMap` for general use, `TreeMap` for sorted keys, `LinkedHashMap` for insertion order
  - `ConcurrentHashMap` for thread-safe operations
- **Immutable Collections**:
  - Use `Collections.unmodifiable*()` or `List.of()`, `Set.of()`, `Map.of()` (Java 9+)
  - Consider Guava's immutable collections
- **Empty Collections**: Return empty collections, not null (`Collections.empty*()` or `List.of()`)

### 4.2 Collection Best Practices
- **Initialization**: Specify initial capacity for large collections
- **Iteration**:
  - Use enhanced for-loop or forEach when index not needed
  - Use iterator's `remove()` method for safe removal during iteration
- **Null Elements**: Avoid putting null in collections when possible
- **Collection Utilities**: Leverage `Collections` utility class methods
- **Performance**:
  - Avoid repeated `toArray()` calls
  - Use `ArrayList.ensureCapacity()` for known sizes
  - Consider primitive collections (Eclipse Collections, Trove)

### 4.3 Streams API (Java 8+)
- **Use Streams** for data processing pipelines
- **Best Practices**:
  - Use method references over lambdas when clearer (`String::length`)
  - Don't modify external state in stream operations
  - Avoid side effects in forEach
  - Use parallel streams judiciously (not always faster)
  - Use collectors effectively (`Collectors.toList()`, `groupingBy()`, etc.)
- **Optional**: Use `Optional` return types for potentially absent values
  - Don't use `Optional` for fields or parameters
  - Don't call `get()` without checking `isPresent()` (prefer `orElse`, `orElseGet`, `ifPresent`)

---

## 5. Concurrency and Multithreading

### 5.1 Thread Safety
- **Synchronization**: Use synchronized blocks/methods appropriately
- **Volatile**: Use `volatile` for visibility guarantees
- **Immutability**: Prefer immutable objects for thread safety
- **Atomic Classes**: Use `java.util.concurrent.atomic` for lock-free thread safety
- **Thread-Safe Collections**: Use concurrent collections from `java.util.concurrent`

### 5.2 Executor Framework
- **Thread Pools**: Use `ExecutorService` instead of creating threads manually
- **Executors**: Choose appropriate executor type
  - `newFixedThreadPool` for bounded threads
  - `newCachedThreadPool` for many short-lived tasks
  - `newSingleThreadExecutor` for sequential execution
  - `ForkJoinPool` for recursive tasks (Java 7+)
- **Shutdown**: Always shutdown executor services properly

### 5.3 Modern Concurrency (Java 8+)
- **CompletableFuture**: Use for asynchronous programming
- **Virtual Threads**: Consider for high-concurrency scenarios (Java 21+)
- **Structured Concurrency**: Use structured concurrency APIs (Java 19+ preview)

### 5.4 Concurrency Issues
- **Deadlocks**: Verify proper lock ordering
- **Race Conditions**: Check for unsynchronized shared mutable state
- **Thread Leaks**: Ensure threads are properly cleaned up
- **Double-Checked Locking**: Use correctly or avoid (prefer enum singleton)

---

## 6. Java Standard Library Usage

### 6.1 String Handling
- **StringBuilder/StringBuffer**: Use for concatenation in loops
- **String Formatting**: Use `String.format()` or text blocks (Java 15+)
- **String Pool**: Avoid unnecessary `new String()` constructor
- **Intern**: Use `intern()` judiciously (memory implications)
- **Empty Strings**: Use `isEmpty()` or `isBlank()` (Java 11+), not `length() == 0`

### 6.2 Date and Time
- **Modern API**: Use `java.time` package (Java 8+), not `Date` or `Calendar`
- **Temporal Types**:
  - `LocalDate` for dates
  - `LocalTime` for times
  - `LocalDateTime` for timestamps
  - `ZonedDateTime` for timezone-aware
  - `Instant` for machine timestamps
- **Immutability**: All `java.time` classes are immutable and thread-safe
- **Parsing/Formatting**: Use `DateTimeFormatter`

### 6.3 Numbers and Math
- **BigDecimal**: Use for financial calculations (avoid float/double)
  - Create with `String` constructor, not `double`
  - Use `setScale()` with `RoundingMode`
- **Primitive Wrappers**: Avoid unnecessary boxing/unboxing
- **Math Utilities**: Use `Math` class methods instead of reinventing
- **Random**: Use `ThreadLocalRandom` for concurrent usage, or `SecureRandom` for security

### 6.4 I/O and NIO
- **NIO.2**: Prefer `java.nio.file` over `java.io.File`
- **Path**: Use `Path` and `Paths` for file system operations
- **Files Utility**: Leverage `Files` class for common operations
- **Streams**: Use `Stream<String>` for reading file lines
- **Character Encoding**: Always specify charset explicitly (use `StandardCharsets`)

---

## 7. Java Frameworks and Libraries

### 7.1 Spring Framework
- **Dependency Injection**: Use constructor injection over field injection
- **Annotations**: Use appropriate Spring annotations
  - `@Component`, `@Service`, `@Repository`, `@Controller`
  - `@Autowired` with constructor (preferred)
  - `@Value` for configuration properties
- **Configuration**: Use `@Configuration` classes over XML
- **Profiles**: Use `@Profile` for environment-specific beans
- **Transactions**: Use `@Transactional` appropriately (declarative over programmatic)
- **REST APIs**: Use `@RestController`, proper HTTP methods, and status codes

### 7.2 Spring Boot
- **Auto-configuration**: Leverage Spring Boot auto-configuration
- **Properties**: Use `application.properties` or `application.yml`
- **Starters**: Use appropriate Spring Boot starters
- **Actuator**: Include for production monitoring
- **Testing**: Use `@SpringBootTest`, `@WebMvcTest`, `@DataJpaTest`

### 7.3 JPA/Hibernate
- **Entity Design**:
  - Always include `@Id`
  - Use `@GeneratedValue` with appropriate strategy
  - Implement `equals()` and `hashCode()` based on business key
- **Relationships**: Use appropriate mappings (`@OneToMany`, `@ManyToOne`, etc.)
  - Use `FetchType.LAZY` by default
  - Avoid bidirectional relationships unless necessary
- **Queries**:
  - Use JPQL or Criteria API for database-independent queries
  - Use native queries sparingly
  - Check for N+1 query problems (use `JOIN FETCH`)
- **Transactions**: Ensure proper transaction boundaries

### 7.4 Lombok
- **Reduce Boilerplate**: Use appropriately but don't overuse
- **Common Annotations**:
  - `@Data` (use with caution, often too broad)
  - `@Getter`, `@Setter`
  - `@Builder`
  - `@Slf4j` for logging
  - `@RequiredArgsConstructor` for DI
- **Avoid**: `@ToString`, `@EqualsAndHashCode` on JPA entities

### 7.5 Testing Libraries
- **JUnit 5**: Use modern JUnit 5 (`@Test`, `@BeforeEach`, `@AfterEach`)
- **Assertions**: Use AssertJ or Hamcrest for fluent assertions
- **Mocking**: Use Mockito effectively
  - Use `@Mock`, `@InjectMocks` with `@ExtendWith(MockitoExtension.class)`
  - Verify behavior with `verify()`
  - Stub with `when().thenReturn()`
- **Test Naming**: Use descriptive names (`shouldReturnUserWhenUserExists`)

### 7.6 Mockito Best Practices for Modern Java
- **Interface-Based Mocking**: **ALWAYS mock interfaces, not concrete classes**
  - Mockito with inline mocks has limitations with concrete classes that have:
    - Constructor dependencies (especially with `@Value` or injection)
    - Final methods or final classes
    - Complex initialization logic
  - **Solution**: Extract an interface from classes that will be mocked
    ```java
    // ❌ BAD: Mocking concrete class with constructor dependencies
    @Mock
    private CustomerRepository repository; // May fail with Mockito inline mocks
    
    // ✅ GOOD: Mock the interface instead
    @Mock  
    private CustomerRepositoryInterface repository; // Always works
    ```

- **Repository Pattern**: When creating repositories with constructor injection:
  1. Create an interface defining the repository contract
  2. Have the implementation class implement the interface
  3. Inject and mock the interface in services and tests
    ```java
    // Interface for testability
    public interface CustomerRepositoryInterface {
        List<Customer> findAll();
        Optional<Customer> findById(String id);
        Customer save(Customer customer);
        boolean deleteById(String id);
    }
    
    // Implementation
    @Repository
    public class CustomerRepository implements CustomerRepositoryInterface {
        // Constructor with ObjectMapper, @Value, etc.
    }
    
    // Service uses interface
    @Service
    public class CustomerService {
        private final CustomerRepositoryInterface repository;
        
        public CustomerService(CustomerRepositoryInterface repository) {
            this.repository = repository;
        }
    }
    ```

- **Common Mockito Errors and Solutions**:
  | Error | Cause | Solution |
  |-------|-------|----------|
  | `MockitoException: Could not modify all classes` | Mocking concrete class with constructor dependencies | Extract interface and mock that |
  | `Mockito cannot mock this class` | Class is final or has final methods | Use interface or `mockito-inline` |
  | `You are seeing this disclaimer because Mockito is configured to create inlined mocks` | Mockito inline limitations | Design for testability with interfaces |

- **Spring Boot Testing Alternatives**:
  - For `@WebMvcTest`: Use `@MockBean` which works with Spring context
  - For integration tests: Use `@SpringBootTest` with `@MockBean`
  - For pure unit tests: Use interfaces with `@Mock`

---

## 8. Performance and Optimization

### 8.1 Memory Management
- **Object Creation**: Minimize unnecessary object creation
- **String Concatenation**: Use `StringBuilder` in loops
- **Autoboxing**: Avoid in performance-critical code
- **Collections**: Right-size collections with initial capacity
- **Weak/Soft References**: Use for caching scenarios
- **Memory Leaks**: Watch for static collections, listeners, thread locals

### 8.2 JVM Performance
- **Lazy Initialization**: Use only when beneficial
- **Class Loading**: Be aware of classloader implications
- **Reflection**: Minimize use (performance penalty)
- **Serialization**: Consider alternatives (Protocol Buffers, JSON)
- **JIT Compilation**: Write JIT-friendly code (avoid megamorphic call sites)

### 8.3 Database Performance
- **Connection Pooling**: Always use (HikariCP recommended)
- **Batch Operations**: Use for bulk inserts/updates
- **Indexing**: Ensure proper database indexes
- **Pagination**: Use for large result sets
- **Caching**: Implement appropriate caching strategy (Redis, Caffeine)

### 8.4 Profiling and Monitoring
- **Logging**: Use appropriate log levels
- **Metrics**: Instrument with Micrometer/Actuator
- **APM Tools**: Support for profiling tools (JProfiler, YourKit, VisualVM)

---

## 9. Security (Java-Specific)

### 9.1 Java Security Best Practices
- **Serialization**: 
  - Avoid Java serialization if possible (use JSON, Protocol Buffers)
  - Implement `serialVersionUID` if using serialization
  - Validate deserialized data
  - Use `ObjectInputFilter` (Java 9+)
- **Reflection**: Minimize usage (security and performance)
- **Class Loading**: Be cautious with custom classloaders
- **Security Manager**: Understand security manager implications (deprecated in Java 17)

### 9.2 Input Validation
- **SQL Injection**: Always use parameterized queries (PreparedStatement)
- **XSS Prevention**: Sanitize user input in web applications
- **Path Traversal**: Validate file paths, use `Path.normalize()`
- **Regular Expressions**: Validate regex to prevent ReDoS attacks

### 9.3 Cryptography
- **JCA/JCE**: Use Java Cryptography Architecture properly
- **Strong Algorithms**: Use modern algorithms (AES-256, SHA-256+, RSA-2048+)
- **SecureRandom**: Use for cryptographic operations
- **KeyStore**: Proper key management with KeyStore
- **SSL/TLS**: Ensure proper TLS configuration

---

## 10. Build Tools and Dependencies

### 10.1 Maven
- **POM Structure**: Proper project structure and inheritance
- **Dependency Management**: Use `<dependencyManagement>` for versions
- **Scope**: Use appropriate dependency scopes (`compile`, `test`, `provided`, `runtime`)
- **Plugins**: Keep plugin versions explicit
- **Properties**: Extract versions to properties
- **BOM**: Use Bill of Materials for framework dependencies

### 10.2 Gradle
- **Build Scripts**: Use Kotlin DSL or Groovy DSL consistently
- **Dependency Configurations**: Use appropriate configurations
- **Task Dependencies**: Proper task graph
- **Plugins**: Use version catalog for dependency management

### 10.3 Dependency Management
- **Version Control**: Pin dependency versions, avoid SNAPSHOT in production
- **Vulnerability Scanning**: Use OWASP Dependency-Check or Snyk
- **Minimal Dependencies**: Avoid dependency bloat
- **Transitive Dependencies**: Understand and manage transitive dependencies
- **Conflicts**: Resolve version conflicts explicitly

---

## 11. Code Quality Tools

### 11.1 Static Analysis
- **Checkstyle**: Enforce coding standards
- **PMD**: Detect code smells and potential bugs
- **SpotBugs**: Find bugs in bytecode
- **SonarQube**: Comprehensive code quality analysis
- **Error Prone**: Catch common Java mistakes at compile time

### 11.2 Code Coverage
- **JaCoCo**: Measure test coverage
- **Coverage Goals**: Aim for reasonable coverage (80%+ for critical code)
- **Coverage Quality**: Focus on meaningful tests, not just coverage numbers

### 11.3 Code Formatting
- **Google Java Format**: Consistent code formatting
- **Prettier Java**: Alternative formatter
- **IDE Formatters**: Configure consistently across team
- **EditorConfig**: Use for cross-IDE consistency

---

## 12. Documentation (Java-Specific)

### 12.1 Javadoc
- **Public API**: Always document public classes and methods
- **Standard Tags**: Use properly
  - `@param` for parameters
  - `@return` for return values
  - `@throws` for exceptions
  - `@deprecated` with alternative
  - `@since` for version tracking
  - `@see` for related elements
- **Code Examples**: Include `{@code}` examples where helpful
- **Links**: Use `{@link}` for cross-references
- **HTML**: Minimal HTML, focus on content
- **Package Documentation**: Include `package-info.java` for packages

### 12.2 Code Comments
- **When to Comment**: Explain "why", not "what"
- **TODO Comments**: Include ticket reference and assignee
- **Magic Numbers**: Extract to named constants with documentation
- **Complex Algorithms**: Document algorithm and complexity

---

## 13. Testing (Java-Specific)

### 13.1 Unit Testing
- **Test Structure**: Arrange-Act-Assert or Given-When-Then
- **Test Independence**: Each test should run independently
- **Test Data**: Use test data builders or fixtures
- **Parameterized Tests**: Use `@ParameterizedTest` for multiple inputs
- **Nested Tests**: Use `@Nested` for logical grouping

### 13.2 Integration Testing
- **Test Containers**: Use for database/external service testing
- **Spring Test**: Use Spring test support appropriately
- **Test Profiles**: Separate test configuration
- **Test Fixtures**: Manage test data properly

### 13.3 Test Quality
- **Assertion Libraries**: Use AssertJ for readable assertions
- **Test Naming**: Descriptive names (`shouldReturnErrorWhenUserNotFound`)
- **Fast Tests**: Keep unit tests fast (<1s), integration tests reasonable
- **Flaky Tests**: Fix or remove flaky tests immediately

---

## 14. Java-Specific Anti-Patterns

### 14.1 Common Anti-Patterns to Avoid
- **God Object**: Classes that know/do too much
- **Anemic Domain Model**: Domain objects without behavior
- **Stringly-Typed**: Using Strings instead of types (use enums, value objects)
- **Singleton Abuse**: Overusing singleton pattern (use DI instead)
- **Exception Swallowing**: Catching exceptions without handling
- **Premature Optimization**: Optimizing before measuring
- **Magic Numbers**: Hardcoded numbers without explanation
- **Copy-Paste Programming**: Duplicating code instead of refactoring
- **Swiss Army Knife**: Utility classes that do everything
- **Yo-yo Problem**: Deep inheritance hierarchies

### 14.2 Code Smells
- **Long Methods**: Methods should be short and focused
- **Long Parameter Lists**: Use parameter objects or builder pattern
- **Feature Envy**: Method uses another class's data more than its own
- **Data Clumps**: Groups of data that always appear together (create class)
- **Primitive Obsession**: Using primitives instead of value objects
- **Inappropriate Intimacy**: Classes too dependent on each other's internals

---

## 15. Java Review Checklist

### Critical (Must Fix)
- [ ] No raw types (use generics properly)
- [ ] All resources closed with try-with-resources
- [ ] No SQL injection vulnerabilities (use PreparedStatement)
- [ ] equals() and hashCode() implemented correctly
- [ ] No mutable static fields
- [ ] Proper exception handling (no swallowing)
- [ ] No hardcoded credentials or secrets
- [ ] Thread-safety for shared mutable state

### High Priority (Should Fix)
- [ ] Use modern Java features appropriate for target version
- [ ] Collections declared with interface types
- [ ] Proper use of Optional (no get() without checking)
- [ ] Immutable objects where possible
- [ ] Dependency injection over new keyword
- [ ] N+1 query problems resolved
- [ ] Proper transaction boundaries
- [ ] Javadoc for public API

### Medium Priority (Consider Fixing)
- [ ] Use method references over lambdas where clearer
- [ ] Use StringBuilder for string concatenation in loops
- [ ] Collections initialized with appropriate capacity
- [ ] Use EnumSet/EnumMap for enum collections
- [ ] Static imports for frequently used utilities
- [ ] Proper logging levels
- [ ] Test coverage for business logic

### Low Priority (Nice to Have)
- [ ] Use var for obvious types (Java 17+)
- [ ] Consider records for DTOs (Java 17+)
- [ ] Use text blocks for multi-line strings (Java 15+)
- [ ] Additional Javadoc examples
- [ ] Extract magic numbers to constants

---

## Review Process

1. **Language Features**: Verify appropriate Java version features are used
2. **Core Standards**: Check adherence to Java naming and structure conventions
3. **Framework Usage**: Validate Spring/JPA/library usage patterns
4. **Performance**: Identify obvious performance issues
5. **Security**: Java-specific security vulnerabilities
6. **Testing**: Quality and coverage of Java tests
7. **Documentation**: Javadoc completeness
8. **Anti-Patterns**: Detect and flag Java anti-patterns

---

**Note**: These guidelines assume Java 8+ as baseline. Adjust recommendations based on the actual Java version used in the project. Always consider the project's specific requirements and constraints when applying these guidelines.
