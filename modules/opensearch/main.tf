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
resource "hcloud_server" "opensearch_cluster_vm" {
  name        = var.opensearch_cluster_vm
  server_type = var.server_type
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
    ip         = var.opensearch_static_ip # Static IP for opensearch server
  }

  # This server's only bootstrap requirement is to trust the internal
  # SSH key from the bastion and configure DNS to use bastion's dnsmasq server.
  user_data = templatefile("${path.module}/templates/userdata_opensearch.tpl", {
    netdata_username        = var.netdata_username
    netdata_password        = var.netdata_password
    nginx_netdata_config    = file("${path.module}/templates/nginx_netdata.conf.tpl")
    bastion_private_ip      = var.bastion_private_ip
    internal_ssh_public_key = var.internal_ssh_public_key
    opensearch_version      = var.opensearch_version
    opensearch_cluster_name = var.opensearch_cluster_name
    opensearch_admin_password = var.opensearch_admin_password
    opensearch_heap_size    = var.opensearch_heap_size
    opensearch_data_path    = var.opensearch_data_path
  })
}
