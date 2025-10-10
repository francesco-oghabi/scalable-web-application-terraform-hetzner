variable "rabbit_cluster_vm" {
  type        = string
  description = "RabbitMQ Server Name"
  default     = "rabbitmq-server"
}

variable "server_image" {
  type        = string
  description = "ubuntu-22.04"
  default     = "ubuntu-22.04"
}

variable "rabbit_server_type" {
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

variable "internal_ssh_public_key" {
  type        = string
  description = "Internal SSH public key"
  sensitive   = true
}

variable "bastion_private_ip" {
  type        = string
  description = "Bastion private IP address"
}

variable "rabbit_static_ip" {
  type        = string
  description = "Static IP for RabbitMQ server in private network"
  default     = "10.0.0.7"
}

variable "rabbitmq_version" {
  type        = string
  description = "RabbitMQ Version"
  default     = "4.1"
}

variable "rabbitmq_user" {
  type        = string
  description = "RabbitMQ admin username"
  default     = "admin"
}

variable "rabbitmq_password" {
  type        = string
  description = "RabbitMQ admin password"
  sensitive   = true
}

variable "rabbitmq_erlang_cookie" {
  type        = string
  description = "RabbitMQ Erlang cookie for clustering"
  sensitive   = true
  default     = ""
}