---
applyTo:
  - "**/infra/terraform/**/*.tf"
  - "**/infra/terraform/**/*.tfvars"
---

# Terraform Instructions

## Azure Infrastructure Best Practices

### Module Structure

- Create reusable modules in `modules/`
- Use environment-specific configurations in `envs/`
- Keep modules focused on a single resource type or logical grouping

### Variables

```hcl
# DO: Add descriptions and validation
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition     = contains(["eastus", "westus2", "centralus"], var.location)
    error_message = "Location must be one of: eastus, westus2, centralus"
  }
}

# DON'T: Omit descriptions or use unclear names
variable "loc" {
  type = string
}
```

### Outputs

- Output important values (endpoints, resource IDs)
- Add descriptions to outputs
- Use outputs for module connections

### Security

- Never hardcode secrets in `.tf` files
- Use Azure Key Vault for secrets
- Reference secrets using `data` sources
- Use managed identities when possible

### Naming Conventions

Follow Azure naming conventions:
- `rg-budgetbuddy-dev-eastus` (resource group)
- `app-budgetbuddy-dev` (app service)
- `sql-budgetbuddy-dev` (SQL server)
- `kv-budgetbuddy-dev` (key vault)

### State Management

- Use Azure Storage for remote state
- Enable state locking
- Separate state files by environment

## Validation Commands

```bash
cd infra/terraform/envs/dev

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Show plan
terraform plan

# Apply changes (with approval)
terraform apply
```

## Code Review Checklist

- [ ] Variables have descriptions and validation
- [ ] Outputs have descriptions
- [ ] No hardcoded secrets
- [ ] Follows Azure naming conventions
- [ ] Uses modules for reusability
- [ ] Remote state configured
- [ ] Tags applied to all resources
