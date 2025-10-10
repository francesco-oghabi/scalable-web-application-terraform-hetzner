output "server" {
  description = "DATABASE CLUSTER VM"
  value       = hcloud_server.database_cluster_vm
}

output "database_access_instructions" {
  description = "Instructions for accessing and managing the MariaDB database"
  value = <<-EOT

  ═══════════════════════════════════════════════════════════════════════════════
  📊 MARIADB DATABASE SERVER - ACCESS & MANAGEMENT INSTRUCTIONS
  ═══════════════════════════════════════════════════════════════════════════════

  Server IP (Private): ${var.database_static_ip}
  Database Name:       ${var.mariadb_database}
  Database User:       ${var.mariadb_user}
  MariaDB Version:     ${var.mariadb_version}

  ═══════════════════════════════════════════════════════════════════════════════
  🔐 ACCESSING THE DATABASE
  ═══════════════════════════════════════════════════════════════════════════════

  1. Connect to database server via SSH (through bastion):
     ssh -J root@<bastion_public_ip> root@${var.database_static_ip}

  2. Access MariaDB as root user:
     docker exec -it mariadb mariadb -uroot -p
     # Enter password: <mariadb_root_password>

  3. Access as application user:
     docker exec -it mariadb mariadb -u${var.mariadb_user} -p ${var.mariadb_database}
     # Enter password: <mariadb_password>

  4. Access as read-only user (monitoring):
     docker exec -it mariadb mariadb -u${var.mariadb_readonly_user} -p
     # Enter password: <mariadb_readonly_password>

  ═══════════════════════════════════════════════════════════════════════════════
  💾 DATABASE BACKUP (DUMP)
  ═══════════════════════════════════════════════════════════════════════════════

  1. Full database dump:
     docker exec mariadb mariadb-dump -uroot -p<PASSWORD> ${var.mariadb_database} > backup_$(date +%Y%m%d_%H%M%S).sql

  2. All databases dump:
     docker exec mariadb mariadb-dump -uroot -p<PASSWORD> --all-databases > full_backup_$(date +%Y%m%d_%H%M%S).sql

  3. Compressed backup:
     docker exec mariadb mariadb-dump -uroot -p<PASSWORD> ${var.mariadb_database} | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

  4. Backup with structure only (no data):
     docker exec mariadb mariadb-dump -uroot -p<PASSWORD> --no-data ${var.mariadb_database} > structure_$(date +%Y%m%d).sql

  5. Backup specific table:
     docker exec mariadb mariadb-dump -uroot -p<PASSWORD> ${var.mariadb_database} table_name > table_backup.sql

  ═══════════════════════════════════════════════════════════════════════════════
  📥 DATABASE RESTORE (IMPORT)
  ═══════════════════════════════════════════════════════════════════════════════

  1. Import SQL file:
     docker exec -i mariadb mariadb -uroot -p<PASSWORD> ${var.mariadb_database} < backup.sql

  2. Import compressed backup:
     gunzip < backup.sql.gz | docker exec -i mariadb mariadb -uroot -p<PASSWORD> ${var.mariadb_database}

  3. Import to specific database:
     docker exec -i mariadb mariadb -uroot -p<PASSWORD> -D database_name < backup.sql

  4. Import with verbose output:
     docker exec -i mariadb mariadb -uroot -p<PASSWORD> ${var.mariadb_database} -v < backup.sql

  ═══════════════════════════════════════════════════════════════════════════════
  🔄 COPY DATABASE FROM/TO LOCAL MACHINE
  ═══════════════════════════════════════════════════════════════════════════════

  1. Dump from server to local machine:
     ssh -J root@<bastion_public_ip> root@${var.database_static_ip} \
       "docker exec mariadb mariadb-dump -uroot -p<PASSWORD> ${var.mariadb_database}" > local_backup.sql

  2. Import from local machine to server:
     cat local_backup.sql | ssh -J root@<bastion_public_ip> root@${var.database_static_ip} \
       "docker exec -i mariadb mariadb -uroot -p<PASSWORD> ${var.mariadb_database}"

  3. Using SCP through bastion:
     # Copy backup TO server:
     scp -o "ProxyJump root@<bastion_public_ip>" backup.sql root@${var.database_static_ip}:/tmp/

     # Copy backup FROM server:
     scp -o "ProxyJump root@<bastion_public_ip>" root@${var.database_static_ip}:/tmp/backup.sql ./

  ═══════════════════════════════════════════════════════════════════════════════
  🛠️ USEFUL DATABASE COMMANDS
  ═══════════════════════════════════════════════════════════════════════════════

  1. Show databases:
     docker exec mariadb mariadb -uroot -p<PASSWORD> -e "SHOW DATABASES;"

  2. Show tables in database:
     docker exec mariadb mariadb -uroot -p<PASSWORD> ${var.mariadb_database} -e "SHOW TABLES;"

  3. Show database size:
     docker exec mariadb mariadb -uroot -p<PASSWORD> -e "SELECT table_schema AS 'Database',
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
       FROM information_schema.tables WHERE table_schema='${var.mariadb_database}' GROUP BY table_schema;"

  4. Check MariaDB status:
     docker exec mariadb mariadb -uroot -p<PASSWORD> -e "STATUS;"

  5. Show current connections:
     docker exec mariadb mariadb -uroot -p<PASSWORD> -e "SHOW PROCESSLIST;"

  ═══════════════════════════════════════════════════════════════════════════════
  🐳 DOCKER CONTAINER MANAGEMENT
  ═══════════════════════════════════════════════════════════════════════════════

  1. Container status:
     docker ps | grep mariadb

  2. Container logs:
     docker logs mariadb
     docker logs --tail 100 mariadb
     docker logs -f mariadb  # Follow mode

  3. Container stats:
     docker stats mariadb --no-stream

  4. Restart container:
     docker restart mariadb

  5. Stop/Start container:
     docker stop mariadb
     docker start mariadb

  ═══════════════════════════════════════════════════════════════════════════════
  📊 NETDATA MONITORING
  ═══════════════════════════════════════════════════════════════════════════════

  Access Netdata monitoring dashboard:
  http://<bastion_public_ip>:8080/netdata-database/

  Username: ${var.netdata_username}
  Password: <netdata_password>

  ═══════════════════════════════════════════════════════════════════════════════
  ⚠️  IMPORTANT NOTES
  ═══════════════════════════════════════════════════════════════════════════════

  - Replace <PASSWORD> with actual password (avoid using passwords in command line)
  - Replace <bastion_public_ip> with actual bastion public IP
  - Data is persisted in /var/lib/mariadb on the server
  - Always test backups by restoring to a test database
  - Schedule regular automated backups for production environments
  - Use read-only user (${var.mariadb_readonly_user}) for monitoring/reporting queries

  ═══════════════════════════════════════════════════════════════════════════════
  EOT
}
