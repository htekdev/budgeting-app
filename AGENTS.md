# GitHub Copilot Agents for BudgetBuddy

This document describes the custom agents available in this repository and how to use them effectively.

## Available Agents

### 1. Code Review Agent
**Location:** `.github/agents/code-reviewer.agent.md`

**Purpose:** Comprehensive code review focusing on quality, security, and best practices.

**When to use:**
- Before submitting a PR
- When reviewing teammate's code
- For security audits
- When refactoring code

**How to invoke:**
```
@workspace /agents Review my code changes for security and quality issues
```

**What it checks:**
- Code quality and maintainability
- Security vulnerabilities
- Project conventions adherence
- Error handling
- Test coverage
- Performance issues

---

### 2. Testing Agent
**Location:** `.github/agents/testing.agent.md`

**Purpose:** Generate comprehensive tests for your code.

**When to use:**
- When adding new features
- When increasing test coverage
- When fixing bugs (write test first)
- For TDD workflows

**How to invoke:**
```
@workspace /agents Generate unit tests for the BudgetsController
@workspace /agents Create integration tests for the budget API endpoints
```

**Capabilities:**
- C# xUnit tests for backend
- TypeScript Vitest/Jest tests for frontend
- Integration tests
- Mocking strategies
- Edge case coverage

---

### 3. Documentation Agent
**Location:** `.github/agents/documentation.agent.md`

**Purpose:** Create and maintain comprehensive documentation.

**When to use:**
- Documenting new features
- Creating API documentation
- Writing deployment guides
- Onboarding new developers

**How to invoke:**
```
@workspace /agents Document the Budgets API endpoints
@workspace /agents Create a deployment runbook for Azure
```

**What it creates:**
- API documentation
- Architecture documentation
- Deployment procedures
- Developer guides
- Troubleshooting guides

---

## Agent Skills

Agent skills are reusable procedures that agents (and you) can reference. They're located in `.github/skills/`.

### Available Skills:

1. **database-migration.skill.md**
   - Creating Entity Framework migrations
   - Managing schema changes
   - Rollback procedures

2. **debugging-api.skill.md**
   - Troubleshooting common API issues
   - Performance optimization
   - Error diagnosis

3. **deploy-azure.skill.md**
   - Complete Azure deployment guide
   - Multiple deployment options
   - Post-deployment configuration

## Using Agents Effectively

### Best Practices

1. **Be Specific**
   ```
   ❌ "Review my code"
   ✅ "Review the BudgetsController for security issues and SQL injection vulnerabilities"
   ```

2. **Provide Context**
   ```
   ❌ "Write tests"
   ✅ "Write unit tests for the CreateBudget method, including validation and error cases"
   ```

3. **Reference Skills**
   ```
   "Using the debugging-api skill, help me troubleshoot why my API returns 500 errors"
   ```

4. **Iterate**
   - Start with agent suggestions
   - Refine based on output
   - Ask follow-up questions

### Example Workflows

#### New Feature Development
1. Write the feature code
2. Ask Testing Agent to generate tests
3. Ask Code Review Agent to review
4. Ask Documentation Agent to document

#### Bug Fix
1. Use Debugging API skill to diagnose
2. Write a failing test (with Testing Agent help)
3. Fix the bug
4. Ask Code Review Agent to review the fix

#### Deployment
1. Reference Deploy Azure skill
2. Ask Documentation Agent to create deployment checklist
3. Execute deployment steps
4. Document any issues encountered

## Customizing Agents

### Adding New Agents

1. Create a new file in `.github/agents/`
2. Follow the naming convention: `<name>.agent.md`
3. Define clear responsibilities and examples
4. Document when to use the agent

### Adding New Skills

1. Create a new file in `.github/skills/`
2. Follow the naming convention: `<name>.skill.md`
3. Provide step-by-step procedures
4. Include troubleshooting tips

## Path-Scoped Instructions

The repository also includes path-scoped instructions that automatically apply when working on specific file types:

- **backend.instructions.md**: Applied to all `.cs` files
- **frontend.instructions.md**: Applied to all TypeScript/React files
- **terraform.instructions.md**: Applied to all `.tf` files

These instructions ensure consistent coding standards without explicit invocation.

## Getting Help

If you need help with:
- **General coding**: Check `.github/copilot-instructions.md`
- **Specific technology**: Check path-scoped instructions
- **Procedures**: Check agent skills
- **Complex tasks**: Invoke appropriate agent

Remember: Agents are here to help you build better software faster. Use them liberally!
