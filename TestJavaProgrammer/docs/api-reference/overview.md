# API Reference Overview

Complete reference documentation for the Customer Management API endpoints, models, and error responses.

## Base URL

```
http://localhost:8080
```

For production deployments, replace with your actual domain.

## API Endpoints Summary

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/customers` | Create a new customer | No |
| `GET` | `/api/customers` | Get all customers (paginated) | No |
| `GET` | `/api/customers/{id}` | Get a specific customer | No |
| `PUT` | `/api/customers/{id}` | Update a customer | No |
| `DELETE` | `/api/customers/{id}` | Delete a customer | No |

## Quick Reference

### Content Types

All endpoints use JSON:

- **Request**: `Content-Type: application/json`
- **Response**: `Content-Type: application/json`

### Status Codes

| Code | Meaning | When |
|------|---------|------|
| `200` | OK | Successful GET, PUT |
| `201` | Created | Successful POST |
| `204` | No Content | Successful DELETE |
| `400` | Bad Request | Validation errors |
| `404` | Not Found | Customer not found |
| `500` | Internal Server Error | Server error |

### Pagination Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | `0` | Page number (0-indexed) |
| `size` | integer | `20` | Items per page |

## Interactive Documentation

Access the interactive Swagger UI documentation:

**[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)**

Features:
- Try out API calls directly from the browser
- See request/response examples
- View all parameter options
- Download OpenAPI specification

## OpenAPI Specification

Download the complete OpenAPI 3.0 specification:

**[http://localhost:8080/api-docs](http://localhost:8080/api-docs)**

Use this specification with tools like:
- **Postman** - Import for API testing
- **Swagger Codegen** - Generate client SDKs
- **API Gateway** - Configure routing

## Data Model

### Customer

```json
{
  "id": "string (UUID)",
  "name": "string",
  "email": "string (email format)"
}
```

**Field Descriptions:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `id` | string | No* | UUID format | Unique identifier (auto-generated) |
| `name` | string | Yes | Not blank, max 100 chars | Customer's full name |
| `email` | string | Yes | Valid email format | Customer's email address |

*ID is auto-generated on creation and required for updates.

### Paginated Response

```json
{
  "content": [Customer],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5
}
```

**Field Descriptions:**

| Field | Type | Description |
|-------|------|-------------|
| `content` | array | Array of Customer objects |
| `page` | integer | Current page number (0-indexed) |
| `size` | integer | Items per page |
| `totalElements` | integer | Total number of customers |
| `totalPages` | integer | Total number of pages |

### Error Response

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

## Client Libraries

### cURL Examples

See [Endpoints Documentation](endpoints.md) for detailed cURL examples.

### HTTP Client (Java)

```java
HttpClient client = HttpClient.newHttpClient();
HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("http://localhost:8080/api/customers"))
    .header("Content-Type", "application/json")
    .POST(HttpRequest.BodyPublishers.ofString("""
        {
          "name": "John Doe",
          "email": "john@example.com"
        }
        """))
    .build();

HttpResponse<String> response = client.send(request, 
    HttpResponse.BodyHandlers.ofString());
```

### Fetch API (JavaScript)

```javascript
const response = await fetch('http://localhost:8080/api/customers', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com'
  })
});

const customer = await response.json();
```

### Axios (JavaScript/Node.js)

```javascript
const axios = require('axios');

const customer = await axios.post('http://localhost:8080/api/customers', {
  name: 'John Doe',
  email: 'john@example.com'
});

console.log(customer.data);
```

### Requests (Python)

```python
import requests

response = requests.post(
    'http://localhost:8080/api/customers',
    json={
        'name': 'John Doe',
        'email': 'john@example.com'
    }
)

customer = response.json()
```

## Rate Limiting

Currently, the API does not implement rate limiting. For production use, consider implementing:

- Request rate limiting (e.g., 100 requests/minute per IP)
- Authentication and authorization
- API keys or OAuth 2.0

## Versioning

The current API version is **v1**. Future versions may use:

- URI versioning: `/api/v2/customers`
- Header versioning: `Accept: application/vnd.api.v2+json`

## CORS

Cross-Origin Resource Sharing (CORS) can be configured in `application.properties`. See [Configuration Guide](../user-guide/configuration.md#cors-configuration).

## API Design Principles

The API follows REST principles:

- **Resource-based URLs**: `/api/customers`, not `/api/getCustomers`
- **HTTP methods**: Use appropriate verbs (GET, POST, PUT, DELETE)
- **Stateless**: Each request contains all necessary information
- **JSON format**: Consistent data format
- **HTTP status codes**: Meaningful status codes for responses
- **Pagination**: Efficient data retrieval for large datasets

## Next Steps

<div class="grid cards" markdown>

-   :material-api: **Endpoints**
    
    ---
    
    Detailed documentation for each API endpoint
    
    [View Endpoints →](endpoints.md)

-   :material-code-json: **Models**
    
    ---
    
    Complete data model schemas
    
    [View Models →](models.md)

-   :material-file-code: **OpenAPI Spec**
    
    ---
    
    Download and use the OpenAPI specification
    
    [View Spec →](openapi.md)

-   :material-alert-circle: **Error Handling**
    
    ---
    
    Understanding error responses
    
    [View Guide →](../user-guide/error-handling.md)

</div>

---

!!! info "API Testing"
    Use the [Swagger UI](http://localhost:8080/swagger-ui.html) for interactive API testing without writing code.
