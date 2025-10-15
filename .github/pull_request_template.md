## Description

<!-- Provide a clear and concise description of your changes -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Configuration change
- [ ] Dependency update

## Related Issues

<!-- Link to related issues using #issue_number or "Fixes #issue_number" -->

Fixes #
Related to #

## Motivation and Context

<!-- Why is this change required? What problem does it solve? -->

## Changes Made

<!-- Provide a detailed list of changes -->

-
-
-

## Affected Components

<!-- Mark all components affected by this PR -->

- [ ] Bastion Host
- [ ] Database Module (MariaDB)
- [ ] PHP-Nginx Module
- [ ] OpenSearch Module
- [ ] Redis Module
- [ ] RabbitMQ Module
- [ ] Network Configuration
- [ ] Monitoring (Netdata)
- [ ] Documentation
- [ ] CI/CD
- [ ] Other: ___________

## Testing Performed

<!-- Describe the testing you've done -->

### Terraform Validation

- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan` produces expected output

### Infrastructure Testing

- [ ] Tested in isolated test environment
- [ ] Successfully deployed infrastructure
- [ ] Successfully destroyed infrastructure
- [ ] Verified all services are running correctly

### Test Environment Details

<!-- Provide details about your test environment -->

- Terraform Version:
- Hetzner Cloud Region:
- Server Types Used:

### Test Results

<!-- Describe the results of your testing -->

```
# Paste relevant output or test results here
```

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Checklist

<!-- Ensure all items are completed before submitting -->

### Code Quality

- [ ] My code follows the project's style guidelines
- [ ] I have formatted my Terraform code with `terraform fmt`
- [ ] I have validated my configuration with `terraform validate`
- [ ] I have reviewed my own code before submitting
- [ ] My code follows Terraform best practices

### Security

- [ ] I have not included any sensitive data (passwords, tokens, API keys, IP addresses)
- [ ] I have not committed `.tfvars` files with real credentials
- [ ] I have not committed `.tfstate` or `.tfstate.backup` files
- [ ] I have not committed SSH private keys
- [ ] I have reviewed the Security Policy (SECURITY.md)

### Documentation

- [ ] I have updated the README.md (if needed)
- [ ] I have updated relevant module documentation (if needed)
- [ ] I have updated CHANGELOG.md following the existing format
- [ ] I have updated `terraform.tfvars.template` (if adding variables)
- [ ] I have added comments to complex code sections
- [ ] My commit messages follow the Conventional Commits specification

### Testing

- [ ] I have tested my changes in a clean environment
- [ ] I have verified that `terraform plan` works as expected
- [ ] I have verified that `terraform apply` works as expected
- [ ] I have verified that `terraform destroy` cleans up all resources
- [ ] All existing tests still pass (if applicable)

### Breaking Changes

<!-- If this is a breaking change, complete this section -->

- [ ] I have documented all breaking changes in CHANGELOG.md
- [ ] I have updated the documentation to reflect breaking changes
- [ ] I have provided migration instructions (if needed)

## Breaking Changes Details

<!-- If this PR introduces breaking changes, describe them here -->

**What breaks:**


**Migration path:**


## Additional Notes

<!-- Any additional information that reviewers should know -->

## Deployment Considerations

<!-- Are there any special considerations for deploying these changes? -->

- [ ] Requires Terraform state migration
- [ ] Requires infrastructure recreation
- [ ] Requires manual intervention after apply
- [ ] Requires update to existing deployments
- [ ] Safe to deploy without additional steps

### Deployment Instructions

<!-- Provide specific deployment instructions if needed -->

```bash
# Add any special deployment steps here
```

## Rollback Plan

<!-- How can these changes be rolled back if needed? -->

## Post-Deployment Verification

<!-- How should users verify that the changes are working correctly? -->

- [ ] Check that all servers are accessible
- [ ] Verify all services are running
- [ ] Check monitoring dashboards
- [ ] Verify network connectivity
- [ ] Other: ___________

## Review Requests

<!-- Tag specific reviewers or request reviews for specific aspects -->

- [ ] I need review for security implications
- [ ] I need review for Terraform best practices
- [ ] I need review for documentation accuracy
- [ ] I need help with testing

## Additional Context

<!-- Add any other context about the PR here -->

---

**By submitting this pull request, I confirm that:**

- [ ] I have read and agree to follow the [Code of Conduct](../CODE-OF-CONDUCT.md)
- [ ] I have read the [Contributing Guidelines](../CONTRIBUTING.md)
- [ ] My contribution is licensed under the same license as this project (MIT)
- [ ] I agree to the terms stated in the [Security Policy](../SECURITY.md)