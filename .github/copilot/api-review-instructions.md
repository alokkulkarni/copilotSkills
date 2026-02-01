# API Design and Review Guidelines

## Purpose
This document provides comprehensive API design and review guidelines to ensure APIs are production-ready, following industry standards and best practices. These guidelines are language-agnostic and complement (not duplicate) language-specific and generic review instructions.

---

## 1. API Design Principles

### 1.1 REST API Design Principles
- **Resource-Based**: URLs represent resources, not actions
- **HTTP Methods**: Use appropriate HTTP verbs (GET, POST, PUT, PATCH, DELETE)
- **Stateless**: Each request contains all information needed
- **Uniform Interface**: Consistent structure across endpoints
- **Cacheable**: Responses indicate if they can be cached
- **Layered System**: Client cannot tell if connected directly to server or intermediary

### 1.2 GraphQL API Design Principles
- **Schema-First**: Define schema before implementation
- **Type Safety**: Strong typing throughout
- **Query Efficiency**: Allow clients to request exactly what they need
- **Single Endpoint**: One endpoint for all queries/mutations
- **Introspection**: Schema is self-documenting
- **Real-time**: Support subscriptions for real-time data

### 1.3 gRPC API Design Principles
- **Contract-First**: Define .proto files before implementation
- **Strongly Typed**: Protocol Buffers provide type safety
- **Bi-directional Streaming**: Support streaming in both directions
- **HTTP/2**: Leverage HTTP/2 benefits (multiplexing, server push)
- **Language Agnostic**: Support multiple languages
- **Efficient**: Binary serialization for performance

### 1.4 Universal API Principles
- **Consistency**: Consistent naming, structure, and behavior
- **Simplicity**: Easy to understand and use
- **Discoverability**: Self-documenting with clear documentation
- **Versioning**: Clear versioning strategy
- **Security**: Built-in security from the start
- **Performance**: Optimized for expected load
- **Reliability**: Handle errors gracefully
- **Observability**: Comprehensive logging and monitoring

---

## 2. API Endpoint Design (REST)

### 2.1 URL Structure

**Best Practices**:
```
✅ GOOD:
GET    /api/v1/users              # List users
GET    /api/v1/users/{id}         # Get specific user
POST   /api/v1/users              # Create user
PUT    /api/v1/users/{id}         # Update user (full)
PATCH  /api/v1/users/{id}         # Update user (partial)
DELETE /api/v1/users/{id}         # Delete user
GET    /api/v1/users/{id}/orders  # Get user's orders

❌ BAD:
GET    /api/v1/getUsers            # Action in URL
POST   /api/v1/user/create         # Action in URL
GET    /api/v1/users-list          # Inconsistent naming
PUT    /api/v1/updateUser/{id}     # Action in URL
DELETE /api/v1/removeUser          # Action in URL
```

**Rules**:
- [ ] Use nouns, not verbs in URLs
- [ ] Use plural nouns for collections (`/users`, not `/user`)
- [ ] Use lowercase letters
- [ ] Use hyphens for multi-word resources (`/order-items`, not `/orderItems` or `/order_items`)
- [ ] Keep URLs shallow (max 3 levels deep)
- [ ] Use path parameters for resource IDs (`/users/{id}`)
- [ ] Use query parameters for filtering, sorting, pagination

### 2.2 HTTP Methods Usage

**GET** - Retrieve resources:
```
GET /api/v1/users              # List all users
GET /api/v1/users/{id}         # Get specific user
GET /api/v1/users?status=active&page=1&limit=20  # Filtered list

Rules:
- [ ] Idempotent (multiple identical requests same as single)
- [ ] No request body
- [ ] Safe (no side effects)
- [ ] Cacheable
```

**POST** - Create resources:
```
POST /api/v1/users
Body: { "name": "John", "email": "john@example.com" }

Rules:
- [ ] Not idempotent (creates new resource each time)
- [ ] Request body contains resource data
- [ ] Returns 201 Created with Location header
- [ ] Returns created resource in response body
```

**PUT** - Update entire resource:
```
PUT /api/v1/users/{id}
Body: { "name": "John Doe", "email": "john@example.com", "status": "active" }

Rules:
- [ ] Idempotent
- [ ] Replaces entire resource
- [ ] All fields required in request body
- [ ] Returns 200 OK with updated resource
- [ ] Returns 404 if resource doesn't exist
```

**PATCH** - Partial update:
```
PATCH /api/v1/users/{id}
Body: { "email": "newemail@example.com" }

Rules:
- [ ] Idempotent (recommended)
- [ ] Updates only specified fields
- [ ] Other fields remain unchanged
- [ ] Returns 200 OK with updated resource
```

**DELETE** - Remove resource:
```
DELETE /api/v1/users/{id}

Rules:
- [ ] Idempotent
- [ ] No request body (typically)
- [ ] Returns 204 No Content (successful deletion)
- [ ] Returns 404 if resource doesn't exist
- [ ] Consider soft delete for data retention
```

### 2.3 Query Parameters

**Filtering**:
```
GET /api/v1/users?status=active
GET /api/v1/users?role=admin&status=active
GET /api/v1/products?category=electronics&price_min=100&price_max=500
```

**Sorting**:
```
GET /api/v1/users?sort=created_at
GET /api/v1/users?sort=-created_at           # Descending (- prefix)
GET /api/v1/users?sort=last_name,first_name  # Multiple fields
```

**Pagination**:
```
# Offset-based
GET /api/v1/users?page=2&limit=20
GET /api/v1/users?offset=40&limit=20

# Cursor-based (preferred for large datasets)
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ&limit=20
```

**Field Selection** (Sparse Fieldsets):
```
GET /api/v1/users?fields=id,name,email
GET /api/v1/users/{id}?fields=id,name,email,orders(id,total)
```

**Search**:
```
GET /api/v1/users?q=john
GET /api/v1/products?search=laptop&search_fields=name,description
```

---

## 3. Request and Response Design

### 3.1 Request Body Standards

**JSON Format** (Preferred):
```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "address": {
      "street": "123 Main St",
      "city": "New York",
      "country": "USA"
    },
    "tags": ["premium", "verified"]
  }
}
```

**Best Practices**:
- [ ] Use JSON as default format
- [ ] Use camelCase or snake_case consistently (choose one)
- [ ] Use meaningful field names
- [ ] Group related fields
- [ ] Use arrays for lists
- [ ] Use nested objects for complex structures
- [ ] Include only necessary data
- [ ] Validate all input fields

### 3.2 Response Body Standards

**Success Response**:
```json
{
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2026-01-31T13:00:00Z",
    "updated_at": "2026-01-31T13:00:00Z"
  },
  "meta": {
    "timestamp": "2026-01-31T13:00:00Z",
    "request_id": "abc-123-xyz"
  }
}
```

**List Response with Pagination**:
```json
{
  "data": [
    { "id": 1, "name": "User 1" },
    { "id": 2, "name": "User 2" }
  ],
  "meta": {
    "total": 150,
    "page": 1,
    "per_page": 20,
    "total_pages": 8
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "prev": null,
    "first": "/api/v1/users?page=1",
    "last": "/api/v1/users?page=8"
  }
}
```

**Error Response**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-01-31T13:00:00Z",
    "request_id": "abc-123-xyz"
  }
}
```

### 3.3 HTTP Status Codes

**Success Codes**:
```
200 OK              - Successful GET, PUT, PATCH, DELETE
201 Created         - Successful POST (resource created)
202 Accepted        - Async operation accepted
204 No Content      - Successful DELETE (no response body)
206 Partial Content - Partial response (range requests)
```

**Client Error Codes**:
```
400 Bad Request          - Invalid request (syntax, validation)
401 Unauthorized         - Authentication required or failed
403 Forbidden            - Authenticated but not authorized
404 Not Found            - Resource doesn't exist
405 Method Not Allowed   - HTTP method not supported
406 Not Acceptable       - Cannot produce requested format
409 Conflict             - Request conflicts with current state
410 Gone                 - Resource permanently deleted
422 Unprocessable Entity - Validation errors
429 Too Many Requests    - Rate limit exceeded
```

**Server Error Codes**:
```
500 Internal Server Error - Unexpected server error
502 Bad Gateway           - Invalid response from upstream
503 Service Unavailable   - Server temporarily unavailable
504 Gateway Timeout       - Upstream timeout
```

**Status Code Rules**:
- [ ] Use appropriate status codes
- [ ] Be consistent across endpoints
- [ ] Include error details in response body
- [ ] Use 4xx for client errors, 5xx for server errors
- [ ] Never expose internal error details in production

---

## 4. API Versioning

### 4.1 Versioning Strategies

**URI Versioning** (Recommended):
```
✅ GOOD:
/api/v1/users
/api/v2/users

Pros: Clear, explicit, easy to cache
Cons: URL changes with version
```

**Header Versioning**:
```
GET /api/users
Headers: Accept: application/vnd.myapi.v1+json

Pros: Clean URLs, flexible
Cons: Harder to test, less discoverable
```

**Query Parameter Versioning**:
```
GET /api/users?version=1

Pros: Simple, flexible
Cons: Can be forgotten, not RESTful
```

### 4.2 Versioning Best Practices

**Rules**:
- [ ] Choose one versioning strategy and stick to it
- [ ] Start with v1, not v0
- [ ] Increment major version for breaking changes
- [ ] Support at least 2 versions concurrently
- [ ] Announce deprecation well in advance (6-12 months)
- [ ] Document migration path between versions
- [ ] Use semantic versioning (major.minor.patch) in headers
- [ ] Never break existing clients without notice

**Breaking Changes** (require new version):
- Removing endpoints or fields
- Changing field types
- Changing response structure
- Changing authentication method
- Changing status codes for existing scenarios

**Non-Breaking Changes** (can be added to current version):
- Adding new endpoints
- Adding optional fields
- Adding optional query parameters
- Adding new response fields (at the end)
- Fixing bugs

---

## 5. Authentication and Authorization

### 5.1 Authentication Methods

**API Keys**:
```
Headers: X-API-Key: your-api-key-here

✅ Use for: Server-to-server communication
❌ Don't use for: User authentication in web/mobile apps
Security: Rotate regularly, secure storage
```

**OAuth 2.0** (Recommended for user authentication):
```
Headers: Authorization: Bearer <access_token>

Types:
- Authorization Code (for web apps)
- Client Credentials (for server-to-server)
- Refresh Token (for long-lived access)

✅ Use for: User authentication, third-party access
Security: Short-lived tokens, refresh tokens, scopes
```

**JWT (JSON Web Tokens)**:
```
Headers: Authorization: Bearer <jwt_token>

✅ Use for: Stateless authentication
Security: Signed tokens, short expiry, secure storage
```

**Basic Authentication**:
```
Headers: Authorization: Basic <base64(username:password)>

❌ Avoid in production
Only use with HTTPS for internal/test environments
```

### 5.2 Authorization Patterns

**Role-Based Access Control (RBAC)**:
```
Roles: admin, user, guest
Permissions assigned to roles

Example:
- admin: full access
- user: read/write own data
- guest: read-only public data
```

**Attribute-Based Access Control (ABAC)**:
```
Access based on attributes:
- User attributes (role, department)
- Resource attributes (owner, status)
- Environment attributes (time, location)

Example: Allow access if user.department == resource.department
```

**Scope-Based Authorization**:
```
OAuth scopes define permissions:
- read:users
- write:users
- admin:users

Token includes only granted scopes
```

### 5.3 Security Best Practices

**Authentication**:
- [ ] Always use HTTPS in production
- [ ] Never send credentials in URL parameters
- [ ] Implement rate limiting on auth endpoints
- [ ] Use secure token storage (httpOnly cookies, secure storage)
- [ ] Implement token expiration and refresh
- [ ] Log failed authentication attempts
- [ ] Implement account lockout after failed attempts
- [ ] Use strong password requirements
- [ ] Support multi-factor authentication (MFA)

**Authorization**:
- [ ] Verify authorization on every request
- [ ] Implement principle of least privilege
- [ ] Check permissions at resource level, not just endpoint
- [ ] Prevent horizontal privilege escalation (user accessing other user's data)
- [ ] Prevent vertical privilege escalation (user gaining admin access)
- [ ] Validate resource ownership
- [ ] Log authorization failures

---

## 6. Rate Limiting and Throttling

### 6.1 Rate Limit Implementation

**Response Headers**:
```
X-RateLimit-Limit: 1000         # Requests allowed in window
X-RateLimit-Remaining: 999      # Requests remaining
X-RateLimit-Reset: 1643720400   # Timestamp when limit resets
Retry-After: 3600               # Seconds until retry allowed
```

**Rate Limit Exceeded Response**:
```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1643720400
Retry-After: 3600

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please retry after 1 hour.",
    "retry_after": 3600
  }
}
```

### 6.2 Rate Limiting Strategies

**Fixed Window**:
```
1000 requests per hour
Window resets at fixed times (e.g., :00 minutes)

Pros: Simple to implement
Cons: Burst at window boundaries
```

**Sliding Window**:
```
1000 requests per rolling 60-minute window

Pros: Smoother rate limiting
Cons: More complex to implement
```

**Token Bucket**:
```
Bucket holds tokens
Each request consumes token
Tokens refill at fixed rate

Pros: Allows bursts, smooth over time
Cons: More complex
```

### 6.3 Rate Limiting Best Practices

**Rules**:
- [ ] Implement rate limiting on all public endpoints
- [ ] Use different limits for authenticated vs. anonymous users
- [ ] Higher limits for premium/paid users
- [ ] Lower limits for sensitive operations (auth, password reset)
- [ ] Include rate limit info in response headers
- [ ] Return clear error messages with retry time
- [ ] Document rate limits clearly
- [ ] Monitor rate limit hits
- [ ] Allow rate limit overrides for specific clients (with approval)

**Recommended Limits**:
```
Anonymous users:    100 requests/hour
Authenticated:      1000 requests/hour
Premium users:      10000 requests/hour
Authentication:     10 attempts/15 minutes
Password reset:     3 attempts/hour
```

---

## 7. Error Handling

### 7.1 Error Response Structure

**Standard Error Format**:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [],
    "documentation_url": "https://api.example.com/docs/errors/ERROR_CODE"
  },
  "meta": {
    "timestamp": "2026-01-31T13:00:00Z",
    "request_id": "abc-123-xyz",
    "path": "/api/v1/users"
  }
}
```

**Validation Error**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Invalid email format",
        "value": "not-an-email"
      },
      {
        "field": "age",
        "code": "OUT_OF_RANGE",
        "message": "Must be between 18 and 120",
        "value": 15
      }
    ]
  }
}
```

### 7.2 Error Codes

**Define Clear Error Codes**:
```
VALIDATION_ERROR          - Input validation failed
AUTHENTICATION_REQUIRED   - Authentication needed
INVALID_CREDENTIALS      - Wrong username/password
PERMISSION_DENIED        - Not authorized
RESOURCE_NOT_FOUND       - Resource doesn't exist
RESOURCE_CONFLICT        - Conflict with existing resource
RATE_LIMIT_EXCEEDED      - Too many requests
SERVER_ERROR             - Internal server error
SERVICE_UNAVAILABLE      - Service temporarily down
EXTERNAL_SERVICE_ERROR   - External dependency failed
```

### 7.3 Error Handling Best Practices

**Rules**:
- [ ] Use consistent error response structure
- [ ] Include machine-readable error codes
- [ ] Provide human-readable messages
- [ ] Include actionable details when possible
- [ ] Never expose internal error details (stack traces, DB errors)
- [ ] Log errors with sufficient context
- [ ] Include request_id for tracing
- [ ] Provide documentation URL for errors
- [ ] Use appropriate HTTP status codes
- [ ] Include timestamp in error responses
- [ ] Support internationalization for error messages
- [ ] Monitor error rates and patterns

**Security Considerations**:
```
❌ BAD: "User with email john@example.com not found"
✅ GOOD: "Invalid credentials"

❌ BAD: "SQL Error: Table 'users' doesn't exist"
✅ GOOD: "Internal server error" (log detailed error internally)

❌ BAD: Stack trace in production response
✅ GOOD: Generic error message (stack trace logged internally)
```

---

## 8. API Documentation

### 8.1 Documentation Standards

**Required Documentation**:
- [ ] API overview and purpose
- [ ] Authentication and authorization guide
- [ ] Base URL and versioning
- [ ] All endpoints with descriptions
- [ ] Request/response examples for each endpoint
- [ ] Error codes and meanings
- [ ] Rate limits
- [ ] Pagination details
- [ ] Filtering and sorting options
- [ ] Webhooks (if applicable)
- [ ] SDKs and client libraries
- [ ] Changelog
- [ ] Migration guides between versions

### 8.2 OpenAPI/Swagger Specification

**Use OpenAPI 3.0** for REST APIs:
```yaml
openapi: 3.0.3
info:
  title: User Management API
  version: 1.0.0
  description: API for managing users
  contact:
    email: api@example.com

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging

paths:
  /users:
    get:
      summary: List users
      description: Returns a paginated list of users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: integer
          example: 123
        email:
          type: string
          format: email
          example: user@example.com
        name:
          type: string
          example: John Doe
```

### 8.3 Documentation Best Practices

**Rules**:
- [ ] Keep documentation in sync with implementation
- [ ] Provide interactive documentation (Swagger UI, Postman)
- [ ] Include code examples in multiple languages
- [ ] Document all possible error responses
- [ ] Provide cURL examples
- [ ] Include authentication examples
- [ ] Document request/response headers
- [ ] Provide pagination examples
- [ ] Document webhook payloads
- [ ] Include rate limit information
- [ ] Provide sandbox/test environment
- [ ] Version documentation alongside API

---

## 9. Performance and Scalability

### 9.1 Response Time

**Performance Targets**:
```
GET requests:    < 200ms (p95)
POST requests:   < 500ms (p95)
PUT/PATCH:       < 500ms (p95)
DELETE:          < 300ms (p95)
List endpoints:  < 1000ms (p95)
```

### 9.2 Caching

**HTTP Caching Headers**:
```
# Cache for 1 hour
Cache-Control: public, max-age=3600

# Don't cache
Cache-Control: no-cache, no-store, must-revalidate

# Cache with validation
Cache-Control: private, max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 31 Jan 2026 12:00:00 GMT
```

**Caching Strategies**:
- [ ] Cache GET requests with appropriate TTL
- [ ] Use ETags for conditional requests
- [ ] Implement Last-Modified headers
- [ ] Use CDN for static responses
- [ ] Cache at multiple layers (API, database, CDN)
- [ ] Invalidate cache on updates
- [ ] Use cache keys that include version and parameters

### 9.3 Pagination

**Limit Results**:
```
# Default and maximum limits
Default page size: 20
Maximum page size: 100
Maximum offset: 10000

# Cursor-based for large datasets
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ&limit=20
```

### 9.4 Database Query Optimization

**Rules**:
- [ ] Use database indexes on frequently queried fields
- [ ] Implement query result caching
- [ ] Use connection pooling
- [ ] Avoid N+1 query problems
- [ ] Use database query explain plans
- [ ] Implement read replicas for read-heavy workloads
- [ ] Use appropriate isolation levels
- [ ] Monitor slow queries

### 9.5 Async Operations

**Long-Running Operations**:
```
POST /api/v1/reports
Response: 202 Accepted
{
  "job_id": "abc-123",
  "status": "processing",
  "status_url": "/api/v1/reports/abc-123/status"
}

GET /api/v1/reports/abc-123/status
Response: 200 OK
{
  "job_id": "abc-123",
  "status": "completed",
  "result_url": "/api/v1/reports/abc-123/download"
}
```

---

## 10. API Security

### 10.1 Security Checklist

**Transport Security**:
- [ ] Use HTTPS everywhere (TLS 1.2+)
- [ ] Implement HSTS headers
- [ ] Use secure cipher suites
- [ ] Validate SSL certificates

**Input Validation**:
- [ ] Validate all input data
- [ ] Sanitize user input
- [ ] Use allow-lists, not deny-lists
- [ ] Validate content-type headers
- [ ] Limit request body size
- [ ] Validate file uploads (type, size, content)

**Output Encoding**:
- [ ] Encode output data
- [ ] Set correct content-type headers
- [ ] Use Content-Security-Policy headers
- [ ] Prevent XSS in error messages

**SQL Injection Prevention**:
- [ ] Use parameterized queries
- [ ] Use ORM safely
- [ ] Validate and sanitize input
- [ ] Apply principle of least privilege to database users

**Authentication & Authorization**:
- [ ] Implement proper authentication
- [ ] Use strong token generation
- [ ] Implement token expiration
- [ ] Validate tokens on every request
- [ ] Check authorization at resource level
- [ ] Implement rate limiting on auth endpoints
- [ ] Log authentication failures

**Data Protection**:
- [ ] Encrypt sensitive data at rest
- [ ] Encrypt data in transit (HTTPS)
- [ ] Mask sensitive data in logs
- [ ] Implement proper key management
- [ ] Follow GDPR/privacy regulations

**API Security Headers**:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

### 10.2 OWASP API Security Top 10

**1. Broken Object Level Authorization**:
- [ ] Verify user can access specific resource
- [ ] Don't rely on client-provided IDs without validation
- [ ] Check ownership/permissions on every request

**2. Broken User Authentication**:
- [ ] Implement strong authentication mechanisms
- [ ] Use secure token generation
- [ ] Implement token expiration
- [ ] Protect against brute force attacks

**3. Excessive Data Exposure**:
- [ ] Return only necessary data
- [ ] Implement field filtering
- [ ] Don't expose internal object structures
- [ ] Review API responses for sensitive data

**4. Lack of Resources & Rate Limiting**:
- [ ] Implement rate limiting
- [ ] Set maximum request body size
- [ ] Limit pagination size
- [ ] Set timeout for operations

**5. Broken Function Level Authorization**:
- [ ] Verify user role/permissions for each endpoint
- [ ] Don't rely on client-side authorization
- [ ] Implement RBAC or ABAC
- [ ] Check authorization at function level

**6. Mass Assignment**:
- [ ] Use allow-lists for updatable fields
- [ ] Don't bind user input directly to objects
- [ ] Validate which fields can be updated by user
- [ ] Implement separate DTOs for input/output

**7. Security Misconfiguration**:
- [ ] Use secure default configurations
- [ ] Keep all software up to date
- [ ] Disable unnecessary features
- [ ] Review error messages for information disclosure

**8. Injection**:
- [ ] Use parameterized queries
- [ ] Validate and sanitize all input
- [ ] Use allow-lists for input validation
- [ ] Implement proper error handling

**9. Improper Assets Management**:
- [ ] Maintain API inventory
- [ ] Deprecate old API versions properly
- [ ] Document all endpoints
- [ ] Remove unused endpoints

**10. Insufficient Logging & Monitoring**:
- [ ] Log all authentication attempts
- [ ] Log authorization failures
- [ ] Monitor for unusual patterns
- [ ] Implement alerting for security events

---

## 11. API Testing

### 11.1 Testing Types

**Unit Tests**:
- [ ] Test individual functions and methods
- [ ] Mock external dependencies
- [ ] Test business logic
- [ ] Test validation logic
- [ ] Cover edge cases

**Integration Tests**:
- [ ] Test API endpoints
- [ ] Test database integration
- [ ] Test external service integration
- [ ] Test authentication/authorization
- [ ] Test error scenarios

**Contract Tests**:
- [ ] Verify API adheres to contract (OpenAPI spec)
- [ ] Test request/response schemas
- [ ] Test backward compatibility
- [ ] Consumer-driven contract testing

**Performance Tests**:
- [ ] Load testing (expected traffic)
- [ ] Stress testing (beyond capacity)
- [ ] Spike testing (sudden traffic increase)
- [ ] Endurance testing (sustained load)
- [ ] Test response times under load

**Security Tests**:
- [ ] Penetration testing
- [ ] Vulnerability scanning
- [ ] Authentication testing
- [ ] Authorization testing
- [ ] Input validation testing
- [ ] SQL injection testing
- [ ] XSS testing

### 11.2 Testing Best Practices

**Rules**:
- [ ] Automate API tests
- [ ] Test happy paths and error scenarios
- [ ] Test all HTTP methods
- [ ] Test all status codes
- [ ] Test with various input combinations
- [ ] Test boundary conditions
- [ ] Test authentication/authorization scenarios
- [ ] Test rate limiting
- [ ] Test pagination
- [ ] Test concurrent requests
- [ ] Test with real-world data volumes
- [ ] Include tests in CI/CD pipeline

**Test Data**:
- [ ] Use separate test database
- [ ] Reset test data between tests
- [ ] Use realistic test data
- [ ] Test with edge cases
- [ ] Test with invalid data
- [ ] Test with missing fields
- [ ] Test with extra fields

---

## 12. Monitoring and Observability

### 12.1 Logging

**What to Log**:
- [ ] All API requests (method, path, status, duration)
- [ ] Authentication attempts (success/failure)
- [ ] Authorization failures
- [ ] Input validation errors
- [ ] Server errors (with stack traces)
- [ ] External service calls
- [ ] Performance metrics
- [ ] Security events

**Log Format** (Structured JSON):
```json
{
  "timestamp": "2026-01-31T13:00:00.123Z",
  "level": "INFO",
  "request_id": "abc-123-xyz",
  "method": "GET",
  "path": "/api/v1/users/123",
  "status": 200,
  "duration_ms": 45,
  "user_id": "user-456",
  "ip": "192.168.1.1",
  "user_agent": "Mozilla/5.0..."
}
```

**What NOT to Log**:
- [ ] Passwords or secrets
- [ ] Authentication tokens (except last 4 chars)
- [ ] Credit card numbers
- [ ] Personal identifiable information (PII) in plain text
- [ ] Social security numbers
- [ ] Health information

### 12.2 Metrics

**Key Metrics to Track**:
```
Request Metrics:
- Total requests per second
- Requests per endpoint
- Request duration (p50, p95, p99)
- Error rate by status code

Performance Metrics:
- Response time percentiles
- Database query time
- External API call time
- Queue processing time

Business Metrics:
- Active users
- API usage per client
- Feature usage
- Conversion rates

Infrastructure Metrics:
- CPU usage
- Memory usage
- Network I/O
- Database connections
```

### 12.3 Distributed Tracing

**Implement Tracing**:
- [ ] Use correlation IDs across services
- [ ] Trace requests through entire system
- [ ] Track external service calls
- [ ] Identify bottlenecks
- [ ] Debug performance issues
- [ ] Use tools like Jaeger, Zipkin, or OpenTelemetry

### 12.4 Health Checks

**Health Check Endpoint**:
```
GET /health
Response: 200 OK
{
  "status": "healthy",
  "version": "1.2.3",
  "timestamp": "2026-01-31T13:00:00Z",
  "checks": {
    "database": "healthy",
    "cache": "healthy",
    "external_api": "healthy"
  }
}
```

**Readiness Check**:
```
GET /ready
Response: 200 OK or 503 Service Unavailable
{
  "ready": true,
  "dependencies": {
    "database": "connected",
    "cache": "connected"
  }
}
```

---

## 13. API Deprecation

### 13.1 Deprecation Process

**Steps**:
1. **Announce**: Notify users 6-12 months in advance
2. **Document**: Update documentation with deprecation notice
3. **Mark**: Add deprecation headers to responses
4. **Monitor**: Track usage of deprecated endpoints
5. **Support**: Provide migration guide and support
6. **Remove**: Remove after grace period

**Deprecation Headers**:
```
Deprecation: true
Sunset: Sat, 31 Jul 2026 23:59:59 GMT
Link: <https://api.example.com/docs/v2-migration>; rel="deprecation"
```

### 13.2 Migration Guide

**Provide Clear Migration Path**:
- [ ] Document all breaking changes
- [ ] Provide side-by-side comparison (old vs new)
- [ ] Include code examples for migration
- [ ] Offer tools for automated migration (if possible)
- [ ] Provide support channels
- [ ] Set clear timeline

---

## 14. API Review Checklist

### 14.1 Design Review

**Endpoint Design**:
- [ ] URLs use nouns, not verbs
- [ ] Consistent naming conventions
- [ ] Appropriate HTTP methods used
- [ ] RESTful resource hierarchy
- [ ] Clear and logical URL structure

**Request/Response**:
- [ ] Consistent request/response format
- [ ] Appropriate status codes
- [ ] Proper error handling
- [ ] Pagination implemented for lists
- [ ] Filtering and sorting supported

**Versioning**:
- [ ] Clear versioning strategy
- [ ] Version in URL or header
- [ ] Backward compatibility maintained
- [ ] Deprecation policy defined

### 14.2 Security Review

**Authentication & Authorization**:
- [ ] Proper authentication mechanism
- [ ] Token-based authentication implemented
- [ ] Authorization checks on all endpoints
- [ ] Principle of least privilege applied
- [ ] No sensitive data in URLs

**Data Protection**:
- [ ] HTTPS enforced
- [ ] Input validation on all endpoints
- [ ] Output encoding implemented
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection (where applicable)

**Rate Limiting**:
- [ ] Rate limiting implemented
- [ ] Appropriate limits set
- [ ] Rate limit headers included
- [ ] Clear error messages for rate limits

### 14.3 Performance Review

**Optimization**:
- [ ] Database queries optimized
- [ ] Appropriate indexes exist
- [ ] Caching implemented where appropriate
- [ ] Pagination for large datasets
- [ ] Connection pooling configured
- [ ] N+1 query problems avoided

**Response Times**:
- [ ] Response times within targets
- [ ] Slow query monitoring
- [ ] Performance testing completed
- [ ] Load testing results acceptable

### 14.4 Documentation Review

**Completeness**:
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Error codes documented
- [ ] Authentication guide included
- [ ] Rate limits documented
- [ ] OpenAPI/Swagger spec available
- [ ] Migration guides for versions
- [ ] Changelog maintained

### 14.5 Testing Review

**Coverage**:
- [ ] Unit tests for business logic
- [ ] Integration tests for endpoints
- [ ] Contract tests for API spec
- [ ] Performance tests completed
- [ ] Security tests conducted
- [ ] All HTTP methods tested
- [ ] Error scenarios tested
- [ ] Edge cases covered

### 14.6 Production Readiness

**Operational**:
- [ ] Monitoring implemented
- [ ] Logging configured properly
- [ ] Health check endpoint exists
- [ ] Alerting configured
- [ ] Distributed tracing set up
- [ ] Metrics collection enabled

**Reliability**:
- [ ] Error handling comprehensive
- [ ] Graceful degradation implemented
- [ ] Circuit breakers for external calls
- [ ] Retry logic implemented
- [ ] Timeout configurations set
- [ ] Disaster recovery plan exists

---

## 15. API Anti-Patterns

### 15.1 Common Mistakes to Avoid

**❌ Ignoring HTTP Methods**:
```
Bad: POST /api/v1/getUser
Good: GET /api/v1/users/{id}
```

**❌ Exposing Internal Implementation**:
```
Bad: GET /api/v1/users/database-table-id/123
Good: GET /api/v1/users/123
```

**❌ Poor Error Messages**:
```
Bad: { "error": "Error" }
Good: {
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "field": "email"
  }
}
```

**❌ Breaking Changes Without Version Bump**:
```
Bad: Removing field from v1 API
Good: Keep field in v1, remove in v2
```

**❌ No Rate Limiting**:
```
Bad: Unlimited requests allowed
Good: Rate limiting implemented with clear limits
```

**❌ Returning Too Much Data**:
```
Bad: Return entire user object with password hash
Good: Return only necessary fields, exclude sensitive data
```

**❌ Inconsistent Naming**:
```
Bad:
/api/v1/users
/api/v1/getUserOrders
/api/v1/product-list

Good:
/api/v1/users
/api/v1/users/{id}/orders
/api/v1/products
```

---

## 16. GraphQL-Specific Guidelines

### 16.1 Schema Design

**Best Practices**:
- [ ] Design schema first
- [ ] Use strong typing
- [ ] Provide clear descriptions for types and fields
- [ ] Use appropriate scalar types
- [ ] Implement proper null handling
- [ ] Use interfaces for common fields
- [ ] Use unions for polymorphic types

**Example Schema**:
```graphql
type User {
  id: ID!
  email: String!
  name: String
  orders(first: Int = 10, after: String): OrderConnection!
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(first: Int = 20, after: String): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): UserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UserPayload!
}
```

### 16.2 GraphQL Security

**Depth Limiting**:
- [ ] Limit query depth (e.g., max 5 levels)
- [ ] Prevent circular queries
- [ ] Implement query complexity analysis

**Cost Analysis**:
- [ ] Calculate query cost before execution
- [ ] Limit expensive queries
- [ ] Charge different costs for different fields

---

## 17. gRPC-Specific Guidelines

### 17.1 Proto File Design

**Best Practices**:
- [ ] Use appropriate field types
- [ ] Use enums for fixed sets of values
- [ ] Version services appropriately
- [ ] Provide clear comments
- [ ] Use oneof for mutually exclusive fields
- [ ] Use repeated for arrays

**Example Proto**:
```protobuf
syntax = "proto3";

package user.v1;

service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (User);
}

message User {
  string id = 1;
  string email = 2;
  string name = 3;
  int64 created_at = 4;
}

message GetUserRequest {
  string id = 1;
}
```

---

## Conclusion

Production-ready APIs require careful attention to design, security, performance, documentation, and observability. By following these guidelines, teams can build APIs that are:

- **Secure**: Protected against common vulnerabilities
- **Performant**: Fast and scalable
- **Reliable**: Handle errors gracefully
- **Well-Documented**: Easy to understand and use
- **Maintainable**: Easy to evolve and support
- **Observable**: Easy to monitor and debug

**Key Principles**:
1. **Consistency**: Maintain consistent patterns across all endpoints
2. **Security First**: Build security in from the start
3. **Performance**: Optimize for production load
4. **Documentation**: Keep docs in sync with implementation
5. **Monitoring**: Instrument for observability
6. **Testing**: Comprehensive testing at all levels
7. **Versioning**: Clear strategy for evolution

---

**Version**: 1.0  
**Last Updated**: 2026-01-31  
**Applies To**: REST, GraphQL, gRPC APIs across all languages
