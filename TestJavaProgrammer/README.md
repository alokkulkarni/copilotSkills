# Demo Customer Service

[![CI Build and Test](https://github.com/alokkulkarni/copilotSkills/actions/workflows/ci.yml/badge.svg)](https://github.com/alokkulkarni/copilotSkills/actions/workflows/ci.yml)
[![CodeQL](https://github.com/alokkulkarni/copilotSkills/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/alokkulkarni/copilotSkills/actions/workflows/codeql-analysis.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java Version](https://img.shields.io/badge/Java-17-blue.svg)](https://openjdk.org/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.2-green.svg)](https://spring.io/projects/spring-boot)

A Spring Boot application that manages customer data using a local JSON file storage.

## Features
- REST API to Create, Read, Update, and Delete (CRUD) customers.
- Local file-based persistence (`customers.json`).
- Input validation and UUID generation.
- Pagination support with metadata.
- OpenAPI/Swagger documentation.
- Comprehensive test coverage.

## Prerequisites
- Java 17 or higher
- Maven 3.6+ (or use included wrapper if available)

## Getting Started

### Installation
1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd TestJavaProgrammer
   ```

### Running the Application
Run the application using Maven:
```bash
mvn spring-boot:run
```
The application will start on `http://localhost:8080`.

### API Documentation
Once running, access the Swagger UI at:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/api-docs
- **OpenAPI YAML**: http://localhost:8080/api-docs.yaml

## API Usage

### Add Customer
```bash
curl -X POST http://localhost:8080/api/customers \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "email": "alice@example.com"}'
```

### Get All Customers
```bash
curl http://localhost:8080/api/customers
```

### Update Customer
```bash
# Replace {id} with the actual ID
curl -X PUT http://localhost:8080/api/customers/{id} \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice Cooper", "email": "alice@cooper.com"}'
```

### Delete Customer
```bash
curl -X DELETE http://localhost:8080/api/customers/{id}
```

## License
MIT License - See [LICENSE](LICENSE) file for details.
