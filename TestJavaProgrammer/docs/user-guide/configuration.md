# Configuration

Learn how to configure the Customer Management API for different environments and use cases.

## Configuration Files

The application uses Spring Boot's standard configuration system:

| File | Location | Purpose |
|------|----------|---------|
| **application.properties** | `src/main/resources/` | Main configuration |
| **application-dev.properties** | `src/main/resources/` | Development profile |
| **application-prod.properties** | `src/main/resources/` | Production profile |

## Application Properties

### Server Configuration

```properties
# Server port
server.port=8080

# Server context path (optional)
# server.servlet.context-path=/api

# Enable compression
server.compression.enabled=true
server.compression.mime-types=application/json,text/html,text/plain
```

### Data Storage Configuration

```properties
# Data file location
app.data.file=customers.json

# Alternative: Absolute path
# app.data.file=/var/data/customers.json

# Or use environment variable
# app.data.file=${DATA_FILE_PATH:customers.json}
```

### Logging Configuration

```properties
# Root logging level
logging.level.root=INFO

# Application logging
logging.level.com.example.demo=DEBUG

# Spring Framework logging
logging.level.org.springframework.web=DEBUG

# Log file location
logging.file.name=logs/application.log

# Log pattern
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
```

### Pagination Defaults

```properties
# Default page size
spring.data.web.pageable.default-page-size=20

# Maximum page size
spring.data.web.pageable.max-page-size=100

# One-indexed parameters (default is zero-indexed)
spring.data.web.pageable.one-indexed-parameters=false
```

### Swagger/OpenAPI Configuration

```properties
# OpenAPI documentation path
springdoc.api-docs.path=/api-docs

# Swagger UI path
springdoc.swagger-ui.path=/swagger-ui.html

# Enable Swagger UI
springdoc.swagger-ui.enabled=true

# Group operations by tags
springdoc.swagger-ui.tagsSorter=alpha

# Display operation IDs
springdoc.swagger-ui.displayOperationId=true
```

### CORS Configuration

For cross-origin requests:

```properties
# Allow all origins (development only!)
cors.allowed-origins=*

# Production: Specify allowed origins
# cors.allowed-origins=https://example.com,https://app.example.com

# Allowed methods
cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS

# Allowed headers
cors.allowed-headers=*

# Allow credentials
cors.allow-credentials=true
```

## Environment Variables

Override configuration using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | `8080` | HTTP port |
| `APP_DATA_FILE` | `customers.json` | Data file path |
| `LOG_LEVEL` | `INFO` | Logging level |
| `SPRING_PROFILES_ACTIVE` | - | Active profile |

### Setting Environment Variables

=== "macOS/Linux"

    ```bash
    export SERVER_PORT=9090
    export APP_DATA_FILE=/var/data/customers.json
    export LOG_LEVEL=DEBUG
    
    # Run application
    java -jar target/demo-0.0.1-SNAPSHOT.jar
    ```

=== "Windows PowerShell"

    ```powershell
    $env:SERVER_PORT="9090"
    $env:APP_DATA_FILE="C:\data\customers.json"
    $env:LOG_LEVEL="DEBUG"
    
    # Run application
    java -jar target/demo-0.0.1-SNAPSHOT.jar
    ```

=== "Docker"

    ```bash
    docker run -d \
      -e SERVER_PORT=9090 \
      -e APP_DATA_FILE=/app/data/customers.json \
      -e LOG_LEVEL=DEBUG \
      -p 9090:9090 \
      customer-api:latest
    ```

## Spring Profiles

Use profiles to manage environment-specific configuration:

### Development Profile

Create `application-dev.properties`:

```properties
# Development configuration
server.port=8080
logging.level.root=DEBUG
logging.level.com.example.demo=TRACE

# Use in-memory data (if implemented)
app.data.file=customers-dev.json

# Enable detailed error messages
server.error.include-message=always
server.error.include-binding-errors=always
server.error.include-stacktrace=always
```

Activate:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Production Profile

Create `application-prod.properties`:

```properties
# Production configuration
server.port=9292
logging.level.root=WARN
logging.level.com.example.demo=INFO

# Production data location
app.data.file=/var/data/customers.json

# Minimal error details
server.error.include-message=never
server.error.include-binding-errors=never
server.error.include-stacktrace=never

# Enable compression
server.compression.enabled=true
```

Activate:
```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

## JVM Configuration

Optimize JVM settings for your environment:

### Development

```bash
java -Xms256m -Xmx512m \
  -XX:+UseG1GC \
  -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Production

```bash
java -Xms1g -Xmx2g \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UseStringDeduplication \
  -XX:+ParallelRefProcEnabled \
  -Djava.security.egd=file:/dev/./urandom \
  -jar target/demo-0.0.1-SNAPSHOT.jar
```

### Container (Docker/Kubernetes)

```bash
java -XX:+UseContainerSupport \
  -XX:InitialRAMPercentage=50.0 \
  -XX:MaxRAMPercentage=80.0 \
  -XX:+UseG1GC \
  -jar target/demo-0.0.1-SNAPSHOT.jar
```

!!! tip "Container Memory"
    When running in containers, use percentage-based memory settings instead of absolute values for better portability.

## Actuator Configuration

Enable Spring Boot Actuator for monitoring:

```properties
# Enable actuator
management.endpoints.enabled-by-default=true

# Expose endpoints
management.endpoints.web.exposure.include=health,info,metrics

# Health endpoint details
management.endpoint.health.show-details=always

# Info endpoint
info.app.name=Customer Management API
info.app.version=@project.version@
info.app.description=@project.description@
```

Access endpoints:
- Health: `http://localhost:8080/actuator/health`
- Info: `http://localhost:8080/actuator/info`
- Metrics: `http://localhost:8080/actuator/metrics`

## Security Configuration (Future)

When implementing security:

```properties
# JWT Configuration
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

# HTTPS Configuration
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.p12
server.ssl.key-store-password=${KEYSTORE_PASSWORD}
server.ssl.key-store-type=PKCS12
```

## Configuration Precedence

Spring Boot loads configuration in this order (highest to lowest priority):

1. Command-line arguments
2. `SPRING_APPLICATION_JSON` (environment variable)
3. ServletConfig init parameters
4. ServletContext init parameters
5. Java System properties (`System.getProperties()`)
6. OS environment variables
7. Profile-specific properties (`application-{profile}.properties`)
8. Application properties (`application.properties`)
9. Default properties

## Example Configurations

### Minimal (Default)

```properties
server.port=8080
app.data.file=customers.json
logging.level.root=INFO
```

### Development

```properties
server.port=8080
app.data.file=customers-dev.json
logging.level.root=DEBUG
logging.level.com.example.demo=TRACE
server.error.include-stacktrace=always
springdoc.swagger-ui.enabled=true
```

### Production

```properties
server.port=9292
app.data.file=/var/data/customers.json
logging.level.root=WARN
logging.level.com.example.demo=INFO
logging.file.name=/var/log/customer-api/application.log
server.error.include-stacktrace=never
server.compression.enabled=true
management.endpoints.web.exposure.include=health,metrics
```

## Troubleshooting Configuration

### View Effective Configuration

```bash
# Show all configuration properties
java -jar target/demo-0.0.1-SNAPSHOT.jar \
  --debug
```

### Check Active Profiles

Add to `application.properties`:
```properties
logging.level.org.springframework.boot.autoconfigure=DEBUG
```

Look for:
```
The following profiles are active: dev,local
```

### Configuration Not Loading

1. **Check file location**: Must be in `src/main/resources/`
2. **Check file name**: `application.properties` (exact match)
3. **Check syntax**: No spaces around `=`
4. **Check profile**: Ensure correct profile is active

## Next Steps

- [API Usage Guide](api-usage.md) - Learn how to use the API
- [Error Handling](error-handling.md) - Understanding error responses
- [Deployment](../deployment/docker.md) - Deploy to production

---

!!! question "Configuration Issues?"
    Check the [FAQ](../reference/faq.md) for common configuration problems.
