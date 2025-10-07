terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52.0"
    }
    tls = { # Add tls provider for key generation
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}


# --- Internal SSH Key Generation for Bastion to Private Servers ---
resource "tls_private_key" "internal_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096 # Adhering to the RSA 4096-bit requirement
}


################################################################
# 2. The Bastion Host (NAT Gateway & WireGuard Server)
# This is the ONLY server with a public IP.
################################################################
resource "hcloud_server" "bastion" {
  name        = var.bastion_host_server_name
  server_type = var.bastion_host_server_type
  image       = var.server_image
  location    = var.location
  ssh_keys    = [var.ssh_key_name]

  # Attach to the private network
  network {
    network_id = hcloud_network.private_net.id
  }

  # This script runs on first boot to configure the NAT routing,
  # sets up the internal SSH private key, configures dnsmasq DNS server, and configures the WireGuard VPN server.
  user_data = templatefile("${path.module}/templates/userdata_bastion.tpl", {
    private_network_ip_range = hcloud_network_subnet.private_subnet.ip_range
    internal_ssh_private_key = tls_private_key.internal_ssh_key.private_key_pem
  })

  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

# Wait for bastion cloud-init to complete
resource "null_resource" "wait_for_bastion_cloud_init" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = hcloud_server.bastion.ipv4_address
      user        = "root"
      private_key = file(var.ssh_bastion_private_key_path)
      timeout     = "10m"
    }

    inline = [
      "timeout 300 bash -c 'until [ -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done' || true",
      "echo 'Bastion cloud-init completed'"
    ]
  }

  depends_on = [
    hcloud_server.bastion
  ]
}

module "php-nginx" {
  source           = "./modules/php-nginx"
  location         = var.location
  network_id       = hcloud_network.private_net.id
  server_type      = var.server_type
  ssh_key_name     = var.ssh_key_name
  hcloud_token     = var.hcloud_token
  netdata_username = var.netdata_username
  netdata_password = var.netdata_password
}

module "database" {
  source = "./modules/database"

  hcloud_token          = var.hcloud_token
  location              = var.location
  mariadb_password      = var.mariadb_password
  mariadb_root_password = var.mariadb_root_password
  netdata_password      = var.netdata_password
  network_id            = hcloud_network.private_net.id
  server_type           = var.server_type
  ssh_key_name          = var.ssh_key_name
  mariadb_readonly_password = var.mariadb_readonly_password
  internal_ssh_public_key = tls_private_key.internal_ssh_key.public_key_openssh
  bastion_private_ip = one(hcloud_server.bastion.network).ip

  depends_on = [
    null_resource.wait_for_bastion_cloud_init
  ]
}
