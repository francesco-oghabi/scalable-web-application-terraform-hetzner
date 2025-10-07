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
resource "hcloud_server" "php_nginx_cluster_vm" {
  name        = var.php_nginx_cluster_vm
  server_type = var.server_type # Slightly larger for cluster workloads
  image       = var.server_image
  location    = var.location
  ssh_keys    = [var.ssh_key_name]

  # Critical: Disable all public networking
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Attach ONLY to the private network
  network {
    network_id = var.network_id

  }

  # This server's only bootstrap requirement is to trust the internal
  # SSH key from the bastion and configure DNS to use bastion's dnsmasq server.
  user_data = templatefile("${path.module}/templates/userdata_php_nginx.tpl", {
    netdata_username       = var.netdata_username
    netdata_password       = var.netdata_password
    nginx_netdata_config   = file("${path.module}/templates/nginx_netdata.conf.tpl")
  })


}
