variable "redis_cluster_vm" {
  type        = string
  description = "Redis Server Name"
  default     = "redis-server"
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

variable "internal_ssh_public_key" {
  type        = string
  description = "Internal SSH public key"
  sensitive   = true
}

variable "bastion_private_ip" {
  type        = string
  description = "Bastion private IP address"
}

variable "redis_static_ip" {
  type        = string
  description = "Static IP for Redis server in private network"
  default     = "10.0.0.6"
}

variable "redis_version" {
  type        = string
  description = "Redis Version"
  default     = "7.2"
}

variable "redis_password" {
  type        = string
  description = "Redis password"
  sensitive   = true
}

variable "redis_maxmemory" {
  type        = string
  description = "Redis max memory (e.g., 512mb, 1gb, 2gb)"
  default     = "512mb"
}

variable "redis_maxmemory_policy" {
  type        = string
  description = "Redis maxmemory policy"
  default     = "allkeys-lru"
}