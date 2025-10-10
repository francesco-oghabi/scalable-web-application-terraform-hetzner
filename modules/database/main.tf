terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52.0"
    }
  }
}
################################################################
# Phase 2: These servers will be user to host services: argo/vault etc
################################################################
resource "hcloud_server" "database_cluster_vm" {
  name        = var.database_cluster_vm
  server_type = var.server_type # Slightly larger for cluster workloads
  image       = var.server_image
  location    = var.location
  ssh_keys    = [var.ssh_key_name]

  # Critical: Disable all public networking
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  # Attach ONLY to the private network
  network {
    network_id = var.network_id
    ip         = var.database_static_ip # Static IP for database server
  }

  # This server's only bootstrap requirement is to trust the internal
  # SSH key from the bastion and configure DNS to use bastion's dnsmasq server.
  user_data = templatefile("${path.module}/templates/userdata_database.tpl", {
    netdata_username          = var.netdata_username
    netdata_password          = var.netdata_password
    nginx_netdata_config      = file("${path.module}/templates/nginx_netdata.conf.tpl")
    mariadb_root_password     = var.mariadb_root_password
    mariadb_database          = var.mariadb_database
    bastion_private_ip        = var.bastion_private_ip
    mariadb_user              = var.mariadb_user
    mariadb_password          = var.mariadb_password
    mariadb_readonly_user     = var.mariadb_readonly_user
    mariadb_readonly_password = var.mariadb_readonly_password
    internal_ssh_public_key   = var.internal_ssh_public_key
    mariadb_version           = var.mariadb_version


  })


}
