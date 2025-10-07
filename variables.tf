variable "hcloud_token" {
  type        = string
  description = "Your Hetzner Cloud API token."
  sensitive   = true
}

variable "server_image" {
  type        = string
  description = "ubuntu-22.04"
  default     = "ubuntu-22.04"
}

variable "network_name" {
  type        = string
  description = "Network name "
  default     = "armah-network"
}



variable "server_type" {
  type        = string
  description = "Server Type"
}


variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key you have added to your Hetzner project."
  default     = "magefleet-pub"
}

variable "environment" {
  type        = string
  description = "Environment, it could be production, staging, development"
  default     = "staging"
  sensitive   = false
}

variable "location" {
  type        = string
  description = "Location"
  default     = "nbg1"
  sensitive   = false
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
variable "bastion_host_server_name" {
  type        = string
  description = "Bastion Host Server name"
}
variable "bastion_host_server_type" {
  type        = string
  description = "Bastion Host Server Type"
}

variable "ssh_bastion_private_key_path" {
  type        = string
  description = "Path to SSH private key for connecting to servers"
  default     = "~/.ssh/id_rsa"
}