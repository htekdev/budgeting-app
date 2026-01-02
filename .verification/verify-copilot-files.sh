#!/bin/bash
# Verification script for GitHub Copilot customization files
# Based on official GitHub Copilot documentation and specifications

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0
WARNINGS=0

echo "=================================================="
echo "Verifying GitHub Copilot Customization Files"
echo "=================================================="
echo ""

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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

# Check if a file is valid Markdown
check_markdown() {
    local file=$1
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Basic check: file should have some content
    if [ ! -s "$file" ]; then
        return 1
    fi
    
    return 0
}

# Check YAML frontmatter
check_yaml_frontmatter() {
    local file=$1
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Check if file starts with ---
    if ! head -n 1 "$file" | grep -q "^---$"; then
        return 1
    fi
    
    # Check if there's a closing ---
    if ! tail -n +2 "$file" | grep -q "^---$"; then
        return 1
    fi
    
    return 0
}

# Extract and validate YAML frontmatter
validate_yaml_frontmatter() {
    local file=$1
    local temp_yaml=$(mktemp)
    
    # Extract YAML between first two ---
    awk '/^---$/{flag++; next} flag==1' "$file" | head -n -1 > "$temp_yaml"
    
    # Try to parse with Python (if available)
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$temp_yaml'))" 2>/dev/null
        local result=$?
        rm -f "$temp_yaml"
        return $result
    fi
    
    rm -f "$temp_yaml"
    return 0
}

echo "1. Checking .github/copilot-instructions.md"
echo "--------------------------------------------"
COPILOT_INSTRUCTIONS="$REPO_ROOT/.github/copilot-instructions.md"
if [ -f "$COPILOT_INSTRUCTIONS" ]; then
    success "File exists at correct location"
    
    if check_markdown "$COPILOT_INSTRUCTIONS"; then
        success "File contains content"
    else
        error "File is empty"
    fi
    
    # Check for external URLs (warning only)
    if grep -q "http:/\|https:/" "$COPILOT_INSTRUCTIONS"; then
        warning "File contains URLs - Copilot won't fetch external resources"
    fi
    
    # Check for "follow" or "refer to" patterns that might indicate external references
    if grep -qi "follow.*\.md\|refer to.*\.md\|see.*\.md" "$COPILOT_INSTRUCTIONS"; then
        warning "File appears to reference other documents - use inline instructions instead"
    fi
else
    error "File not found at $COPILOT_INSTRUCTIONS"
fi
echo ""

echo "2. Checking .github/instructions/*.instructions.md files"
echo "---------------------------------------------------------"
INSTRUCTIONS_DIR="$REPO_ROOT/.github/instructions"
if [ -d "$INSTRUCTIONS_DIR" ]; then
    success "Instructions directory exists"
    
    # Find all .instructions.md files
    instruction_files=$(find "$INSTRUCTIONS_DIR" -name "*.instructions.md" 2>/dev/null || true)
    
    if [ -n "$instruction_files" ]; then
        file_count=$(echo "$instruction_files" | wc -l)
        info "Found $file_count instruction file(s)"
        
        while IFS= read -r file; do
            filename=$(basename "$file")
            echo "  Checking: $filename"
            
            if check_yaml_frontmatter "$file"; then
                success "    Has YAML frontmatter"
                
                if validate_yaml_frontmatter "$file"; then
                    success "    YAML is valid"
                    
                    # Check for applyTo field
                    if grep -q "applyTo:" "$file"; then
                        success "    Has 'applyTo' field"
                    else
                        error "    Missing 'applyTo' field in frontmatter"
                    fi
                else
                    error "    YAML frontmatter is invalid"
                fi
            else
                error "    Missing or invalid YAML frontmatter"
            fi
        done <<< "$instruction_files"
    else
        warning "No .instructions.md files found (optional)"
    fi
else
    warning "Instructions directory not found (optional): $INSTRUCTIONS_DIR"
fi
echo ""

echo "3. Checking AGENTS.md"
echo "---------------------"
AGENTS_MD="$REPO_ROOT/AGENTS.md"
if [ -f "$AGENTS_MD" ]; then
    success "File exists at repository root"
    
    if check_markdown "$AGENTS_MD"; then
        success "File contains content"
    else
        error "File is empty"
    fi
else
    warning "AGENTS.md not found at root (optional but recommended)"
fi
echo ""

echo "4. Checking .github/agents/*.agent.md files"
echo "--------------------------------------------"
AGENTS_DIR="$REPO_ROOT/.github/agents"
if [ -d "$AGENTS_DIR" ]; then
    success "Agents directory exists"
    
    # Find all .agent.md files
    agent_files=$(find "$AGENTS_DIR" -name "*.agent.md" 2>/dev/null || true)
    
    if [ -n "$agent_files" ]; then
        file_count=$(echo "$agent_files" | wc -l)
        info "Found $file_count agent file(s)"
        
        while IFS= read -r file; do
            filename=$(basename "$file")
            echo "  Checking: $filename"
            
            if check_yaml_frontmatter "$file"; then
                success "    Has YAML frontmatter"
                
                if validate_yaml_frontmatter "$file"; then
                    success "    YAML is valid"
                    
                    # Check for required fields
                    if grep -q "name:" "$file"; then
                        success "    Has 'name' field"
                    else
                        error "    Missing 'name' field (required)"
                    fi
                    
                    if grep -q "description:" "$file"; then
                        success "    Has 'description' field"
                    else
                        error "    Missing 'description' field (required)"
                    fi
                    
                    if grep -q "tools:" "$file"; then
                        success "    Has 'tools' field"
                    else
                        error "    Missing 'tools' field (required)"
                    fi
                else
                    error "    YAML frontmatter is invalid"
                fi
            else
                error "    Missing or invalid YAML frontmatter"
            fi
        done <<< "$agent_files"
    else
        warning "No .agent.md files found (optional)"
    fi
else
    warning "Agents directory not found (optional): $AGENTS_DIR"
fi
echo ""

echo "5. Checking .github/skills/*/SKILL.md files"
echo "--------------------------------------------"
SKILLS_DIR="$REPO_ROOT/.github/skills"
if [ -d "$SKILLS_DIR" ]; then
    success "Skills directory exists"
    
    # Find all SKILL.md files
    skill_files=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null || true)
    
    if [ -n "$skill_files" ]; then
        file_count=$(echo "$skill_files" | wc -l)
        info "Found $file_count skill file(s)"
        
        while IFS= read -r file; do
            skill_dir=$(dirname "$file")
            skill_name=$(basename "$skill_dir")
            echo "  Checking: $skill_name/SKILL.md"
            
            if check_yaml_frontmatter "$file"; then
                success "    Has YAML frontmatter"
                
                if validate_yaml_frontmatter "$file"; then
                    success "    YAML is valid"
                    
                    # Check for required fields
                    if grep -q "name:" "$file"; then
                        success "    Has 'name' field"
                        
                        # Extract name and validate format
                        yaml_name=$(grep "name:" "$file" | head -1 | sed 's/name://;s/[" ]//g')
                        if [[ "$yaml_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
                            success "    Name format is valid: $yaml_name"
                            
                            # Check if directory name matches
                            if [ "$yaml_name" = "$skill_name" ]; then
                                success "    Directory name matches 'name' field"
                            else
                                error "    Directory name '$skill_name' doesn't match 'name' field '$yaml_name'"
                            fi
                        else
                            error "    Name format invalid (use lowercase, hyphens only): $yaml_name"
                        fi
                    else
                        error "    Missing 'name' field (required)"
                    fi
                    
                    if grep -q "description:" "$file"; then
                        success "    Has 'description' field"
                        
                        # Check for angle brackets
                        if grep "description:" "$file" | grep -q "[<>]"; then
                            error "    Description contains angle brackets (not allowed)"
                        fi
                    else
                        error "    Missing 'description' field (required)"
                    fi
                else
                    error "    YAML frontmatter is invalid"
                fi
            else
                error "    Missing or invalid YAML frontmatter"
            fi
        done <<< "$skill_files"
    else
        warning "No SKILL.md files found (optional)"
    fi
else
    warning "Skills directory not found (optional): $SKILLS_DIR"
fi
echo ""

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All Copilot customization file checks passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in Copilot customization files${NC}"
    exit 1
fi
