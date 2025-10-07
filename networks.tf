################################################################
# 1. The Private Network Foundation
################################################################
resource "hcloud_network" "private_net" {
  name     = var.network_name
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/16"
}

# Route for internet access through bastion (NAT gateway)
resource "hcloud_network_route" "internet_route" {
  network_id  = hcloud_network.private_net.id
  destination = "0.0.0.0/0"
  gateway     = one(hcloud_server.bastion.network).ip

  depends_on = [
    hcloud_server.bastion
  ]
}