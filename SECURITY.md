# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The BudgetBuddy team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security vulnerabilities through one of these methods:

1. **GitHub Security Advisories** (Preferred)
   - Go to https://github.com/htekdev/budgeting-app/security/advisories
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send an email to: security@budgetbuddy.example (replace with actual email)
   - Include "SECURITY" in the subject line
   - Provide detailed information (see below)

### What to Include

Please provide the following information:

- **Type of vulnerability** (e.g., SQL injection, XSS, CSRF)
- **Location** (file path, line number, URL)
- **Step-by-step reproduction** instructions
- **Proof of concept** (code snippet or screenshot)
- **Impact** assessment
- **Suggested fix** (if you have one)
- **Your name/handle** (for attribution)

### Example Report

```
Subject: SECURITY - SQL Injection in Budget API

Type: SQL Injection
Location: src/backend/BudgetBuddy.API/Program.cs, line 142
Severity: High

Description:
The budget search endpoint is vulnerable to SQL injection through the 
'name' query parameter.

Reproduction:
1. Send GET request to /api/budgets?name='; DROP TABLE Budgets; --
2. Observe error message revealing database structure

Impact:
Attacker could execute arbitrary SQL queries, potentially:
- Accessing sensitive data
- Modifying or deleting records
- Compromising the entire database

Suggested Fix:
Use parameterized queries or LINQ instead of string concatenation.

POC:
curl "http://localhost:5000/api/budgets?name='; DROP TABLE Budgets; --"
```

## Response Timeline

- **Acknowledgment**: Within 48 hours
- **Assessment**: Within 5 business days
- **Fix Development**: Depends on severity
  - Critical: 1-3 days
  - High: 3-7 days
  - Medium: 7-14 days
  - Low: 14-30 days
- **Disclosure**: After fix is released

## Disclosure Policy

### Coordinated Disclosure

We follow coordinated disclosure:

1. **Report received** - We acknowledge receipt
2. **Verification** - We verify the vulnerability
3. **Fix development** - We develop and test a fix
4. **Release** - We release the patched version
5. **Public disclosure** - We publicly disclose (with your permission)

### Public Disclosure

After a fix is released, we will:
- Publish a security advisory on GitHub
- Credit the reporter (unless they prefer anonymity)
- Detail the vulnerability and fix
- Provide upgrade instructions

Please wait for our go-ahead before publicly disclosing.

## Security Best Practices

### For Users

1. **Keep Updated**
   - Always use the latest version
   - Apply security patches promptly
   - Monitor release notes

2. **Secure Configuration**
   - Use strong database passwords
   - Enable HTTPS in production
   - Set up proper CORS policies
   - Use environment variables for secrets

3. **Access Control**
   - Implement proper authentication
   - Use least privilege principle
   - Regularly review access logs

4. **Monitoring**
   - Enable Application Insights
   - Set up alerts for anomalies
   - Review logs regularly

### For Contributors

1. **Code Review**
   - Review security implications
   - Check for common vulnerabilities
   - Use static analysis tools

2. **Dependencies**
   - Keep dependencies updated
   - Review dependency advisories
   - Use `npm audit` and `dotnet list package --vulnerable`

3. **Secrets Management**
   - Never commit secrets to Git
   - Use Azure Key Vault in production
   - Use User Secrets for local development
   - Use environment variables

4. **Input Validation**
   - Validate all user inputs
   - Use parameterized queries
   - Sanitize outputs
   - Implement proper error handling

## Known Security Considerations

### Current Implementation

1. **Authentication**: Not yet implemented
   - ⚠️ All endpoints are currently public
   - 🔒 Future: JWT-based authentication planned

2. **Authorization**: Not yet implemented
   - ⚠️ No user-level access control
   - 🔒 Future: Role-based authorization planned

3. **Rate Limiting**: Not implemented
   - ⚠️ API endpoints can be called unlimited times
   - 🔒 Future: Rate limiting middleware planned

4. **Input Validation**: Partial
   - ✅ Entity Framework prevents SQL injection
   - ⚠️ Limited validation on API inputs
   - 🔒 Future: Comprehensive validation with FluentValidation

5. **HTTPS**: Configured for production
   - ✅ HTTPS redirection enabled
   - ✅ TrustServerCertificate for development only

### Mitigations

Current security measures:

1. **SQL Injection**: Protected by Entity Framework's parameterized queries
2. **CORS**: Configured to allow specific origins only
3. **Logging**: Structured logging with Serilog (no sensitive data logged)
4. **Dependencies**: Regular updates via Dependabot
5. **Code Scanning**: CodeQL security analysis in CI

## Security Checklist for Deployment

Before deploying to production:

- [ ] Change default passwords
- [ ] Enable HTTPS only
- [ ] Configure proper CORS policies
- [ ] Set up Azure Key Vault for secrets
- [ ] Enable Application Insights
- [ ] Configure SQL Server firewall rules
- [ ] Set up managed identity for App Service
- [ ] Enable SQL Server auditing
- [ ] Configure security headers
- [ ] Set up DDoS protection
- [ ] Enable Azure Security Center
- [ ] Review and minimize exposed endpoints
- [ ] Set up backup and disaster recovery
- [ ] Configure monitoring and alerts

## Compliance

### Data Privacy

- BudgetBuddy stores financial data
- Users are responsible for compliance with regulations (GDPR, CCPA, etc.)
- Consider data residency requirements
- Implement data retention policies
- Provide data export functionality

### Security Standards

We aim to follow:
- OWASP Top 10
- Microsoft Security Development Lifecycle
- Azure Security Best Practices
- CIS Benchmarks for Azure

## Security Resources

### Internal

- [System Design](docs/architecture/system-design.md)
- [Local Setup Guide](docs/runbooks/local-setup.md)
- [Contributing Guidelines](CONTRIBUTING.md)

### External

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)
- [.NET Security Best Practices](https://learn.microsoft.com/en-us/dotnet/standard/security/)
- [React Security Best Practices](https://snyk.io/blog/10-react-security-best-practices/)

## Bug Bounty Program

Currently, we do not have a bug bounty program. However:
- We appreciate responsible disclosure
- We will credit researchers (with permission)
- We may offer recognition on our website

## Contact

For security-related questions (non-vulnerabilities):
- 💬 [GitHub Discussions - Security](https://github.com/htekdev/budgeting-app/discussions/categories/security)
- 📧 security@budgetbuddy.example (replace with actual email)

**Remember: For vulnerabilities, use private channels only!**

## Updates

This security policy may be updated. Check back regularly.

Last updated: 2026-01-02

---

Thank you for helping keep BudgetBuddy and its users safe! 🔒
