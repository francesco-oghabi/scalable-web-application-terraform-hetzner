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

variable "opensearch_server_type" {
  type        = string
  description = "OpenSearch Server Type"
}

variable "redis_server_type" {
  type        = string
  description = "Redis Server Type"
}



variable "server_type" {
  type        = string
  description = "Server Type"
}


variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key you have added to your Hetzner project."
  default     = "key-pub"
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

variable "php_nginx_static_ip" {
  type        = string
  description = "Static IP for PHP NGINX server in private network"
  default     = "10.0.0.3"
}



variable "database_static_ip" {
  type        = string
  description = "Static IP for database server in private network"
  default     = "10.0.0.4"
}

variable "mariadb_version" {
  type        = string
  description = "MariaDB Version"
  default     = "latest"
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

variable "rabbit_static_ip" {
  type        = string
  description = "Static IP for RabbitMQ server in private network"
  default     = "10.0.0.7"
}

variable "rabbit_server_type" {
  type        = string
  description = "RabbitMQ Server Type"
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
  default     = "CHANGEME_ERLANG_COOKIE"
}