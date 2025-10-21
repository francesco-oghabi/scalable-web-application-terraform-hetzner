variable "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  type        = string
}

variable "database_private_ip" {
  description = "Private IP address of the database server"
  type        = string
  default     = "10.0.0.4"
}

variable "mariadb_readonly_user" {
  description = "MariaDB read-only user for backups"
  type        = string
  default     = "readonly"
}

variable "mariadb_readonly_password" {
  description = "Password for the MariaDB read-only user"
  type        = string
  sensitive   = true
}

variable "backup_user_public_key" {
  description = "SSH public key for the backup user (optional, if not provided a new key will be generated)"
  type        = string
  default     = ""
}

variable "allowed_databases" {
  description = "List of databases allowed for backup. Empty list means all databases are allowed."
  type        = list(string)
  default     = []
}

variable "ssh_bastion_private_key_path" {
  description = "Path to SSH private key for connecting to the bastion host"
  type        = string
  default     = "~/.ssh/id_rsa"
}