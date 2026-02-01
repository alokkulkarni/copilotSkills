# GitHub Actions Workflows

This directory contains the CI/CD workflows for the Customer Management API project.

## Workflow Overview

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| CI Build and Test | [ci.yml](ci.yml) | Push, PR, Tags, Manual | Build, test, code quality, packages, Docker |
| PR Validation | [pr-validation.yml](pr-validation.yml) | Pull Request | Validate PRs |
| CodeQL Security | [codeql-analysis.yml](codeql-analysis.yml) | Push, PR, Weekly | Security scanning |
| Dependency Review | [dependency-review.yml](dependency-review.yml) | Pull Request | Dependency security |
| Release | [release.yml](release.yml) | Manual | Create releases, publish packages, Docker |
| Scheduled Maintenance | [scheduled-maintenance.yml](scheduled-maintenance.yml) | Weekly | Health checks |

## Workflow Details

### CI Build and Test (`ci.yml`)

**Triggers:**
- Push to `main`, `develop`, or `release` branches
- Push tags (`v*`)
- Pull requests to `main`
- Manual dispatch

**Jobs:**
1. **build** - Compile, test (matrix: Java 17/21), and package the application
2. **code-quality** - Checkstyle and SpotBugs analysis
3. **verify-api-docs** - Verify OpenAPI specification exists
4. **notify-failure** - Send notifications on failure
5. **publish-packages** - Publish JAR to GitHub Packages (on tags/main)
6. **docker-build** - Build and push Docker image to GHCR (multi-arch: amd64/arm64)

**Security Features:**
- **Trivy Scanning**: Vulnerability scanning for Docker images (CRITICAL/HIGH)
- **SBOM Generation**: Software Bill of Materials uploaded as artifact
- **Multi-architecture**: Builds for both amd64 and arm64 platforms

**Artifacts:**
- Test results (7 days retention)
- Coverage report (7 days retention)
- Application JAR (30 days retention)

**Package Publishing:**
- **GitHub Packages**: JAR published on tags (`v*`) and `main` branch
- **GHCR**: Docker image published on tags, `main`, and `develop` branches

### PR Validation (`pr-validation.yml`)

**Triggers:**
- Pull requests to `main`

**Jobs:**
1. **validate** - Build and run tests
2. **size-check** - Check PR size
3. **documentation-check** - Verify documentation exists

### CodeQL Security Analysis (`codeql-analysis.yml`)

**Triggers:**
- Push to `main`
- Pull requests to `main`
- Weekly schedule (Monday 6 AM UTC)
- Manual dispatch

**Jobs:**
1. **analyze** - Run CodeQL security scanning for Java

### Dependency Review (`dependency-review.yml`)

**Triggers:**
- Pull requests that modify `pom.xml`

**Jobs:**
1. **dependency-review** - Check for vulnerabilities and license compliance
2. **maven-dependency-check** - Report available dependency updates

### Release (`release.yml`)

**Triggers:**
- Manual dispatch with version input

**Jobs:**
1. **validate** - Validate version format and check tag doesn't exist
2. **build-release** - Build release artifact
3. **create-release** - Create GitHub Release with artifacts
4. **publish-packages** - Publish JAR to GitHub Packages
5. **docker-release** - Build and push Docker image to GHCR (multi-arch: amd64/arm64)
6. **notify-release** - Summary notification of release status

**Security Features:**
- **Cosign Signing**: Docker images are signed for supply chain security
- **Trivy Scanning**: Vulnerability scanning for CRITICAL and HIGH severity
- **SBOM Generation**: Software Bill of Materials for compliance

**Inputs:**
- `version` (required): Semantic version (e.g., 1.0.0)
- `prerelease` (optional): Mark as pre-release
- `release_notes` (optional): Custom release notes
- `skip_docker` (optional): Skip Docker image build

### Scheduled Maintenance (`scheduled-maintenance.yml`)

**Triggers:**
- Weekly (Sunday 2 AM UTC)
- Manual dispatch

**Jobs:**
1. **dependency-updates** - Report available dependency updates
2. **build-health** - Verify build is healthy

## Package Distribution

### GitHub Packages (Maven)

JAR artifacts are published to GitHub Packages on:
- Push of version tags (`v*`)
- Push to `main` branch

**Using the Package:**

Add the GitHub Packages repository to your `pom.xml`:

```xml
<repositories>
    <repository>
        <id>github</id>
        <url>https://maven.pkg.github.com/alokkulkarni/copilotSkills</url>
    </repository>
</repositories>
```

Add the dependency:

```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>customer-api</artifactId>
    <version>1.0.0</version>
</dependency>
```

Configure authentication in your `~/.m2/settings.xml`:

```xml
<servers>
    <server>
        <id>github</id>
        <username>YOUR_GITHUB_USERNAME</username>
        <password>YOUR_GITHUB_TOKEN</password>
    </server>
</servers>
```

### Docker Images (GHCR)

Docker images are published to GitHub Container Registry on:
- Push of version tags (`v*`) - tagged with version number
- Push to `main` branch - tagged with `latest`
- Push to `develop` branch - tagged with `develop`
- Manual release - tagged with release version

**Supported Architectures:**
- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (Apple Silicon, ARM servers)

**Security Features:**
- **Cosign Signed**: Release images are signed with Cosign for verification
- **Vulnerability Scanned**: Trivy scans for CRITICAL/HIGH vulnerabilities
- **SBOM Available**: Software Bill of Materials downloadable as artifacts

**Image Location:**
```
ghcr.io/alokkulkarni/copilotSkills/customer-api
```

**Pull the Image:**

```bash
# Latest from main branch
docker pull ghcr.io/alokkulkarni/copilotskills/customer-api:latest

# Specific version
docker pull ghcr.io/alokkulkarni/copilotskills/customer-api:1.0.0

# Development version
docker pull ghcr.io/alokkulkarni/copilotskills/customer-api:develop

# Specify architecture explicitly
docker pull --platform linux/arm64 ghcr.io/alokkulkarni/copilotskills/customer-api:latest
```

**Verify Image Signature (Cosign):**

```bash
# Install Cosign: https://docs.sigstore.dev/cosign/installation/
cosign verify ghcr.io/alokkulkarni/copilotskills/customer-api:1.0.0
```

**Run the Container:**

```bash
# Basic run
docker run -p 8080:8080 ghcr.io/alokkulkarni/copilotskills/customer-api:latest

# With environment variables
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=production \
  ghcr.io/alokkulkarni/copilotskills/customer-api:latest

# With health check
docker run -p 8080:8080 \
  --health-cmd="curl -f http://localhost:8080/actuator/health || exit 1" \
  --health-interval=30s \
  ghcr.io/alokkulkarni/copilotskills/customer-api:latest
```

**Docker Compose Example:**

```yaml
version: '3.8'
services:
  customer-api:
    image: ghcr.io/alokkulkarni/copilotskills/customer-api:latest
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Required Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `GITHUB_TOKEN` | Auto | Automatic GitHub token (used for packages and GHCR) |
| `SLACK_WEBHOOK_URL` | Optional | Slack webhook for failure notifications |

## Required Repository Settings

### Package Settings

For GitHub Packages and GHCR to work:
1. **Repository Settings → Actions → General**
   - Workflow permissions: "Read and write permissions"
   - Allow GitHub Actions to create and approve pull requests (if needed)

2. **Package Visibility**
   - Packages inherit repository visibility by default
   - Configure package settings if different visibility is needed

### Branch Protection Rules (Recommended)

For the `main` branch:
- ✅ Require a pull request before merging
- ✅ Require status checks to pass before merging
  - `Build and Test`
  - `Validate PR`
  - `Analyze with CodeQL`
  - `Review Dependencies`
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging

### Environments (Optional)

For the `release.yml` workflow, you can create a `production` environment with:
- Required reviewers
- Wait timer (optional)
- Deployment branches: `main` only

## Status Badges

Add these badges to your README.md:

```markdown
![CI Build](https://github.com/alokkulkarni/copilotSkills/actions/workflows/ci.yml/badge.svg)
![CodeQL](https://github.com/alokkulkarni/copilotSkills/actions/workflows/codeql-analysis.yml/badge.svg)
```

## Local Testing

You can test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # macOS
# or: choco install act-cli  # Windows

# Run CI workflow
act push -W .github/workflows/ci.yml

# Run specific job
act push -W .github/workflows/ci.yml -j build

# List all workflows
act -l
```

### Build Docker Image Locally

```bash
# Build the JAR first
./mvnw clean package -DskipTests

# Build Docker image
docker build -t customer-api:local .

# Run locally
docker run -p 8080:8080 customer-api:local
```

## Troubleshooting

### Common Issues

1. **Build fails on checkout**
   - Ensure `fetch-depth: 0` for full history when needed

2. **Cache misses**
   - Verify pom.xml is at the expected path
   - Check cache key patterns

3. **Test reports not appearing**
   - Ensure surefire reports are generated at expected path

4. **Release fails**
   - Check version format matches semantic versioning
   - Verify tag doesn't already exist

5. **Package publish fails**
   - Ensure workflow has `packages: write` permission
   - Check GitHub token has necessary scopes
   - Verify distributionManagement in pom.xml

6. **Docker push fails**
   - Ensure workflow has `packages: write` permission
   - Verify GHCR login succeeded
   - Check image name is lowercase

### Debug Mode

Enable debug logging by setting repository secrets:
- `ACTIONS_STEP_DEBUG` = `true`
- `ACTIONS_RUNNER_DEBUG` = `true`

## Contributing

When modifying workflows:
1. Follow the conventions in `.github/copilot/github-actions-instructions.md`
2. Pin all actions to SHA with version comment
3. Test locally with `act` before pushing
4. Update this README if adding new workflows
