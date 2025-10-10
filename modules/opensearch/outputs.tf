output "opensearch_server_id" {
  value       = hcloud_server.opensearch_cluster_vm.id
  description = "The ID of the OpenSearch server"
}

output "opensearch_server_name" {
  value       = hcloud_server.opensearch_cluster_vm.name
  description = "The name of the OpenSearch server"
}

output "opensearch_static_ip" {
  value       = var.opensearch_static_ip
  description = "The static private IP of the OpenSearch server"
}

output "opensearch_access_instructions" {
  value = <<-EOT

    ================================================================================
    OPENSEARCH ACCESS INSTRUCTIONS
    ================================================================================

    OpenSearch Version: ${var.opensearch_version}
    Cluster Name: ${var.opensearch_cluster_name}
    Server IP (Private Network): ${var.opensearch_static_ip}
    Admin Username: admin
    Admin Password: ${var.opensearch_admin_password}

    --------------------------------------------------------------------------------
    1. ACCESS OPENSEARCH VIA BASTION (SSH TUNNEL)
    --------------------------------------------------------------------------------

    First, SSH into the bastion, then connect to OpenSearch server:

    ssh -J root@BASTION_IP root@${var.opensearch_static_ip}

    Once on the OpenSearch server, you can interact with OpenSearch:

    # Check cluster health
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_cluster/health?pretty"

    # List all indices
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_cat/indices?v"

    # Check installed plugins
    docker exec opensearch /usr/share/opensearch/bin/opensearch-plugin list

    # View OpenSearch logs
    docker logs opensearch

    # View OpenSearch logs (follow mode)
    docker logs -f opensearch

    --------------------------------------------------------------------------------
    2. INTERACT WITH OPENSEARCH CONTAINER
    --------------------------------------------------------------------------------

    # Access OpenSearch container shell
    ssh -J root@BASTION_IP root@${var.opensearch_static_ip}
    docker exec -it opensearch bash

    # Check OpenSearch status from within container
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/"

    # Stop OpenSearch container
    docker stop opensearch

    # Start OpenSearch container
    docker start opensearch

    # Restart OpenSearch container
    docker restart opensearch

    # View container resource usage
    docker stats opensearch

    --------------------------------------------------------------------------------
    3. OPENSEARCH OPERATIONS FROM LOCAL MACHINE (VIA SSH TUNNEL)
    --------------------------------------------------------------------------------

    Create an SSH tunnel to access OpenSearch from your local machine:

    ssh -L 9200:${var.opensearch_static_ip}:9200 -J root@BASTION_IP root@${var.opensearch_static_ip}

    Then from another terminal on your local machine:

    # Cluster health
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_cluster/health?pretty"

    # Create an index
    curl -u admin:${var.opensearch_admin_password} -XPUT "http://localhost:9200/my-index"

    # Index a document
    curl -u admin:${var.opensearch_admin_password} -XPOST "http://localhost:9200/my-index/_doc" \
      -H 'Content-Type: application/json' \
      -d '{"name":"John Doe","age":30}'

    # Search documents
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/my-index/_search?pretty"

    --------------------------------------------------------------------------------
    4. BACKUP AND RESTORE
    --------------------------------------------------------------------------------

    # Register a snapshot repository
    ssh -J root@BASTION_IP root@${var.opensearch_static_ip}

    curl -u admin:${var.opensearch_admin_password} -XPUT "http://localhost:9200/_snapshot/my_backup" \
      -H 'Content-Type: application/json' \
      -d '{
        "type": "fs",
        "settings": {
          "location": "/usr/share/opensearch/snapshots"
        }
      }'

    # Create a snapshot
    curl -u admin:${var.opensearch_admin_password} -XPUT "http://localhost:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true"

    # List snapshots
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_snapshot/my_backup/_all?pretty"

    # Restore from snapshot
    curl -u admin:${var.opensearch_admin_password} -XPOST "http://localhost:9200/_snapshot/my_backup/snapshot_1/_restore"

    --------------------------------------------------------------------------------
    5. DATA MANAGEMENT
    --------------------------------------------------------------------------------

    OpenSearch data is stored at: ${var.opensearch_data_path}

    # Backup data directory
    ssh -J root@BASTION_IP root@${var.opensearch_static_ip}
    docker stop opensearch
    tar -czf opensearch-data-backup-$(date +%Y%m%d).tar.gz ${var.opensearch_data_path}
    docker start opensearch

    # Copy backup to local machine
    scp -o ProxyJump=root@BASTION_IP root@${var.opensearch_static_ip}:/root/opensearch-data-backup-*.tar.gz .

    # Restore data from backup
    docker stop opensearch
    rm -rf ${var.opensearch_data_path}/*
    tar -xzf opensearch-data-backup-*.tar.gz -C /
    docker start opensearch

    --------------------------------------------------------------------------------
    6. INSTALLED PLUGINS
    --------------------------------------------------------------------------------

    The following plugins are installed:
    - analysis-phonetic: Provides phonetic analysis capabilities
    - analysis-icu: Provides Unicode text analysis capabilities

    # Verify installed plugins
    ssh -J root@BASTION_IP root@${var.opensearch_static_ip}
    docker exec opensearch /usr/share/opensearch/bin/opensearch-plugin list

    --------------------------------------------------------------------------------
    7. PERFORMANCE TUNING
    --------------------------------------------------------------------------------

    Current heap size: ${var.opensearch_heap_size}

    # Monitor JVM memory usage
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_nodes/stats/jvm?pretty"

    # Monitor thread pools
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/_cat/thread_pool?v"

    # Clear cache
    curl -u admin:${var.opensearch_admin_password} -XPOST "http://localhost:9200/_cache/clear"

    --------------------------------------------------------------------------------
    8. USEFUL COMMANDS
    --------------------------------------------------------------------------------

    # Delete an index
    curl -u admin:${var.opensearch_admin_password} -XDELETE "http://localhost:9200/my-index"

    # Get index settings
    curl -u admin:${var.opensearch_admin_password} -XGET "http://localhost:9200/my-index/_settings?pretty"

    # Update index settings
    curl -u admin:${var.opensearch_admin_password} -XPUT "http://localhost:9200/my-index/_settings" \
      -H 'Content-Type: application/json' \
      -d '{"index":{"number_of_replicas":0}}'

    # Reindex data
    curl -u admin:${var.opensearch_admin_password} -XPOST "http://localhost:9200/_reindex" \
      -H 'Content-Type: application/json' \
      -d '{
        "source": {"index": "old-index"},
        "dest": {"index": "new-index"}
      }'

    ================================================================================

  EOT
  description = "Instructions for accessing and managing OpenSearch"
}