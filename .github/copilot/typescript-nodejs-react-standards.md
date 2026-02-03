# TypeScript, Node.js & React Coding Standards

## Purpose
This instruction file defines coding standards and best practices for TypeScript-based applications including Node.js backend services and React frontend applications. These standards complement the generic coding instructions with TypeScript, Node.js, and React-specific guidelines.

---

## TypeScript Core Standards

### 1. TypeScript Configuration
- ✅ **Always use strict mode**: Enable `strict: true` in `tsconfig.json`
- ✅ **Target modern ECMAScript**: Use ES2020 or later
- ✅ **Enable strict null checks**: `strictNullChecks: true`
- ✅ **Enable no implicit any**: `noImplicitAny: true`
- ✅ **Enable strict function types**: `strictFunctionTypes: true`
- ✅ **Path mapping**: Use path aliases for cleaner imports (e.g., `@/components`, `@/utils`)
- ✅ **Source maps**: Always generate source maps for debugging
- ✅ **Declaration files**: Generate `.d.ts` files for libraries

### 2. Type Safety
- ✅ **Explicit types**: Always define explicit return types for functions
- ✅ **Avoid `any`**: Never use `any` type; use `unknown` if type is truly unknown
- ✅ **Type guards**: Use type guards for runtime type checking
- ✅ **Discriminated unions**: Use for complex state management
- ✅ **Generic constraints**: Apply proper constraints to generic types
- ✅ **Utility types**: Leverage built-in utility types (`Partial`, `Pick`, `Omit`, `Record`, etc.)
- ✅ **Const assertions**: Use `as const` for immutable literals
- ✅ **Type inference**: Let TypeScript infer types when obvious, but be explicit for public APIs

```typescript
// ✅ Good - Explicit return type
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Bad - No return type
function calculateTotal(items: Item[]) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ✅ Good - Using unknown instead of any
function processData(data: unknown): ProcessedData {
  if (isValidData(data)) {
    return transform(data);
  }
  throw new Error('Invalid data');
}
```

### 3. Interface vs Type
- ✅ **Prefer interfaces** for object shapes and class contracts
- ✅ **Use types** for unions, intersections, and mapped types
- ✅ **Consistent naming**: Interface names should be descriptive (no `I` prefix)
- ✅ **Extend vs intersection**: Use `extends` for interfaces, `&` for types

```typescript
// ✅ Good - Interface for object shape
interface User {
  id: string;
  name: string;
  email: string;
}

// ✅ Good - Type for unions
type Status = 'pending' | 'approved' | 'rejected';

// ✅ Good - Type for intersection
type AuditedUser = User & { createdAt: Date; updatedAt: Date };
```

### 4. Enums and Constants
- ✅ **Prefer const enums** for compile-time constants
- ✅ **Use string literal unions** over string enums when possible
- ✅ **Const objects**: Use `as const` for readonly objects
- ✅ **UPPER_SNAKE_CASE**: For true constants

```typescript
// ✅ Good - String literal union
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';

// ✅ Good - Const object with as const
const API_ENDPOINTS = {
  USERS: '/api/users',
  PRODUCTS: '/api/products',
} as const;

// ✅ Good - Const enum for numeric values
const enum StatusCode {
  OK = 200,
  NOT_FOUND = 404,
  SERVER_ERROR = 500,
}
```

---

## Node.js Backend Standards

### 1. Project Structure
```
src/
├── config/           # Configuration files
├── controllers/      # Route controllers
├── middleware/       # Express middleware
├── models/          # Data models/entities
├── routes/          # Route definitions
├── services/        # Business logic
├── utils/           # Utility functions
├── types/           # TypeScript type definitions
├── validators/      # Input validation schemas
└── index.ts         # Application entry point
```

### 2. Express.js Best Practices
- ✅ **Async error handling**: Use express-async-errors or async wrappers
- ✅ **Request validation**: Validate all inputs using libraries like `zod` or `joi`
- ✅ **Typed request/response**: Extend Express types for type safety
- ✅ **Middleware order**: Security → Logging → Parsing → Routes → Error handling
- ✅ **Environment variables**: Use `dotenv` and validate with schema
- ✅ **Graceful shutdown**: Handle SIGTERM and SIGINT signals
- ✅ **Health checks**: Implement `/health` and `/ready` endpoints

```typescript
// ✅ Good - Typed Express request handler
interface CreateUserRequest {
  body: {
    name: string;
    email: string;
  };
}

const createUser = async (
  req: Request<{}, {}, CreateUserRequest['body']>,
  res: Response
): Promise<void> => {
  const user = await userService.create(req.body);
  res.status(201).json(user);
};

// ✅ Good - Error handling middleware
const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  logger.error('Error:', err);
  
  if (err instanceof ValidationError) {
    res.status(400).json({ error: err.message });
    return;
  }
  
  res.status(500).json({ error: 'Internal server error' });
};
```

### 3. API Design
- ✅ **RESTful conventions**: Follow REST principles
- ✅ **Versioning**: Use URL versioning (`/api/v1/`)
- ✅ **HTTP status codes**: Use appropriate status codes
- ✅ **Pagination**: Implement for list endpoints
- ✅ **Rate limiting**: Implement rate limiting for public APIs
- ✅ **CORS**: Configure CORS properly
- ✅ **Request IDs**: Add correlation IDs for tracing

### 4. Database & ORM
- ✅ **Type-safe queries**: Use TypeORM, Prisma, or similar with full type safety
- ✅ **Connection pooling**: Configure connection pools
- ✅ **Migrations**: Use migrations for schema changes
- ✅ **Transactions**: Use transactions for multi-step operations
- ✅ **Indexes**: Define indexes for query optimization
- ✅ **Soft deletes**: Implement soft deletes when appropriate

### 5. Security
- ✅ **Input sanitization**: Sanitize all user inputs
- ✅ **SQL injection prevention**: Use parameterized queries
- ✅ **XSS prevention**: Escape output, use Content Security Policy
- ✅ **CSRF protection**: Implement CSRF tokens for state-changing operations
- ✅ **Authentication**: Use JWT or session-based auth with secure storage
- ✅ **Authorization**: Implement role-based access control
- ✅ **Helmet.js**: Use helmet for security headers
- ✅ **Secrets management**: Never commit secrets, use environment variables

### 6. Logging & Monitoring
- ✅ **Structured logging**: Use winston or pino with structured logs
- ✅ **Log levels**: Use appropriate log levels (error, warn, info, debug)
- ✅ **Request logging**: Log all incoming requests
- ✅ **Error tracking**: Integrate error tracking (Sentry, etc.)
- ✅ **Performance monitoring**: Track response times and resource usage
- ✅ **No sensitive data**: Never log passwords, tokens, or PII

---

## React Frontend Standards

### 1. Project Structure
```
src/
├── components/       # Reusable components
│   ├── common/      # Shared components
│   └── features/    # Feature-specific components
├── hooks/           # Custom React hooks
├── pages/           # Page components
├── services/        # API services
├── store/           # State management
├── types/           # TypeScript types
├── utils/           # Utility functions
├── styles/          # Global styles
└── App.tsx          # Root component
```

### 2. Component Standards
- ✅ **Functional components**: Always use function components (not class components)
- ✅ **TypeScript props**: Define explicit prop types with interfaces
- ✅ **Named exports**: Use named exports for better refactoring
- ✅ **One component per file**: Keep components focused
- ✅ **Props destructuring**: Destructure props in function signature
- ✅ **Default props**: Use default parameters instead of `defaultProps`
- ✅ **Prop types order**: Required props first, optional props last

```typescript
// ✅ Good - Properly typed React component
interface UserCardProps {
  user: User;
  onEdit: (userId: string) => void;
  className?: string;
  isLoading?: boolean;
}

export const UserCard: React.FC<UserCardProps> = ({
  user,
  onEdit,
  className = '',
  isLoading = false,
}) => {
  return (
    <div className={`user-card ${className}`}>
      {isLoading ? <Spinner /> : <UserDetails user={user} onEdit={onEdit} />}
    </div>
  );
};
```

### 3. Hooks Best Practices
- ✅ **Custom hooks**: Extract reusable logic into custom hooks
- ✅ **Hook naming**: Prefix custom hooks with `use`
- ✅ **Dependencies**: Always specify correct dependency arrays
- ✅ **useCallback**: Memoize callbacks passed to child components
- ✅ **useMemo**: Memoize expensive computations
- ✅ **useEffect cleanup**: Always cleanup subscriptions and timers
- ✅ **Conditional hooks**: Never call hooks conditionally

```typescript
// ✅ Good - Custom hook with proper typing
interface UseApiOptions<T> {
  url: string;
  initialData?: T;
}

interface UseApiReturn<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

export const useApi = <T,>({ url, initialData = null }: UseApiOptions<T>): UseApiReturn<T> => {
  const [data, setData] = useState<T | null>(initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetch(url);
      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
};
```

### 4. State Management
- ✅ **Local state first**: Use useState for component-local state
- ✅ **Context API**: Use Context for simple global state
- ✅ **State libraries**: Use Redux Toolkit, Zustand, or Jotai for complex state
- ✅ **Immutable updates**: Never mutate state directly
- ✅ **State colocation**: Keep state close to where it's used
- ✅ **Derived state**: Compute derived values instead of storing them

### 5. Performance Optimization
- ✅ **React.memo**: Memoize expensive components
- ✅ **Lazy loading**: Use `React.lazy` for code splitting
- ✅ **Virtualization**: Use virtualization for long lists
- ✅ **Image optimization**: Use next/image or similar for images
- ✅ **Bundle size**: Monitor and optimize bundle size
- ✅ **Avoid inline functions**: Extract functions that are passed as props

### 6. Styling
- ✅ **CSS Modules**: Use CSS Modules for component styles
- ✅ **Styled Components**: Or use styled-components/emotion for CSS-in-JS
- ✅ **Tailwind CSS**: Or use utility-first CSS with Tailwind
- ✅ **Responsive design**: Mobile-first responsive design
- ✅ **Theme**: Implement theme support with CSS variables or theme provider
- ✅ **Consistent spacing**: Use design tokens for spacing and colors

### 7. Forms
- ✅ **Form libraries**: Use react-hook-form or Formik
- ✅ **Validation**: Use zod or yup for schema validation
- ✅ **Controlled components**: Prefer controlled components
- ✅ **Error handling**: Display validation errors clearly
- ✅ **Loading states**: Show loading states during submission
- ✅ **Accessibility**: Proper labels and ARIA attributes

### 8. Testing
- ✅ **Unit tests**: Test components with React Testing Library
- ✅ **Integration tests**: Test user flows
- ✅ **Hook testing**: Test custom hooks with @testing-library/react-hooks
- ✅ **Mock API**: Mock API calls in tests
- ✅ **Accessibility testing**: Test with @testing-library/jest-dom
- ✅ **Coverage**: Aim for >80% code coverage

---

## Async/Await & Promises

### 1. Async Best Practices
- ✅ **Always use async/await**: Prefer over raw promises
- ✅ **Error handling**: Always use try-catch with async/await
- ✅ **Promise.all**: Use for parallel operations
- ✅ **Promise.allSettled**: Use when you need all results regardless of failures
- ✅ **Avoid blocking**: Never use blocking synchronous operations
- ✅ **Timeout handling**: Implement timeouts for external calls

```typescript
// ✅ Good - Proper async error handling
async function fetchUserData(userId: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    logger.error('Failed to fetch user data:', error);
    throw new Error('Unable to fetch user data');
  }
}

// ✅ Good - Parallel operations with Promise.all
async function fetchDashboardData(): Promise<DashboardData> {
  const [users, products, orders] = await Promise.all([
    fetchUsers(),
    fetchProducts(),
    fetchOrders(),
  ]);
  
  return { users, products, orders };
}
```

---

## Package Management

### 1. Dependencies
- ✅ **Lock files**: Always commit `package-lock.json` or `yarn.lock`
- ✅ **Exact versions**: Use exact versions for production dependencies
- ✅ **Security audits**: Run `npm audit` regularly
- ✅ **Update strategy**: Keep dependencies updated regularly
- ✅ **Dev vs prod**: Properly categorize dev and production dependencies
- ✅ **Peer dependencies**: Specify peer dependencies correctly

### 2. Package.json
- ✅ **Scripts**: Define clear npm scripts for common tasks
- ✅ **Engines**: Specify Node.js and npm versions
- ✅ **License**: Always include a license
- ✅ **Repository**: Include repository information
- ✅ **Types**: Include type definitions for published packages

---

## Error Handling

### 1. Custom Error Classes
- ✅ **Extend Error**: Create custom error classes extending Error
- ✅ **Error codes**: Use error codes for programmatic handling
- ✅ **Context**: Include relevant context in errors
- ✅ **Stack traces**: Preserve stack traces

```typescript
// ✅ Good - Custom error class
export class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
    public code: string = 'VALIDATION_ERROR'
  ) {
    super(message);
    this.name = 'ValidationError';
    Error.captureStackTrace(this, this.constructor);
  }
}

// ✅ Good - Error handling with custom errors
function validateEmail(email: string): void {
  if (!email.includes('@')) {
    throw new ValidationError('Invalid email format', 'email', 'INVALID_EMAIL');
  }
}
```

### 2. Error Boundaries (React)
- ✅ **Implement error boundaries**: Catch rendering errors
- ✅ **Fallback UI**: Provide meaningful fallback UI
- ✅ **Error reporting**: Report errors to monitoring service
- ✅ **Granular boundaries**: Use multiple error boundaries for different sections

---

## Code Quality Checks

### 1. Linting & Formatting
- ✅ **ESLint**: Configure ESLint with TypeScript support
- ✅ **Prettier**: Use Prettier for code formatting
- ✅ **Pre-commit hooks**: Use husky and lint-staged
- ✅ **Editor config**: Include `.editorconfig` file
- ✅ **Import order**: Configure import sorting

### 2. TypeScript Checks
- ❌ **No `any` type**: Avoid using `any`
- ❌ **No `@ts-ignore`**: Never use `@ts-ignore` or `@ts-nocheck`
- ❌ **No implicit returns**: All functions must have explicit return types
- ❌ **No unused variables**: Remove unused imports and variables
- ❌ **No console logs**: Remove console.log statements (use logger)

### 3. Code Smells
- ❌ **Large components**: Components should be < 200 lines
- ❌ **Deep nesting**: Avoid more than 3 levels of nesting
- ❌ **Long functions**: Functions should be < 50 lines
- ❌ **Magic numbers**: Replace magic numbers with named constants
- ❌ **Duplicate code**: Extract duplicate logic into functions
- ❌ **God objects**: Avoid classes/modules with too many responsibilities

---

## Testing Standards

### 1. Test Structure
- ✅ **Arrange-Act-Assert**: Follow AAA pattern
- ✅ **Descriptive names**: Use descriptive test names
- ✅ **One assertion**: Focus on one thing per test
- ✅ **Test isolation**: Tests should be independent
- ✅ **Mock external dependencies**: Mock API calls, databases, etc.

### 2. Coverage Requirements
- ✅ **Unit tests**: >80% coverage for business logic
- ✅ **Integration tests**: Cover critical user flows
- ✅ **E2E tests**: Cover main user journeys
- ✅ **Edge cases**: Test error conditions and edge cases

---

## Documentation

### 1. Code Documentation
- ✅ **TSDoc comments**: Use TSDoc for public APIs
- ✅ **README**: Comprehensive README with setup instructions
- ✅ **API documentation**: Generate API docs from code
- ✅ **Examples**: Include usage examples
- ✅ **Changelog**: Maintain CHANGELOG.md

### 2. Inline Comments
- ✅ **Why, not what**: Explain why, not what (code shows what)
- ✅ **Complex logic**: Comment complex algorithms
- ✅ **TODO comments**: Use TODO/FIXME with ticket references
- ✅ **Avoid obvious comments**: Don't comment obvious code

---

## Performance Considerations

### 1. Node.js Performance
- ✅ **Async operations**: Keep event loop non-blocking
- ✅ **Streaming**: Use streams for large data
- ✅ **Caching**: Implement caching strategies
- ✅ **Connection pooling**: Reuse database connections
- ✅ **Memory management**: Monitor memory usage
- ✅ **Profiling**: Profile performance bottlenecks

### 2. React Performance
- ✅ **Code splitting**: Split code by routes
- ✅ **Lazy loading**: Lazy load components
- ✅ **Memoization**: Memoize expensive computations
- ✅ **Virtual scrolling**: Use for long lists
- ✅ **Debounce/throttle**: For expensive operations
- ✅ **Web workers**: Use for CPU-intensive tasks

---

## Checklist for Code Review

### TypeScript Specific
- [ ] No `any` types used
- [ ] All functions have explicit return types
- [ ] Proper type guards for runtime checks
- [ ] Interfaces used for object shapes
- [ ] Types used for unions and intersections
- [ ] Strict mode enabled in tsconfig.json
- [ ] No `@ts-ignore` or `@ts-nocheck` comments

### Node.js Specific
- [ ] Async/await used for all async operations
- [ ] Proper error handling with try-catch
- [ ] Input validation implemented
- [ ] Environment variables properly configured
- [ ] Logging implemented with appropriate levels
- [ ] Security best practices followed
- [ ] Database queries are type-safe and parameterized

### React Specific
- [ ] Functional components used
- [ ] Props properly typed with interfaces
- [ ] Hooks follow rules of hooks
- [ ] Dependencies specified correctly in useEffect
- [ ] Components memoized where appropriate
- [ ] Accessibility attributes present
- [ ] Loading and error states handled
- [ ] Forms use proper validation

### General
- [ ] No hardcoded values (use config/environment)
- [ ] No console.log statements (use proper logging)
- [ ] Tests written and passing
- [ ] Code formatted with Prettier
- [ ] ESLint passes with no warnings
- [ ] Documentation updated
- [ ] No unused imports or variables
- [ ] Build completes without errors

---

## Common Anti-Patterns to Avoid

### TypeScript
- ❌ Using `any` instead of proper types
- ❌ Using `as` for type coercion without validation
- ❌ Ignoring TypeScript errors with comments
- ❌ Not enabling strict mode
- ❌ Using enums when const objects would suffice

### Node.js
- ❌ Blocking the event loop with synchronous operations
- ❌ Not handling promise rejections
- ❌ Exposing sensitive data in error messages
- ❌ Not validating user inputs
- ❌ Committing secrets to version control

### React
- ❌ Calling hooks conditionally
- ❌ Missing dependencies in useEffect
- ❌ Mutating state directly
- ❌ Creating components inside components
- ❌ Using array index as key
- ❌ Forgetting to cleanup effects

---

## Version Requirements
- **Node.js**: Use LTS version (18.x or 20.x)
- **TypeScript**: Use latest stable version (5.x)
- **React**: Use latest stable version (18.x)
- **Package Manager**: npm (9.x+), yarn (3.x+), or pnpm (8.x+)

---

## Summary
This document provides comprehensive TypeScript, Node.js, and React coding standards. All code must:
1. Use TypeScript with strict mode enabled
2. Follow type safety principles with no `any` types
3. Implement proper error handling and validation
4. Use modern React patterns with hooks
5. Follow security best practices
6. Include comprehensive tests
7. Be properly documented
8. Pass all linting and formatting checks

These standards ensure consistent, maintainable, and high-quality TypeScript applications across the team.
