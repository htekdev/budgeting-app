#!/bin/bash
# Verification script for GitHub Actions CI/CD workflows
# Validates workflow YAML files and structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=================================================="
echo "Verifying GitHub Actions Workflows"
echo "=================================================="
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo "ℹ️  $1"
}

echo "1. Checking .github/workflows directory"
echo "----------------------------------------"
WORKFLOWS_DIR="$REPO_ROOT/.github/workflows"
if [ -d "$WORKFLOWS_DIR" ]; then
    success "Workflows directory exists"
    
    # Find all workflow files
    workflow_files=$(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
    
    if [ -n "$workflow_files" ]; then
        file_count=$(echo "$workflow_files" | wc -l)
        info "Found $file_count workflow file(s)"
        echo ""
        
        while IFS= read -r file; do
            filename=$(basename "$file")
            echo "  Checking: $filename"
            echo "  -------------------------"
            
            # Check YAML syntax
            if command -v python3 &> /dev/null; then
                if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                    success "    Valid YAML syntax"
                else
                    error "    Invalid YAML syntax"
                    continue
                fi
            else
                warning "    Python not available, skipping YAML validation"
            fi
            
            # Check for 'on' trigger (required)
            if grep -q "^on:" "$file"; then
                success "    Has 'on' trigger definition"
                
                # Check for common triggers
                if grep -A 5 "^on:" "$file" | grep -q "push:\|pull_request:\|workflow_dispatch:\|schedule:"; then
                    success "    Has standard triggers configured"
                fi
            else
                error "    Missing 'on' trigger (required)"
            fi
            
            # Check for 'jobs' section (required)
            if grep -q "^jobs:" "$file"; then
                success "    Has 'jobs' section"
                
                # Count number of jobs
                job_count=$(grep -A 1000 "^jobs:" "$file" | grep "^  [a-zA-Z]" | wc -l)
                info "    Defines $job_count job(s)"
            else
                error "    Missing 'jobs' section (required)"
            fi
            
            # Check for checkout action
            if grep -q "actions/checkout" "$file"; then
                success "    Uses checkout action"
            else
                warning "    No checkout action found (may not need it)"
            fi
            
            # Check for specific CI steps based on project type
            
            # .NET specific checks
            if grep -q "setup-dotnet\|dotnet build\|dotnet test" "$file"; then
                success "    Contains .NET build/test steps"
                
                # Check for .NET version
                if grep -q "dotnet-version.*10\|dotnet-version.*'10" "$file"; then
                    success "    Configured for .NET 10"
                else
                    warning "    .NET version not explicitly set to 10"
                fi
            fi
            
            # Node/npm specific checks
            if grep -q "setup-node\|npm install\|npm test\|npm run" "$file"; then
                success "    Contains Node.js build/test steps"
            fi
            
            # Check for runs-on specification
            if grep -q "runs-on:" "$file"; then
                success "    Specifies runner(s)"
                
                # Check for common runners
                if grep "runs-on:" "$file" | grep -q "ubuntu-latest\|windows-latest\|macos-latest"; then
                    success "    Uses GitHub-hosted runner"
                fi
            else
                error "    Missing 'runs-on' specification"
            fi
            
            # Check for name field (optional but recommended)
            if grep -q "^name:" "$file"; then
                success "    Has descriptive name"
            else
                info "    No workflow name (will use filename)"
            fi
            
            echo ""
        done <<< "$workflow_files"
    else
        error "No workflow files found in $WORKFLOWS_DIR"
    fi
else
    error "Workflows directory not found at $WORKFLOWS_DIR"
fi
echo ""

echo "2. Checking for CI workflow specifically"
echo "-----------------------------------------"
if [ -d "$WORKFLOWS_DIR" ]; then
    # Look for common CI workflow names
    if ls "$WORKFLOWS_DIR"/ci.yml "$WORKFLOWS_DIR"/ci.yaml "$WORKFLOWS_DIR"/build.yml "$WORKFLOWS_DIR"/build.yaml 2>/dev/null | grep -q .; then
        success "Found CI workflow file"
    else
        # Check if any workflow has CI-related content
        if find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" | xargs grep -l "build\|test" 2>/dev/null | grep -q .; then
            success "Found workflow with CI steps"
        else
            warning "No explicit CI workflow found"
        fi
    fi
fi
echo ""

echo "3. Checking for security best practices"
echo "----------------------------------------"
if [ -d "$WORKFLOWS_DIR" ]; then
    workflow_files=$(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
    
    if [ -n "$workflow_files" ]; then
        # Check for secrets usage
        if grep -rq "secrets\." "$WORKFLOWS_DIR" 2>/dev/null; then
            success "Uses GitHub secrets for sensitive data"
        else
            info "No secrets usage found (may not be needed)"
        fi
        
        # Check for hardcoded credentials (basic check)
        if grep -riE "password.*=|token.*=|api_key.*=" "$WORKFLOWS_DIR" 2>/dev/null | grep -v "secrets\." | grep -q .; then
            warning "Potential hardcoded credentials found in workflows"
        fi
        
        # Check for permissions specification (security best practice)
        if grep -rq "permissions:" "$WORKFLOWS_DIR" 2>/dev/null; then
            success "Workflow permissions explicitly defined"
        else
            info "No explicit permissions set (using defaults)"
        fi
    fi
fi
echo ""

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All GitHub Actions workflow checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in workflows${NC}"
    exit 1
fi
