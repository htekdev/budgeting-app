#!/bin/bash
# Verification script for Docker and Dev Container configuration
# Validates docker-compose.yml and .devcontainer setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=================================================="
echo "Verifying Docker & Dev Container Configuration"
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

echo "1. Checking docker-compose.yml"
echo "-------------------------------"
COMPOSE_FILE="$REPO_ROOT/docker-compose.yml"
if [ -f "$COMPOSE_FILE" ]; then
    success "docker-compose.yml exists"
    
    # Check YAML syntax with docker-compose if available
    if command -v docker-compose &> /dev/null; then
        if docker-compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
            success "docker-compose.yml syntax is valid"
        else
            error "docker-compose.yml has syntax errors"
        fi
    elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
        if docker compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
            success "docker-compose.yml syntax is valid"
        else
            error "docker-compose.yml has syntax errors"
        fi
    else
        warning "docker-compose not available, skipping syntax validation"
    fi
    
    # Check for services section
    if grep -q "services:" "$COMPOSE_FILE"; then
        success "Services section found"
        
        # Check for database service
        if grep -A 50 "services:" "$COMPOSE_FILE" | grep -q "db:\|database:"; then
            success "Database service defined"
            
            # Check for SQL Server image
            if grep -q "mcr.microsoft.com/mssql/server" "$COMPOSE_FILE"; then
                success "Using official Microsoft SQL Server image"
                
                # Check for required environment variables
                if grep -A 10 "mcr.microsoft.com/mssql/server" "$COMPOSE_FILE" | grep -q "ACCEPT_EULA"; then
                    success "ACCEPT_EULA environment variable found"
                else
                    error "ACCEPT_EULA environment variable missing"
                fi
                
                if grep -A 10 "mcr.microsoft.com/mssql/server" "$COMPOSE_FILE" | grep -q "MSSQL_SA_PASSWORD\|SA_PASSWORD"; then
                    success "SQL Server password configured"
                else
                    error "SQL Server password not configured"
                fi
            else
                warning "Not using Microsoft SQL Server image"
            fi
            
            # Check for volume mount
            if grep -A 15 "db:\|database:" "$COMPOSE_FILE" | grep -q "volumes:"; then
                success "Database volume configured for persistence"
            else
                warning "No volume configured - data will be lost on container removal"
            fi
        else
            error "No database service found"
        fi
        
        # Check for backend service
        if grep -A 50 "services:" "$COMPOSE_FILE" | grep -q "backend:\|api:"; then
            success "Backend service defined"
        else
            warning "Backend service not found"
        fi
        
        # Check for frontend service
        if grep -A 50 "services:" "$COMPOSE_FILE" | grep -q "frontend:\|web:"; then
            success "Frontend service defined"
        else
            warning "Frontend service not found"
        fi
        
    else
        error "No services section found in docker-compose.yml"
    fi
    
    # Check for volumes section
    if grep -q "^volumes:" "$COMPOSE_FILE"; then
        success "Volumes section defined"
    else
        info "No top-level volumes section (may be using inline volumes)"
    fi
else
    error "docker-compose.yml not found at $COMPOSE_FILE"
fi
echo ""

echo "2. Checking .devcontainer configuration"
echo "----------------------------------------"
DEVCONTAINER_DIR="$REPO_ROOT/.devcontainer"
DEVCONTAINER_JSON="$DEVCONTAINER_DIR/devcontainer.json"

if [ -d "$DEVCONTAINER_DIR" ]; then
    success ".devcontainer directory exists"
    
    if [ -f "$DEVCONTAINER_JSON" ]; then
        success "devcontainer.json exists"
        
        # Check JSON syntax
        if command -v python3 &> /dev/null; then
            if python3 -c "import json; json.load(open('$DEVCONTAINER_JSON'))" 2>/dev/null; then
                success "devcontainer.json syntax is valid"
            else
                error "devcontainer.json has syntax errors"
            fi
        else
            warning "Python not available, skipping JSON validation"
        fi
        
        # Check for name field
        if grep -q "\"name\":" "$DEVCONTAINER_JSON"; then
            success "Name field defined"
        else
            warning "No name field defined"
        fi
        
        # Check for dockerComposeFile reference
        if grep -q "\"dockerComposeFile\":" "$DEVCONTAINER_JSON"; then
            success "dockerComposeFile reference found"
            
            # Verify it points to docker-compose.yml
            if grep -q "docker-compose.yml\|compose.yaml" "$DEVCONTAINER_JSON"; then
                success "References docker-compose configuration"
            else
                warning "dockerComposeFile doesn't reference standard compose file"
            fi
        else
            info "No dockerComposeFile (may use Dockerfile or image directly)"
        fi
        
        # Check for service field (when using docker-compose)
        if grep -q "\"dockerComposeFile\":" "$DEVCONTAINER_JSON"; then
            if grep -q "\"service\":" "$DEVCONTAINER_JSON"; then
                success "Primary service specified"
            else
                warning "No primary service specified for docker-compose setup"
            fi
        fi
        
        # Check for workspaceFolder
        if grep -q "\"workspaceFolder\":" "$DEVCONTAINER_JSON"; then
            success "Workspace folder configured"
        else
            info "No explicit workspaceFolder (using default)"
        fi
        
        # Check for forwardPorts
        if grep -q "\"forwardPorts\":" "$DEVCONTAINER_JSON"; then
            success "Port forwarding configured"
        else
            warning "No port forwarding configured"
        fi
        
        # Check for postCreateCommand or postStartCommand
        if grep -q "\"postCreateCommand\"\|\"postStartCommand\":" "$DEVCONTAINER_JSON"; then
            success "Post-creation commands configured"
        else
            info "No post-creation commands defined"
        fi
    else
        error "devcontainer.json not found at $DEVCONTAINER_JSON"
    fi
else
    error ".devcontainer directory not found at $DEVCONTAINER_DIR"
fi
echo ""

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All Docker & Dev Container checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in Docker configuration${NC}"
    exit 1
fi
