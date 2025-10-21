terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Generate SSH key for backup user if not provided
resource "tls_private_key" "backup_user" {
  count     = var.backup_user_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  backup_public_key  = var.backup_user_public_key != "" ? var.backup_user_public_key : tls_private_key.backup_user[0].public_key_openssh
  backup_private_key = var.backup_user_public_key != "" ? "" : tls_private_key.backup_user[0].private_key_openssh
  allowed_dbs_list   = length(var.allowed_databases) > 0 ? join(",", var.allowed_databases) : "ALL"
}

# Deploy backup configuration to bastion
resource "null_resource" "setup_backup_user" {
  connection {
    type        = "ssh"
    host        = var.bastion_public_ip
    user        = "root"
    private_key = file(var.ssh_bastion_private_key_path)
    timeout     = "5m"
  }

  # Upload the dump script
  provisioner "file" {
    content = templatefile("${path.module}/templates/db-dump.sh.tpl", {
      database_ip       = var.database_private_ip
      readonly_user     = var.mariadb_readonly_user
      readonly_password = var.mariadb_readonly_password
      allowed_databases = local.allowed_dbs_list
    })
    destination = "/tmp/db-dump.sh"
  }

  # Upload MySQL client configuration
  provisioner "file" {
    content = templatefile("${path.module}/templates/my.cnf.tpl", {
      readonly_user     = var.mariadb_readonly_user
      readonly_password = var.mariadb_readonly_password
      database_ip       = var.database_private_ip
    })
    destination = "/tmp/dbbackup-my.cnf"
  }

  # Setup backup user and configure SSH
  provisioner "remote-exec" {
    inline = [
      "set -e",

      # Install MySQL client if not present
      "if ! command -v mysqldump &> /dev/null; then",
      "  apt-get update -qq",
      "  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mariadb-client",
      "fi",

      # Create backup user
      "if ! id -u dbbackup &> /dev/null; then",
      "  useradd -m -s /bin/bash -d /home/dbbackup dbbackup",
      "  echo 'Backup user created'",
      "else",
      "  echo 'Backup user already exists'",
      "  # Update shell if user exists with nologin",
      "  usermod -s /bin/bash dbbackup",
      "fi",

      # Install dump script
      "mv /tmp/db-dump.sh /usr/local/bin/db-dump.sh",
      "chmod 755 /usr/local/bin/db-dump.sh",
      "chown root:root /usr/local/bin/db-dump.sh",

      # Setup MySQL client config for backup user
      "mkdir -p /home/dbbackup/.mysql",
      "mv /tmp/dbbackup-my.cnf /home/dbbackup/.mysql/my.cnf",
      "chmod 600 /home/dbbackup/.mysql/my.cnf",
      "chown -R dbbackup:dbbackup /home/dbbackup/.mysql",

      # Setup SSH authorized_keys with forced command
      "mkdir -p /home/dbbackup/.ssh",
      "chmod 700 /home/dbbackup/.ssh",
      "echo 'command=\"/usr/local/bin/db-dump.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ${local.backup_public_key}' > /home/dbbackup/.ssh/authorized_keys",
      "chmod 600 /home/dbbackup/.ssh/authorized_keys",
      "chown -R dbbackup:dbbackup /home/dbbackup/.ssh",

      # Create log directory
      "mkdir -p /var/log/dbbackup",
      "chown dbbackup:dbbackup /var/log/dbbackup",

      "echo 'Database backup user setup completed successfully'"
    ]
  }
}