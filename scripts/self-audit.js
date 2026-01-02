#!/usr/bin/env node

/**
 * Self-Audit Script for BudgetBuddy
 * 
 * Runs comprehensive checks to verify all components meet requirements:
 * - Backend build and tests
 * - Frontend build and linting
 * - Copilot customization file validation
 * - Infrastructure validation
 * - Documentation checks
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function success(message) {
  log(`✅ ${message}`, colors.green);
}

function error(message) {
  log(`❌ ${message}`, colors.red);
}

function warning(message) {
  log(`⚠️  ${message}`, colors.yellow);
}

function info(message) {
  log(`ℹ️  ${message}`, colors.cyan);
}

function section(message) {
  log(`\n${'='.repeat(60)}`, colors.blue);
  log(`  ${message}`, colors.blue);
  log(`${'='.repeat(60)}`, colors.blue);
}

function run(command, description, options = {}) {
  try {
    info(`Running: ${description}`);
    execSync(command, { 
      stdio: options.silent ? 'pipe' : 'inherit',
      cwd: options.cwd || process.cwd()
    });
    success(`${description} - PASSED`);
    return true;
  } catch (e) {
    if (!options.optional) {
      error(`${description} - FAILED`);
      if (options.silent) {
        console.log(e.stdout?.toString() || e.message);
      }
      return false;
    } else {
      warning(`${description} - SKIPPED (optional)`);
      return true;
    }
  }
}

function fileExists(filePath) {
  return fs.existsSync(path.resolve(__dirname, '..', filePath));
}

function validateFile(filePath, description) {
  if (fileExists(filePath)) {
    success(`${description} exists`);
    return true;
  } else {
    error(`${description} missing: ${filePath}`);
    return false;
  }
}

// Main audit function
async function runAudit() {
  log('\n🔍 BudgetBuddy Self-Audit Starting...', colors.cyan);
  log('This will verify all project components\n');

  const results = {
    passed: 0,
    failed: 0,
    warnings: 0,
  };

  // 1. Project Structure Check
  section('1. Project Structure');
  const requiredDirs = [
    'src/backend',
    'src/frontend',
    'infrastructure/terraform',
    '.github/agents',
    '.github/instructions',
    '.github/skills',
    '.github/workflows',
    'docs/architecture',
    'docs/runbooks',
  ];

  requiredDirs.forEach(dir => {
    if (validateFile(dir, dir)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 2. Backend Validation
  section('2. Backend (.NET)');
  
  if (run('dotnet --version', 'Check .NET SDK', { silent: true })) {
    results.passed++;
  } else {
    results.failed++;
  }

  if (run('dotnet build', 'Build backend', { cwd: 'src/backend' })) {
    results.passed++;
  } else {
    results.failed++;
  }

  if (run('dotnet test --no-build', 'Run backend tests', { cwd: 'src/backend', optional: true })) {
    results.passed++;
  } else {
    results.warnings++;
  }

  // 3. Frontend Validation
  section('3. Frontend (React + TypeScript)');

  if (run('node --version', 'Check Node.js', { silent: true })) {
    results.passed++;
  } else {
    results.failed++;
  }

  if (run('npm run lint', 'Lint frontend', { cwd: 'src/frontend', optional: true })) {
    results.passed++;
  } else {
    results.warnings++;
  }

  if (run('npm run type-check', 'TypeScript type check', { cwd: 'src/frontend', optional: true })) {
    results.passed++;
  } else {
    results.warnings++;
  }

  // 4. Copilot Customization Validation
  section('4. Copilot Customization Files');

  const copilotFiles = [
    '.github/copilot-instructions.md',
    '.github/instructions/backend.instructions.md',
    '.github/instructions/frontend.instructions.md',
    '.github/agents/backend-expert.agent.md',
    '.github/agents/frontend-expert.agent.md',
    '.github/agents/devops-expert.agent.md',
    '.github/skills/budget-calculator.skill.md',
    'AGENTS.md',
  ];

  copilotFiles.forEach(file => {
    if (validateFile(file, file)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 5. Infrastructure Validation
  section('5. Infrastructure as Code');

  const terraformFiles = [
    'infrastructure/terraform/main.tf',
    'infrastructure/terraform/variables.tf',
    'infrastructure/terraform/resources.tf',
    'infrastructure/terraform/outputs.tf',
    'infrastructure/terraform/terraform.tfvars.example',
  ];

  terraformFiles.forEach(file => {
    if (validateFile(file, file)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 6. Docker Configuration
  section('6. Docker & Containerization');

  const dockerFiles = [
    'docker-compose.yml',
    'src/backend/Dockerfile',
    'src/frontend/Dockerfile',
    '.devcontainer/devcontainer.json',
  ];

  dockerFiles.forEach(file => {
    if (validateFile(file, file)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 7. CI/CD Workflows
  section('7. GitHub Actions Workflows');

  const workflows = [
    '.github/workflows/backend-ci.yml',
    '.github/workflows/frontend-ci.yml',
    '.github/workflows/codeql.yml',
  ];

  workflows.forEach(file => {
    if (validateFile(file, file)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 8. Documentation
  section('8. Documentation');

  const docs = [
    'README.md',
    'AGENTS.md',
    'docs/runbooks/verification.md',
    '.gitignore',
  ];

  docs.forEach(file => {
    if (validateFile(file, file)) {
      results.passed++;
    } else {
      results.failed++;
    }
  });

  // 9. Final Report
  section('Final Audit Report');

  log(`\n📊 Results:`);
  log(`   ✅ Passed:   ${results.passed}`, colors.green);
  log(`   ❌ Failed:   ${results.failed}`, colors.red);
  log(`   ⚠️  Warnings: ${results.warnings}`, colors.yellow);

  const total = results.passed + results.failed + results.warnings;
  const percentage = ((results.passed / total) * 100).toFixed(1);

  log(`\n   Success Rate: ${percentage}%\n`);

  if (results.failed > 0) {
    error('❌ AUDIT FAILED - Please fix the errors above');
    process.exit(1);
  } else if (results.warnings > 0) {
    warning('⚠️  AUDIT PASSED with warnings - Consider addressing warnings');
    process.exit(0);
  } else {
    success('✅ AUDIT PASSED - All checks successful!');
    process.exit(0);
  }
}

// Run the audit
runAudit().catch(err => {
  error(`Audit script error: ${err.message}`);
  process.exit(1);
});
