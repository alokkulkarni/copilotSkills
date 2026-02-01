# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Database persistence option (PostgreSQL/MySQL)
- User authentication and authorization
- Rate limiting
- Caching layer

## [0.0.2] - 2026-02-01

### Added
- Comprehensive test suite with 61 tests
- `CustomerTestBuilder` utility for centralized test data
- `@DisplayName` annotations for human-readable test names
- `@Nested` classes for logical test organization
- `@ParameterizedTest` for validation scenarios
- Concurrent access tests for thread-safety validation
- Domain object tests for `PageResponse` with Customer records
- Interface-based mocking (`CustomerServiceInterface`, `CustomerRepositoryInterface`)
- Multi-stage Dockerfile with security best practices
- Health check endpoint support
- Non-root user in Docker container
- OpenAPI specification file (`docs/api/openapi.yaml`)

### Changed
- Controller tests now use standalone MockMvc (faster execution)
- Improved error handling with detailed validation messages
- Enhanced pagination with `PageResponse` record

### Fixed
- Mockito mocking issues with concrete classes (now uses interfaces)
- ApplicationContext loading issues in tests

## [0.0.1] - 2026-02-01

### Added
- Initial project structure with Spring Boot 3.2.2
- Customer model using Java Record
- Local file-based repository (`customers.json`)
- REST Controller with full CRUD operations:
  - `GET /api/customers` - List all customers (paginated)
  - `GET /api/customers/{id}` - Get customer by ID
  - `POST /api/customers` - Create new customer
  - `PUT /api/customers/{id}` - Update existing customer
  - `DELETE /api/customers/{id}` - Delete customer
- Service layer for business logic
- Global exception handler with structured error responses
- Input validation using Jakarta Bean Validation
- UUID auto-generation for new customers
- Pagination support with metadata
- OpenAPI/Swagger documentation integration
- GitHub Actions CI/CD workflows
- MIT License
