#!/bin/bash
# Master verification script - runs all verification checks
# This is the single command to validate the entire repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_ERRORS=0
TOTAL_WARNINGS=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================================="
echo "  BudgetBuddy Master Verification"
echo "=========================================================="
echo ""
echo "Running all verification scripts..."
echo ""

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Array to track results
declare -A results

run_verification() {
    local script=$1
    local name=$2
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Running: $name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if bash "$SCRIPT_DIR/$script"; then
        results["$name"]="PASS"
        echo ""
    else
        results["$name"]="FAIL"
        ((TOTAL_ERRORS++))
        echo ""
    fi
}

# Run all verification scripts
run_verification "verify-copilot-files.sh" "Copilot Customization Files"
run_verification "verify-project-structure.sh" "Project Structure"
run_verification "verify-docker.sh" "Docker & Dev Containers"
run_verification "verify-terraform.sh" "Terraform Configuration"
run_verification "verify-ci.sh" "GitHub Actions Workflows"

# Print summary
echo "=========================================================="
echo "  VERIFICATION SUMMARY"
echo "=========================================================="
echo ""

for check in "${!results[@]}"; do
    result="${results[$check]}"
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASSED${NC} - $check"
    else
        echo -e "${RED}✗ FAILED${NC} - $check"
    fi
done

echo ""
echo "=========================================================="
echo ""

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL VERIFICATIONS PASSED!${NC}"
    echo ""
    echo "The BudgetBuddy repository meets all defined criteria."
    echo "No drift detected from specifications."
    exit 0
else
    echo -e "${RED}❌ $TOTAL_ERRORS VERIFICATION(S) FAILED${NC}"
    echo ""
    echo "Please fix the errors above and run this script again."
    exit 1
fi
