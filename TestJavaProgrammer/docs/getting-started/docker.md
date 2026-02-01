# Docker Setup

Learn how to run the Customer Management API in a Docker container for consistent deployment across environments.

## Prerequisites

Ensure Docker is installed on your system:

```bash
docker --version
# Expected: Docker version 20.x.x or higher
```

[Install Docker](https://docs.docker.com/get-docker/) if not already installed.

## Build the Docker Image

### Step 1: Build the Application

First, build the JAR file:

```bash
mvn clean package -DskipTests
```

### Step 2: Build Docker Image

Build the Docker image using the included Dockerfile:

```bash
docker build -t customer-api:latest .
```

Expected output:
```
[+] Building 12.3s (10/10) FINISHED
 => [internal] load build definition
 => => transferring dockerfile
 => [internal] load .dockerignore
 => [1/4] FROM eclipse-temurin:17-jre-alpine
 => CACHED [2/4] RUN apk add --no-cache dumb-init
 => [3/4] RUN addgroup -g 1001 -S appgroup
 => [4/4] WORKDIR /app
 => exporting to image
 => => writing image sha256:abc123...
 => => naming to docker.io/library/customer-api:latest
```

### Verify the Image

```bash
docker images | grep customer-api
```

Output:
```
customer-api    latest    abc123def456    2 minutes ago    250MB
```

## Run the Container

### Basic Run

Start a container with default settings:

```bash
docker run -d \
  --name customer-api \
  -p 9292:9292 \
  customer-api:latest
```

Options explained:
- `-d`: Run in detached mode (background)
- `--name`: Give the container a friendly name
- `-p 9292:9292`: Map host port 9292 to container port 9292

### Run with Volume Mount

To persist data across container restarts:

```bash
docker run -d \
  --name customer-api \
  -p 9292:9292 \
  -v $(pwd)/customers.json:/app/customers.json \
  customer-api:latest
```

!!! tip "Why Mount a Volume?"
    Without a volume, customer data is lost when the container is removed. Mounting `customers.json` persists the data on your host machine.

### Run with Custom Port

Override the default port using environment variables:

```bash
docker run -d \
  --name customer-api \
  -p 8080:8080 \
  -e SERVER_PORT=8080 \
  customer-api:latest
```

### Run with Custom Data File Location

```bash
docker run -d \
  --name customer-api \
  -p 9292:9292 \
  -v /path/to/data:/data \
  -e APP_DATA_FILE=/data/customers.json \
  customer-api:latest
```

## Verify the Container

### Check Container Status

```bash
docker ps
```

Output:
```
CONTAINER ID   IMAGE                  STATUS         PORTS                    NAMES
abc123def456   customer-api:latest    Up 2 minutes   0.0.0.0:9292->9292/tcp   customer-api
```

### View Container Logs

```bash
docker logs customer-api
```

Look for successful startup:
```
INFO: Started DemoApplication in 2.345 seconds
```

### Follow Logs in Real-Time

```bash
docker logs -f customer-api
```

Press `Ctrl+C` to stop following logs.

## Test the Containerized API

### Check Health

```bash
curl http://localhost:9292/actuator/health
```

Response:
```json
{
  "status": "UP"
}
```

### Create a Customer

```bash
curl -X POST http://localhost:9292/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Docker User",
    "email": "docker@example.com"
  }'
```

### Access Swagger UI

Open in browser:
**[http://localhost:9292/swagger-ui.html](http://localhost:9292/swagger-ui.html)**

## Container Management

### Stop the Container

```bash
docker stop customer-api
```

### Start the Container

```bash
docker start customer-api
```

### Restart the Container

```bash
docker restart customer-api
```

### Remove the Container

```bash
docker stop customer-api
docker rm customer-api
```

### View Container Resource Usage

```bash
docker stats customer-api
```

Output shows CPU, memory, and network usage in real-time.

## Docker Compose (Optional)

For easier management, create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  customer-api:
    image: customer-api:latest
    container_name: customer-api
    ports:
      - "9292:9292"
    volumes:
      - ./customers.json:/app/customers.json
    environment:
      - SERVER_PORT=9292
      - APP_DATA_FILE=/app/customers.json
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:9292/actuator/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
```

### Use Docker Compose

```bash
# Start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Docker Image Features

The included Dockerfile provides:

### Security

- ✅ **Non-root user**: Runs as `appuser` (UID 1001)
- ✅ **Minimal base image**: Alpine Linux for smaller attack surface
- ✅ **No hardcoded secrets**: All configuration via environment variables

### Performance

- ✅ **Optimized JVM settings**: Container-aware memory management
- ✅ **G1 Garbage Collector**: Better performance for containerized apps
- ✅ **Multi-stage build support**: Smaller final image size

### Reliability

- ✅ **Health check**: Automatic health monitoring
- ✅ **Signal handling**: Proper shutdown via dumb-init
- ✅ **Restart policies**: Configurable restart behavior

## Multi-Architecture Support

Build for multiple architectures:

```bash
# Build for ARM64 (Apple Silicon, AWS Graviton)
docker build --platform linux/arm64 -t customer-api:arm64 .

# Build for AMD64 (Standard x86_64)
docker build --platform linux/amd64 -t customer-api:amd64 .
```

## Troubleshooting

??? failure "Container Exits Immediately"
    **Check logs**:
    ```bash
    docker logs customer-api
    ```
    
    **Common causes**:
    - Port already in use
    - Invalid configuration
    - Missing data file (if not using volume)

??? failure "Cannot Access API on localhost:9292"
    **Check port mapping**:
    ```bash
    docker ps
    ```
    
    Ensure the PORTS column shows `0.0.0.0:9292->9292/tcp`
    
    **Try**:
    ```bash
    curl http://127.0.0.1:9292/actuator/health
    ```

??? failure "Permission Denied on customers.json"
    **Fix file permissions**:
    ```bash
    chmod 666 customers.json
    ```
    
    Or run container with user ID:
    ```bash
    docker run -d \
      --name customer-api \
      --user $(id -u):$(id -g) \
      -p 9292:9292 \
      customer-api:latest
    ```

## Next Steps

<div class="grid cards" markdown>

-   :material-kubernetes: **Kubernetes Deployment**
    
    ---
    
    Deploy to production with Kubernetes
    
    [View Guide →](../deployment/docker.md)

-   :material-cloud-upload: **CI/CD Pipeline**
    
    ---
    
    Automate builds and deployments
    
    [View Guide →](../deployment/ci-cd.md)

-   :material-chart-line: **Monitoring**
    
    ---
    
    Monitor container metrics
    
    [Learn More →](../user-guide/configuration.md)

</div>

---

!!! info "Docker Best Practices"
    For production deployments, consider:
    - Using specific image tags (not `latest`)
    - Implementing proper logging solutions
    - Setting resource limits
    - Using secrets management
