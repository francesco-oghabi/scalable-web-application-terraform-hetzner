#!/bin/bash
#
# Database Backup Script
# This script allows secure, read-only database dumps via SSH
#
# Usage: ssh dbbackup@bastion "database_name" > dump.sql
#        ssh dbbackup@bastion "--list-databases"
#

set -euo pipefail

# Configuration
DATABASE_HOST="${database_ip}"
MYSQL_USER="${readonly_user}"
LOG_FILE="/var/log/dbbackup/access.log"
ALLOWED_DATABASES="${allowed_databases}"

# Logging function
log_access() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local client_ip="$${SSH_CLIENT%% *}"
    echo "$timestamp - IP: $client_ip - Database: $1 - Action: $2" >> "$LOG_FILE"
}

# Validate database name (alphanumeric, underscore, hyphen only)
validate_database_name() {
    local db_name="$1"
    if [[ ! "$db_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: Invalid database name. Only alphanumeric characters, underscores, and hyphens are allowed." >&2
        log_access "$db_name" "REJECTED - Invalid characters"
        exit 1
    fi
}

# Check if database is in allowed list
check_allowed_database() {
    local db_name="$1"

    # If ALLOWED_DATABASES is "ALL", allow any database
    if [ "$ALLOWED_DATABASES" = "ALL" ]; then
        return 0
    fi

    # Check if database is in the allowed list
    IFS=',' read -ra ALLOWED <<< "$ALLOWED_DATABASES"
    for allowed_db in "$${ALLOWED[@]}"; do
        if [ "$db_name" = "$allowed_db" ]; then
            return 0
        fi
    done

    echo "ERROR: Database '$db_name' is not in the allowed list." >&2
    echo "Allowed databases: $ALLOWED_DATABASES" >&2
    log_access "$db_name" "REJECTED - Not in allowed list"
    exit 1
}

# List available databases
list_databases() {
    log_access "N/A" "LIST_DATABASES"

    echo "=== Available Databases ===" >&2
    mysql --defaults-file=/home/dbbackup/.mysql/my.cnf \
          -h "$DATABASE_HOST" \
          -N -B -e "SHOW DATABASES;" 2>/dev/null | grep -Ev '^(information_schema|performance_schema|mysql|sys)$' || true

    if [ "$ALLOWED_DATABASES" != "ALL" ]; then
        echo "" >&2
        echo "Note: Only these databases are allowed for backup: $ALLOWED_DATABASES" >&2
    fi

    exit 0
}

# Main script
main() {
    # Get the database name from SSH_ORIGINAL_COMMAND or first argument
    DB_NAME="$${SSH_ORIGINAL_COMMAND:-$${1:-}}"

    # Remove any quotes from the database name
    DB_NAME=$(echo "$DB_NAME" | tr -d '"' | tr -d "'")

    # Check for special commands
    if [ "$DB_NAME" = "--list-databases" ] || [ "$DB_NAME" = "-l" ]; then
        list_databases
    fi

    # Validate input
    if [ -z "$DB_NAME" ]; then
        echo "ERROR: No database name provided." >&2
        echo "" >&2
        echo "Usage:" >&2
        echo "  ssh dbbackup@bastion \"database_name\" > dump.sql" >&2
        echo "  ssh dbbackup@bastion \"--list-databases\"" >&2
        log_access "N/A" "REJECTED - No database specified"
        exit 1
    fi

    # Validate database name format
    validate_database_name "$DB_NAME"

    # Check if database is allowed
    check_allowed_database "$DB_NAME"

    # Check if database exists
    if ! mysql --defaults-file=/home/dbbackup/.mysql/my.cnf \
               -h "$DATABASE_HOST" \
               -N -B -e "SHOW DATABASES LIKE '$DB_NAME';" 2>/dev/null | grep -q "^$DB_NAME$"; then
        echo "ERROR: Database '$DB_NAME' does not exist." >&2
        log_access "$DB_NAME" "REJECTED - Database not found"
        exit 1
    fi

    # Log the access
    log_access "$DB_NAME" "SUCCESS"

    # Perform the dump
    # Options:
    #   --single-transaction: consistent dump without locking tables
    #   --quick: retrieve rows one at a time (memory efficient)
    #   --skip-lock-tables: don't lock tables (read-only user can't lock anyway)
    #   --routines: include stored procedures and functions
    #   --triggers: include triggers
    #   --events: include events
    mysqldump --defaults-file=/home/dbbackup/.mysql/my.cnf \
              -h "$DATABASE_HOST" \
              --single-transaction \
              --quick \
              --skip-lock-tables \
              --routines \
              --triggers \
              --events \
              "$DB_NAME" 2>/dev/null

    # Check dump status
    if [ $? -eq 0 ]; then
        log_access "$DB_NAME" "DUMP_COMPLETED"
    else
        log_access "$DB_NAME" "DUMP_FAILED"
        exit 1
    fi
}

# Run main function
main "$@"