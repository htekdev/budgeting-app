# Agent Instructions for BudgetBuddy Repository

This file defines how AI agents (including GitHub Copilot Agents and other autonomous development agents) should operate when working with this repository.

## Agent Behavior Guidelines

### General Principles

1. **Follow the Repository Structure**: Always respect the layered architecture defined in `.github/copilot-instructions.md`
2. **Test Your Changes**: Every code change must include appropriate tests
3. **Document Your Work**: Update documentation when making architectural or API changes
4. **Small, Focused PRs**: Make incremental changes that can be reviewed easily
5. **Security First**: Never commit secrets, always validate inputs, follow security guidelines

### Before Making Changes

1. **Review Context**: Read relevant files first (README, architecture docs, existing code)
2. **Understand Requirements**: Clarify the task before implementing
3. **Plan**: Outline your approach and identify affected files
4. **Check Dependencies**: Understand how your changes impact other components

### While Making Changes

1. **Follow Conventions**: Use coding standards defined in copilot-instructions.md
2. **Write Tests First**: Consider TDD approach for business logic
3. **Incremental Development**: Make changes in small, testable chunks
4. **Validate Frequently**: Build and test after each logical change
5. **Handle Errors**: Add proper error handling and logging

### After Making Changes

1. **Run All Checks**:
   ```bash
   # Backend
   cd src/backend && dotnet build && dotnet test
   
   # Frontend
   cd src/frontend && npm run lint && npm run build
   ```

2. **Verify Documentation**: Update README, API docs, or runbooks if needed

3. **Review Security**: Check for secrets, validate inputs, review permissions

4. **Create Quality PR**: 
   - Descriptive title
   - Bullet-point summary of changes
   - Testing performed
   - Breaking changes noted

## Command Execution Rules

### Safe Commands (Always Allowed)

- `dotnet build`, `dotnet test`, `dotnet restore`
- `npm install`, `npm run lint`, `npm run build`, `npm test`
- `terraform fmt`, `terraform validate`, `terraform plan`
- `docker-compose up -d`, `docker-compose logs`
- `git status`, `git diff`, `git log`

### Commands Requiring Confirmation

- `dotnet ef migrations add` - Confirm migration name and reason
- `dotnet ef database update` - Confirm target database
- `terraform apply` - Confirm environment and changes
- `docker-compose down -v` - Confirm data loss
- `git push` - Confirm branch and changes

### Forbidden Commands

- `rm -rf` (especially on src/ or db/ directories)
- `git push --force`
- `DROP DATABASE` or similar destructive SQL
- Committing hardcoded secrets or credentials

## Agent-Specific Guidelines

### Code Generation Agent

**Purpose**: Generate new code following existing patterns

**Approach**:
1. Identify similar existing code as a template
2. Maintain consistency with project conventions
3. Generate corresponding tests
4. Add appropriate error handling and logging
5. Update relevant documentation

**Example Tasks**:
- Adding new API endpoints
- Creating new React components
- Implementing service layer logic

### Code Review Agent

**Purpose**: Review code for quality, security, and best practices

**Focus Areas**:
1. **Architecture**: Does it follow Clean Architecture principles?
2. **Security**: Any vulnerabilities or exposed secrets?
3. **Testing**: Are there adequate tests?
4. **Performance**: Any obvious performance issues?
5. **Maintainability**: Is the code readable and well-documented?

**Review Checklist**:
- [ ] Follows repository coding conventions
- [ ] Includes unit tests
- [ ] Handles errors appropriately
- [ ] No security vulnerabilities
- [ ] No hardcoded secrets
- [ ] Documentation updated
- [ ] Breaking changes noted

### Debugging Agent

**Purpose**: Diagnose and fix issues

**Process**:
1. Reproduce the issue locally if possible
2. Review logs and error messages
3. Identify root cause
4. Implement minimal fix
5. Add tests to prevent regression
6. Document the issue and fix

### Refactoring Agent

**Purpose**: Improve code quality without changing behavior

**Rules**:
1. **One refactoring at a time**: Don't mix multiple refactorings
2. **Tests must pass**: Before and after refactoring
3. **No behavior changes**: Only structure improvements
4. **Incremental approach**: Small, reviewable changes

**Common Refactorings**:
- Extract method/class
- Rename for clarity
- Remove code duplication
- Simplify complex logic

### Documentation Agent

**Purpose**: Create and maintain project documentation

**Responsibilities**:
1. Keep README.md up to date
2. Maintain API documentation (OpenAPI/Swagger comments)
3. Update runbooks when processes change
4. Create architecture decision records (ADRs) for significant decisions
5. Ensure code comments are accurate

## Nearest-File Precedence

This AGENTS.md file at the repository root provides baseline instructions. If additional AGENTS.md files exist in subdirectories, the nearest one in the directory tree takes precedence for that subtree.

**Example**:
- `/AGENTS.md` applies globally
- `/src/backend/AGENTS.md` (if it existed) would apply to backend code
- `/src/frontend/AGENTS.md` (if it existed) would apply to frontend code

## Agent Handoff Patterns

### Sequential Workflow

```
[Planner Agent]
    ↓ (creates plan)
[Implementer Agent]
    ↓ (writes code)
[Reviewer Agent]
    ↓ (reviews code)
[Documentation Agent]
    ↓ (updates docs)
```

### Parallel Workflow

```
[Planner Agent]
    ├→ [Backend Implementer]
    └→ [Frontend Implementer]
         ↓
    [Integration Tester]
```

## Error Recovery

If an agent encounters an error:

1. **Log the error**: Capture full error message and context
2. **Analyze**: Determine if it's a code issue, environment issue, or understanding gap
3. **Attempt fix**: If code issue, make minimal fix
4. **Escalate if needed**: If unable to resolve, document and request human review
5. **Learn**: Document the issue for future reference

## Quality Gates

Before completing any task, verify:

1. ✅ Code builds successfully
2. ✅ All tests pass
3. ✅ Linting passes (no errors, warnings acceptable with justification)
4. ✅ No new security vulnerabilities introduced
5. ✅ Documentation is updated
6. ✅ Changes are committed with clear messages
7. ✅ PR is created (if applicable)

## Guardrails

### Always Do

- ✅ Follow repository conventions
- ✅ Write tests for new code
- ✅ Handle errors gracefully
- ✅ Log important operations
- ✅ Validate user inputs
- ✅ Update documentation
- ✅ Use dependency injection
- ✅ Keep changes focused and small

### Never Do

- ❌ Commit secrets or credentials
- ❌ Make breaking changes without discussion
- ❌ Skip tests
- ❌ Ignore linting errors
- ❌ Directly modify production databases
- ❌ Remove existing functionality without replacement
- ❌ Copy-paste code without understanding it
- ❌ Leave commented-out code (use git history instead)

## Validation Commands by Area

### Backend Validation

```bash
cd src/backend
dotnet restore
dotnet build
dotnet test
dotnet format --verify-no-changes
```

### Frontend Validation

```bash
cd src/frontend
npm install
npm run lint
npm run build
# npm test (when tests are added)
```

### Database Validation

```bash
# Check migrations are valid
cd src/backend
dotnet ef migrations list --project BudgetBuddy.Infrastructure --startup-project BudgetBuddy.Api

# Verify database connection
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "SELECT @@VERSION"
```

### Infrastructure Validation

```bash
cd infra/terraform/envs/dev
terraform fmt -check -recursive
terraform validate
terraform plan
```

## Specific Instructions by File Type

### For *.cs files

- Use latest C# features appropriately
- Add XML documentation comments for public members
- Use `async/await` for I/O operations
- Follow Clean Architecture layer boundaries
- Use dependency injection

### For *.tsx/*.ts files

- Use strict TypeScript
- Define types explicitly
- Use functional components with hooks
- Handle loading and error states
- Use React Query for server state

### For *.sql files

- Use clear, readable formatting
- Include comments for complex queries
- Test queries for performance
- Use transactions where appropriate

### For *.tf files

- One resource per file when practical
- Use modules for reusability
- Add descriptions to variables
- Use outputs for important values
- Follow Azure naming conventions

## Agent Skills Reference

Agents can leverage specialized skills defined in `.github/skills/`:

- **api-design**: RESTful API design patterns
- **db-migrations**: Database migration strategies
- **terraform-best-practices**: Infrastructure as Code patterns
- **github-actions-cicd**: CI/CD pipeline design
- **testing-strategy**: Test design and implementation
- **security-review**: Security analysis and fixes
- **budgeting-domain**: Domain-specific business logic
- **reporting-queries**: Efficient database queries for reports

Refer to individual SKILL.md files for detailed guidance.

## Communication

When agents need to communicate findings or request input:

1. **Be Specific**: Provide exact file paths, line numbers, error messages
2. **Provide Context**: Explain what you were trying to achieve
3. **Suggest Solutions**: Offer potential approaches
4. **Ask Clear Questions**: Make it easy for humans to provide guidance

## Continuous Improvement

This AGENTS.md file should be updated when:

- New patterns emerge
- Common issues are identified
- Process improvements are discovered
- Tool or framework changes occur

Agents should suggest updates to this file when they identify gaps or ambiguities.
