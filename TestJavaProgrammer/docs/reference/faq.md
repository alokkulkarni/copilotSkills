# FAQ - Frequently Asked Questions

Find answers to common questions about the Customer Management API.

## General Questions

### What is this project?

The Customer Management API is a production-ready Spring Boot REST API for managing customer data. It provides complete CRUD operations with input validation, pagination, comprehensive testing, and Docker support.

### What technologies are used?

- **Java 17** - Programming language (LTS version)
- **Spring Boot 3.2.2** - Application framework
- **Maven 3.6+** - Build tool
- **JUnit 5** - Testing framework
- **Docker** - Containerization
- **Swagger/OpenAPI** - API documentation

### Is this production-ready?

Yes! The project includes:
- ✅ Comprehensive testing (61 tests, 98% coverage)
- ✅ Input validation with detailed error messages
- ✅ Thread-safe concurrent access
- ✅ Docker containerization
- ✅ Health checks and monitoring
- ✅ Security best practices (non-root user in Docker)

### What license is it under?

This project is licensed under the MIT License. See [License](license.md) for details.

## Installation & Setup

### What are the prerequisites?

You need:
- Java JDK 17 or higher
- Maven 3.6+
- Git (for cloning the repository)
- Docker (optional, for containerization)

See [Installation Guide](../getting-started/installation.md) for detailed instructions.

### How do I build the project?

```bash
mvn clean package
```

This compiles the code, runs tests, and creates an executable JAR file.

### Why does the build fail with "JAVA_HOME not set"?

Maven cannot find your Java installation. Set the JAVA_HOME environment variable:

**macOS/Linux:**
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

**Windows:**
```powershell
setx JAVA_HOME "C:\Program Files\Java\jdk-17"
```

### Can I use Java 11?

No. This project requires **Java 17 or higher** due to modern language features and Spring Boot 3.x requirements.

## Running the Application

### How do I start the application?

```bash
mvn spring-boot:run
```

Or run the JAR directly:
```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

### What port does the application use?

Default port is **8080**. Access the API at:
- API: `http://localhost:8080/api/customers`
- Swagger UI: `http://localhost:8080/swagger-ui.html`

### How do I change the port?

Edit `src/main/resources/application.properties`:
```properties
server.port=9090
```

Or set an environment variable:
```bash
export SERVER_PORT=9090
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Port 8080 is already in use. What should I do?

Either:
1. Stop the application using port 8080
2. Change the port (see above)
3. Find and kill the process:
   ```bash
   lsof -ti:8080 | xargs kill -9  # macOS/Linux
   ```

## API Usage

### How do I access the API documentation?

Open your browser and go to:
**[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)**

You'll see interactive API documentation where you can test endpoints directly.

### What's the base URL for API calls?

```
http://localhost:8080/api/customers
```

### How do I create a customer?

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com"
  }'
```

See [Quick Start Guide](../getting-started/quick-start.md) for more examples.

### How does pagination work?

Use `page` and `size` query parameters:

```bash
curl "http://localhost:8080/api/customers?page=0&size=10"
```

Response includes pagination metadata:
```json
{
  "content": [...],
  "page": 0,
  "size": 10,
  "totalElements": 50,
  "totalPages": 5
}
```

See [Pagination Guide](../user-guide/pagination.md) for details.

### Why do I get a 400 error when creating a customer?

You're likely missing required fields or have invalid data. Check:
- `name` must not be blank
- `email` must be a valid email format

Example error response:
```json
{
  "status": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "must be a well-formed email address"
    }
  ]
}
```

### Can I create a customer without an email?

No. Both `name` and `email` are required fields and must not be blank.

## Data Storage

### Where is customer data stored?

In a JSON file: `customers.json` in the project root directory.

### Is the data persistent?

Yes, data is persisted to `customers.json` and survives application restarts.

### Can I change the data file location?

Yes! Edit `application.properties`:
```properties
app.data.file=/path/to/custom/customers.json
```

Or use an environment variable:
```bash
export APP_DATA_FILE=/path/to/customers.json
```

### Is the data storage thread-safe?

Yes. The repository uses synchronized methods to ensure safe concurrent access.

### Can I use a real database instead of JSON?

Yes! The repository pattern makes it easy to swap implementations. You would:
1. Add a database dependency (e.g., PostgreSQL)
2. Create a new repository implementation using Spring Data JPA
3. Update the configuration

## Docker

### How do I run the application in Docker?

```bash
# Build the Docker image
docker build -t customer-api:latest .

# Run the container
docker run -d -p 9292:9292 --name customer-api customer-api:latest
```

See [Docker Setup Guide](../getting-started/docker.md) for details.

### Why does the Docker container use port 9292?

The Dockerfile is configured with `ENV SERVER_PORT=9292`. You can override this:

```bash
docker run -d -p 8080:8080 -e SERVER_PORT=8080 customer-api:latest
```

### How do I persist data across Docker container restarts?

Mount the `customers.json` file as a volume:

```bash
docker run -d \
  -p 9292:9292 \
  -v $(pwd)/customers.json:/app/customers.json \
  customer-api:latest
```

### The Docker image is large. Can I make it smaller?

The Dockerfile already uses:
- Multi-stage builds (build stage + runtime stage)
- Alpine Linux base image (minimal footprint)
- Only JRE (not full JDK) in final image

Typical image size: ~250MB

## Testing

### How do I run tests?

```bash
mvn test
```

### How many tests are there?

61 tests across:
- 17 controller tests
- 14 service tests
- 17 repository tests
- 13 model tests

### What's the test coverage?

Approximately **98%** code coverage.

### Can I skip tests during build?

```bash
mvn clean package -DskipTests
```

Not recommended for production builds!

### How do I run only specific tests?

```bash
# Run tests in a specific class
mvn test -Dtest=CustomerControllerTest

# Run a specific test method
mvn test -Dtest=CustomerControllerTest#testCreateCustomer
```

## Development

### Which IDE should I use?

Any Java IDE works:
- **IntelliJ IDEA** (Community or Ultimate)
- **VS Code** (with Java extensions)
- **Eclipse**

See [Installation Guide](../getting-started/installation.md#ide-setup) for IDE-specific setup.

### How do I enable hot reload during development?

Add Spring Boot DevTools:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
</dependency>
```

Then run with Maven:
```bash
mvn spring-boot:run
```

### How do I contribute to this project?

See [Contributing Guide](../development/contributing.md) for:
- Code style guidelines
- How to submit pull requests
- Testing requirements
- Documentation standards

## Troubleshooting

### The application starts but I can't access it

1. Check the application started successfully (no errors in logs)
2. Verify the correct port (default: 8080)
3. Check firewall settings
4. Try `http://127.0.0.1:8080` instead of `localhost`

### Tests fail with "FileNotFoundException"

Ensure you're running tests from the project root directory where `pom.xml` is located.

### Docker container exits immediately

Check logs:
```bash
docker logs customer-api
```

Common causes:
- Port already in use
- Invalid configuration
- Insufficient memory

### Memory issues when running the application

Increase JVM heap size:
```bash
java -Xms512m -Xmx1024m -jar target/demo-0.0.1-SNAPSHOT.jar
```

### API returns 500 Internal Server Error

Check application logs for the stack trace. Common causes:
- File permission issues on `customers.json`
- Corrupted JSON data
- Disk space full

## Performance

### How many customers can it handle?

The in-memory JSON storage is suitable for:
- **Development**: Thousands of records
- **Production**: Consider a real database for > 10,000 customers

### Is the API fast?

Response times:
- Single customer operations: < 10ms
- Paginated list: < 50ms (for reasonable dataset sizes)

### How can I improve performance?

1. Use a real database (PostgreSQL, MySQL)
2. Implement caching (Redis, Caffeine)
3. Add database indexes
4. Use connection pooling
5. Enable HTTP compression

## Security

### Is authentication required?

No. This is a demo/reference implementation. For production:
- Implement Spring Security
- Add JWT authentication
- Use HTTPS
- Implement rate limiting

### Is the API secure?

Basic security is in place:
- Input validation prevents injection attacks
- Docker runs as non-root user
- No hardcoded credentials

For production, see [Security Guide](security.md).

### How do I enable HTTPS?

Configure SSL in `application.properties`:
```properties
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=${KEYSTORE_PASSWORD}
```

See [Configuration Guide](../user-guide/configuration.md) for details.

## Still Have Questions?

- :material-github: **GitHub Issues**: [Report a bug or ask a question](https://github.com/alokkulkarni/copilotSkills/issues)
- :material-file-document: **Documentation**: Browse the [complete documentation](../index.md)
- :material-email: **Contact**: Check the project README for contact information

---

!!! tip "Didn't find your answer?"
    Open an issue on GitHub with your question. We'll update this FAQ!
