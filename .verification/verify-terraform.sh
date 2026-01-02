#!/bin/bash
# Verification script for Terraform configuration
# Validates Terraform files and best practices

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=================================================="
echo "Verifying Terraform Configuration"
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

echo "1. Checking Terraform directory structure"
echo "------------------------------------------"
TERRAFORM_DIR="$REPO_ROOT/terraform"
if [ -d "$TERRAFORM_DIR" ]; then
    success "Terraform directory exists"
    
    # Check for main.tf
    if [ -f "$TERRAFORM_DIR/main.tf" ]; then
        success "main.tf exists"
    else
        error "main.tf not found"
    fi
    
    # Check for variables.tf
    if [ -f "$TERRAFORM_DIR/variables.tf" ]; then
        success "variables.tf exists"
    else
        warning "variables.tf not found (recommended)"
    fi
    
    # Check for outputs.tf
    if [ -f "$TERRAFORM_DIR/outputs.tf" ]; then
        success "outputs.tf exists"
    else
        warning "outputs.tf not found (recommended)"
    fi
    
    # Check for versions.tf or provider version constraints
    if [ -f "$TERRAFORM_DIR/versions.tf" ]; then
        success "versions.tf exists"
    elif grep -rq "required_providers" "$TERRAFORM_DIR"/*.tf 2>/dev/null; then
        success "Provider version constraints found"
    else
        error "No provider version constraints found (required)"
    fi
    
    # Check for modules directory
    if [ -d "$TERRAFORM_DIR/modules" ]; then
        success "modules directory exists (modular design)"
    else
        info "No modules directory (acceptable for simple projects)"
    fi
else
    error "Terraform directory not found at $TERRAFORM_DIR"
    echo ""
    echo "=================================================="
    echo "Summary"
    echo "=================================================="
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    echo ""
    echo -e "${RED}✗ Found $ERRORS error(s) in Terraform configuration${NC}"
    exit 1
fi
echo ""

echo "2. Checking for hardcoded secrets"
echo "----------------------------------"
# Check for common secret patterns in .tf files
if find "$TERRAFORM_DIR" -name "*.tf" -type f -exec grep -l "password.*=.*\".*\"" {} \; 2>/dev/null | grep -q .; then
    error "Found hardcoded passwords in .tf files"
fi

if find "$TERRAFORM_DIR" -name "*.tf" -type f -exec grep -l "secret.*=.*\".*\"" {} \; 2>/dev/null | grep -q .; then
    warning "Found potential hardcoded secrets in .tf files"
fi

if find "$TERRAFORM_DIR" -name "*.tf" -type f -exec grep -l "token.*=.*\".*\"" {} \; 2>/dev/null | grep -q .; then
    warning "Found potential hardcoded tokens in .tf files"
fi

# Check if secrets are using variables or key vault references
if grep -rq "var\.\|data\.azurerm_key_vault" "$TERRAFORM_DIR"/*.tf 2>/dev/null; then
    success "Using variables or key vault for configuration"
else
    info "No variable references found (may not be needed)"
fi
echo ""

echo "3. Running terraform fmt -check"
echo "--------------------------------"
if command -v terraform &> /dev/null; then
    cd "$TERRAFORM_DIR"
    if terraform fmt -check -recursive > /dev/null 2>&1; then
        success "Terraform files are properly formatted"
    else
        warning "Terraform files need formatting (run 'terraform fmt')"
    fi
    cd "$REPO_ROOT"
else
    warning "Terraform CLI not installed, skipping format check"
fi
echo ""

echo "4. Running terraform validate"
echo "------------------------------"
if command -v terraform &> /dev/null; then
    cd "$TERRAFORM_DIR"
    
    # Check if .terraform directory exists (initialized)
    if [ -d ".terraform" ]; then
        if terraform validate > /dev/null 2>&1; then
            success "Terraform configuration is valid"
        else
            error "Terraform validation failed"
            terraform validate
        fi
    else
        info "Terraform not initialized, skipping validation"
        info "Run 'terraform init' to initialize"
    fi
    cd "$REPO_ROOT"
else
    warning "Terraform CLI not installed, skipping validation"
fi
echo ""

echo "5. Checking for remote backend configuration"
echo "---------------------------------------------"
if grep -rq "backend.*\"azurerm\"\|backend.*\"s3\"\|backend.*\"gcs\"" "$TERRAFORM_DIR"/*.tf 2>/dev/null; then
    success "Remote backend configured"
else
    warning "No remote backend configured (recommended for team collaboration)"
fi
echo ""

echo "6. Checking for resource tags"
echo "------------------------------"
if grep -rq "tags.*=" "$TERRAFORM_DIR"/*.tf 2>/dev/null; then
    success "Resource tags found in configuration"
else
    info "No resource tags found (recommended for organization)"
fi
echo ""

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All Terraform checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in Terraform configuration${NC}"
    exit 1
fi
