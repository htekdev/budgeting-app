#!/bin/bash
# Verification script for project structure
# Validates backend (.NET 10) and frontend (React + TypeScript) structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=================================================="
echo "Verifying Project Structure"
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

echo "1. Checking Backend (ASP.NET Core Web API)"
echo "-------------------------------------------"
BACKEND_DIR="$REPO_ROOT/backend"
if [ -d "$BACKEND_DIR" ]; then
    success "Backend directory exists"
    
    # Check for .csproj file
    if ls "$BACKEND_DIR"/*.csproj 1> /dev/null 2>&1; then
        success "Found .csproj file"
        
        # Check .NET version
        csproj_file=$(ls "$BACKEND_DIR"/*.csproj | head -1)
        if grep -q "<TargetFramework>net10.0</TargetFramework>" "$csproj_file"; then
            success ".NET 10 target framework configured"
        else
            error ".NET 10 target framework not found in .csproj"
        fi
    else
        error "No .csproj file found in backend directory"
    fi
    
    # Check for Program.cs
    if [ -f "$BACKEND_DIR/Program.cs" ]; then
        success "Program.cs exists"
    else
        error "Program.cs not found"
    fi
    
    # Check for Controllers directory
    if [ -d "$BACKEND_DIR/Controllers" ]; then
        success "Controllers directory exists"
    else
        warning "Controllers directory not found"
    fi
    
    # Check for Models directory
    if [ -d "$BACKEND_DIR/Models" ]; then
        success "Models directory exists"
    else
        warning "Models directory not found"
    fi
    
    # Check for appsettings.json
    if [ -f "$BACKEND_DIR/appsettings.json" ]; then
        success "appsettings.json exists"
        
        # Check for SQL Server connection string
        if grep -q "ConnectionStrings" "$BACKEND_DIR/appsettings.json"; then
            success "ConnectionStrings configuration found"
        else
            warning "No ConnectionStrings found in appsettings.json"
        fi
    else
        warning "appsettings.json not found"
    fi
    
    # Check for Properties/launchSettings.json
    if [ -f "$BACKEND_DIR/Properties/launchSettings.json" ]; then
        success "Properties/launchSettings.json exists"
    else
        warning "Properties/launchSettings.json not found"
    fi
    
    # Warn if Startup.cs exists (deprecated)
    if [ -f "$BACKEND_DIR/Startup.cs" ]; then
        warning "Startup.cs found - this is deprecated in .NET 6+"
    fi
else
    error "Backend directory not found at $BACKEND_DIR"
fi
echo ""

echo "2. Checking Frontend (React + TypeScript)"
echo "------------------------------------------"
FRONTEND_DIR="$REPO_ROOT/frontend"
if [ -d "$FRONTEND_DIR" ]; then
    success "Frontend directory exists"
    
    # Check for package.json
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        success "package.json exists"
        
        # Check for React and TypeScript dependencies
        if grep -q "\"react\":" "$FRONTEND_DIR/package.json"; then
            success "React dependency found"
        else
            error "React not found in dependencies"
        fi
        
        if grep -q "\"typescript\":" "$FRONTEND_DIR/package.json"; then
            success "TypeScript dependency found"
        else
            error "TypeScript not found in dependencies"
        fi
    else
        error "package.json not found"
    fi
    
    # Check for tsconfig.json
    if [ -f "$FRONTEND_DIR/tsconfig.json" ]; then
        success "tsconfig.json exists"
        
        # Check for strict mode in tsconfig.json or tsconfig.app.json
        strict_found=false
        if [ -f "$FRONTEND_DIR/tsconfig.app.json" ]; then
            if grep -q "\"strict\": *true" "$FRONTEND_DIR/tsconfig.app.json"; then
                strict_found=true
            fi
        fi
        
        if grep -q "\"strict\": *true" "$FRONTEND_DIR/tsconfig.json"; then
            strict_found=true
        fi
        
        if [ "$strict_found" = true ]; then
            success "TypeScript strict mode enabled"
        else
            warning "TypeScript strict mode not explicitly set"
        fi
    else
        error "tsconfig.json not found"
    fi
    
    # Check for ESLint config
    if [ -f "$FRONTEND_DIR/.eslintrc.json" ] || [ -f "$FRONTEND_DIR/.eslintrc.js" ] || [ -f "$FRONTEND_DIR/eslint.config.js" ]; then
        success "ESLint configuration found"
    else
        warning "No ESLint configuration found"
    fi
    
    # Check for Prettier config
    if [ -f "$FRONTEND_DIR/.prettierrc" ] || [ -f "$FRONTEND_DIR/.prettierrc.json" ] || [ -f "$FRONTEND_DIR/.prettierrc.js" ]; then
        success "Prettier configuration found"
    else
        warning "No Prettier configuration found"
    fi
    
    # Check for vite.config
    if [ -f "$FRONTEND_DIR/vite.config.ts" ] || [ -f "$FRONTEND_DIR/vite.config.js" ]; then
        success "Vite configuration found"
    else
        info "Vite configuration not found (using different build tool)"
    fi
    
    # Check for src directory
    if [ -d "$FRONTEND_DIR/src" ]; then
        success "src directory exists"
    else
        error "src directory not found"
    fi
else
    error "Frontend directory not found at $FRONTEND_DIR"
fi
echo ""

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All project structure checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in project structure${NC}"
    exit 1
fi
