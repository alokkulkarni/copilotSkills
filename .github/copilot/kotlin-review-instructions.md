# Kotlin-Specific Code Review Guidelines

## Purpose
This document provides comprehensive Kotlin-specific code review guidelines to ensure adherence to Kotlin best practices, language features, interoperability with Java, Android/JVM frameworks, and ecosystem standards.

---

## 1. Kotlin Language Standards and Best Practices

### 1.1 Kotlin Version and Features
- **Current Kotlin Version**: Verify project uses supported Kotlin version (1.7+ recommended, 1.9+ preferred)
- **Modern Kotlin Features**: Encourage use of modern Kotlin features
  - Kotlin 1.3+: Coroutines (stable), contracts, inline classes
  - Kotlin 1.4+: SAM conversions for Kotlin interfaces, trailing comma
  - Kotlin 1.5+: JVM records, sealed interfaces, value classes
  - Kotlin 1.6+: Suspend functions as supertypes, builder inference
  - Kotlin 1.7+: Context receivers (experimental), definitely non-nullable types
  - Kotlin 1.8+: Recursive type generics improvements
  - Kotlin 1.9+: Data objects, time marks API, enum class improvements
  - Kotlin 2.0+: K2 compiler, performance improvements
- **Language Features**: Use appropriate Kotlin idioms
- **Experimental Features**: Document usage of experimental APIs with `@OptIn`

### 1.2 Code Structure and Organization
- **File Naming**: PascalCase matching the primary class (`UserService.kt`)
- **Multiple Classes Per File**: Allowed if closely related
- **Top-Level Functions**: Use for utility functions (encouraged in Kotlin)
- **File Organization Order**:
  1. Package declaration
  2. Import statements (alphabetically sorted)
  3. Top-level constants
  4. Top-level functions
  5. Class declarations
  6. Extensions
- **Package Structure**: Organize by feature, not layer (package-by-feature preferred)

### 1.3 Naming Conventions (Kotlin-Specific)
- **Classes/Interfaces**: PascalCase (`UserRepository`, `PaymentService`)
- **Objects**: PascalCase (`DatabaseConfig`, `AppConstants`)
- **Functions**: camelCase starting with verb (`getUserById`, `calculateTotal`)
- **Properties**: camelCase (`userName`, `isActive`)
- **Constants**: 
  - UPPER_SNAKE_CASE for top-level and object constants
  - camelCase for const val in companion objects
- **Backing Properties**: Underscore prefix (`private val _users`, `val users`)
- **Type Parameters**: Single uppercase letter or descriptive (`T`, `E`, `K`, `V`, `Request`)
- **Boolean Properties**: Use "is", "has", "can", "should" prefixes
- **Extension Functions**: Descriptive names indicating extension (`String.toSha256()`)
- **Sealed Classes**: Suffix with state/result/event (`sealed class LoginState`)

---

## 2. Kotlin Core Language Features

### 2.1 Null Safety
- **Non-Nullable by Default**: Use nullable types (`?`) only when necessary
- **Safe Call Operator**: Use `?.` for null-safe calls
- **Elvis Operator**: Use `?:` for default values
  ```kotlin
  val length = text?.length ?: 0
  ```
- **Safe Casts**: Use `as?` instead of `as` when unsure
- **Not-Null Assertion**: Avoid `!!` operator except when absolutely certain
  - Document why `!!` is safe when used
  - Never use on external input
- **lateinit**: Use for non-nullable properties initialized later
  - Check `::property.isInitialized` before access if unsure
  - Only for `var` properties
- **Null Checks**: Use `requireNotNull()`, `checkNotNull()` for validation
- **Platform Types**: Be cautious with Java interop (nullability unknown)

### 2.2 Data Classes
- **Use Data Classes** for DTOs, value objects, and simple data containers
- **Automatic Methods**: Leverage auto-generated `equals()`, `hashCode()`, `toString()`, `copy()`
- **Primary Constructor**: Declare properties in primary constructor
- **Destructuring**: Use for multiple return values
  ```kotlin
  val (name, age) = user
  ```
- **Component Functions**: Auto-generated for data classes
- **Copy**: Use `copy()` for immutable updates
- **Validation**: Add `init` block for validation if needed
- **Avoid Mutable Data Classes**: Prefer `val` over `var` in data classes

### 2.3 Sealed Classes and Interfaces
- **Use Sealed Classes** for restricted hierarchies (states, results, events)
  ```kotlin
  sealed class Result<out T> {
      data class Success<T>(val data: T) : Result<T>()
      data class Error(val exception: Exception) : Result<Nothing>()
      object Loading : Result<Nothing>()
  }
  ```
- **Sealed Interfaces**: Use for more flexibility (Kotlin 1.5+)
- **Exhaustive When**: Sealed classes enable exhaustive when expressions
- **State Representation**: Ideal for state machines
- **Error Handling**: Use for typed error handling

### 2.4 Object Declarations
- **Singleton**: Use `object` for singletons
- **Companion Objects**: Use for factory methods and constants
  ```kotlin
  class User {
      companion object {
          fun create(name: String) = User(name)
      }
  }
  ```
- **Anonymous Objects**: Use for one-time implementations
- **Object Expressions**: Use for single-use object instances
- **Avoid Overuse**: Don't abuse singletons (prefer dependency injection)

### 2.5 Properties and Fields
- **Properties vs Fields**: Use Kotlin properties (getters/setters automatic)
- **Custom Accessors**: Define when needed
  ```kotlin
  val isEmpty: Boolean
      get() = size == 0
  ```
- **Backing Fields**: Use `field` keyword in custom accessors
- **Backing Properties**: Use underscore prefix for private backing property
  ```kotlin
  private val _items = mutableListOf<String>()
  val items: List<String> get() = _items
  ```
- **Late-Initialized Properties**: Use `lateinit` for non-nullable late initialization
- **Lazy Properties**: Use `by lazy` for expensive initialization
  ```kotlin
  val database by lazy { createDatabase() }
  ```
- **Delegated Properties**: Use property delegation for reusable patterns
- **const val**: Use for compile-time constants (primitives and strings only)

### 2.6 Functions
- **Single Expression Functions**: Use `=` syntax for single expressions
  ```kotlin
  fun square(x: Int) = x * x
  ```
- **Default Parameters**: Use instead of method overloading
  ```kotlin
  fun connect(timeout: Int = 1000, retries: Int = 3)
  ```
- **Named Arguments**: Use for clarity with multiple parameters
  ```kotlin
  connect(timeout = 5000, retries = 5)
  ```
- **Extension Functions**: Use to add functionality to existing classes
  ```kotlin
  fun String.toSlug() = lowercase().replace(" ", "-")
  ```
- **Infix Functions**: Use for DSL-like syntax (sparingly)
  ```kotlin
  infix fun Int.times(str: String) = str.repeat(this)
  // Usage: 2 times "Hello"
  ```
- **Operator Overloading**: Use judiciously for intuitive operations
- **Higher-Order Functions**: Functions that take/return functions
- **Inline Functions**: Use `inline` for higher-order functions with lambdas

### 2.7 Lambdas and Higher-Order Functions
- **Lambda Syntax**: Use concise lambda syntax
  ```kotlin
  items.filter { it.isActive }
  ```
- **Trailing Lambda**: Place lambda outside parentheses if last parameter
- **it Parameter**: Use for single-parameter lambdas
- **Explicit Parameters**: Use named parameters for clarity when needed
- **Function References**: Use `::` for method references
  ```kotlin
  items.map(String::toUpperCase)
  ```
- **Destructuring in Lambdas**: Use for data classes and pairs
  ```kotlin
  map.forEach { (key, value) -> println("$key: $value") }
  ```

### 2.8 Scope Functions
- **let**: Use for null checks and transformations
  ```kotlin
  user?.let { println(it.name) }
  ```
- **run**: Use for object configuration and computing result
- **with**: Use for calling multiple methods on object
- **apply**: Use for object configuration (returns object)
  ```kotlin
  val user = User().apply {
      name = "John"
      email = "john@example.com"
  }
  ```
- **also**: Use for side effects (returns object)
- **takeIf/takeUnless**: Use for conditional processing
- **Use Appropriately**: Don't chain excessively or nest deeply

---

## 3. Collections and Sequences

### 3.1 Kotlin Collections
- **Immutable by Default**: Use read-only collections
  - `List<T>` (read-only) vs `MutableList<T>`
  - `Set<T>` vs `MutableSet<T>`
  - `Map<K, V>` vs `MutableMap<K, V>`
- **Collection Builders**: Use builder functions
  ```kotlin
  val list = listOf(1, 2, 3)
  val map = mapOf("a" to 1, "b" to 2)
  ```
- **Mutable Collections**: Create explicitly when needed
  ```kotlin
  val mutableList = mutableListOf<String>()
  ```
- **Arrays**: Use sparingly (prefer lists)
  - Use `IntArray`, `ByteArray` for primitives (performance)
  - Use `arrayOf()` for object arrays

### 3.2 Collection Operations
- **Transformations**: `map`, `filter`, `flatMap`
- **Aggregations**: `reduce`, `fold`, `sum`, `count`
- **Grouping**: `groupBy`, `partition`
- **Sorting**: `sorted`, `sortedBy`, `sortedWith`
- **Finding**: `find`, `first`, `last`, `any`, `all`, `none`
- **Chaining**: Chain operations fluently
  ```kotlin
  users.filter { it.isActive }
       .map { it.name }
       .sorted()
  ```
- **Performance**: Consider using sequences for large collections

### 3.3 Sequences
- **Use Sequences** for large collections and chained operations
  ```kotlin
  val result = list.asSequence()
      .filter { it > 0 }
      .map { it * 2 }
      .toList()
  ```
- **Lazy Evaluation**: Sequences are lazily evaluated
- **Terminal Operations**: `toList()`, `toSet()`, `count()`, `forEach()`
- **When to Use**: Multiple operations on large collections
- **generateSequence**: Create infinite sequences

---

## 4. Coroutines and Concurrency

### 4.1 Kotlin Coroutines Basics
- **Suspend Functions**: Use `suspend` for async operations
  ```kotlin
  suspend fun fetchUser(): User
  ```
- **Coroutine Builders**:
  - `launch`: Fire-and-forget (returns Job)
  - `async`: Compute result (returns Deferred)
  - `runBlocking`: Bridge blocking/non-blocking (tests only)
- **Coroutine Scope**: Always launch in appropriate scope
  - `GlobalScope`: Avoid (ties to application lifetime)
  - `CoroutineScope`: Create custom scopes
  - `viewModelScope`, `lifecycleScope` (Android)
- **Structured Concurrency**: Parent waits for children

### 4.2 Coroutine Context and Dispatchers
- **Dispatchers**:
  - `Dispatchers.Main`: UI thread (Android)
  - `Dispatchers.IO`: IO operations (networking, files)
  - `Dispatchers.Default`: CPU-intensive work
  - `Dispatchers.Unconfined`: Don't use in production
- **Context Switching**: Use `withContext` to switch dispatchers
  ```kotlin
  suspend fun fetchData() = withContext(Dispatchers.IO) {
      // Network call
  }
  ```
- **Job**: Coroutine lifecycle handle
- **SupervisorJob**: Failure doesn't cancel siblings
- **CoroutineExceptionHandler**: Handle uncaught exceptions

### 4.3 Coroutine Best Practices
- **Cancellation**: Always support cancellation
  - Check `isActive` in loops
  - Use `ensureActive()` or `yield()`
- **Exception Handling**: Use try-catch in suspend functions
- **Structured Concurrency**: Launch in proper scopes
- **Resource Cleanup**: Use `finally` or `use` for cleanup
- **Testing**: Use `runTest` for coroutine tests (Kotlin 1.6+)
- **Flow**: Use for reactive streams
  ```kotlin
  fun observeUsers(): Flow<List<User>> = flow {
      emit(fetchUsers())
  }
  ```

### 4.4 Flow
- **Cold Streams**: Flows are cold (start on collection)
- **Operators**: `map`, `filter`, `flatMapConcat`, `combine`
- **Terminal Operators**: `collect`, `toList`, `first`, `fold`
- **StateFlow**: Hot flow for state (replaces LiveData)
- **SharedFlow**: Hot flow for events
- **flowOn**: Change dispatcher for upstream
- **Backpressure**: Handle with `buffer`, `conflate`, `collectLatest`

---

## 5. Kotlin and Java Interoperability

### 5.1 Calling Java from Kotlin
- **Platform Types**: Java types have unknown nullability (T!)
  - Specify nullability explicitly when calling Java
  - Use `@Nullable` and `@NonNull` annotations in Java
- **Getters/Setters**: Access as properties
  ```kotlin
  val name = javaObject.getName() // Java
  val name = javaObject.name      // Kotlin
  ```
- **Static Methods**: Access via class name
- **SAM Conversions**: Lambdas for single-method interfaces
  ```kotlin
  button.setOnClickListener { view -> /* ... */ }
  ```
- **Checked Exceptions**: Not checked in Kotlin
- **Java Primitives**: Mapped to Kotlin types automatically

### 5.2 Calling Kotlin from Java
- **@JvmStatic**: Make companion object members static
  ```kotlin
  companion object {
      @JvmStatic
      fun create() = User()
  }
  ```
- **@JvmField**: Expose property as field (no getter/setter)
- **@JvmOverloads**: Generate overloads for default parameters
  ```kotlin
  @JvmOverloads
  fun connect(timeout: Int = 1000)
  // Generates: connect() and connect(int)
  ```
- **@JvmName**: Specify custom JVM name
- **@Throws**: Declare checked exceptions for Java
  ```kotlin
  @Throws(IOException::class)
  fun readFile()
  ```
- **Top-Level Functions**: Compiled to static methods in `*Kt` class
- **@file:JvmName**: Customize class name for top-level functions
- **@file:JvmMultifileClass**: Combine multiple files

### 5.3 Interoperability Best Practices
- **Java-Friendly APIs**: Use `@Jvm*` annotations for Java consumption
- **Collections**: Use read-only interfaces for immutability signals
- **Nothing Type**: Mapped to `Void` in Java
- **Object**: Singleton accessible via `INSTANCE` field
- **Package Functions**: Accessible as static methods
- **Nullability Annotations**: Add to Java code for better Kotlin interop

---

## 6. Kotlin with Spring Framework

### 6.1 Spring Boot with Kotlin
- **Open Classes**: Use `open` or `all-open` plugin for Spring proxying
  - Spring requires classes to be open for CGLIB proxies
  - Use `kotlin-spring` plugin (makes `@Component`, `@Service`, etc. open)
- **Dependency Injection**:
  - **Constructor Injection**: Preferred (immutable properties)
    ```kotlin
    @Service
    class UserService(
        private val userRepository: UserRepository,
        private val emailService: EmailService
    )
    ```
  - Use `val` for dependencies (immutable)
  - No need for `@Autowired` on constructor
- **Nullable Injection**: Use nullable type if optional
  ```kotlin
  @Service
  class CacheService(
      private val cache: Cache?
  )
  ```

### 6.2 Spring Configuration
- **Configuration Classes**: Use `@Configuration` with Kotlin
  ```kotlin
  @Configuration
  class AppConfig {
      @Bean
      fun objectMapper(): ObjectMapper = ObjectMapper()
  }
  ```
- **Properties**: Use `@ConfigurationProperties` with data classes
  ```kotlin
  @ConfigurationProperties("app")
  data class AppProperties(
      val name: String,
      val timeout: Int = 1000
  )
  ```
- **Enable Configuration Processor**: Add kapt plugin
- **Validation**: Use `@Validated` with data classes

### 6.3 Spring Web (MVC/WebFlux)
- **REST Controllers**:
  ```kotlin
  @RestController
  @RequestMapping("/api/users")
  class UserController(private val userService: UserService) {
      
      @GetMapping("/{id}")
      fun getUser(@PathVariable id: Long): User {
          return userService.findById(id)
      }
      
      @PostMapping
      fun createUser(@RequestBody @Valid user: User): User {
          return userService.create(user)
      }
  }
  ```
- **Suspend Functions**: Use with Spring WebFlux (Kotlin 1.3+)
  ```kotlin
  @GetMapping("/{id}")
  suspend fun getUser(@PathVariable id: Long): User {
      return userService.findById(id)
  }
  ```
- **Flow**: Use Flow with WebFlux for streaming
  ```kotlin
  @GetMapping("/stream")
  fun streamUsers(): Flow<User> = userService.getAllUsers()
  ```
- **Extension Functions**: Use for response builders
- **Nullable Parameters**: Use for optional query parameters

### 6.4 Spring Data with Kotlin
- **Repository Interfaces**:
  ```kotlin
  interface UserRepository : JpaRepository<User, Long> {
      fun findByEmail(email: String): User?
      suspend fun findByUsername(username: String): User?
  }
  ```
- **Kotlin Extensions**: Use Spring Data Kotlin extensions
  ```kotlin
  val user = userRepository.findByIdOrNull(1)
  ```
- **Entity Classes**:
  - Use data classes with caution (JPA requires open classes)
  - Use `kotlin-jpa` plugin (makes `@Entity` open, no-arg constructor)
  - Use `val` for ID, `var` for mutable properties
  ```kotlin
  @Entity
  data class User(
      @Id @GeneratedValue
      val id: Long = 0,
      var name: String,
      var email: String
  )
  ```
- **Null Safety**: Return nullable types from queries
- **Coroutines**: Use suspend functions with R2DBC

### 6.5 Spring Testing with Kotlin
- **Test Configuration**:
  ```kotlin
  @SpringBootTest
  @AutoConfigureMockMvc
  class UserControllerTest {
      @Autowired
      lateinit var mockMvc: MockMvc
      
      @Test
      fun `should return user by id`() {
          mockMvc.get("/api/users/1")
              .andExpect { status { isOk() } }
      }
  }
  ```
- **Kotlin DSL**: Use Kotlin-specific test DSLs
- **MockK**: Prefer MockK over Mockito for Kotlin
- **lateinit**: Use for `@Autowired` test dependencies
- **Backticks**: Use for test method names with spaces

---

## 7. Kotlin for Android Development

### 7.1 Android-Specific Features
- **View Binding**: Use instead of findViewById
- **Kotlin Extensions**: (Deprecated, use View Binding)
- **Parcelize**: Use `@Parcelize` for Parcelable
  ```kotlin
  @Parcelize
  data class User(val name: String, val age: Int) : Parcelable
  ```
- **Android KTX**: Use AndroidX KTX extensions
  ```kotlin
  val uri = "https://example.com".toUri()
  ```

### 7.2 Activity and Fragment
- **Property Initialization**: Use `by lazy` or `lateinit`
  ```kotlin
  class MainActivity : AppCompatActivity() {
      private val binding by lazy { 
          ActivityMainBinding.inflate(layoutInflater) 
      }
      
      override fun onCreate(savedInstanceState: Bundle?) {
          super.onCreate(savedInstanceState)
          setContentView(binding.root)
      }
  }
  ```
- **View Binding**: Always use for view access
- **ViewModel**: Use `by viewModels()` delegate
  ```kotlin
  private val viewModel: UserViewModel by viewModels()
  ```

### 7.3 Android Architecture Components
- **ViewModel**:
  ```kotlin
  class UserViewModel : ViewModel() {
      private val _users = MutableLiveData<List<User>>()
      val users: LiveData<List<User>> = _users
      
      // Or with StateFlow
      private val _state = MutableStateFlow<UiState>(UiState.Loading)
      val state: StateFlow<UiState> = _state.asStateFlow()
  }
  ```
- **LiveData**: Use or migrate to StateFlow
- **Room Database**: Use with Kotlin
  ```kotlin
  @Dao
  interface UserDao {
      @Query("SELECT * FROM users")
      fun getAllUsers(): Flow<List<User>>
      
      @Insert
      suspend fun insert(user: User)
  }
  ```
- **Navigation Component**: Use with type-safe arguments

### 7.4 Jetpack Compose
- **Composable Functions**:
  ```kotlin
  @Composable
  fun UserProfile(user: User) {
      Column {
          Text(text = user.name)
          Text(text = user.email)
      }
  }
  ```
- **State Management**: Use `remember`, `mutableStateOf`
  ```kotlin
  var text by remember { mutableStateOf("") }
  ```
- **Side Effects**: Use `LaunchedEffect`, `DisposableEffect`
- **ViewModel Integration**: Use `viewModel()` or `hiltViewModel()`

---

## 8. Functional Programming in Kotlin

### 8.1 Functional Constructs
- **Higher-Order Functions**: Functions as parameters/return values
- **Pure Functions**: No side effects, same input → same output
- **Immutability**: Prefer immutable data structures
- **Function Composition**: Combine functions
- **Recursion**: Use tail recursion with `tailrec`
  ```kotlin
  tailrec fun factorial(n: Int, acc: Int = 1): Int =
      if (n <= 1) acc else factorial(n - 1, n * acc)
  ```

### 8.2 Functional Operators
- **map**: Transform elements
- **filter**: Select elements
- **reduce/fold**: Aggregate to single value
- **flatMap**: Transform and flatten
- **zip**: Combine collections
- **partition**: Split into two groups
- **groupBy**: Group by key

### 8.3 Arrow Library (Optional)
- **Either**: Represent success or failure
- **Option**: Null-safe alternative
- **Validated**: Accumulate errors
- **IO**: Pure functional effects
- **Use When**: Building functional architecture

---

## 9. DSLs (Domain-Specific Languages)

### 9.1 Creating DSLs
- **Type-Safe Builders**: Use lambda with receiver
  ```kotlin
  fun html(init: HTML.() -> Unit): HTML {
      val html = HTML()
      html.init()
      return html
  }
  ```
- **@DslMarker**: Prevent scope confusion
- **Infix Functions**: For DSL syntax
- **Extension Lambdas**: For builder patterns

### 9.2 Using DSLs
- **Ktor DSL**: For routing and server setup
- **Exposed DSL**: For SQL queries
- **kotlinx.html**: For HTML generation
- **Gradle Kotlin DSL**: For build scripts
- **Anko** (Legacy): For Android UI

---

## 10. Error Handling (Kotlin-Specific)

### 10.1 Exception Handling
- **All Exceptions Unchecked**: No checked exceptions in Kotlin
- **Try-Catch**: Standard exception handling
  ```kotlin
  try {
      riskyOperation()
  } catch (e: IOException) {
      handleError(e)
  } finally {
      cleanup()
  }
  ```
- **Try as Expression**: Returns value
  ```kotlin
  val result = try { parseString(input) } catch (e: Exception) { null }
  ```
- **Nothing Type**: For functions that never return
  ```kotlin
  fun fail(message: String): Nothing = throw IllegalStateException(message)
  ```

### 10.2 Result and Arrow
- **Result Type**: Standard library result wrapper
  ```kotlin
  fun divide(a: Int, b: Int): Result<Int> = try {
      Result.success(a / b)
  } catch (e: ArithmeticException) {
      Result.failure(e)
  }
  ```
- **runCatching**: Create Result from block
  ```kotlin
  val result = runCatching { riskyOperation() }
  ```
- **getOrElse/getOrNull**: Extract value safely
- **onSuccess/onFailure**: Handle results

### 10.3 Validation Functions
- **require**: Validate arguments (IllegalArgumentException)
  ```kotlin
  fun setAge(age: Int) {
      require(age > 0) { "Age must be positive" }
  }
  ```
- **check**: Validate state (IllegalStateException)
- **requireNotNull/checkNotNull**: Null checks
- **error**: Throw IllegalStateException

---

## 11. Performance Optimization

### 11.1 Kotlin-Specific Optimizations
- **Inline Functions**: Reduce overhead for higher-order functions
  ```kotlin
  inline fun <T> Iterable<T>.customFilter(predicate: (T) -> Boolean): List<T>
  ```
- **Inline Classes/Value Classes**: Zero-overhead wrappers
  ```kotlin
  @JvmInline
  value class UserId(val value: String)
  ```
- **Reified Type Parameters**: Access type info at runtime
  ```kotlin
  inline fun <reified T> isInstance(value: Any) = value is T
  ```
- **Sequences**: Lazy evaluation for collections
- **Primitive Arrays**: Use `IntArray`, `DoubleArray` not `Array<Int>`

### 11.2 Memory Optimization
- **Data Classes**: Efficient value objects
- **Object Declarations**: Singletons (single instance)
- **Lazy Initialization**: Defer expensive operations
- **Sequences**: Avoid intermediate collections
- **String Templates**: More efficient than concatenation

### 11.3 Compilation Optimization
- **Compiler Plugins**: kotlin-spring, kotlin-jpa, etc.
- **Incremental Compilation**: Enable in Gradle
- **Parallel Compilation**: Use Gradle parallel execution
- **Build Cache**: Enable Gradle build cache

---

## 12. Testing in Kotlin

### 12.1 Testing Frameworks
- **JUnit 5**: Standard for JVM testing
  ```kotlin
  @Test
  fun `should calculate sum correctly`() {
      val result = calculator.sum(2, 3)
      assertEquals(5, result)
  }
  ```
- **Kotest**: Kotlin-first testing framework
  ```kotlin
  class UserServiceTest : StringSpec({
      "should return user by id" {
          val user = userService.findById(1)
          user.name shouldBe "John"
      }
  })
  ```
- **Spek**: BDD framework for Kotlin
- **Backtick Names**: Use for descriptive test names

### 12.2 Mocking and Stubbing
- **MockK**: Kotlin-first mocking library
  ```kotlin
  @Test
  fun `should call repository`() {
      val repository = mockk<UserRepository>()
      every { repository.findById(1) } returns User(1, "John")
      
      val service = UserService(repository)
      val user = service.getUser(1)
      
      verify { repository.findById(1) }
      assertEquals("John", user.name)
  }
  ```
- **Relaxed Mocks**: Mock returns default values
  ```kotlin
  val mock = mockk<Service>(relaxed = true)
  ```
- **Spy**: Partial mocking
- **Slot**: Capture arguments

### 12.3 Coroutine Testing
- **runTest**: Test coroutines (Kotlin 1.6+)
  ```kotlin
  @Test
  fun `should fetch users`() = runTest {
      val users = userService.fetchUsers()
      assertTrue(users.isNotEmpty())
  }
  ```
- **TestCoroutineDispatcher**: Control coroutine execution
- **advanceUntilIdle**: Execute pending coroutines
- **Turbine**: Test Flow emissions
  ```kotlin
  @Test
  fun `should emit users`() = runTest {
      userFlow.test {
          assertEquals(emptyList(), awaitItem())
          assertEquals(listOf(user), awaitItem())
      }
  }
  ```

### 12.4 Property-Based Testing
- **Kotest Property Testing**: Generate test cases
  ```kotlin
  property("reversing twice returns original") {
      forAll<String> { str ->
          str.reversed().reversed() == str
      }
  }
  ```

---

## 13. Build Tools and Dependencies

### 13.1 Gradle with Kotlin DSL
- **build.gradle.kts**: Use Kotlin DSL over Groovy
  ```kotlin
  plugins {
      kotlin("jvm") version "1.9.0"
      kotlin("plugin.spring") version "1.9.0"
  }
  
  dependencies {
      implementation("org.jetbrains.kotlin:kotlin-stdlib")
      implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.0")
  }
  ```
- **Type-Safe Configuration**: Leverage IDE support
- **Extension Functions**: Use for custom configuration
- **Version Catalogs**: Centralize dependency versions
- **buildSrc**: Share build logic

### 13.2 Kotlin Compiler Plugins
- **kotlin-spring**: Makes Spring annotations open
- **kotlin-jpa**: Makes JPA entities open, adds no-arg constructor
- **kotlin-allopen**: Custom all-open annotations
- **kotlin-noarg**: Custom no-arg constructor annotations
- **kotlin-serialization**: Kotlinx serialization support
- **Parcelize**: Android Parcelable support

### 13.3 Dependency Management
- **Kotlin Standard Library**: Always included
- **Coroutines**: kotlinx-coroutines-core
- **Serialization**: kotlinx-serialization-json
- **DateTime**: kotlinx-datetime
- **Dependency Scope**: Use appropriate configurations
  - `implementation`: Private dependency
  - `api`: Exposed to consumers
  - `compileOnly`: Compile-time only
  - `runtimeOnly`: Runtime only

---

## 14. Code Quality and Static Analysis

### 14.1 Detekt
- **Static Analysis**: Kotlin-specific linter
- **Configuration**: `.detekt.yml` for rules
- **Rule Sets**: Complexity, style, performance, etc.
- **Custom Rules**: Create project-specific rules
- **Baseline**: Establish baseline for legacy code
- **CI Integration**: Run in CI pipeline

### 14.2 Ktlint
- **Code Formatting**: Kotlin style guide enforcement
- **Auto-Format**: Fix issues automatically
- **EditorConfig**: Configure via `.editorconfig`
- **Pre-Commit Hook**: Format before commit
- **CI Integration**: Fail build on violations

### 14.3 Android Lint (for Android)
- **Android-Specific**: Checks for Android issues
- **Custom Lint Rules**: Create project-specific checks
- **Suppress Warnings**: Use `@SuppressLint` sparingly

### 14.4 SonarQube
- **Code Quality**: Comprehensive analysis
- **Kotlin Support**: Use SonarKotlin plugin
- **Technical Debt**: Track and reduce debt
- **Security**: Detect security vulnerabilities

---

## 15. Documentation

### 15.1 KDoc
- **Documentation Comments**: Use `/**` for KDoc
  ```kotlin
  /**
   * Calculates the sum of two integers.
   *
   * @param a the first number
   * @param b the second number
   * @return the sum of a and b
   * @throws IllegalArgumentException if inputs are negative
   */
  fun sum(a: Int, b: Int): Int
  ```
- **Tags**: 
  - `@param`: Document parameters
  - `@return`: Document return value
  - `@throws`: Document exceptions
  - `@see`: Cross-reference
  - `@sample`: Include code samples
  - `@property`: Document properties
- **Markdown**: Use Markdown in KDoc
- **Links**: Use `[ClassName]` for links

### 15.2 Dokka
- **API Documentation**: Generate HTML/Markdown docs
- **Configuration**: Configure in build.gradle.kts
- **Multi-Module**: Support multi-module projects
- **Custom Formats**: JSON, Javadoc-style

---

## 16. Kotlin-Specific Anti-Patterns

### 16.1 Common Anti-Patterns
- **Excessive `!!` Usage**: Defeats null safety purpose
- **lateinit Abuse**: Use lazy or nullable instead when appropriate
- **Mutable Collections**: Expose mutable collections publicly
- **Data Class Misuse**: Using for entities with behavior
- **Long Functions**: Not leveraging extension functions
- **Callback Hell**: Not using coroutines
- **Platform Types**: Not handling Java nullability
- **Scope Function Abuse**: Overusing or nesting scope functions
- **Companion Object Abuse**: Using as namespace for unrelated functions
- **Global State**: Mutable global variables

### 16.2 Code Smells
- **God Objects**: Classes doing too much
- **Long Parameter Lists**: Not using data classes or builders
- **Primitive Obsession**: Not using value classes or type aliases
- **Magic Numbers**: Hardcoded numbers without names
- **Nullable Boolean**: Use sealed class or enum instead
- **Deep Nesting**: Not using early returns or when expressions
- **Mutable Data Classes**: Using `var` in data classes
- **Blocking Calls**: In coroutine scopes

---

## 17. Kotlin Multiplatform (Optional)

### 17.1 Common Code
- **expect/actual**: Platform-specific implementations
  ```kotlin
  // Common
  expect fun platformName(): String
  
  // JVM
  actual fun platformName() = "JVM"
  
  // JS
  actual fun platformName() = "JavaScript"
  ```
- **Common Dependencies**: Use multiplatform libraries
- **Shared Logic**: Business logic in common module

### 17.2 Platform-Specific
- **Platform Modules**: JVM, JS, Native
- **Gradle Configuration**: Configure source sets
- **Interop**: Platform-specific interoperability

---

## 18. Kotlin Code Review Checklist

### Critical (Must Fix)
- [ ] No use of `!!` without clear justification and safety guarantee
- [ ] No mutable collections exposed publicly (use read-only interfaces)
- [ ] Proper null safety (no ignoring platform types from Java)
- [ ] All coroutines launched in appropriate scope (no GlobalScope)
- [ ] Coroutine cancellation supported in long-running operations
- [ ] No blocking calls in coroutine context
- [ ] Proper exception handling in suspend functions
- [ ] Spring classes properly configured (all-open plugin or manual `open`)
- [ ] No hardcoded credentials or secrets

### High Priority (Should Fix)
- [ ] Use data classes for DTOs and value objects
- [ ] Use sealed classes for state representation
- [ ] Prefer immutability (`val` over `var`)
- [ ] Use extension functions to extend functionality
- [ ] Proper use of scope functions (not nested/overused)
- [ ] Use `when` expressions over if-else chains
- [ ] Constructor injection for Spring dependencies
- [ ] Proper use of lateinit (only when necessary)
- [ ] Use sequences for large collection operations
- [ ] Flow instead of LiveData for new code

### Medium Priority (Consider Fixing)
- [ ] Single-expression functions use `=` syntax
- [ ] Named arguments for functions with multiple parameters
- [ ] Default parameters instead of overloading
- [ ] Use trailing lambdas appropriately
- [ ] Use `by lazy` for expensive initialization
- [ ] Backing properties for mutable collections
- [ ] Use value classes for type-safe primitives
- [ ] Proper KDoc for public APIs
- [ ] Use `require`/`check` for validation
- [ ] Avoid deep nesting (use early returns)

### Low Priority (Nice to Have)
- [ ] Use infix functions for DSL-like code
- [ ] Use operator overloading where intuitive
- [ ] Extract constants to companion objects
- [ ] Use type aliases for complex types
- [ ] Use destructuring declarations
- [ ] Consider using Arrow for functional patterns
- [ ] Use property delegation for common patterns
- [ ] Add `@JvmStatic`, `@JvmOverloads` for Java interop
- [ ] Use string templates instead of concatenation
- [ ] Consider multiline strings for long text

---

## 19. Android-Specific Kotlin Checklist

### Critical (Must Fix)
- [ ] No memory leaks (check lifecycle awareness)
- [ ] All UI updates on main thread
- [ ] Proper lifecycle handling in coroutines
- [ ] View binding instead of findViewById
- [ ] No activity/context leaks in background work

### High Priority (Should Fix)
- [ ] Use ViewModel for UI state
- [ ] Use StateFlow/LiveData for observable data
- [ ] Room queries return Flow or suspend functions
- [ ] Proper Parcelable implementation with @Parcelize
- [ ] Use AndroidX KTX extensions

---

## 20. Spring Framework Kotlin Checklist

### Critical (Must Fix)
- [ ] `kotlin-spring` plugin enabled (or manual `open`)
- [ ] `kotlin-jpa` plugin for JPA entities
- [ ] Constructor injection used

### High Priority (Should Fix)
- [ ] Use `@ConfigurationProperties` with data classes
- [ ] Suspend functions for async endpoints (WebFlux)
- [ ] Nullable types for optional dependencies
- [ ] Use Spring Data Kotlin extensions
- [ ] Proper transaction boundaries

---

## Review Process

1. **Language Features**: Verify appropriate Kotlin idioms are used
2. **Null Safety**: Check proper handling of nullability
3. **Coroutines**: Validate structured concurrency and cancellation
4. **Java Interop**: Verify proper interoperability patterns
5. **Spring Integration**: Check Spring-specific configurations (if applicable)
6. **Android**: Validate lifecycle and architecture components (if applicable)
7. **Collections**: Ensure immutability and proper collection usage
8. **Testing**: Review test quality with Kotlin testing tools
9. **Performance**: Identify optimization opportunities
10. **Anti-Patterns**: Detect and flag Kotlin-specific anti-patterns

---

**Note**: These guidelines assume Kotlin 1.7+ as baseline with coroutines and Flow. Adjust recommendations based on the actual Kotlin version, target platform (JVM, Android, JS, Native), and frameworks used in the project. Always consider the project's specific requirements and constraints when applying these guidelines.
