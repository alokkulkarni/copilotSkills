# Multi-stage Dockerfile for Customer Management API
# 
# This Dockerfile supports two build modes:
# 1. Pre-built JAR (default): Uses JAR_FILE build arg to copy existing JAR
# 2. Build from source: Uncomment build stages and comment out runtime-only stage
#
# Features:
# - Multi-architecture support (amd64, arm64)
# - Non-root user for security
# - Health check endpoint
# - Optimized layer caching for dependencies

# ============================================
# Stage 1: Dependency Resolution (for caching)
# Uncomment to build from source with optimized caching
# ============================================
# FROM eclipse-temurin:17-jdk-alpine AS deps
# WORKDIR /app
# 
# # Copy only pom.xml first to cache dependencies
# COPY pom.xml .
# 
# # Download dependencies (cached unless pom.xml changes)
# RUN apk add --no-cache maven && \
#     mvn dependency:go-offline -B
# 
# ============================================
# Stage 2: Build (for building from source)
# Uncomment to build from source
# ============================================
# FROM deps AS build
# WORKDIR /app
# 
# # Copy source code
# COPY src ./src
# 
# # Build the application
# RUN mvn package -DskipTests -B && \
#     mv target/*.jar target/app.jar

# ============================================
# Runtime Stage - Using pre-built JAR
# ============================================
FROM eclipse-temurin:17-jre-alpine AS runtime

# Labels for container registry (OCI Image Spec)
LABEL org.opencontainers.image.source="https://github.com/alokkulkarni/copilotSkills"
LABEL org.opencontainers.image.description="Customer Management API - Spring Boot Application"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="Alok Kulkarni"
LABEL org.opencontainers.image.title="Customer Management API"

# Install curl for health checks (wget is already included in alpine)
# Using wget in healthcheck as it's lighter than curl
RUN apk add --no-cache dumb-init

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy the JAR file
# The JAR file will be passed as a build argument or copied from the build context
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# For building from source, use this instead:
# COPY --from=build /app/target/app.jar app.jar

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 9292

# Health check using wget (lighter than curl)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:9292/actuator/health || exit 1

# JVM options for containerized environment
# - UseContainerSupport: Enables container-aware memory management
# - MaxRAMPercentage: Limits heap to 75% of container memory
# - UseG1GC: Use G1 garbage collector (good for containers)
# - UseStringDeduplication: Reduces memory for duplicate strings
ENV JAVA_OPTS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -Djava.security.egd=file:/dev/./urandom"

# Use dumb-init as PID 1 to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
