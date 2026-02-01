# GitHub Actions Workflow Standards and Best Practices

## Purpose
This instruction file provides comprehensive standards and best practices for writing, building, and maintaining GitHub Actions workflows. These guidelines ensure workflows are secure, maintainable, efficient, and follow industry standards.

---

## Workflow Structure and Organization

### 1. File Naming and Location
- **Location**: All workflows must be stored in `.github/workflows/` directory
- **Naming Convention**: Use kebab-case for workflow filenames (e.g., `ci-build.yml`, `deploy-production.yml`)
- **Descriptive Names**: Filename should clearly indicate the workflow's purpose
- **Extension**: Use `.yml` or `.yaml` consistently across the repository

### 2. Workflow Naming
```yaml
name: Clear and Descriptive Workflow Name
```
- Use clear, descriptive names that explain the workflow's purpose
- Avoid generic names like "CI" or "Build"
- Good examples: "Build and Test Java Application", "Deploy to Production", "Security Scan"

### 3. Workflow Triggers
```yaml
on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - '.github/workflows/**'
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
```

**Best Practices:**
- Be specific with trigger conditions to avoid unnecessary runs
- Use `paths` and `paths-ignore` to filter relevant changes
- Include `workflow_dispatch` for manual triggers when appropriate
- Use branch protection patterns carefully
- Consider using `schedule` with cron for periodic tasks

---

## Security Best Practices

### 1. Secrets Management
```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  
jobs:
  build:
    steps:
      - name: Use secret
        run: |
          # Never echo or log secrets
          curl -H "Authorization: Bearer ${{ secrets.TOKEN }}"
```

**Critical Security Rules:**
- **NEVER** hardcode secrets, API keys, passwords, or tokens in workflow files
- Always use GitHub Secrets for sensitive data
- Never print secrets to logs using `echo`, `print`, or similar commands
- Use environment-specific secrets (e.g., `PROD_API_KEY`, `DEV_API_KEY`)
- Rotate secrets regularly
- Use least-privilege principle for secret access

### 2. Action Pinning and Security
```yaml
steps:
  # GOOD: Pin to specific SHA with latest stable version reference
  - uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab # v4.1.0
  
  # ACCEPTABLE: Pin to major version tag (but always use latest stable)
  - uses: actions/setup-node@v4  # Use v4 not v3 for latest stable
  
  # AVOID: Using @main or @master
  - uses: some-org/some-action@main  # Risky!
```

**Action Security Standards:**
- Pin actions to full-length commit SHA for maximum security in production workflows
- **ALWAYS use the latest stable version** of actions (check GitHub Marketplace or action repository releases)
- Add comment with semantic version for reference
- For third-party actions, verify source and reputation
- Regularly update pinned versions to latest stable releases
- Use Dependabot to keep actions updated
- When pinning, ensure the commit SHA corresponds to the **latest stable release tag**, not an older version
- Review action release notes for breaking changes before updating

### 3. Permission Management
```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
  
jobs:
  security-scan:
    permissions:
      contents: read
      security-events: write
```

**Permission Best Practices:**
- Set minimal permissions at workflow and job level
- Use `permissions: read-all` or `permissions: write-all` sparingly
- Explicitly declare required permissions
- Use job-level permissions to further restrict access

### 4. Code Injection Prevention
```yaml
# VULNERABLE - DO NOT USE
- name: Vulnerable step
  run: echo "Comment: ${{ github.event.comment.body }}"

# SECURE - Use intermediate environment variable
- name: Secure step
  env:
    COMMENT_BODY: ${{ github.event.comment.body }}
  run: echo "Comment: $COMMENT_BODY"
```

**Injection Protection:**
- Never directly interpolate user input into `run` commands
- Use environment variables for user-controlled data
- Validate and sanitize inputs
- Use `$GITHUB_ENV` for passing data between steps

---

## Workflow Design and Maintainability

### 1. Job Organization
```yaml
jobs:
  validate:
    name: Code Validation
    runs-on: ubuntu-latest
    steps: [...]
  
  build:
    name: Build Application
    needs: validate
    runs-on: ubuntu-latest
    steps: [...]
  
  test:
    name: Run Tests
    needs: build
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
    runs-on: ${{ matrix.os }}
    steps: [...]
```

**Job Design Principles:**
- Use descriptive job names
- Organize jobs logically (validate → build → test → deploy)
- Use `needs` to define dependencies and execution order
- Parallelize independent jobs for faster execution
- Use matrix strategy for testing across multiple configurations

### 2. Step Organization
```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v3
    with:
      fetch-depth: 0
  
  - name: Set up build environment
    uses: actions/setup-node@v3
    with:
      node-version: '18'
      cache: 'npm'
  
  - name: Install dependencies
    run: npm ci
  
  - name: Run linter
    run: npm run lint
  
  - name: Run tests
    run: npm test
    env:
      NODE_ENV: test
```

**Step Standards:**
- Every step must have a descriptive `name`
- Group related commands in single steps
- Use `run` with multi-line scripts for complex operations
- Order steps logically
- Use conditional execution with `if` when needed

### 3. Reusable Workflows
```yaml
# .github/workflows/reusable-build.yml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      node-version:
        required: false
        type: string
        default: '18'
    secrets:
      deploy-token:
        required: true
    outputs:
      build-id:
        value: ${{ jobs.build.outputs.build-id }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      build-id: ${{ steps.build.outputs.id }}
    steps: [...]
```

**Reusable Workflow Benefits:**
- DRY principle - avoid duplication
- Consistent execution across repositories
- Centralized maintenance
- Clear input/output contracts

### 4. Composite Actions
Create composite actions for repeated step sequences:

```yaml
# .github/actions/setup-build-env/action.yml
name: 'Setup Build Environment'
description: 'Sets up Node.js and installs dependencies'
inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '18'
runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v3
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'
    - run: npm ci
      shell: bash
```

---

## Performance and Efficiency

### 1. Caching Strategies
```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      ~/.m2/repository
      ~/.gradle/caches
    key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json', '**/pom.xml') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

**Caching Best Practices:**
- Cache dependencies to reduce build time
- Use appropriate cache keys with file hashes
- Implement restore-keys for fallback caching
- Cache build outputs when appropriate
- Set reasonable cache retention policies

### 2. Artifact Management
```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v3
  with:
    name: build-${{ github.sha }}
    path: |
      dist/
      build/
    retention-days: 30
    if-no-files-found: error

- name: Download artifacts
  uses: actions/download-artifact@v3
  with:
    name: build-${{ github.sha }}
```

**Artifact Guidelines:**
- Use meaningful artifact names with context (commit SHA, build number)
- Set appropriate retention days (default is 90, but consider costs)
- Upload only necessary files
- Use compression for large artifacts
- Document artifact structure

### 3. Concurrency Control
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

**Concurrency Management:**
- Use concurrency groups to prevent duplicate runs
- Cancel in-progress runs for PR updates
- Be careful with deployment workflows (avoid cancel-in-progress)
- Use appropriate grouping strategies

---

## Error Handling and Resilience

### 1. Continue on Error
```yaml
- name: Optional security scan
  run: npm audit
  continue-on-error: true

- name: Critical deployment
  run: ./deploy.sh
  # Will fail workflow if this fails (default behavior)
```

**Error Handling:**
- Use `continue-on-error: true` only for non-critical steps
- Always fail on critical operations
- Document why a step can continue on error
- Use conditional steps based on previous step results

### 2. Timeout Configuration
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - name: Long running task
        run: ./long-task.sh
        timeout-minutes: 15
```

**Timeout Standards:**
- Set realistic timeouts at job and step levels
- Default job timeout is 360 minutes - override when necessary
- Prevent hung jobs from wasting resources
- Set shorter timeouts for steps expected to complete quickly

### 3. Retry Logic
```yaml
- name: Flaky network operation
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_wait_seconds: 30
    command: npm install
```

**Retry Best Practices:**
- Use retry actions for network-dependent operations
- Configure exponential backoff when available
- Set maximum attempt limits
- Don't retry on expected failures

---

## Environment and Runner Configuration

### 1. Runner Selection
```yaml
jobs:
  build-linux:
    runs-on: ubuntu-latest  # Most cost-effective
  
  build-windows:
    runs-on: windows-latest  # Use only when necessary
  
  build-mac:
    runs-on: macos-latest  # Most expensive
  
  build-self-hosted:
    runs-on: [self-hosted, linux, x64]
```

**Runner Guidelines:**
- Use `ubuntu-latest` as default (fastest and cheapest)
- Use specific OS only when required
- Consider self-hosted runners for private data or specialized hardware
- Use runner labels effectively for self-hosted runners
- Keep self-hosted runners updated and secure

### 2. Environment Variables
```yaml
env:
  GLOBAL_VAR: "global-value"

jobs:
  build:
    env:
      JOB_VAR: "job-value"
    steps:
      - name: Step with env
        env:
          STEP_VAR: "step-value"
        run: |
          echo "Global: $GLOBAL_VAR"
          echo "Job: $JOB_VAR"
          echo "Step: $STEP_VAR"
      
      - name: Set dynamic env
        run: echo "BUILD_ID=$(date +%s)" >> $GITHUB_ENV
      
      - name: Use dynamic env
        run: echo "Build ID: $BUILD_ID"
```

**Environment Variable Best Practices:**
- Use appropriate scope (global, job, step)
- Use `$GITHUB_ENV` for dynamic variables
- Use descriptive variable names (SCREAMING_SNAKE_CASE)
- Document non-obvious environment variables
- Avoid overriding reserved environment variables

### 3. Container Jobs
```yaml
jobs:
  container-job:
    runs-on: ubuntu-latest
    container:
      image: node:18-alpine
      env:
        NODE_ENV: production
      options: --cpus 2 --memory 4g
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
```

**Container Best Practices:**
- Use specific image tags, not `latest`
- Configure health checks for services
- Set resource limits when needed
- Use minimal base images (alpine when possible)
- Clean up containers properly

---

## Testing and Quality Assurance

### 1. Test Execution
```yaml
- name: Run unit tests
  run: npm run test:unit
  env:
    CI: true

- name: Run integration tests
  run: npm run test:integration
  timeout-minutes: 20

- name: Upload test results
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: test-results
    path: test-results/

- name: Publish test report
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: Test Results
    path: test-results/*.xml
    reporter: jest-junit
```

**Testing Standards:**
- Run tests in CI environment
- Use appropriate timeouts
- Upload test results even on failure
- Generate and publish test reports
- Separate unit, integration, and e2e tests

### 2. Code Coverage
```yaml
- name: Generate coverage report
  run: npm run test:coverage

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
    fail_ci_if_error: true
    verbose: true
```

**Coverage Standards:**
- Generate coverage reports in CI
- Upload to coverage services
- Set coverage thresholds
- Fail on coverage decrease
- Include coverage in PR comments

### 3. Code Quality Checks
```yaml
- name: Run linter
  run: npm run lint

- name: Check code formatting
  run: npm run format:check

- name: Run static analysis
  run: npm run analyze

- name: Security audit
  run: npm audit --audit-level=moderate
```

---

## Documentation and Maintenance

### 1. Workflow Documentation
```yaml
name: CI/CD Pipeline

# Purpose: Builds, tests, and deploys the application
# Trigger: On push to main, PR to main, and manual dispatch
# Prerequisites: 
#   - DEPLOY_TOKEN secret must be configured
#   - Node.js 18+ required
# Outputs: Deployment URL in job summary

on:
  push:
    branches: [main]
```

**Documentation Requirements:**
- Add workflow description in YAML comments
- Document prerequisites and secrets needed
- Explain complex logic
- Document outputs and artifacts
- Maintain README for custom actions

### 2. Status Badges
```markdown
# README.md
[![CI](https://github.com/owner/repo/workflows/CI/badge.svg)](https://github.com/owner/repo/actions)
[![Coverage](https://codecov.io/gh/owner/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/owner/repo)
```

**Badge Guidelines:**
- Add workflow status badges to README
- Include coverage and quality badges
- Keep badges up-to-date
- Use descriptive badge labels

### 3. Change Management
```yaml
# CHANGELOG: 
# 2024-01-15: Added container scanning step
# 2024-01-10: Updated to Node 18
# 2024-01-05: Added retry logic for npm install
```

**Version Control:**
- Document significant workflow changes
- Use semantic versioning for reusable workflows
- Test workflow changes in feature branches
- Review workflow changes in PRs

---

## Deployment Standards

### 1. Environment Deployment
```yaml
jobs:
  deploy:
    name: Deploy to ${{ inputs.environment }}
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.environment }}
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - name: Deploy application
        id: deploy
        run: |
          URL=$(./deploy.sh ${{ inputs.environment }})
          echo "url=$URL" >> $GITHUB_OUTPUT
```

**Deployment Best Practices:**
- Use GitHub Environments for deployment protection
- Require approvals for production deployments
- Set environment-specific secrets
- Output deployment URLs
- Use deployment gates and protection rules

### 2. Rollback Capability
```yaml
- name: Deploy with rollback
  id: deploy
  run: ./deploy.sh

- name: Health check
  id: health
  run: ./health-check.sh

- name: Rollback on failure
  if: failure() && steps.deploy.outcome == 'success'
  run: ./rollback.sh
```

**Rollback Standards:**
- Implement automated rollback on failure
- Verify deployment health before completing
- Keep previous versions available
- Document rollback procedures
- Test rollback mechanisms regularly

### 3. Blue-Green and Canary Deployments
```yaml
- name: Deploy to canary
  run: ./deploy.sh --target=canary --traffic=10

- name: Monitor canary metrics
  run: ./monitor.sh --duration=10m

- name: Promote to production
  if: success()
  run: ./deploy.sh --target=production --traffic=100
```

---

## Monitoring and Observability

### 1. Job Summaries
```yaml
- name: Generate deployment summary
  run: |
    echo "## Deployment Summary" >> $GITHUB_STEP_SUMMARY
    echo "- **Environment**: Production" >> $GITHUB_STEP_SUMMARY
    echo "- **Version**: ${{ github.sha }}" >> $GITHUB_STEP_SUMMARY
    echo "- **URL**: https://app.example.com" >> $GITHUB_STEP_SUMMARY
```

**Summary Standards:**
- Use job summaries for key information
- Format with Markdown
- Include deployment URLs and versions
- Add test result summaries
- Keep summaries concise

### 2. Notifications
```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Workflow failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**Notification Guidelines:**
- Notify on deployment failures
- Use appropriate channels (Slack, Teams, email)
- Include relevant context
- Avoid notification spam
- Configure notification preferences

### 3. Logging
```yaml
- name: Debug information
  if: runner.debug == '1'
  run: |
    echo "::group::Environment Variables"
    env | sort
    echo "::endgroup::"
```

**Logging Standards:**
- Use log groups for organization
- Add debug logging for troubleshooting
- Use log levels appropriately
- Sanitize sensitive data from logs
- Make logs searchable and filterable

---

## Common Patterns and Examples

### 1. Monorepo Support
```yaml
on:
  push:
    paths:
      - 'services/api/**'
      - 'shared/**'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      api: ${{ steps.filter.outputs.api }}
      web: ${{ steps.filter.outputs.web }}
    steps:
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            api:
              - 'services/api/**'
            web:
              - 'services/web/**'
  
  build-api:
    needs: detect-changes
    if: needs.detect-changes.outputs.api == 'true'
    runs-on: ubuntu-latest
    steps: [...]
```

### 2. Multi-Stage Pipeline
```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.version.outputs.version }}
  test:
    needs: build
  security-scan:
    needs: build
  deploy-staging:
    needs: [test, security-scan]
    environment: staging
  deploy-production:
    needs: deploy-staging
    environment: production
```

### 3. Matrix Testing with Exclusions
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node: [16, 18, 20]
    exclude:
      - os: macos-latest
        node: 16
    include:
      - os: ubuntu-latest
        node: 20
        experimental: true
  fail-fast: false
```

---

## Anti-Patterns to Avoid

### ❌ DO NOT DO
1. **Hardcode secrets**: Never put credentials in workflow files
2. **Use unversioned actions**: Always pin action versions
3. **Ignore failures**: Don't use `continue-on-error` everywhere
4. **Over-trigger workflows**: Be specific with `on` conditions
5. **Run unnecessary jobs**: Use path filters and conditions
6. **Ignore timeouts**: Always set reasonable timeouts
7. **Skip testing workflows**: Test in feature branches first
8. **Create monolithic workflows**: Break into reusable components
9. **Ignore security**: Review third-party actions carefully
10. **Forget documentation**: Document complex workflows

---

## Validation Checklist

Before merging workflow changes, verify:

- [ ] Workflow name is descriptive
- [ ] Triggers are appropriate and specific
- [ ] No secrets are hardcoded
- [ ] Actions are pinned to specific versions
- [ ] **All actions use latest stable versions** (verify against GitHub Marketplace or action repository releases)
- [ ] Permissions are minimal and explicit
- [ ] Steps have descriptive names
- [ ] Error handling is implemented
- [ ] Timeouts are configured
- [ ] Caching is utilized where beneficial
- [ ] Testing is comprehensive
- [ ] Documentation is complete
- [ ] Notifications are configured
- [ ] Rollback capability exists for deployments
- [ ] Workflow has been tested in a non-production environment
- [ ] Action versions are up-to-date with latest stable releases (not using deprecated or outdated versions)

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

---

**Version**: 1.0.0  
**Last Updated**: 2024-01-31  
**Maintained By**: DevOps Team
