output "redis_server_id" {
  value       = hcloud_server.redis_cluster_vm.id
  description = "The ID of the Redis server"
}

output "redis_server_name" {
  value       = hcloud_server.redis_cluster_vm.name
  description = "The name of the Redis server"
}

output "redis_static_ip" {
  value       = var.redis_static_ip
  description = "The static private IP of the Redis server"
}

output "redis_access_instructions" {
  value = <<-EOT

    ================================================================================
    REDIS ACCESS INSTRUCTIONS
    ================================================================================

    Redis Version: ${var.redis_version}
    Server IP (Private Network): ${var.redis_static_ip}
    Redis Password: ${var.redis_password}
    Max Memory: ${var.redis_maxmemory}
    Maxmemory Policy: ${var.redis_maxmemory_policy}

    --------------------------------------------------------------------------------
    1. ACCESS REDIS VIA BASTION (SSH TUNNEL)
    --------------------------------------------------------------------------------

    First, SSH into the bastion, then connect to Redis server:

    ssh -J root@BASTION_IP root@${var.redis_static_ip}

    Once on the Redis server, you can interact with Redis:

    # Connect to Redis CLI
    docker exec -it redis redis-cli -a '${var.redis_password}'

    # Test connection
    docker exec redis redis-cli -a '${var.redis_password}' PING

    # Get Redis info
    docker exec redis redis-cli -a '${var.redis_password}' INFO

    # View Redis logs
    docker logs redis

    # View Redis logs (follow mode)
    docker logs -f redis

    --------------------------------------------------------------------------------
    2. REDIS OPERATIONS FROM LOCAL MACHINE (VIA SSH TUNNEL)
    --------------------------------------------------------------------------------

    Create an SSH tunnel to access Redis from your local machine:

    ssh -L 6379:${var.redis_static_ip}:6379 -J root@BASTION_IP root@${var.redis_static_ip}

    Then from another terminal on your local machine with redis-cli installed:

    # Connect to Redis
    redis-cli -a '${var.redis_password}'

    # Or use specific commands
    redis-cli -a '${var.redis_password}' PING
    redis-cli -a '${var.redis_password}' SET mykey "Hello Redis"
    redis-cli -a '${var.redis_password}' GET mykey

    --------------------------------------------------------------------------------
    3. COMMON REDIS COMMANDS
    --------------------------------------------------------------------------------

    # Set a key
    docker exec redis redis-cli -a '${var.redis_password}' SET mykey "myvalue"

    # Get a key
    docker exec redis redis-cli -a '${var.redis_password}' GET mykey

    # Delete a key
    docker exec redis redis-cli -a '${var.redis_password}' DEL mykey

    # List all keys
    docker exec redis redis-cli -a '${var.redis_password}' KEYS '*'

    # Get all keys with pattern
    docker exec redis redis-cli -a '${var.redis_password}' KEYS 'user:*'

    # Set key with expiration (seconds)
    docker exec redis redis-cli -a '${var.redis_password}' SETEX session:123 3600 "session_data"

    # Check if key exists
    docker exec redis redis-cli -a '${var.redis_password}' EXISTS mykey

    # Get TTL of key
    docker exec redis redis-cli -a '${var.redis_password}' TTL session:123

    # Flush all data (BE CAREFUL!)
    docker exec redis redis-cli -a '${var.redis_password}' FLUSHALL

    --------------------------------------------------------------------------------
    4. BACKUP AND RESTORE
    --------------------------------------------------------------------------------

    # Manual backup (creates dump.rdb)
    ssh -J root@BASTION_IP root@${var.redis_static_ip}
    docker exec redis redis-cli -a '${var.redis_password}' SAVE

    # Background backup
    docker exec redis redis-cli -a '${var.redis_password}' BGSAVE

    # Check last save time
    docker exec redis redis-cli -a '${var.redis_password}' LASTSAVE

    # Copy backup to local machine
    docker cp redis:/data/dump.rdb /root/redis-backup-$(date +%Y%m%d).rdb
    scp -o ProxyJump=root@BASTION_IP root@${var.redis_static_ip}:/root/redis-backup-*.rdb .

    # Restore from backup
    # 1. Stop Redis container
    docker stop redis
    # 2. Copy backup file to container volume
    docker run --rm -v redis_data:/data -v /root:/backup ubuntu cp /backup/dump.rdb /data/dump.rdb
    # 3. Start Redis container
    docker start redis

    --------------------------------------------------------------------------------
    5. CONTAINER MANAGEMENT
    --------------------------------------------------------------------------------

    # Stop Redis container
    docker stop redis

    # Start Redis container
    docker start redis

    # Restart Redis container
    docker restart redis

    # View container stats
    docker stats redis

    # View container logs
    docker logs redis --tail 100

    --------------------------------------------------------------------------------
    6. MONITORING
    --------------------------------------------------------------------------------

    # Check memory usage
    docker exec redis redis-cli -a '${var.redis_password}' INFO memory

    # Check stats
    docker exec redis redis-cli -a '${var.redis_password}' INFO stats

    # Check keyspace
    docker exec redis redis-cli -a '${var.redis_password}' INFO keyspace

    # Monitor commands in real-time
    docker exec redis redis-cli -a '${var.redis_password}' MONITOR

    # Get slow log
    docker exec redis redis-cli -a '${var.redis_password}' SLOWLOG GET 10

    --------------------------------------------------------------------------------
    7. USEFUL INFORMATION
    --------------------------------------------------------------------------------

    - Redis is configured with AOF (Append Only File) persistence
    - Max memory: ${var.redis_maxmemory}
    - Eviction policy: ${var.redis_maxmemory_policy}
    - Data is persisted in Docker volume: redis_data
    - Redis listens on port: 6379 (private network only)

    ================================================================================

  EOT
  description = "Instructions for accessing and managing Redis"
  sensitive   = true
}