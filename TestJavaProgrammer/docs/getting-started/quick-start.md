# Quick Start

Get up and running with the Customer Management API in under 5 minutes!

## Start the Application

### Using Maven

The fastest way to start the application:

```bash
mvn spring-boot:run
```

Expected output:
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.2.2)

INFO: Started DemoApplication in 2.345 seconds
```

The application is now running on **http://localhost:8080**

### Using Executable JAR

Alternatively, run the pre-built JAR:

```bash
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

## Verify It's Running

### Check Application Health

```bash
curl http://localhost:8080/actuator/health
```

Expected response:
```json
{
  "status": "UP"
}
```

### Access Swagger UI

Open your browser and navigate to:

**[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)**

You'll see the interactive API documentation interface.

## Your First API Call

Let's create and manage some customers!

### 1. Create a Customer

=== "cURL"

    ```bash
    curl -X POST http://localhost:8080/api/customers \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Alice Johnson",
        "email": "alice@example.com"
      }'
    ```

=== "HTTPie"

    ```bash
    http POST localhost:8080/api/customers \
      name="Alice Johnson" \
      email="alice@example.com"
    ```

=== "PowerShell"

    ```powershell
    Invoke-RestMethod -Method Post -Uri http://localhost:8080/api/customers `
      -ContentType "application/json" `
      -Body '{"name":"Alice Johnson","email":"alice@example.com"}'
    ```

**Response** (201 Created):
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Alice Johnson",
  "email": "alice@example.com"
}
```

!!! tip "Save the ID"
    Copy the `id` value from the response - you'll need it for the next steps!

### 2. Get All Customers

```bash
curl http://localhost:8080/api/customers
```

**Response**:
```json
{
  "content": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Alice Johnson",
      "email": "alice@example.com"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1
}
```

### 3. Get a Specific Customer

Replace `{id}` with the ID from step 1:

```bash
curl http://localhost:8080/api/customers/a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Response**:
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Alice Johnson",
  "email": "alice@example.com"
}
```

### 4. Update a Customer

```bash
curl -X PUT http://localhost:8080/api/customers/a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Cooper",
    "email": "alice.cooper@example.com"
  }'
```

**Response** (200 OK):
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Alice Cooper",
  "email": "alice.cooper@example.com"
}
```

### 5. Delete a Customer

```bash
curl -X DELETE http://localhost:8080/api/customers/a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Response**: `204 No Content` (empty body)

## Test with Pagination

Create multiple customers and test pagination:

=== "Create Multiple Customers"

    ```bash
    # Customer 1
    curl -X POST http://localhost:8080/api/customers \
      -H "Content-Type: application/json" \
      -d '{"name":"Bob Smith","email":"bob@example.com"}'
    
    # Customer 2
    curl -X POST http://localhost:8080/api/customers \
      -H "Content-Type: application/json" \
      -d '{"name":"Carol White","email":"carol@example.com"}'
    
    # Customer 3
    curl -X POST http://localhost:8080/api/customers \
      -H "Content-Type: application/json" \
      -d '{"name":"David Brown","email":"david@example.com"}'
    ```

=== "Get First Page (2 items)"

    ```bash
    curl "http://localhost:8080/api/customers?page=0&size=2"
    ```
    
    Response shows 2 customers and pagination metadata.

=== "Get Second Page"

    ```bash
    curl "http://localhost:8080/api/customers?page=1&size=2"
    ```
    
    Response shows the remaining customer(s).

## Test Error Handling

### Invalid Email Format

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Invalid User",
    "email": "not-an-email"
  }'
```

**Response** (400 Bad Request):
```json
{
  "timestamp": "2026-02-01T12:00:00.000+00:00",
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

### Missing Required Fields

```bash
curl -X POST http://localhost:8080/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": ""
  }'
```

**Response** (400 Bad Request):
```json
{
  "timestamp": "2026-02-01T12:00:00.000+00:00",
  "status": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "message": "must not be blank"
    },
    {
      "field": "email",
      "message": "must not be blank"
    }
  ]
}
```

## Stop the Application

Press `Ctrl+C` in the terminal where the application is running.

## Where Data is Stored

Customer data is saved to `customers.json` in the project root:

```bash
cat customers.json
```

The file contains a JSON array of all customers.

## Next Steps

!!! success "You're All Set!"
    You've successfully run the API and performed all CRUD operations!

### Learn More

<div class="grid cards" markdown>

-   :material-book-open-variant: **API Usage Guide**
    
    ---
    
    Detailed examples for all API endpoints
    
    [View Guide →](../user-guide/api-usage.md)

-   :material-docker: **Docker Setup**
    
    ---
    
    Run the application in a container
    
    [View Guide →](docker.md)

-   :material-cog: **Configuration**
    
    ---
    
    Customize application settings
    
    [View Guide →](../user-guide/configuration.md)

-   :material-api: **API Reference**
    
    ---
    
    Complete API documentation
    
    [View Reference →](../api-reference/overview.md)

</div>

---

!!! question "Having Issues?"
    Check the [FAQ](../reference/faq.md) or [report an issue](https://github.com/alokkulkarni/copilotSkills/issues) on GitHub.
