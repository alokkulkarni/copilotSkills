# Swift-Specific Code Review Guidelines

## Purpose
This document provides comprehensive Swift-specific code review guidelines to ensure adherence to Swift best practices, language features, iOS/macOS frameworks, and ecosystem standards.

---

## 1. Swift Language Standards and Best Practices

### 1.1 Swift Version and Features
- **Current Swift Version**: Verify project uses supported Swift version (5.5+ recommended)
- **Modern Swift Features**: Encourage use of modern Swift features
  - Swift 5.0+: Result type, raw strings, key path expressions
  - Swift 5.1+: Opaque return types (`some View`), property wrappers
  - Swift 5.2+: Callable values, key path member lookup
  - Swift 5.3+: Multiple trailing closures, synthesized Comparable conformance
  - Swift 5.4+: Result builders, improved implicit member syntax
  - Swift 5.5+: async/await, actors, structured concurrency
  - Swift 5.6+: Existential `any` keyword
  - Swift 5.7+: Regex literals, if let shorthand, generic parameters
  - Swift 5.9+: Macros, parameter packs
  - Swift 6.0+: Full data race safety, complete concurrency checking
- **Language Mode**: Check if using Swift 6 language mode for concurrency safety
- **Deprecated Features**: Flag usage of deprecated Swift features

### 1.2 Code Structure and Organization
- **File Organization**:
  - One primary type per file (extensions can be in separate files)
  - Group related functionality using `// MARK: -` comments
  - Order: Imports → Type Definition → Properties → Initializers → Methods → Extensions
- **MARK Comments**: Use to organize code sections
  ```swift
  // MARK: - Properties
  // MARK: - Lifecycle
  // MARK: - Public Methods
  // MARK: - Private Methods
  // MARK: - Protocol Conformance
  ```
- **Extensions**: Use for protocol conformance and logical grouping
- **Access Control**: Always specify access level explicitly (`private`, `fileprivate`, `internal`, `public`, `open`)

### 1.3 Naming Conventions (Swift-Specific)
- **Types**: PascalCase (`UserProfile`, `NetworkManager`, `PaymentViewController`)
- **Functions/Methods**: camelCase, start with verb (`fetchUsers`, `calculateTotal`, `isValid`)
- **Variables/Properties**: camelCase (`userName`, `totalPrice`, `isLoading`)
- **Constants**: camelCase for local, PascalCase for global (`let maxRetries`, `struct Constants`)
- **Enums**: 
  - PascalCase for enum name
  - camelCase for cases (`case success`, `case failure`, `case notFound`)
- **Protocols**: 
  - Nouns for capabilities (`Codable`, `Identifiable`)
  - Adjectives with "-able", "-ible" suffix (`Equatable`, `Hashable`)
  - "-ing" suffix for behavior (`Networking`, `Logging`)
  - "-Delegate", "-DataSource" suffix for delegation patterns
- **Type Parameters**: Single uppercase letter or descriptive (`T`, `Element`, `Key`, `Value`)
- **Boolean Variables**: Use "is", "has", "should", "can" prefixes (`isEnabled`, `hasChildren`, `shouldRefresh`)
- **Acronyms**: Treat as words (`var urlString` not `var uRLString`, `class HtmlParser` not `HTMLParser`)

---

## 2. Swift Core Language Features

### 2.1 Optionals
- **Use Optionals** to represent absence of value (not sentinel values)
- **Optional Binding**:
  - Prefer `if let` and `guard let` over force unwrapping
  - Use shorthand syntax: `if let name { }` (Swift 5.7+)
  - Chain multiple bindings: `if let name, let age, age > 18 { }`
- **Optional Chaining**: Use `?.` for graceful optional property access
- **Nil-Coalescing**: Use `??` for default values
- **Force Unwrapping**: Avoid `!` except when absolutely certain (IBOutlets, well-documented assumptions)
- **Implicitly Unwrapped Optionals**: Avoid `!` type except for IBOutlets and specific framework requirements
- **Optional Map/FlatMap**: Use for transformations

### 2.2 Value Types vs Reference Types
- **Structs (Value Types)**:
  - Prefer for data models, immutable data
  - Use for thread-safe data sharing
  - Automatic memberwise initializer
- **Classes (Reference Types)**:
  - Use when identity matters
  - Use for Objective-C interoperability
  - Required for inheritance
  - Use when reference semantics needed
- **Copy-on-Write**: Understand COW for collections
- **Mutability**: Prefer immutability (let over var)

### 2.3 Protocols and Protocol-Oriented Programming
- **Protocol-Oriented Design**: Favor protocols over class inheritance
- **Protocol Extensions**: Provide default implementations
- **Protocol Composition**: Combine protocols with `&` operator
- **Associated Types**: Use for generic protocol requirements
- **Protocol Inheritance**: Build hierarchies of protocols
- **Existential Types**: Use `any` keyword for clarity (Swift 5.6+)
- **Opaque Types**: Use `some` for hiding implementation details

### 2.4 Enumerations
- **Use Enums** for related values and state representation
- **Associated Values**: Store additional data with enum cases
  ```swift
  enum Result<T> {
      case success(T)
      case failure(Error)
  }
  ```
- **Raw Values**: Use for simple value mapping
- **Computed Properties**: Add computed properties to enums
- **Methods**: Add behavior directly to enums
- **CaseIterable**: Conform for iteration over cases
- **@unknown default**: Use in switches for future-proofing
- **Indirect Enums**: Use for recursive types

### 2.5 Properties
- **Stored Properties**: Simple value storage
- **Computed Properties**: Calculate values on access
  - Use for derived values
  - Provide getter and optional setter
  - Keep computation lightweight
- **Property Observers**: `willSet` and `didSet` for side effects
- **Lazy Properties**: Use `lazy var` for expensive initialization
- **Property Wrappers**: Use for reusable property logic
  - `@State`, `@Binding`, `@ObservedObject` (SwiftUI)
  - Custom wrappers for validation, caching
- **Type Properties**: Use `static` for shared state/constants
- **Private(set)**: Use for read-only public properties

### 2.6 Functions and Closures
- **Parameter Labels**: Use descriptive argument labels
  ```swift
  func move(from start: Point, to end: Point)
  ```
- **Default Parameters**: Provide sensible defaults
- **Variadic Parameters**: Use for variable argument counts
- **In-Out Parameters**: Use `inout` for mutation (sparingly)
- **Trailing Closures**: Use for single closure parameters
- **Multiple Trailing Closures**: Use for clarity (Swift 5.3+)
- **Autoclosures**: Use `@autoclosure` for deferred execution (sparingly)
- **Escaping Closures**: Mark with `@escaping` when necessary
- **Capture Lists**: Use `[weak self]` or `[unowned self]` to avoid retain cycles
- **Function Types**: Use as first-class citizens

### 2.7 Generics
- **Generic Functions**: Use for type-safe reusable code
- **Generic Types**: Create flexible data structures
- **Type Constraints**: Constrain with protocols (`T: Equatable`)
- **Where Clauses**: Add complex constraints
- **Associated Types**: Use in protocols for flexibility
- **Generic Subscripts**: Create flexible collection access
- **Phantom Types**: Use for compile-time type safety

---

## 3. Memory Management and Performance

### 3.1 Automatic Reference Counting (ARC)
- **Strong References**: Default behavior
- **Weak References**: Use `weak` to break retain cycles (delegates, parents)
- **Unowned References**: Use `unowned` when lifetime is guaranteed
- **Retain Cycles**: Always check closures for strong reference cycles
- **Capture Lists**: Use in closures `[weak self]` or `[unowned self]`
- **Closure Capture**: Understand capture semantics (value vs reference)

### 3.2 Memory Management Best Practices
- **Avoid Retain Cycles**:
  - Delegate pattern: weak delegate references
  - Closure captures: weak or unowned self
  - Parent-child relationships: weak child references
- **Manual Memory Management**: Avoid unless necessary
- **Instruments**: Profile with Instruments for leaks and allocations
- **Memory Warnings**: Handle `didReceiveMemoryWarning` in view controllers

### 3.3 Performance Optimization
- **Copy-on-Write**: Leverage for efficient value types
- **Lazy Evaluation**: Use `lazy` for expensive operations
- **String Performance**: Use `String` efficiently
  - Prefer string interpolation over concatenation
  - Use `ContiguousArray` for performance-critical code
- **Collection Performance**: Choose appropriate collection types
  - `Array` for ordered collections
  - `Set` for uniqueness and fast lookup
  - `Dictionary` for key-value pairs
- **Struct vs Class**: Prefer structs for performance (stack allocation)

---

## 4. Error Handling

### 4.1 Swift Error Handling
- **Error Protocol**: Define custom errors conforming to `Error`
- **Throwing Functions**: Use `throws` keyword
  ```swift
  func fetchData() throws -> Data
  ```
- **Do-Catch**: Handle errors with do-catch blocks
  ```swift
  do {
      let data = try fetchData()
  } catch {
      print("Error: \(error)")
  }
  ```
- **Try Variations**:
  - `try`: Standard error propagation
  - `try?`: Convert to optional (silences error)
  - `try!`: Force unwrap (crash on error, use sparingly)
- **Rethrows**: Use for functions taking throwing closures
- **Result Type**: Use for asynchronous error handling (pre-async/await)

### 4.2 Error Handling Best Practices
- **Specific Errors**: Define meaningful error types
- **Error Context**: Include relevant information in errors
- **Don't Silence**: Avoid `try?` unless truly optional
- **Propagate**: Let errors bubble up appropriately
- **Log Errors**: Always log unexpected errors
- **User-Facing**: Convert technical errors to user-friendly messages

---

## 5. Concurrency and Async Programming

### 5.1 Modern Concurrency (Swift 5.5+)
- **Async/Await**: Use for asynchronous operations
  ```swift
  func fetchUser() async throws -> User
  let user = try await fetchUser()
  ```
- **Task**: Create concurrent work units
- **Task Groups**: Manage multiple concurrent tasks
- **Actors**: Use for thread-safe mutable state
  ```swift
  actor UserCache {
      private var cache: [String: User] = [:]
  }
  ```
- **@MainActor**: Ensure UI updates on main thread
- **Sendable**: Mark types safe for concurrent access
- **AsyncSequence**: Handle asynchronous sequences

### 5.2 Legacy Concurrency (Grand Central Dispatch)
- **DispatchQueue**: Use for GCD operations (when async/await not available)
  - `DispatchQueue.main`: UI updates
  - `DispatchQueue.global()`: Background work
- **Dispatch Groups**: Coordinate multiple tasks
- **Semaphores**: Control resource access
- **Operations**: Use `Operation` and `OperationQueue` for complex dependencies

### 5.3 Concurrency Best Practices
- **Main Thread**: All UI updates must be on main thread
- **Background Work**: Offload heavy work from main thread
- **Race Conditions**: Protect shared mutable state
- **Deadlocks**: Avoid circular waiting
- **Actor Isolation**: Use actors for mutable state in concurrent code
- **Sendable Conformance**: Ensure types are thread-safe

### 5.4 Combine Framework (Reactive Programming)
- **Publishers**: Use for asynchronous event streams
- **Subscribers**: Handle published values
- **Operators**: Transform and combine publishers
- **@Published**: Property wrapper for observable values
- **Cancellables**: Store and manage subscriptions
- **AnyCancellable**: Type-erased cancellable
- **Migration**: Consider migrating to async/await for new code

---

## 6. SwiftUI

### 6.1 SwiftUI Basics
- **Views**: Conform to `View` protocol
- **Body**: Return `some View` from body property
- **View Modifiers**: Chain modifiers for styling
- **Composition**: Break complex views into smaller components
- **Preview Provider**: Include previews for all views
- **View Builders**: Use `@ViewBuilder` for flexible view composition

### 6.2 State Management
- **@State**: Use for view-local state
- **@Binding**: Use for two-way data flow
- **@ObservedObject**: Use for external reference type state
- **@StateObject**: Use to create and own observed objects
- **@EnvironmentObject**: Use for dependency injection
- **@Environment**: Access system-wide settings
- **@Published**: Mark observable properties in ObservableObject
- **Ownership**: Know when to use @StateObject vs @ObservedObject

### 6.3 SwiftUI Best Practices
- **Single Responsibility**: Keep views focused
- **Extract Subviews**: Break down complex views
- **Avoid Logic**: Keep business logic out of views
- **View Models**: Use MVVM pattern with ObservableObject
- **Preference Keys**: Use for child-to-parent communication
- **Animation**: Use `.animation()` and `withAnimation()`
- **Performance**: Avoid unnecessary view updates
  - Use `Equatable` for view optimization
  - Leverage `@State` and `@Binding` properly

---

## 7. UIKit (iOS/macOS)

### 7.1 View Controllers
- **Lifecycle**: Understand view controller lifecycle
  - `viewDidLoad`, `viewWillAppear`, `viewDidAppear`
  - `viewWillDisappear`, `viewDidDisappear`
- **Memory Management**: Release resources in `viewDidDisappear` or `deinit`
- **View Hierarchy**: Build programmatically or with Interface Builder
- **Segues**: Use for navigation with storyboards
- **Dependency Injection**: Pass dependencies via initializers

### 7.2 Views and Auto Layout
- **Programmatic UI**: Use Auto Layout constraints programmatically
- **Translates Autoresizing Mask**: Set to `false` for programmatic constraints
- **Constraint Priorities**: Use priorities for flexible layouts
- **Stack Views**: Prefer `UIStackView` for simple layouts
- **Safe Area**: Respect safe area layout guides
- **Compression Resistance**: Set appropriate content hugging/compression

### 7.3 UIKit Best Practices
- **MVC Pattern**: Separate model, view, and controller concerns
- **Delegation**: Use delegation pattern properly (weak delegates)
- **Notifications**: Use `NotificationCenter` for decoupled communication
- **Target-Action**: Use for control events
- **Storyboards vs Code**: Be consistent in project approach
- **Reusable Cells**: Register and dequeue table/collection view cells efficiently

---

## 8. iOS/macOS Frameworks

### 8.1 Foundation
- **String**: Use Swift String, not NSString
- **Collections**: Use Swift native collections
- **Date**: Use `Date` and `DateFormatter`
- **URL**: Use `URL` for web addresses and file paths
- **UserDefaults**: Use for simple persistence
- **FileManager**: Use for file operations
- **NotificationCenter**: Use for app-wide notifications
- **Bundle**: Access app resources

### 8.2 Networking
- **URLSession**: Use for network requests
  - `URLSession.shared` for simple requests
  - Custom sessions for advanced configuration
- **Async/Await**: Use modern async URLSession APIs
  ```swift
  let (data, response) = try await URLSession.shared.data(from: url)
  ```
- **Combine**: Use for reactive networking (legacy)
- **Error Handling**: Handle network errors gracefully
- **Reachability**: Check network connectivity
- **Security**: Use HTTPS, validate certificates

### 8.3 Data Persistence
- **UserDefaults**: Simple key-value storage
- **Codable**: Use for JSON/Plist serialization
- **Core Data**: Use for complex object graphs
  - Managed object context threading
  - Fetch requests optimization
  - Batch operations for performance
- **SwiftData**: Use for modern data persistence (iOS 17+)
- **FileManager**: Use for file-based storage
- **Keychain**: Use for sensitive data (passwords, tokens)

### 8.4 Testing
- **XCTest**: Use for unit and UI testing
- **Test Naming**: Use descriptive names (`testFetchUserReturnsValidUser`)
- **Arrange-Act-Assert**: Structure tests clearly
- **Mocking**: Create mock objects for dependencies
- **Asynchronous Testing**: Use `XCTestExpectation` or async test support
- **UI Testing**: Use `XCUITest` for UI automation
- **Code Coverage**: Aim for high coverage on business logic
- **Test Doubles**: Use protocols for dependency injection

---

## 9. Swift Package Manager and Dependencies

### 9.1 Swift Package Manager (SPM)
- **Package.swift**: Define package manifest correctly
- **Dependencies**: Specify version requirements properly
- **Targets**: Organize code into targets
- **Products**: Define library and executable products
- **Local Packages**: Use for modularization

### 9.2 Dependency Management
- **CocoaPods**: Traditional dependency manager
  - Keep Podfile.lock in version control
  - Specify versions explicitly
- **Carthage**: Decentralized dependency manager
- **Version Pinning**: Pin dependencies to specific versions
- **Vulnerability Scanning**: Check for security issues
- **Minimal Dependencies**: Avoid dependency bloat
- **License Compliance**: Verify compatible licenses

---

## 10. Code Quality and Style

### 10.1 Swift Style Guide
- **SwiftLint**: Use for automated style checking
- **Indentation**: 4 spaces (or 2, be consistent)
- **Line Length**: Maximum 120-140 characters
- **Spacing**: 
  - Space after colons in type annotations: `let name: String`
  - No space before colons: `func test(param: String)`
- **Braces**: Opening brace on same line
- **Commas**: Space after, not before
- **Operators**: Spaces around operators
- **Vertical Whitespace**: One blank line between methods

### 10.2 Code Organization
- **Import Statements**: Group and sort imports
  - System frameworks first
  - Third-party frameworks
  - Internal modules
- **Type Declarations**: One per file (generally)
- **Extensions**: Use for organizing code and protocol conformance
- **Nested Types**: Use for types only relevant to enclosing type

### 10.3 Documentation
- **Documentation Comments**: Use `///` for public APIs
- **Markup**: Use Swift markup syntax
  - `- Parameter name: Description`
  - `- Returns: Description`
  - `- Throws: Description`
  - `- Note:`, `- Warning:`, `- Important:`
- **Code Examples**: Include in documentation when helpful
- **README**: Document architecture, setup, and usage

---

## 11. Security (Swift/iOS Specific)

### 11.1 Data Security
- **Keychain**: Store sensitive data (passwords, tokens, keys)
- **Encryption**: Use CommonCrypto or CryptoKit
- **Data Protection**: Use file protection attributes
- **Secure Coding**: Validate and sanitize inputs
- **App Transport Security**: Configure ATS properly

### 11.2 Authentication and Authorization
- **Biometric Authentication**: Use LocalAuthentication framework
- **OAuth**: Implement OAuth flows securely
- **Token Storage**: Use Keychain for auth tokens
- **Certificate Pinning**: Implement for critical connections
- **Session Management**: Handle timeouts and logout

### 11.3 Privacy
- **Permissions**: Request only necessary permissions
- **Privacy Manifests**: Declare data usage (iOS 17+)
- **User Consent**: Obtain before accessing sensitive data
- **Data Minimization**: Collect only required data
- **Privacy Descriptions**: Provide clear `Info.plist` descriptions

---

## 12. Testing (Swift-Specific)

### 12.1 Unit Testing
- **XCTest Framework**: Use for unit tests
- **Test Structure**: Given-When-Then or Arrange-Act-Assert
- **Test Isolation**: Tests should be independent
- **Mock Objects**: Use protocols for testability
- **Test Coverage**: Aim for 70-80% coverage on business logic
- **Quick/Nimble**: Consider for BDD-style tests
- **Snapshot Testing**: Use for UI component testing

### 12.2 UI Testing
- **XCUITest**: Automated UI testing framework
- **Accessibility Identifiers**: Set for testable UI elements
- **Page Object Pattern**: Organize UI test code
- **Test Stability**: Avoid flaky tests with proper waits
- **Test Data**: Use test-specific data, not production

### 12.3 Performance Testing
- **XCTest Metrics**: Measure performance with `measure` blocks
- **Instruments**: Profile with Time Profiler, Allocations
- **Launch Time**: Monitor app launch performance
- **Memory Usage**: Watch for memory leaks and excessive allocation

---

## 13. Swift-Specific Anti-Patterns

### 13.1 Common Anti-Patterns to Avoid
- **Force Unwrapping**: Excessive use of `!` operator
- **Massive View Controller**: View controllers with too much responsibility
- **Stringly-Typed**: Using strings instead of enums or types
- **Pyramid of Doom**: Nested if-let statements (use guard instead)
- **Global State**: Mutable global variables
- **Singletons Abuse**: Overusing singleton pattern
- **God Objects**: Types that know/do too much
- **Notification Overuse**: Using NotificationCenter instead of delegates
- **Premature Optimization**: Optimizing before profiling

### 13.2 Code Smells
- **Long Parameter Lists**: Use parameter objects or builders
- **Long Methods**: Break down into smaller functions
- **Duplicate Code**: Extract into reusable functions
- **Magic Numbers**: Extract to named constants
- **Deep Nesting**: Use early returns and guard statements
- **Type Switching**: Use protocols and polymorphism instead
- **Optional Chaining Hell**: Refactor complex optional chains

---

## 14. iOS App Architecture Patterns

### 14.1 Common Patterns
- **MVC**: Model-View-Controller (UIKit default)
- **MVVM**: Model-View-ViewModel (SwiftUI preferred)
- **VIPER**: View-Interactor-Presenter-Entity-Router
- **Clean Architecture**: Layered architecture with dependency inversion
- **Coordinator**: Navigation coordination pattern
- **Redux/TCA**: Unidirectional data flow

### 14.2 Architecture Best Practices
- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Injection**: Pass dependencies explicitly
- **Protocol-Oriented**: Use protocols for abstraction
- **Testability**: Design for easy testing
- **Modularity**: Break app into modules/frameworks
- **Single Responsibility**: Each type has one responsibility

---

## 15. Swift Code Review Checklist

### Critical (Must Fix)
- [ ] No force unwrapping (`!`) without documented justification
- [ ] No retain cycles (check closure captures, delegates)
- [ ] All UI updates on main thread (@MainActor or DispatchQueue.main)
- [ ] Sensitive data stored in Keychain, not UserDefaults
- [ ] No hardcoded credentials or API keys
- [ ] Proper error handling (no silent failures)
- [ ] Thread-safe access to shared mutable state
- [ ] Memory warnings handled appropriately

### High Priority (Should Fix)
- [ ] Use modern Swift features (async/await, actors)
- [ ] Proper optional handling (prefer if-let, guard-let over !)
- [ ] Access control specified explicitly
- [ ] Value types (structs) preferred over reference types where appropriate
- [ ] Protocol-oriented design where beneficial
- [ ] Weak/unowned references for delegates
- [ ] Proper SwiftUI state management (@State, @StateObject, etc.)
- [ ] View controllers with reasonable size (<300 lines)

### Medium Priority (Consider Fixing)
- [ ] Use property wrappers for common patterns
- [ ] Extract complex closures to named functions
- [ ] Use enums instead of string/int constants
- [ ] Add MARK comments for code organization
- [ ] Documentation comments for public APIs
- [ ] Use guard for early exits instead of nested ifs
- [ ] Leverage Swift type inference appropriately
- [ ] Test coverage for business logic

### Low Priority (Nice to Have)
- [ ] Use trailing closure syntax where appropriate
- [ ] Use shorthand syntax (if-let shorthand, implicit returns)
- [ ] Consider using result builders for DSLs
- [ ] Add preview providers for SwiftUI views
- [ ] Use multiple trailing closures (Swift 5.3+)
- [ ] Consider using Swift 6 language mode for safety
- [ ] Extract view components in SwiftUI
- [ ] Use computed properties over getter methods

---

## 16. Platform-Specific Considerations

### 16.1 iOS Specific
- **App Lifecycle**: Handle background, foreground, termination
- **View Controllers**: Proper lifecycle management
- **Memory Warnings**: Respond to memory pressure
- **Push Notifications**: Implement properly with UNUserNotificationCenter
- **Background Tasks**: Use BackgroundTasks framework
- **Widgets**: WidgetKit best practices
- **App Extensions**: Proper extension architecture

### 16.2 macOS Specific
- **AppKit**: Use AppKit patterns and conventions
- **Menu Bar**: Proper menu organization
- **Windows**: Window management and restoration
- **Preferences**: Use standard preferences patterns
- **Drag and Drop**: Implement NS drag-and-drop APIs
- **Services**: Provide system services when appropriate

### 16.3 watchOS Specific
- **Complications**: Design efficient complications
- **Background Refresh**: Manage background updates
- **Performance**: Optimize for limited resources
- **Navigation**: Use appropriate navigation patterns

### 16.4 Cross-Platform
- **Conditional Compilation**: Use `#if os(iOS)` appropriately
- **Shared Code**: Maximize code sharing between platforms
- **Platform Differences**: Handle platform-specific APIs gracefully

---

## Review Process

1. **Language Features**: Verify appropriate Swift features are used
2. **Memory Management**: Check for retain cycles and memory issues
3. **Concurrency**: Validate thread safety and async patterns
4. **Framework Usage**: Ensure proper use of UIKit/SwiftUI/Foundation
5. **Architecture**: Verify separation of concerns and patterns
6. **Security**: Check for security vulnerabilities
7. **Performance**: Identify obvious performance issues
8. **Testing**: Review test coverage and quality
9. **Documentation**: Check documentation completeness
10. **Anti-Patterns**: Detect and flag Swift-specific anti-patterns

---

**Note**: These guidelines assume Swift 5.5+ and iOS 15+ as baseline. Adjust recommendations based on the actual Swift version and deployment target used in the project. Always consider the project's specific requirements, architecture patterns, and constraints when applying these guidelines.
