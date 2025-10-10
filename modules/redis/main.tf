terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52.0"
    }
  }
}
################################################################
# Redis Server
################################################################
resource "hcloud_server" "redis_cluster_vm" {
  name        = var.redis_cluster_vm
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
    ip         = var.redis_static_ip
  }

  # This server's only bootstrap requirement is to trust the internal
  # SSH key from the bastion and configure DNS to use bastion's dnsmasq server.
  user_data = templatefile("${path.module}/templates/userdata_redis.tpl", {
    netdata_username        = var.netdata_username
    netdata_password        = var.netdata_password
    nginx_netdata_config    = file("${path.module}/templates/nginx_netdata.conf.tpl")
    bastion_private_ip      = var.bastion_private_ip
    internal_ssh_public_key = var.internal_ssh_public_key
    redis_version           = var.redis_version
    redis_password          = var.redis_password
    redis_maxmemory         = var.redis_maxmemory
    redis_maxmemory_policy  = var.redis_maxmemory_policy
  })
}