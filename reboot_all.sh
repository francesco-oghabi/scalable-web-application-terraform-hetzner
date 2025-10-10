#!/bin/bash

###############################################################################
# Reboot All Servers Script
# This script reboots all servers in the infrastructure
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get infrastructure information from Terraform
print_info "Fetching infrastructure information from Terraform..."

BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)
DATABASE_IP=$(terraform output -raw database_server_private_ip 2>/dev/null)
OPENSEARCH_IP=$(terraform output -raw opensearch_server_private_ip 2>/dev/null)

if [ -z "$BASTION_IP" ]; then
    print_error "Could not fetch bastion IP from Terraform output"
    print_error "Make sure you have run 'terraform apply' first"
    exit 1
fi

print_info "Infrastructure details:"
echo "  - Bastion IP:    $BASTION_IP"
echo "  - Database IP:   $DATABASE_IP"
echo "  - OpenSearch IP: $OPENSEARCH_IP"
echo ""

# Confirmation prompt
print_warning "This will reboot ALL servers in the infrastructure!"
read -p "Are you sure you want to continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Reboot cancelled by user"
    exit 0
fi

###############################################################################
# Reboot Database Server
###############################################################################
print_info "Scheduling database server reboot (via bastion)..."

ssh -J "root@$BASTION_IP" "root@$DATABASE_IP" << 'EOF'
    echo "Scheduling database server reboot in 1 minute..."
    shutdown -r +1 "Reboot triggered by reboot_all.sh script" &
    exit 0
EOF

if [ $? -eq 0 ]; then
    print_success "Database server reboot scheduled"
else
    print_error "Failed to schedule database server reboot"
fi

sleep 2

###############################################################################
# Reboot OpenSearch Server
###############################################################################
print_info "Scheduling OpenSearch server reboot (via bastion)..."

ssh -J "root@$BASTION_IP" "root@$OPENSEARCH_IP" << 'EOF'
    echo "Scheduling OpenSearch server reboot in 1 minute..."
    shutdown -r +1 "Reboot triggered by reboot_all.sh script" &
    exit 0
EOF

if [ $? -eq 0 ]; then
    print_success "OpenSearch server reboot scheduled"
else
    print_error "Failed to schedule OpenSearch server reboot"
fi

sleep 2

###############################################################################
# Reboot Bastion Host
###############################################################################
print_info "Scheduling bastion host reboot..."

ssh "root@$BASTION_IP" << 'EOF'
    echo "Scheduling bastion reboot in 3 minutes..."
    shutdown -r +3 "Reboot triggered by reboot_all.sh script" &
    exit 0
EOF

if [ $? -eq 0 ]; then
    print_success "Bastion host reboot scheduled"
else
    print_error "Failed to schedule bastion host reboot"
fi

###############################################################################
# Summary
###############################################################################
echo ""
print_success "All server reboots have been scheduled!"
echo ""
print_info "Reboot timeline:"
echo "  - Database server:   Will reboot in 1 minute"
echo "  - OpenSearch server: Will reboot in 1 minute"
echo "  - Bastion host:      Will reboot in 3 minutes"
echo ""
print_info "Servers will be back online in approximately 3-5 minutes"
print_info "You can monitor the status with: terraform refresh"
echo ""

# Optional: Wait and check connectivity
read -p "Do you want to wait and check connectivity after reboot? (yes/no): " -r
echo
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    print_info "Waiting 5 minutes for servers to reboot..."
    sleep 300

    print_info "Checking bastion connectivity..."
    if ssh -o ConnectTimeout=10 "root@$BASTION_IP" "echo 'Bastion is online'" 2>/dev/null; then
        print_success "Bastion host is online and accessible"
    else
        print_warning "Bastion host is not yet accessible, may need more time"
    fi

    print_info "Checking database server connectivity..."
    if ssh -J "root@$BASTION_IP" "root@$DATABASE_IP" "echo 'Database server is online'" 2>/dev/null; then
        print_success "Database server is online and accessible"
    else
        print_warning "Database server is not yet accessible, may need more time"
    fi

    print_info "Checking OpenSearch server connectivity..."
    if ssh -J "root@$BASTION_IP" "root@$OPENSEARCH_IP" "echo 'OpenSearch server is online'" 2>/dev/null; then
        print_success "OpenSearch server is online and accessible"
    else
        print_warning "OpenSearch server is not yet accessible, may need more time"
    fi
fi

print_success "Script completed!"