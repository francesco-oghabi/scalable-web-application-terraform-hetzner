variable "opensearch_cluster_vm" {
  type        = string
  description = "OpenSearch Server Name"
  default     = "opensearch-server"
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

variable "opensearch_static_ip" {
  type        = string
  description = "Static IP for OpenSearch server in private network"
  default     = "10.0.0.5"
}

variable "opensearch_version" {
  type        = string
  description = "OpenSearch Version"
  default     = "latest"
}

variable "opensearch_cluster_name" {
  type        = string
  description = "OpenSearch cluster name"
  default     = "opensearch-cluster"
}

variable "opensearch_admin_password" {
  type        = string
  description = "OpenSearch admin user password"
  sensitive   = true
}

variable "opensearch_heap_size" {
  type        = string
  description = "OpenSearch JVM heap size (e.g., 1g, 2g, 4g)"
  default     = "1g"
}

variable "opensearch_data_path" {
  type        = string
  description = "Path for OpenSearch data persistence"
  default     = "/var/lib/opensearch"
}