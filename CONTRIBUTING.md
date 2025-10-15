# Contributing to Hetzner Server Terraform

Thank you for your interest in contributing to this project! We welcome contributions, issues, and feature requests from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Community](#community)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please read [CODE-OF-CONDUCT.md](CODE-OF-CONDUCT.md) before contributing.

## Getting Started

Before you begin contributing, make sure you have:

- [Terraform](https://www.terraform.io/downloads) >= 1.0 installed
- A [Hetzner Cloud](https://www.hetzner.com/cloud) account for testing
- Basic knowledge of Terraform and Infrastructure as Code (IaC)
- Familiarity with Git and GitHub workflows

## Development Setup

1. **Fork the repository** on GitHub

2. **Clone your fork** to your local machine:
   ```bash
   git clone https://github.com/YOUR_USERNAME/hetzner-server-terraform.git
   cd hetzner-server-terraform
   ```

3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/francesco-oghabi/hetzner-server-terraform.git
   ```

4. **Set up your development environment**:
   ```bash
   # Copy the template configuration
   cp terraform.tfvars.template terraform.tfvars

   # Edit terraform.tfvars with your test values
   # WARNING: Use test credentials only, never production
   ```

5. **Initialize Terraform**:
   ```bash
   terraform init
   ```

## How to Contribute

### 1. Create a Feature Branch

Always create a new branch for your work:

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create and checkout a new branch
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/feature-name` - for new features
- `fix/bug-description` - for bug fixes
- `docs/documentation-update` - for documentation changes
- `refactor/component-name` - for code refactoring

### 2. Make Your Changes

- Write clean, readable code
- Follow the existing code style and structure
- Keep changes focused on a single issue or feature
- Test your changes thoroughly

### 3. Format Your Code

Always format your Terraform code before committing:

```bash
terraform fmt -recursive
```

### 4. Validate Your Changes

Ensure your Terraform configuration is valid:

```bash
terraform validate
```

Test with plan (use test credentials):

```bash
terraform plan
```

### 5. Commit Your Changes

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```bash
git add .
git commit -m "type: brief description"
```

Commit message types:
- `feat:` - new feature
- `fix:` - bug fix
- `docs:` - documentation changes
- `style:` - code style changes (formatting, etc.)
- `refactor:` - code refactoring
- `test:` - adding or updating tests
- `chore:` - maintenance tasks

Examples:
```bash
git commit -m "feat: add Redis cluster support"
git commit -m "fix: resolve NAT gateway routing issue"
git commit -m "docs: update SSL certificate configuration"
git commit -m "refactor: optimize cloud-init templates"
```

### 6. Push Your Changes

```bash
git push origin feature/your-feature-name
```

### 7. Open a Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your feature branch
4. Fill in the PR template with:
   - Clear description of changes
   - Related issue numbers (if applicable)
   - Testing performed
   - Screenshots (if applicable)

## Pull Request Process

1. **PR Requirements**:
   - All Terraform code must be formatted (`terraform fmt`)
   - Code must pass validation (`terraform validate`)
   - Documentation must be updated if needed
   - No sensitive data (credentials, state files, etc.)

2. **Review Process**:
   - At least one maintainer approval required
   - All CI checks must pass
   - Address all review comments

3. **After Approval**:
   - Maintainers will merge your PR
   - Your contribution will be included in the next release

## Coding Standards

### Terraform Best Practices

1. **Resource Naming**:
   - Use descriptive, lowercase names with underscores
   - Follow pattern: `resource_type_purpose`
   ```hcl
   resource "hcloud_server" "database_server" {
     name = var.database_server_name
   }
   ```

2. **Variables**:
   - Always provide descriptions
   - Use appropriate types
   - Set sensible defaults when possible
   ```hcl
   variable "server_type" {
     description = "Server type for database and PHP-Nginx servers"
     type        = string
     default     = "cx22"
   }
   ```

3. **Outputs**:
   - Provide clear descriptions
   - Mark sensitive outputs appropriately
   ```hcl
   output "bastion_public_ip" {
     description = "Public IP address of the bastion host"
     value       = hcloud_server.bastion.ipv4_address
   }
   ```

4. **File Organization**:
   - Keep related resources together
   - Use modules for reusable components
   - Separate concerns (networks, servers, etc.)

5. **Comments**:
   - Add comments for complex logic
   - Explain "why" not "what"
   - Document any non-obvious decisions

### Security Practices

1. **Never Commit Sensitive Data**:
   - No credentials, tokens, or passwords
   - No `.tfvars` files with real values
   - No `.tfstate` or `.tfstate.backup` files
   - No SSH private keys

2. **Use Variables**:
   - All sensitive values must be variables
   - Provide `.tfvars.template` examples

3. **Documentation**:
   - Clearly mark sensitive outputs
   - Document security implications
   - Warn about potential security risks

## Testing Guidelines

Before submitting a PR, ensure you've tested your changes:

### 1. Local Testing

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Plan with test variables
terraform plan

# If safe, apply to a test environment
terraform apply
```

### 2. Test Checklist

- [ ] Code formatted with `terraform fmt`
- [ ] Passes `terraform validate`
- [ ] `terraform plan` produces expected changes
- [ ] Tested in an isolated test environment (if applicable)
- [ ] No sensitive data in commits
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (for significant changes)

### 3. Cleanup

Always destroy test infrastructure:

```bash
terraform destroy
```

## Documentation

### When to Update Documentation

Update documentation when you:
- Add new features or modules
- Change existing functionality
- Add new variables or outputs
- Modify deployment procedures
- Change configuration options

### What to Document

1. **README.md**: Update if adding major features or changing architecture
2. **Module READMEs**: Document module-specific changes
3. **CHANGELOG.md**: List your changes following the existing format
4. **Code Comments**: Add comments for complex logic
5. **Examples**: Update `terraform.tfvars.template` if adding variables

### Documentation Style

- Use clear, concise language
- Include code examples
- Add screenshots for UI changes
- Use proper markdown formatting
- Test all commands and examples

## Reporting Bugs

Found a bug? Help us fix it!

### Before Reporting

1. Check existing [issues](https://github.com/francesco-oghabi/hetzner-server-terraform/issues)
2. Ensure you're using the latest version
3. Try to reproduce in a clean environment

### Bug Report Template

Open an [issue](https://github.com/francesco-oghabi/hetzner-server-terraform/issues) with:

**Bug Description**
- Clear description of the problem
- Expected behavior vs actual behavior

**Environment**
- Terraform version: `terraform version`
- Operating System
- Relevant configuration (remove sensitive data)

**Reproduction Steps**
1. Step one
2. Step two
3. ...

**Logs and Output**
```
# Include relevant output from:
# terraform plan
# terraform apply
# Remove any sensitive information!
```

**Additional Context**
- Screenshots (if applicable)
- Related issues or PRs

## Suggesting Features

Have an idea for improvement?

### Feature Request Template

Open an [issue](https://github.com/francesco-oghabi/hetzner-server-terraform/issues) with tag `enhancement`:

**Feature Description**
- Clear description of the proposed feature
- Problem it solves or improvement it provides

**Use Case**
- Specific scenarios where this would be helpful
- Who would benefit from this feature

**Proposed Solution**
- How you envision the feature working
- Any alternative approaches considered

**Additional Context**
- Related features or dependencies
- Examples from other projects

## Community

### Getting Help

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For questions and general discussion
- **Pull Requests**: For contributing code

### Recognition

Contributors will be recognized in:
- GitHub contributors list
- Project acknowledgments
- Release notes (for significant contributions)

### License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Hetzner Server Terraform! Your efforts help make this project better for everyone.