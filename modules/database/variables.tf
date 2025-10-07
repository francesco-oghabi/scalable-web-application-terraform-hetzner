variable "database_cluster_vm" {
  type        = string
  description = "Database Server Name"
  default     = "database-server"
}


variable "server_image" {
  type        = string
  description = "ubuntu-22.04"
  default     = "ubuntu-22.04"
}


variable "server_type" {
  type        = string
  description = "Server Type"
}


variable "location" {
  type        = string
  description = "Server location"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name for server access"
}

variable "network_id" {
  type        = string
  description = "Hetzner network ID"
}
variable "hcloud_token" {
  type        = string
  description = "Your Hetzner Cloud API token."
  sensitive   = true
}

variable "netdata_username" {
  type        = string
  description = "Username for Netdata basic auth"
  default     = "admin"
}

variable "netdata_password" {
  type        = string
  description = "Password for Netdata basic auth"
  sensitive   = true
}

variable "mariadb_root_password" {
  type        = string
  description = "Root password for MariaDB"
  sensitive   = true
}

variable "mariadb_database" {
  type        = string
  description = "Database name to create in MariaDB"
  default     = "magento"
}

variable "mariadb_user" {
  type        = string
  description = "Database user to create in MariaDB"
  default     = "magento"
}

variable "mariadb_password" {
  type        = string
  description = "Password for MariaDB user"
  sensitive   = true
}

variable "mariadb_readonly_user" {
  type        = string
  description = "Read-only user for MariaDB monitoring"
  default     = "readonly"
}

variable "mariadb_readonly_password" {
  type        = string
  description = "Password for MariaDB read-only user"
  sensitive   = true
}



variable "internal_ssh_public_key" {
  type        = string
  description = "Internal SSH public key"
  sensitive = true
}

variable "bastion_private_ip" {
  type        = string
  description = "Internal SSH public key"
}
