# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < 1.0   | :x:                |

We recommend always using the latest version from the main branch for the most up-to-date security fixes.

## Reporting a Vulnerability

We take the security of this project seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Disclose Publicly

Please **do not** create a public GitHub issue for security vulnerabilities. This could put users at risk.

### 2. Report Privately

Send your report via one of these methods:

- **GitHub Security Advisories** (Recommended): Use the [Security tab](https://github.com/francesco-oghabi/hetzner-server-terraform/security/advisories/new) to report privately
- **Email**: Contact the maintainer directly (check the repository for contact information)

### 3. Include Details

Your report should include:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and severity
- **Reproduction Steps**: Detailed steps to reproduce the issue
- **Affected Components**: Which modules, files, or configurations are affected
- **Proposed Fix**: If you have suggestions for fixing the issue
- **Environment**: Terraform version, provider versions, OS, etc.

### Example Report Template

```
**Vulnerability Type**: [e.g., Credential Exposure, Privilege Escalation, etc.]

**Description**:
[Clear description of the vulnerability]

**Impact**:
[What could an attacker do with this vulnerability?]

**Reproduction Steps**:
1. Step one
2. Step two
3. ...

**Affected Versions**:
[Which versions are affected?]

**Proposed Fix**:
[If you have suggestions]

**Additional Context**:
[Any other relevant information]
```

## Response Timeline

- **Acknowledgment**: Within 48 hours of report submission
- **Initial Assessment**: Within 7 days
- **Fix Development**: Varies based on severity and complexity
- **Disclosure**: After fix is released or 90 days, whichever comes first

## Security Best Practices

When using this project, follow these security practices:

### 1. Credential Management

**DO:**
- Use environment variables for sensitive values
- Store credentials in secure vaults (e.g., HashiCorp Vault, AWS Secrets Manager)
- Use Terraform Cloud/Enterprise for remote state with encryption
- Rotate credentials regularly

**DON'T:**
- Commit `.tfvars` files with real credentials
- Share state files publicly (they contain sensitive data)
- Use default or weak passwords
- Store credentials in version control

### 2. State File Security

Terraform state files contain sensitive information:

- Store state files remotely with encryption
- Enable state locking
- Use S3 with encryption + DynamoDB for locking (AWS)
- Restrict access to state files
- Never commit `.tfstate` or `.tfstate.backup` files

### 3. SSH Key Management

- Use strong SSH keys (RSA 4096-bit or Ed25519)
- Never commit private SSH keys
- Use SSH key passphrases
- Rotate SSH keys periodically
- Restrict SSH access by IP when possible

### 4. Network Security

- Keep private servers isolated (no public IPs)
- Use the bastion host as single entry point
- Configure firewall rules appropriately
- Use VPN for additional security layer
- Regularly audit network access rules

### 5. Service Security

**MariaDB:**
- Use strong passwords for all users
- Disable root remote access
- Regular security updates
- Monitor access logs

**OpenSearch:**
- Enable security plugin in production
- Use authentication and authorization
- Restrict network access
- Regular updates

**Redis:**
- Always use password authentication
- Bind to private interfaces only
- Use TLS for production
- Regular updates

**RabbitMQ:**
- Use strong admin passwords
- Configure user permissions properly
- Change default Erlang cookie
- Regular updates

### 6. Monitoring and Auditing

- Enable logging on all services
- Monitor Netdata dashboards regularly
- Set up alerts for suspicious activity
- Review access logs periodically
- Keep audit trail of infrastructure changes

### 7. Updates and Patching

- Keep Terraform up to date
- Update provider versions regularly
- Apply OS security patches promptly
- Update container images regularly
- Subscribe to security advisories

### 8. Hetzner Cloud Security

- Enable two-factor authentication (2FA)
- Use API tokens with limited scope
- Rotate API tokens regularly
- Monitor Hetzner Cloud console for unauthorized changes
- Enable Hetzner Cloud Firewall
- Review audit logs in Hetzner Console

### 9. Backup and Recovery

- Implement regular backup strategy
- Encrypt backups at rest and in transit
- Test backup restoration regularly
- Store backups in separate location
- Document recovery procedures

### 10. Least Privilege Principle

- Grant minimum necessary permissions
- Use read-only users where possible
- Separate service accounts by function
- Regular permission audits

## Known Security Considerations

### 1. Bastion Host Exposure

The bastion host has a public IP and is exposed to the internet:

- Harden the bastion host configuration
- Use fail2ban or similar intrusion prevention
- Monitor SSH access logs
- Consider using SSH key-only authentication
- Implement IP whitelisting if possible
- Use non-standard SSH ports (optional)

### 2. Internal Network Trust

Servers on the private network trust each other:

- Implement service-level authentication
- Use TLS/SSL between services
- Regular security audits
- Monitor internal network traffic

### 3. Cloud-init Secrets

Cloud-init templates may contain sensitive data:

- Templates are stored in Terraform state
- Use sensitive variables properly
- Be cautious with state file storage
- Consider using external secret management

### 4. Docker Security

Services run in Docker containers:

- Keep Docker and images updated
- Use official images or build your own
- Scan images for vulnerabilities
- Implement container security best practices
- Use Docker secrets for sensitive data

### 5. Netdata Access

Netdata monitoring is exposed via web interface:

- Keep basic auth credentials strong
- Consider additional authentication layer
- Use HTTPS for Netdata access
- Restrict access by IP if possible
- Regularly update Netdata

## Vulnerability Disclosure Policy

### Our Commitment

- We will respond to security reports promptly
- We will keep reporters informed of progress
- We will credit reporters (if desired) in security advisories
- We will work to release fixes as quickly as possible

### Coordinated Disclosure

We follow coordinated disclosure principles:

1. Reporter notifies us privately
2. We acknowledge and investigate
3. We develop and test a fix
4. We release the fix
5. We publish a security advisory
6. Reporter may publish details (after fix is released)

### Safe Harbor

We support security research conducted in good faith:

- We will not pursue legal action against researchers who:
  - Report vulnerabilities responsibly
  - Do not exploit vulnerabilities beyond proof of concept
  - Do not access, modify, or delete data without authorization
  - Follow responsible disclosure practices

## Security Updates

Security updates will be announced via:

- **GitHub Security Advisories**: Published on the repository
- **Release Notes**: Included in CHANGELOG.md
- **GitHub Releases**: Tagged with security fix information

Subscribe to repository notifications to receive security updates.

## Additional Resources

- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Hetzner Cloud Security](https://docs.hetzner.com/cloud/general/security/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [OWASP Infrastructure as Code Security](https://owasp.org/www-project-devsecops-guideline/)

## Questions?

If you have questions about this security policy or general security questions (not vulnerability reports), please:

- Open a GitHub Discussion
- Tag your question with `security`
- Check existing discussions first

---

**Remember**: Security is a shared responsibility. This project provides infrastructure code, but securing your deployment requires following best practices and maintaining vigilance.

Last updated: 2025-10-15