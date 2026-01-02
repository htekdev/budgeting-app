# BudgetBuddy AI Agents

This document describes the custom GitHub Copilot agents available for the BudgetBuddy project and how to use them effectively.

## Available Agents

### 🔧 @backend_expert
**Specialization**: .NET 10, C#, ASP.NET Core, Entity Framework Core

Use this agent for:
- Creating or modifying backend API endpoints
- Designing database schemas with Entity Framework Core
- Implementing business logic
- Writing backend tests
- Optimizing database queries
- Troubleshooting backend errors

**Example Prompts**:
- "@backend_expert add a new endpoint to get transactions for a specific category"
- "@backend_expert optimize the budget query to include related transactions in a single database call"
- "@backend_expert create an integration test for the create budget endpoint"

---

### ⚛️ @frontend_expert
**Specialization**: React, TypeScript, Vite, modern frontend development

Use this agent for:
- Creating or modifying React components
- Implementing UI features
- Setting up data fetching with React Query
- Creating forms and validation
- Styling components
- Writing frontend tests

**Example Prompts**:
- "@frontend_expert create a BudgetCard component that displays budget information with progress bar"
- "@frontend_expert implement a form to create a new transaction with category selection"
- "@frontend_expert add error handling and loading states to the BudgetList component"

---

### 🚀 @devops_expert
**Specialization**: Docker, Terraform, GitHub Actions, Azure cloud infrastructure

Use this agent for:
- Creating or modifying infrastructure as code
- Setting up CI/CD pipelines
- Configuring Docker and containers
- Troubleshooting deployment issues
- Optimizing build processes

**Example Prompts**:
- "@devops_expert create a GitHub Actions workflow to deploy the backend to Azure App Service"
- "@devops_expert add health check configuration to the docker-compose.yml"
- "@devops_expert create Terraform configuration for Azure SQL Database with proper security settings"

---

## Agent Collaboration & Handoffs

Agents can work together on complex tasks. Here are common collaboration patterns:

### Full-Stack Feature Implementation
1. **Planning**: "@backend_expert, @frontend_expert design a feature to track monthly spending trends"
2. **Backend First**: "@backend_expert implement the API endpoint for monthly spending trends"
3. **Frontend Integration**: "@frontend_expert create a chart component to visualize the monthly spending data"
4. **Deployment**: "@devops_expert update the CI/CD pipeline to include the new feature"

### Database Schema Changes
1. **Schema Design**: "@backend_expert create an entity for recurring transactions"
2. **Migration**: "@backend_expert create and apply the EF Core migration"
3. **API Update**: "@backend_expert add CRUD endpoints for recurring transactions"
4. **UI Integration**: "@frontend_expert create UI to manage recurring transactions"

### Infrastructure Updates
1. **Planning**: "@devops_expert plan the infrastructure for production deployment"
2. **Implementation**: "@devops_expert create Terraform modules for all Azure resources"
3. **CI/CD**: "@devops_expert create GitHub Actions workflows for automated deployment"
4. **Documentation**: "@devops_expert document the deployment process in the runbooks"

## Skills Reference

Agents have access to predefined skills for common operations:

### budget-calculator
Calculates budget-related metrics like remaining amount, spending by category, and progress percentages.

**Usage**: "@backend_expert use the budget-calculator skill to implement the budget summary endpoint"

### data-seeder
Generates realistic seed data for development and testing.

**Usage**: "@backend_expert use the data-seeder skill to create sample data for 3 users with multiple budgets"

### terraform-validator
Validates Terraform configurations against best practices and security standards.

**Usage**: "@devops_expert use the terraform-validator skill to check the infrastructure code"

## Best Practices for Working with Agents

### 1. Be Specific
❌ "Fix the budget feature"
✅ "@backend_expert fix the budget endpoint to include category totals in the response"

### 2. Provide Context
Include relevant information:
- File paths
- Error messages
- Expected behavior
- Current behavior

### 3. One Task at a Time
Break down complex work into smaller, focused tasks for each agent.

### 4. Review Generated Code
Always review and test agent-generated code:
- Check for security implications
- Verify it follows project patterns
- Run tests
- Test edge cases

### 5. Use the Right Agent
Each agent has specific expertise. Use the agent best suited for your task:
- Backend changes → @backend_expert
- Frontend changes → @frontend_expert
- Infrastructure/deployment → @devops_expert

### 6. Iterate
If the result isn't quite right, provide feedback and ask the agent to refine:
- "@backend_expert the query is slow, can you optimize it with includes?"
- "@frontend_expert add loading skeletons instead of a spinner"

## Agent Workspace Commands

Agents can execute commands to understand the codebase:

```
@backend_expert /search EntityFramework Include patterns
@frontend_expert /explain what does this component do?
@devops_expert /doc generate documentation for this workflow
```

## Limitations

What agents **cannot** do:
- Make decisions about business requirements (you provide these)
- Access external systems or APIs directly
- Modify files outside their expertise area
- Execute commands that require user input or credentials

## Getting Help

If you're unsure which agent to use or how to phrase a request:
1. Start with a general question: "Which agent should I use to add a new budget report?"
2. Review similar patterns in the codebase
3. Check the runbooks in docs/runbooks/
4. Ask an agent to explain: "@backend_expert explain how the budget endpoints work"

## Examples of Complex Workflows

### Adding a New Feature: Budget Sharing
```
1. "@backend_expert create a BudgetShare entity that links users to shared budgets with permission levels"

2. "@backend_expert add endpoints to:
   - Share a budget with another user
   - List users a budget is shared with
   - Remove sharing access
   - Get all budgets shared with current user"

3. "@frontend_expert create a ShareBudgetDialog component with user search and permission selection"

4. "@frontend_expert add a shared budgets section to the dashboard"

5. "@devops_expert update the CI pipeline to run integration tests for budget sharing"
```

### Performance Optimization
```
1. "@backend_expert analyze slow queries in the budgets endpoint using EF Core logging"

2. "@backend_expert optimize by adding:
   - Proper includes for related data
   - Indexes on frequently queried columns
   - Pagination to limit result sets"

3. "@frontend_expert implement virtual scrolling for large budget lists"

4. "@devops_expert add Application Insights to monitor query performance in production"
```

### Security Improvement
```
1. "@backend_expert implement JWT authentication for all endpoints"

2. "@backend_expert add authorization so users can only access their own budgets"

3. "@frontend_expert add login/logout UI and protect routes requiring authentication"

4. "@devops_expert configure Azure Key Vault for storing JWT signing keys"

5. "@devops_expert add security scanning to the CI pipeline"
```

## Feedback

If you discover effective patterns for working with agents, please document them here to help the team!
