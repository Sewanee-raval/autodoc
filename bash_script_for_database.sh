#!/bin/bash

# MariaDB Status Update Script
# Updates the statuses table in linuxsystems database with system status information

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration - modify these variables as needed
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-linuxsystems}"
DB_USER="${DB_USER:-linux}"
DB_PASS="${DB_PASS:-testuser}"
TABLE_NAME="statuses"

# Status variables - set these with your actual values
ip_address="${1:-}"
aide="${2:-}"
fapolicyd="${3:-}"

# Function to display usage
usage() {
    echo "Usage: $0 <ip_address>"
    echo "       OR set variable ip_address"
    echo ""
    echo "Environment variables:"
    echo "  DB_HOST     - Database host (default: 152.97.30.61)"
    echo "  DB_PORT     - Database port (default: 3306)"
    echo "  DB_NAME     - Database name (default: linuxsystems)"
    echo "  DB_USER     - Database username (required)"
    echo "  DB_PASS     - Database password (required)"
    echo ""
    echo "Example:"
    echo "  export DB_USER='myuser'"
    echo "  export DB_PASS='mypassword'"
    echo "  $0 '192.168.1.100'"
    exit 1
}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Function to validate input
validate_input() {
    if [[ -z "$ip_address" ]]; then
        log "ERROR: Missing required parameter"
        usage
    fi
    
    if [[ -z "$DB_USER" ]] || [[ -z "$DB_PASS" ]]; then
        log "ERROR: Database credentials not provided"
        echo "Set DB_USER and DB_PASS environment variables" >&2
        exit 1
    fi
    
    # Basic IP address validation
    if ! [[ "$ip_address" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log "WARNING: IP address format may be invalid: $ip_address"
    fi
}

# Function to test database connection
test_connection() {
    log "Testing database connection..."
    
    if ! mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --execute="SELECT 1;" >/dev/null 2>&1; then
        log "ERROR: Unable to connect to database"
        exit 1
    fi
    
    log "Database connection successful"
}

# Function to create table if it doesn't exist
ensure_table_exists() {
    log "Ensuring table exists..."
    
    local create_table_sql="
    CREATE TABLE IF NOT EXISTS $TABLE_NAME (
        ip_address VARCHAR(45) PRIMARY KEY,
        aide VARCHAR(50) NOT NULL,
        fapolicyd VARCHAR(50) NOT NULL,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );"
    
    if ! mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --execute="$create_table_sql" 2>/dev/null; then
        log "ERROR: Failed to create/verify table"
        exit 1
    fi
    
    log "Table verified/created successfully"
}

# Function to update status in database
update_status() {
    log "Updating status for IP: $ip_address"
    
    # Use INSERT ... ON DUPLICATE KEY UPDATE for upsert functionality
    local upsert_sql="
    INSERT INTO $TABLE_NAME (ip_address, aide, fapolicyd)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE
        aide = VALUES(aide),
        fapolicyd = VALUES(fapolicyd),
        last_updated = CURRENT_TIMESTAMP;"
    
    # Create a temporary SQL file with the prepared statement
    local temp_sql=$(mktemp)
    trap "rm -f $temp_sql" EXIT
    
    cat > "$temp_sql" << EOF
SET @ip = '$ip_address';
SET @aide = '$aide';
SET @fapolicyd = '$fapolicyd';

INSERT INTO $TABLE_NAME (ip_address, aide, fapolicyd)
VALUES (@ip, @aide, @fapolicyd)
ON DUPLICATE KEY UPDATE
    aide = VALUES(aide),
    fapolicyd = VALUES(fapolicyd),
    last_updated = CURRENT_TIMESTAMP;
EOF
    
    if mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
            --database="$DB_NAME" < "$temp_sql" ; then
        log "Status updated successfully"
        
        # Verify the update
        local verify_sql="SELECT ip_address, aide, fapolicyd, last_updated 
                         FROM $TABLE_NAME WHERE ip_address = '$ip_address';"
        
        log "Current record:"
        mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --table --execute="$verify_sql" 2>/dev/null
    else
        log "ERROR: Failed to update status"
        exit 1
    fi
}

# Main execution
main() {
    log "Starting MariaDB status update"
    
    validate_input
    test_connection
    ensure_table_exists
    update_status
    
    log "Status update completed successfully"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi


# This bash script provides a secure and robust way to update your MariaDB database. Here are the key features:
# Security Features:

# Uses environment variables for database credentials (never hardcoded)
# Input validation and sanitization
# Proper error handling with set -euo pipefail
# Temporary files are cleaned up automatically

# Functionality:

# Connects to MariaDB using configurable connection parameters
# Creates the table if it doesn't exist (with appropriate schema)
# Uses UPSERT functionality (INSERT ... ON DUPLICATE KEY UPDATE) to handle both new records and updates
# Includes logging with timestamps
# Verifies the update was successful

# Usage Examples:

# With command line arguments:

# bashexport DB_USER="your_username"
# export DB_PASS="your_password"
# ./script.sh "192.168.1.100" "active" "enabled"

# With environment variables:

# bashexport DB_HOST="db.example.com"
# export DB_USER="your_username" 
# export DB_PASS="your_password"
# export DB_NAME="linuxsystems"
# ./script.sh "10.0.0.50" "inactive" "disabled"
# Database Schema:
# The script creates a table with these columns:

# ip_address (VARCHAR(45), PRIMARY KEY)
# aide (VARCHAR(50))
# fapolicyd (VARCHAR(50))
# last_updated (TIMESTAMP, auto-updated)

# Make the script executable with chmod +x script_name.sh before running it. The script will safely handle both inserting new records and updating existing ones based on the IP address.
