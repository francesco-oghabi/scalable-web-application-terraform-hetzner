output "rabbitmq_server_id" {
  value       = hcloud_server.rabbit_cluster_vm.id
  description = "The ID of the RabbitMQ server"
}

output "rabbitmq_server_name" {
  value       = hcloud_server.rabbit_cluster_vm.name
  description = "The name of the RabbitMQ server"
}

output "rabbitmq_static_ip" {
  value       = var.rabbit_static_ip
  description = "The static private IP of the RabbitMQ server"
}

output "rabbitmq_access_instructions" {
  value = <<-EOT

    ================================================================================
    RABBITMQ ACCESS INSTRUCTIONS
    ================================================================================

    RabbitMQ Version: ${var.rabbitmq_version}
    Server IP (Private Network): ${var.rabbit_static_ip}
    Admin Username: ${var.rabbitmq_user}
    Admin Password: ${var.rabbitmq_password}
    AMQP Port: 5672
    Management UI Port: 15672

    --------------------------------------------------------------------------------
    1. ACCESS RABBITMQ MANAGEMENT UI VIA SSH TUNNEL
    --------------------------------------------------------------------------------

    Create an SSH tunnel to access RabbitMQ Management UI:

    ssh -L 15672:${var.rabbit_static_ip}:15672 -J root@BASTION_IP root@${var.rabbit_static_ip}

    Then open in your browser:
    http://localhost:15672

    Login credentials:
    Username: ${var.rabbitmq_user}
    Password: ${var.rabbitmq_password}

    --------------------------------------------------------------------------------
    2. ACCESS RABBITMQ VIA BASTION (SSH)
    --------------------------------------------------------------------------------

    SSH into the RabbitMQ server:

    ssh -J root@BASTION_IP root@${var.rabbit_static_ip}

    Once on the server, interact with RabbitMQ:

    # Check RabbitMQ status
    docker exec rabbitmq rabbitmqctl status

    # Check cluster status
    docker exec rabbitmq rabbitmqctl cluster_status

    # List queues
    docker exec rabbitmq rabbitmqctl list_queues

    # List exchanges
    docker exec rabbitmq rabbitmqctl list_exchanges

    # List bindings
    docker exec rabbitmq rabbitmqctl list_bindings

    # List connections
    docker exec rabbitmq rabbitmqctl list_connections

    # List channels
    docker exec rabbitmq rabbitmqctl list_channels

    # View logs
    docker logs rabbitmq

    # Follow logs
    docker logs -f rabbitmq

    --------------------------------------------------------------------------------
    3. RABBITMQ OPERATIONS
    --------------------------------------------------------------------------------

    # Create a new user
    docker exec rabbitmq rabbitmqctl add_user myuser mypassword

    # Set user tags (administrator, monitoring, management, etc.)
    docker exec rabbitmq rabbitmqctl set_user_tags myuser administrator

    # Grant permissions (configure, write, read)
    docker exec rabbitmq rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

    # Delete a user
    docker exec rabbitmq rabbitmqctl delete_user myuser

    # List users
    docker exec rabbitmq rabbitmqctl list_users

    # Create a new vhost
    docker exec rabbitmq rabbitmqctl add_vhost my_vhost

    # Delete a vhost
    docker exec rabbitmq rabbitmqctl delete_vhost my_vhost

    # List vhosts
    docker exec rabbitmq rabbitmqctl list_vhosts

    --------------------------------------------------------------------------------
    4. CONNECT TO RABBITMQ FROM APPLICATIONS
    --------------------------------------------------------------------------------

    Connection String:
    amqp://${var.rabbitmq_user}:${var.rabbitmq_password}@${var.rabbit_static_ip}:5672/

    Example Python (pika):
    import pika
    credentials = pika.PlainCredentials('${var.rabbitmq_user}', '${var.rabbitmq_password}')
    connection = pika.BlockingConnection(
        pika.ConnectionParameters('${var.rabbit_static_ip}', 5672, '/', credentials)
    )

    Example Node.js (amqplib):
    const amqp = require('amqplib');
    const connection = await amqp.connect('amqp://${var.rabbitmq_user}:${var.rabbitmq_password}@${var.rabbit_static_ip}:5672/');

    --------------------------------------------------------------------------------
    5. BACKUP AND RESTORE
    --------------------------------------------------------------------------------

    # Export definitions (queues, exchanges, bindings, users, etc.)
    ssh -J root@BASTION_IP root@${var.rabbit_static_ip}
    docker exec rabbitmq rabbitmqadmin export /tmp/rabbitmq-definitions.json
    docker cp rabbitmq:/tmp/rabbitmq-definitions.json /root/rabbitmq-backup-$(date +%Y%m%d).json

    # Copy backup to local machine
    scp -o ProxyJump=root@BASTION_IP root@${var.rabbit_static_ip}:/root/rabbitmq-backup-*.json .

    # Import definitions
    docker cp /root/rabbitmq-backup.json rabbitmq:/tmp/rabbitmq-backup.json
    docker exec rabbitmq rabbitmqadmin import /tmp/rabbitmq-backup.json

    # Backup data volume
    docker stop rabbitmq
    docker run --rm -v rabbitmq_data:/data -v /root:/backup ubuntu \
      tar czf /backup/rabbitmq-data-$(date +%Y%m%d).tar.gz -C /data .
    docker start rabbitmq

    # Restore data volume
    docker stop rabbitmq
    docker run --rm -v rabbitmq_data:/data -v /root:/backup ubuntu \
      tar xzf /backup/rabbitmq-data-backup.tar.gz -C /data
    docker start rabbitmq

    --------------------------------------------------------------------------------
    6. CONTAINER MANAGEMENT
    --------------------------------------------------------------------------------

    # Stop RabbitMQ container
    docker stop rabbitmq

    # Start RabbitMQ container
    docker start rabbitmq

    # Restart RabbitMQ container
    docker restart rabbitmq

    # View container stats
    docker stats rabbitmq

    # View container logs
    docker logs rabbitmq --tail 100

    --------------------------------------------------------------------------------
    7. MONITORING AND HEALTH CHECKS
    --------------------------------------------------------------------------------

    # Health check
    docker exec rabbitmq rabbitmq-diagnostics ping

    # Check if RabbitMQ app is running
    docker exec rabbitmq rabbitmq-diagnostics check_running

    # Check if node is healthy
    docker exec rabbitmq rabbitmq-diagnostics node_health_check

    # Get memory usage
    docker exec rabbitmq rabbitmq-diagnostics memory_breakdown

    # List alarms
    docker exec rabbitmq rabbitmqctl list_alarms

    --------------------------------------------------------------------------------
    8. USEFUL INFORMATION
    --------------------------------------------------------------------------------

    - RabbitMQ Management UI: http://localhost:15672 (via SSH tunnel)
    - AMQP Protocol Port: 5672
    - Data persistence: Docker volume rabbitmq_data
    - Default vhost: /
    - Erlang Cookie: ${var.rabbitmq_erlang_cookie}

    ================================================================================

  EOT
  description = "Instructions for accessing and managing RabbitMQ"
  sensitive   = true
}