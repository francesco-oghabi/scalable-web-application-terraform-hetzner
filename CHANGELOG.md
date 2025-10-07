# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- WireGuard VPN server configuration on bastion
- Automated backup system for MariaDB
- Monitoring dashboard aggregation
- SSL/TLS certificate automation with Let's Encrypt

## [1.0.0] - 2025-10-07

### Added
- Initial release of Hetzner Cloud infrastructure
- Bastion host with NAT gateway functionality
- Private network (10.0.0.0/16) with complete isolation
- Internal DNS server (dnsmasq) on bastion
- Database server module with MariaDB in Docker
- PHP-Nginx application server module
- Automated SSH key generation (RSA 4096-bit) for internal communication
- Network route configuration for internet access via bastion
- Netdata monitoring on all servers with basic auth
- Cloud-init scripts for automated server configuration
- Null resource provisioner to wait for bastion cloud-init completion
- Comprehensive documentation (README.md)
- Contributing guidelines
- MIT License
- `.gitignore` for sensitive files protection

### Security
- Private servers with no public IP exposure
- Internal SSH keys for bastion-to-private-server communication
- Basic authentication for Netdata monitoring
- NAT gateway for controlled internet access
- DNS stub listener disabled on bastion to prevent conflicts

### Infrastructure
- **Bastion Host**:
  - IP forwarding with iptables MASQUERADE
  - dnsmasq DNS server for internal domain resolution
  - systemd-networkd configuration
  - networkd-dispatcher for NAT persistence

- **Database Server**:
  - MariaDB 10.x in Docker with persistent storage
  - Read-only monitoring user
  - Nginx reverse proxy for Netdata
  - DNS configuration pointing to bastion

- **Networking**:
  - Hetzner Cloud Network (10.0.0.0/16)
  - Cloud subnet in eu-central zone
  - Default route (0.0.0.0/0) via bastion NAT gateway

## How to Use This Changelog

### Version Numbering (Semantic Versioning)

Given a version number MAJOR.MINOR.PATCH, increment the:

1. **MAJOR** version when you make incompatible infrastructure changes (e.g., changing network CIDR, removing resources)
2. **MINOR** version when you add functionality in a backwards compatible manner (e.g., new server module, additional features)
3. **PATCH** version when you make backwards compatible bug fixes (e.g., fixing cloud-init scripts, correcting configurations)

### Change Categories

- **Added**: New features or resources
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features or resources
- **Fixed**: Bug fixes
- **Security**: Security improvements or vulnerability fixes
- **Infrastructure**: Infrastructure-specific changes

### Example Entry Format

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature description with details
- Another feature with context

### Changed
- Modified behavior with explanation
- Updated configuration with reasoning

### Fixed
- Bug fix description with issue reference
- Another fix with context

### Security
- Security improvement description
```

---

**Note**: For upgrade instructions between versions, please refer to the specific version's release notes and the `README.md` for any breaking changes.

[Unreleased]: https://github.com/francesco-oghabi/hetzner-server-terraform/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/francesco-oghabi/hetzner-server-terraform/releases/tag/v1.0.0