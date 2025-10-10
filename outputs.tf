###############################################################################
# Infrastructure Outputs
###############################################################################

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = hcloud_server.bastion.ipv4_address
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = one(hcloud_server.bastion.network).ip
}

output "database_server_private_ip" {
  description = "Private IP address of the database server"
  value       = var.database_static_ip
}

output "opensearch_server_private_ip" {
  description = "Private IP address of the OpenSearch server"
  value       = var.opensearch_static_ip
}

###############################################################################
# Database Access Instructions
###############################################################################

output "database_instructions" {
  description = "Complete instructions for accessing and managing the MariaDB database"
  value       = module.database.database_access_instructions
}

###############################################################################
# OpenSearch Access Instructions
###############################################################################

output "opensearch_instructions" {
  description = "Complete instructions for accessing and managing OpenSearch"
  value       = module.opensearch.opensearch_access_instructions
  sensitive = true
}

###############################################################################
# Quick Start Guide
###############################################################################

output "quick_start" {
  description = "Quick start guide for using the infrastructure"
  value = <<-EOT

  ╔═══════════════════════════════════════════════════════════════════════════╗
  ║                   🚀 HETZNER INFRASTRUCTURE - QUICK START                 ║
  ╚═══════════════════════════════════════════════════════════════════════════╝

  Your infrastructure has been successfully deployed!

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📡 SERVER INFORMATION
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Bastion Host (Public):   ${hcloud_server.bastion.ipv4_address}
  Bastion Host (Private):  ${one(hcloud_server.bastion.network).ip}
  Database Server:         ${var.database_static_ip}
  OpenSearch Server:       ${var.opensearch_static_ip}

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐 SSH ACCESS
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Connect to bastion:
    ssh root@${hcloud_server.bastion.ipv4_address}

  Connect to database server (via bastion):
    ssh -J root@${hcloud_server.bastion.ipv4_address} root@${var.database_static_ip}

  Connect to OpenSearch server (via bastion):
    ssh -J root@${hcloud_server.bastion.ipv4_address} root@${var.opensearch_static_ip}

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 NETDATA MONITORING
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Monitoring Dashboard:
    http://${hcloud_server.bastion.ipv4_address}:8080/

  Database Netdata:
    http://${hcloud_server.bastion.ipv4_address}:8080/netdata-database/

  OpenSearch Netdata:
    http://${hcloud_server.bastion.ipv4_address}:8080/netdata-opensearch/

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🗄️ DATABASE ACCESS INSTRUCTIONS
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  To view complete database access and management instructions, run:

    terraform output -raw database_instructions > database_instructions.txt

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 OPENSEARCH ACCESS INSTRUCTIONS
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  To view complete OpenSearch access and management instructions, run:

    terraform output -raw opensearch_instructions > opensearch_instructions.txt

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📚 USEFUL COMMANDS
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  View all outputs:
    terraform output

  View specific output:
    terraform output bastion_public_ip
    terraform output database_server_private_ip

  Refresh infrastructure state:
    terraform refresh

  Show infrastructure state:
    terraform show

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📖 DOCUMENTATION
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Full documentation is available in the README.md file:
    - Architecture overview
    - Configuration options
    - Database management
    - Troubleshooting guide

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  EOT
}