variable "php_nginx_cluster_vm" {
  type        = string
  description = "PHP Nginx Server Name"
  default     = "php-nginx"
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
