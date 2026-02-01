# Installation

This guide will help you install and set up the Customer Management API on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required

| Software | Version | Download |
|----------|---------|----------|
| **Java JDK** | 17 or higher | [OpenJDK](https://openjdk.org/install/) or [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) |
| **Maven** | 3.6+ | [Maven Downloads](https://maven.apache.org/download.cgi) |
| **Git** | Latest | [Git Downloads](https://git-scm.com/downloads) |

### Optional

| Software | Version | Purpose |
|----------|---------|---------|
| **Docker** | Latest | For containerized deployment |
| **IDE** | Any | IntelliJ IDEA, VS Code, Eclipse |

## Verify Prerequisites

Check that all required software is installed correctly:

=== "macOS/Linux"

    ```bash
    # Check Java version
    java -version
    # Expected: openjdk version "17.0.x" or higher
    
    # Check Maven version
    mvn -version
    # Expected: Apache Maven 3.6.x or higher
    
    # Check Git version
    git --version
    # Expected: git version 2.x.x
    ```

=== "Windows"

    ```powershell
    # Check Java version
    java -version
    # Expected: openjdk version "17.0.x" or higher
    
    # Check Maven version
    mvn -version
    # Expected: Apache Maven 3.6.x or higher
    
    # Check Git version
    git --version
    # Expected: git version 2.x.x
    ```

!!! warning "Java Version"
    This project requires **Java 17 or higher** (LTS recommended). Java 11 or earlier will not work.

## Clone the Repository

Clone the repository from GitHub:

```bash
git clone https://github.com/alokkulkarni/copilotSkills.git
cd copilotSkills/TestJavaProgrammer
```

## Project Structure

After cloning, you'll see the following structure:

```
TestJavaProgrammer/
├── src/
│   ├── main/
│   │   ├── java/           # Application source code
│   │   └── resources/      # Configuration files
│   └── test/               # Test source code
├── docs/                   # MkDocs documentation
├── pom.xml                 # Maven configuration
├── Dockerfile              # Docker configuration
└── customers.json          # Data storage file
```

## Build the Project

### Using Maven

Build the project and run tests:

```bash
# Clean and build
mvn clean package

# Build without running tests (faster)
mvn clean package -DskipTests
```

Expected output:
```
[INFO] BUILD SUCCESS
[INFO] Total time: 15.234 s
```

### Build Artifacts

After a successful build, you'll find:

| Artifact | Location | Description |
|----------|----------|-------------|
| **JAR file** | `target/demo-0.0.1-SNAPSHOT.jar` | Executable application |
| **Test reports** | `target/surefire-reports/` | Test execution results |
| **Classes** | `target/classes/` | Compiled application classes |

## Verify Installation

### Run Tests

Verify everything is working by running the test suite:

```bash
mvn test
```

Expected output:
```
[INFO] Tests run: 61, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

!!! success "Installation Complete!"
    If all tests pass, your installation is successful. Proceed to the [Quick Start](quick-start.md) guide.

### Troubleshooting

??? failure "Build Fails with 'JAVA_HOME not set'"
    **Problem**: Maven cannot find your Java installation.
    
    **Solution**: Set the JAVA_HOME environment variable:
    
    === "macOS/Linux"
        ```bash
        export JAVA_HOME=$(/usr/libexec/java_home -v 17)
        # Add to ~/.bashrc or ~/.zshrc for persistence
        ```
    
    === "Windows"
        ```powershell
        setx JAVA_HOME "C:\Program Files\Java\jdk-17"
        # Restart terminal
        ```

??? failure "Tests Fail"
    **Problem**: One or more tests are failing.
    
    **Solution**:
    1. Ensure you're using Java 17 or higher
    2. Clean the build: `mvn clean`
    3. Rebuild: `mvn clean test`
    4. Check for file permissions on `customers.json`

??? failure "Port 8080 Already in Use"
    **Problem**: Another application is using port 8080.
    
    **Solution**: Change the port in `src/main/resources/application.properties`:
    ```properties
    server.port=9090
    ```

## IDE Setup

### IntelliJ IDEA

1. **Import Project**:
   - File → Open → Select `pom.xml`
   - Import as Maven project

2. **Configure JDK**:
   - File → Project Structure → Project SDK → 17

3. **Enable Annotation Processing**:
   - Settings → Build → Compiler → Annotation Processors → Enable

### VS Code

1. **Install Extensions**:
   - Java Extension Pack
   - Spring Boot Extension Pack

2. **Open Project**:
   - File → Open Folder → Select `TestJavaProgrammer`

3. **Trust Workspace**:
   - Click "Yes" when prompted

### Eclipse

1. **Import Maven Project**:
   - File → Import → Maven → Existing Maven Projects
   - Browse to `TestJavaProgrammer` folder

2. **Update Project**:
   - Right-click project → Maven → Update Project

## Next Steps

Now that you have the project installed:

1. :material-rocket: [Quick Start Guide](quick-start.md) - Run the application
2. :material-docker: [Docker Setup](docker.md) - Containerize the application
3. :material-code-braces: [API Usage Guide](../user-guide/api-usage.md) - Learn the API

---

!!! question "Need Help?"
    If you encounter any issues during installation, please [open an issue](https://github.com/alokkulkarni/copilotSkills/issues) on GitHub.
