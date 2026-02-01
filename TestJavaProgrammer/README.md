# Customer Management API

[![CI Build and Test](https://github.com/alokkulkarni/copilotSkills/actions/workflows/ci.yml/badge.svg)](https://github.com/alokkulkarni/copilotSkills/actions/workflows/ci.yml)
[![CodeQL](https://github.com/alokkulkarni/copilotSkills/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/alokkulkarni/copilotSkills/actions/workflows/codeql-analysis.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java Version](https://img.shields.io/badge/Java-17-blue.svg)](https://openjdk.org/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.2-green.svg)](https://spring.io/projects/spring-boot)
[![Test Coverage](https://img.shields.io/badge/Tests-61%20passed-brightgreen.svg)]()

A production-ready Spring Boot REST API for customer management with local JSON file persistence, comprehensive testing, and Docker support.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Running the Application](#running-the-application)
- [Docker Support](#docker-support)
- [API Documentation](#api-documentation)
- [API Usage Examples](#api-usage-examples)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Features

- **RESTful CRUD API** - Create, Read, Update, and Delete customer records
- **Local JSON Persistence** - File-based storage (`customers.json`) for simplicity
- **Input Validation** - Jakarta Bean Validation with custom error responses
- **Pagination Support** - Paginated responses with metadata (page, size, totalElements, totalPages)
- **UUID Generation** - Automatic UUID generation for new customers
- **OpenAPI/Swagger** - Interactive API documentation with Swagger UI
- **Comprehensive Testing** - 61 unit and integration tests with 98% coverage
- **Thread-Safe Repository** - Synchronized file operations for concurrent access
- **Docker Ready** - Multi-stage Dockerfile with health checks and non-root user
- **CI/CD Pipelines** - GitHub Actions for build, test, and security analysis

## Prerequisites

- **Java 17** or higher (LTS recommended)
- **Maven 3.6+** (or use the included Maven wrapper)
- **Docker** (optional, for containerized deployment)

## Getting Started

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alokkulkarni/copilotSkills.git
   cd copilotSkills/TestJavaProgrammer
   ```

2. **Build the project**:
   ```bash
   mvn clean package
   ```

3. **Verify the build**:
   ```bash
   mvn test
   ```

## Running the Application

### Using Maven

```bash
mvn spring-boot:run
```

The application starts on `http://localhost:8080`.

### Using Java JAR

```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

## Docker Support

### Build Docker Image

```bash
# Build the application first
mvn clean package -DskipTests

# Build Docker image
docker build -t customer-api:latest .
```

### Run Docker Container

```bash
docker run -d \
  --name customer-api \
  -p 9292:9292 \
  -v $(pwd)/customers.json:/app/customers.json \
  customer-api:latest
```

### Docker Features

- **Multi-architecture support** (amd64, arm64)
- **Non-root user** for enhanced security
- **Health check endpoint** at `/actuator/health`
- **Optimized JVM settings** for containerized environments
- **Signal handling** via dumb-init

## API Documentation

Once running, access the interactive API documentation:

| Resource | URL |
|----------|-----|
| **Swagger UI** | http://localhost:8080/swagger-ui.html |
| **OpenAPI JSON** | http://localhost:8080/api-docs |
| **OpenAPI YAML** | http://localhost:8080/api-docs.yaml |

## API Usage Examples

### Create Customer

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

**Response** (201 Created):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "John Doe",
  "email": "john@example.com"
}
```

### Get All Customers (Paginated)

```bash
curl "http://localhost:8080/api/customers?page=0&size=10"
```

**Response** (200 OK):
```json
{
  "content": [...],
  "page": 0,
  "size": 10,
  "totalElements": 25,
  "totalPages": 3
}
```

### Get Customer by ID

```bash
curl http://localhost:8080/api/customers/{id}
```

### Update Customer

```bash
curl -X PUT http://localhost:8080/api/customers/{id} \
  -H "Content-Type: application/json" \
  -d '{"name": "John Updated", "email": "john.updated@example.com"}'
```

### Delete Customer

```bash
curl -X DELETE http://localhost:8080/api/customers/{id}
```

**Response**: 204 No Content

## Project Structure

```
TestJavaProgrammer/
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── controller/       # REST controllers
│   │   │   ├── exception/        # Exception handlers
│   │   │   ├── model/            # Domain models (Records)
│   │   │   ├── repository/       # Data access layer
│   │   │   └── service/          # Business logic
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/example/demo/
│           ├── testutil/         # Test utilities (CustomerTestBuilder)
│           ├── CustomerControllerTest.java
│           ├── CustomerServiceTest.java
│           ├── CustomerRepositoryTest.java
│           └── PageResponseTest.java
├── docs/
│   └── api/
│       └── openapi.yaml          # OpenAPI specification
├── .github/
│   └── workflows/                # CI/CD pipelines
├── Dockerfile                    # Multi-stage Docker build
├── pom.xml                       # Maven configuration
└── customers.json                # Data storage file
```

## Testing

The project includes comprehensive test coverage with **61 tests**:

### Test Categories

| Category | Tests | Description |
|----------|-------|-------------|
| **Controller Tests** | 17 | REST endpoint validation, error handling |
| **Service Tests** | 14 | Business logic, pagination |
| **Repository Tests** | 17 | File persistence, concurrent access |
| **Model Tests** | 13 | PageResponse pagination logic |

### Run Tests

```bash
# Run all tests
mvn test

# Run with coverage report
mvn test jacoco:report

# Run specific test class
mvn test -Dtest=CustomerControllerTest
```

### Test Features

- **@DisplayName annotations** for readable test names
- **@Nested classes** for logical grouping
- **@ParameterizedTest** for data-driven tests
- **Concurrent access tests** for thread-safety validation
- **Interface-based mocking** for reliable Mockito usage
- **CustomerTestBuilder** for centralized test data

## Configuration

### Application Properties

| Property | Default | Description |
|----------|---------|-------------|
| `server.port` | 8080 | Application port |
| `app.data.file` | customers.json | Data storage file path |

### Environment Variables

```bash
# Override port
export SERVER_PORT=9090

# Override data file location
export APP_DATA_FILE=/data/customers.json
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- **Issues**: [GitHub Issues](https://github.com/alokkulkarni/copilotSkills/issues)
- **Security**: See [SECURITY.md](SECURITY.md) for vulnerability reporting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Author**: Alok Kulkarni  
**Version**: 0.0.1-SNAPSHOT
