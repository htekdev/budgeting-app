## 📝 Description

<!-- Provide a brief description of the changes in this PR -->

## 🎯 Related Issue

<!-- Link to the issue this PR addresses -->
Closes #(issue number)

## 🔄 Type of Change

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🎨 Code style update (formatting, renaming)
- [ ] ♻️ Refactoring (no functional changes)
- [ ] 🔧 Configuration change
- [ ] 🚀 Performance improvement

## 🧪 How Has This Been Tested?

<!-- Describe the tests you ran to verify your changes -->

- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] End-to-end tests

**Test Configuration**:
- OS: [e.g., Windows 11, macOS 14, Ubuntu 22.04]
- Browser: [e.g., Chrome 120] (if frontend changes)
- .NET Version: [e.g., 8.0.1] (if backend changes)

## 📸 Screenshots (if applicable)

<!-- Add screenshots to show visual changes -->

## ✅ Checklist

### Code Quality
- [ ] My code follows the repository's coding standards
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings or errors
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

### Backend (if applicable)
- [ ] Follows Clean Architecture principles
- [ ] Uses async/await for I/O operations
- [ ] Includes appropriate error handling
- [ ] Has XML documentation comments for public APIs
- [ ] Database migrations created and tested (if schema changes)
- [ ] No domain entities exposed directly in API controllers

### Frontend (if applicable)
- [ ] TypeScript strict mode enabled
- [ ] React Query used for server state (not useState)
- [ ] Loading and error states handled
- [ ] Components are accessible (ARIA attributes)
- [ ] ESLint passes with no errors
- [ ] Code is formatted with Prettier

### Database (if applicable)
- [ ] Migration scripts are idempotent
- [ ] Indexes added for new query patterns
- [ ] Foreign key constraints maintained
- [ ] Seed data updated if needed

### Infrastructure (if applicable)
- [ ] Terraform formatted (`terraform fmt`)
- [ ] Terraform validated (`terraform validate`)
- [ ] Variables have descriptions and validation
- [ ] No secrets hardcoded

### Documentation
- [ ] README updated (if needed)
- [ ] API documentation updated (if API changes)
- [ ] Architecture docs updated (if architectural changes)
- [ ] Runbooks updated (if operational changes)

### Testing
- [ ] All tests pass locally
- [ ] Code coverage maintained or improved
- [ ] CI pipeline passes

## 🔐 Security Considerations

<!-- Have you considered security implications? -->

- [ ] No new security vulnerabilities introduced
- [ ] Input validation added where necessary
- [ ] No secrets exposed in code or logs
- [ ] Authentication/authorization respected (if applicable)

## 📊 Performance Impact

<!-- Will this change impact performance? -->

- [ ] No significant performance impact expected
- [ ] Performance improvement
- [ ] Performance degradation (explain why acceptable)

## 🔄 Breaking Changes

<!-- Are there any breaking changes? -->

- [ ] No breaking changes
- [ ] Breaking changes (describe below and update CHANGELOG)

**Breaking Changes Description**:
<!-- If there are breaking changes, describe them here -->

## 🚀 Deployment Notes

<!-- Any special steps needed for deployment? -->

- [ ] No special deployment steps required
- [ ] Database migration required
- [ ] Configuration changes required
- [ ] Infrastructure changes required

**Deployment Steps**:
<!-- List any special deployment steps here -->

## 📝 Additional Notes

<!-- Any additional information that reviewers should know -->

## 👥 Reviewers

<!-- Tag specific reviewers if needed -->
@mention-reviewers

---

## For Reviewers

### Review Checklist

- [ ] Code follows repository conventions
- [ ] Changes are logical and well-structured
- [ ] Tests adequately cover the changes
- [ ] Documentation is clear and complete
- [ ] No obvious security issues
- [ ] Performance implications considered
- [ ] Breaking changes properly documented

### Review Focus Areas

<!-- Indicate areas that need special attention -->

- [ ] Architecture/design decisions
- [ ] Security implications
- [ ] Performance optimization
- [ ] Test coverage
- [ ] Documentation completeness
