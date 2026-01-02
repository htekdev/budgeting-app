# BudgetBuddy Verification Scripts

This directory contains verification scripts that validate the entire repository against defined criteria and specifications.

## Purpose

These scripts implement a "verification-first" approach where:
1. Criteria are explicitly defined based on authoritative sources
2. Verification scripts are created BEFORE application code
3. A single command validates the entire repository
4. All changes must pass verification before being considered complete

## Scripts

### Master Verification Script

**`master-verify.sh`** - The single command to run all verifications

```bash
./verification/master-verify.sh
```

This script runs all individual verification scripts and reports overall status.

### Individual Verification Scripts

1. **`verify-copilot-files.sh`** - Validates GitHub Copilot customization files
   - `.github/copilot-instructions.md` format and content
   - `.github/instructions/*.instructions.md` with applyTo syntax
   - `AGENTS.md` presence and format
   - `.github/agents/*.agent.md` YAML schema and required fields
   - `.github/skills/*/SKILL.md` structure and validation

2. **`verify-project-structure.sh`** - Validates project structure
   - ASP.NET Core Web API (.NET 10) structure
   - React + TypeScript frontend structure
   - Configuration files (tsconfig, package.json, .csproj)
   - Proper directory organization

3. **`verify-docker.sh`** - Validates Docker and Dev Container configuration
   - docker-compose.yml syntax and structure
   - Service definitions (frontend, backend, database)
   - SQL Server container configuration
   - .devcontainer/devcontainer.json configuration
   - Port forwarding and volume mounts

4. **`verify-terraform.sh`** - Validates Terraform configuration
   - Project structure (main.tf, variables.tf, outputs.tf)
   - Provider version constraints
   - No hardcoded secrets
   - Proper formatting (terraform fmt)
   - Valid configuration (terraform validate)
   - Remote backend configuration

5. **`verify-ci.sh`** - Validates GitHub Actions workflows
   - Workflow YAML syntax
   - Required fields (on, jobs, runs-on)
   - CI/CD steps (build, test)
   - Security best practices

## Running Verifications

### Run All Verifications (Recommended)

```bash
cd .verification
./master-verify.sh
```

### Run Individual Verifications

```bash
cd .verification
./verify-copilot-files.sh
./verify-project-structure.sh
./verify-docker.sh
./verify-terraform.sh
./verify-ci.sh
```

## Exit Codes

- **0**: All checks passed
- **1**: One or more checks failed

## Output

Each script provides:
- ✓ Success messages (green)
- ⚠️ Warning messages (yellow) - non-blocking
- ❌ Error messages (red) - blocking
- ℹ️ Info messages - contextual information

## Criteria Documentation

All validation criteria are based on:
- Official GitHub Copilot documentation
- Microsoft .NET 10 documentation
- React and TypeScript best practices
- Docker and Docker Compose specifications
- HashiCorp Terraform best practices
- GitHub Actions official documentation

See `/tmp/budgetbuddy-criteria/CRITERIA.md` for detailed criteria documentation.

## Integration

These scripts should be:
1. Run before committing changes
2. Integrated into CI/CD pipelines
3. Run as pre-push git hooks (optional)
4. Used for pull request validation

## Dependencies

Optional but recommended:
- `python3` - For YAML/JSON validation
- `docker` or `docker-compose` - For Docker configuration validation
- `terraform` - For Terraform validation
- Standard Unix utilities: `grep`, `find`, `awk`, `sed`

The scripts will gracefully skip validation steps if optional dependencies are not available and provide warnings.
