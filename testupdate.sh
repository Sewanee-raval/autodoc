#!/bin/bash

# Standalone System Status Checker and Database Updater
# Performs comprehensive system security checks and uploads results to MariaDB
# Usage: ./system_status_checker.sh <ip_address>

# Set secure defaults
set -euo pipefail
IFS=$'\n\t'

# Global constants for status checking
readonly SYSTEMCTL_CMD="/usr/bin/systemctl"
readonly GETENFORCE_CMD="/usr/sbin/getenforce"
readonly OSCAP_CMD="/usr/bin/oscap"
readonly PROC_CRYPTO="/proc/sys/crypto/fips_enabled"
readonly AIDE_CONFIG="/etc/aide.conf"
readonly FAPOLICYD_CONFIG="/etc/fapolicyd/fapolicyd.conf"

# Database configuration - set via environment variables
readonly DB_HOST="${DB_HOST:-152.97.30.61}"
readonly DB_PORT="${DB_PORT:-3306}"
readonly DB_NAME="${DB_NAME:-linuxsystems}"
readonly DB_USER="${DB_USER:-linux}"
readonly DB_PASS="${DB_PASS:-testuser}"
readonly TABLE_NAME="statuses"

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_PREFIX="SYSTEM_STATUS"

# Function to display usage
usage() {
    cat << EOF
Usage: $SCRIPT_NAME <ip_address>

Performs comprehensive system security status checks and uploads results to MariaDB database.

Required Environment Variables:
  DB_USER     - Database username
  DB_PASS     - Database password

Optional Environment Variables:
  DB_HOST     - Database host (default: localhost)
  DB_PORT     - Database port (default: 3306)
  DB_NAME     - Database name (default: linuxsystems)

Example:
  export DB_USER="myuser"
  export DB_PASS="mypassword"
  $SCRIPT_NAME 192.168.1.100

Exit Codes:
  0 - Success
  1 - Invalid arguments or missing credentials
  2 - System status collection failed
  3 - Database connection failed
  4 - Database update failed

EOF
    exit 1
}

# Function to log messages with timestamp
log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_PREFIX] [$level] $message" >&2
}

# Function to safely execute commands with timeout and error handling
safe_execute() {
    local cmd="$1"
    local timeout_sec="${2:-10}"
    local output
    
    if ! command -v timeout >/dev/null 2>&1; then
        # Fallback if timeout command is not available
        if output=$(eval "$cmd" 2>/dev/null); then
            echo "$output"
            return 0
        else
            return 1
        fi
    else
        if output=$(timeout "$timeout_sec" bash -c "$cmd" 2>/dev/null); then
            echo "$output"
            return 0
        else
            return 1
        fi
    fi
}

# Function to check if a file exists and is readable
file_readable() {
    local file="$1"
    [[ -f "$file" && -r "$file" ]]
}

# Function to check if a command exists and is executable
command_exists() {
    local cmd="$1"
    [[ -x "$cmd" ]] || command -v "${cmd##*/}" >/dev/null 2>&1
}

# Function to validate input arguments
validate_arguments() {
    if [[ $# -ne 1 ]]; then
        log "ERROR" "Invalid number of arguments"
        usage
    fi
    
    local ip="$1"
    
    # Basic IP address validation
    if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log "ERROR" "Invalid IP address format: $ip"
        exit 1
    fi
    
    # Validate IP octets
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            log "ERROR" "Invalid IP address: $ip (octet $octet > 255)"
            exit 1
        fi
    done
    
    # Check database credentials
    if [[ -z "$DB_USER" ]] || [[ -z "$DB_PASS" ]]; then
        log "ERROR" "Database credentials not provided (DB_USER and DB_PASS required)"
        exit 1
    fi
    
    log "INFO" "Input validation successful for IP: $ip"
}

# Function to get system hostname
get_hostname_status() {
    local hostname_result
    
    log "DEBUG" "Checking hostname status"
    
    # Try multiple methods to get hostname
    if hostname_result=$(safe_execute "hostname -f" 5); then
        echo "${hostname_result}"
    elif hostname_result=$(safe_execute "hostname" 5); then
        echo "${hostname_result}"
    elif file_readable "/etc/hostname"; then
        if hostname_result=$(cat /etc/hostname 2>/dev/null | head -1 | tr -d '\n\r'); then
            echo "${hostname_result}"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to check AIDE status
get_aide_status() {
    local aide_status="unknown"
    
    log "DEBUG" "Checking AIDE status"
    
    # Check if AIDE is installed and configured
    if command_exists "aide" || file_readable "$AIDE_CONFIG"; then
        # Check if AIDE service is available
        if command_exists "$SYSTEMCTL_CMD"; then
            if safe_execute "$SYSTEMCTL_CMD is-enabled aide.timer" >/dev/null 2>&1; then
                if safe_execute "$SYSTEMCTL_CMD is-active aide.timer" >/dev/null 2>&1; then
                    aide_status="active"
                else
                    aide_status="inactive"
                fi
            elif safe_execute "$SYSTEMCTL_CMD is-enabled aide" >/dev/null 2>&1; then
                if safe_execute "$SYSTEMCTL_CMD is-active aide" >/dev/null 2>&1; then
                    aide_status="active"
                else
                    aide_status="inactive"
                fi
            else
                aide_status="disabled"
            fi
        else
            # Fallback for systems without systemctl
            aide_status="installed"
        fi
    else
        aide_status="not_installed"
    fi
    
    echo "$aide_status"
}

# Function to check fapolicyd status
get_fapolicyd_status() {
    local fapolicyd_status="unknown"
    
    log "DEBUG" "Checking fapolicyd status"
    
    if command_exists "$SYSTEMCTL_CMD"; then
        if safe_execute "$SYSTEMCTL_CMD is-enabled fapolicyd" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active fapolicyd" >/dev/null 2>&1; then
                fapolicyd_status="active"
            else
                fapolicyd_status="inactive"
            fi
        else
            # Check if fapolicyd is installed but not enabled
            if file_readable "$FAPOLICYD_CONFIG" || command_exists "fapolicyd"; then
                fapolicyd_status="disabled"
            else
                fapolicyd_status="not_installed"
            fi
        fi
    else
        fapolicyd_status="unknown"
    fi
    
    echo "$fapolicyd_status"
}

# Function to check SELinux status
get_selinux_status() {
    local selinux_status="unknown"
    
    log "DEBUG" "Checking SELinux status"
    
    if command_exists "$GETENFORCE_CMD"; then
        if selinux_status=$(safe_execute "$GETENFORCE_CMD" 5); then
            # Convert to lowercase and handle different possible outputs
            case "${selinux_status,,}" in
                enforcing) echo "enforcing" ;;
                permissive) echo "permissive" ;;
                disabled) echo "disabled" ;;
                *) echo "unknown" ;;
            esac
        else
            echo "unknown"
        fi
    elif file_readable "/sys/fs/selinux/enforce"; then
        local enforce_value
        if enforce_value=$(cat /sys/fs/selinux/enforce 2>/dev/null | head -1); then
            case "$enforce_value" in
                1) echo "enforcing" ;;
                0) echo "permissive" ;;
                *) echo "unknown" ;;
            esac
        else
            echo "unknown"
        fi
    else
        echo "disabled"
    fi
}

# Function to check OpenSCAP status
get_openscap_status() {
    local openscap_status="unknown"
    
    log "DEBUG" "Checking OpenSCAP status"
    
    if command_exists "$OSCAP_CMD" || command_exists "oscap"; then
        # Check if there are any recent SCAP results
        local scap_results_dirs=("/var/lib/oscap" "/var/log/oscap" "/tmp/oscap")
        local found_recent=false
        
        for dir in "${scap_results_dirs[@]}"; do
            if [[ -d "$dir" ]]; then
                # Look for files modified in the last 30 days
                if find "$dir" -name "*.xml" -o -name "*.html" -mtime -30 2>/dev/null | head -1 | grep -q .; then
                    found_recent=true
                    break
                fi
            fi
        done
        
        if $found_recent; then
            openscap_status="recent_scan"
        else
            openscap_status="installed"
        fi
    else
        openscap_status="not_installed"
    fi
    
    echo "$openscap_status"
}

# Function to check logwatch status
get_logwatch_status() {
    local logwatch_status="unknown"
    
    log "DEBUG" "Checking logwatch status"
    
    if command_exists "$SYSTEMCTL_CMD"; then
        # Check logwatch timer first (modern systems)
        if safe_execute "$SYSTEMCTL_CMD is-enabled logwatch.timer" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active logwatch.timer" >/dev/null 2>&1; then
                logwatch_status="active"
            else
                logwatch_status="inactive"
            fi
        # Check logwatch service
        elif safe_execute "$SYSTEMCTL_CMD is-enabled logwatch" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active logwatch" >/dev/null 2>&1; then
                logwatch_status="active"
            else
                logwatch_status="inactive"
            fi
        # Check if logwatch is installed but not as a service (cron-based)
        elif command_exists "logwatch" || file_readable "/etc/logwatch/conf/logwatch.conf"; then
            # Check if there's a cron entry for logwatch
            if crontab -l 2>/dev/null | grep -q logwatch || \
               find /etc/cron.* -name "*logwatch*" -type f 2>/dev/null | head -1 | grep -q .; then
                logwatch_status="cron_enabled"
            else
                logwatch_status="installed"
            fi
        else
            logwatch_status="not_installed"
        fi
    else
        logwatch_status="unknown"
    fi
    
    echo "$logwatch_status"
}

# Function to check fail2ban status
get_fail2ban_status() {
    local fail2ban_status="unknown"
    
    log "DEBUG" "Checking fail2ban status"
    
    if command_exists "$SYSTEMCTL_CMD"; then
        if safe_execute "$SYSTEMCTL_CMD is-enabled fail2ban" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active fail2ban" >/dev/null 2>&1; then
                fail2ban_status="active"
            else
                fail2ban_status="inactive"
            fi
        else
            # Check if fail2ban is installed but not enabled
            if command_exists "fail2ban-server" || file_readable "/etc/fail2ban/fail2ban.conf"; then
                fail2ban_status="disabled"
            else
                fail2ban_status="not_installed"
            fi
        fi
    else
        fail2ban_status="unknown"
    fi
    
    echo "$fail2ban_status"
}

# Function to check firewalld status
get_firewalld_status() {
    local firewalld_status="unknown"
    
    log "DEBUG" "Checking firewalld status"
    
    if command_exists "$SYSTEMCTL_CMD"; then
        if safe_execute "$SYSTEMCTL_CMD is-enabled firewalld" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active firewalld" >/dev/null 2>&1; then
                firewalld_status="active"
            else
                firewalld_status="inactive"
            fi
        else
            # Check if firewalld is installed but not enabled
            if command_exists "firewall-cmd" || file_readable "/etc/firewalld/firewalld.conf"; then
                firewalld_status="disabled"
            else
                firewalld_status="not_installed"
            fi
        fi
    else
        firewalld_status="unknown"
    fi
    
    echo "$firewalld_status"
}

# Function to check FIPS status
get_fips_status() {
    local fips_status="unknown"
    
    log "DEBUG" "Checking FIPS status"
    
    # Check /proc/sys/crypto/fips_enabled
    if file_readable "$PROC_CRYPTO"; then
        local fips_value
        if fips_value=$(cat "$PROC_CRYPTO" 2>/dev/null | head -1); then
            case "$fips_value" in
                1) fips_status="enabled" ;;
                0) fips_status="disabled" ;;
                *) fips_status="unknown" ;;
            esac
        else
            fips_status="unknown"
        fi
    # Fallback: check kernel command line
    elif file_readable "/proc/cmdline"; then
        if grep -q "fips=1" /proc/cmdline 2>/dev/null; then
            fips_status="enabled"
        else
            fips_status="disabled"
        fi
    else
        fips_status="unknown"
    fi
    
    echo "$fips_status"
}

# Function to check SSSD status
get_sssd_status() {
    local sssd_status="unknown"
    
    log "DEBUG" "Checking SSSD status"
    
    if command_exists "$SYSTEMCTL_CMD"; then
        if safe_execute "$SYSTEMCTL_CMD is-enabled sssd" >/dev/null 2>&1; then
            if safe_execute "$SYSTEMCTL_CMD is-active sssd" >/dev/null 2>&1; then
                sssd_status="active"
            else
                sssd_status="inactive"
            fi
        else
            # Check if sssd is installed but not enabled
            if command_exists "sssd" || file_readable "/etc/sssd/sssd.conf"; then
                sssd_status="disabled"
            else
                sssd_status="not_installed"
            fi
        fi
    else
        sssd_status="unknown"
    fi
    
    echo "$sssd_status"
}

# Function to collect all system status information
collect_system_status() {
    local target_ip="$1"
    
    log "INFO" "Starting system status collection for IP: $target_ip"
    
    # Collect all status information with error handling
    local hostname_status aide_status fapolicyd_status selinux_status openscap_status
    local logwatch_status fail2ban_status firewalld_status fips_status sssd_status
    
    hostname_status=$(get_hostname_status)
    aide_status=$(get_aide_status)
    fapolicyd_status=$(get_fapolicyd_status)
    selinux_status=$(get_selinux_status)
    openscap_status=$(get_openscap_status)
    logwatch_status=$(get_logwatch_status)
    fail2ban_status=$(get_fail2ban_status)
    firewalld_status=$(get_firewalld_status)
    fips_status=$(get_fips_status)
    sssd_status=$(get_sssd_status)
    
    # Log collected status
    log "INFO" "Status collection completed:"
    log "INFO" "  IP Address: $target_ip"
    log "INFO" "  Hostname: $hostname_status"
    log "INFO" "  AIDE: $aide_status"
    log "INFO" "  fapolicyd: $fapolicyd_status"
    log "INFO" "  SELinux: $selinux_status"
    log "INFO" "  OpenSCAP: $openscap_status"
    log "INFO" "  Logwatch: $logwatch_status"
    log "INFO" "  Fail2ban: $fail2ban_status"
    log "INFO" "  Firewalld: $firewalld_status"
    log "INFO" "  FIPS: $fips_status"
    log "INFO" "  SSSD: $sssd_status"
    
    # Return all values as a space-separated string
    echo "$target_ip|$hostname_status|$aide_status|$fapolicyd_status|$selinux_status|$openscap_status|$logwatch_status|$fail2ban_status|$firewalld_status|$fips_status|$sssd_status"
}

# Function to test database connection
test_database_connection() {
    log "INFO" "Testing database connection to $DB_HOST:$DB_PORT/$DB_NAME"
    
    if ! mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --execute="SELECT 1;" >/dev/null 2>&1; then
        log "ERROR" "Unable to connect to database"
        return 1
    fi
    
    log "INFO" "Database connection successful"
    return 0
}

# Function to create table if it doesn't exist
ensure_table_exists() {
    log "INFO" "Ensuring database table exists"
    
    local create_table_sql="
    CREATE TABLE IF NOT EXISTS $TABLE_NAME (
        ip_address VARCHAR(45) PRIMARY KEY,
        hostname VARCHAR(255) NOT NULL,
        aide VARCHAR(50) NOT NULL,
        fapolicyd VARCHAR(50) NOT NULL,
        selinux VARCHAR(50) NOT NULL,
        openscap VARCHAR(50) NOT NULL,
        logwatch VARCHAR(50) NOT NULL,
        fail2ban VARCHAR(50) NOT NULL,
        firewalld VARCHAR(50) NOT NULL,
        fips VARCHAR(50) NOT NULL,
        sssd VARCHAR(50) NOT NULL,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );"
    
    if ! mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --execute="$create_table_sql" 2>/dev/null; then
        log "ERROR" "Failed to create/verify table"
        return 1
    fi
    
    log "INFO" "Table verified/created successfully"
    return 0
}

# Function to update database with status information
update_database() {
    local status_data="$1"
    
    # Parse the status data
    IFS='|' read -r ip_addr hostname_val aide_val fapolicyd_val selinux_val openscap_val \
        logwatch_val fail2ban_val firewalld_val fips_val sssd_val <<< "$status_data"
    
    log "INFO" "Updating database for IP: $ip_addr"
    
    # Create a temporary SQL file
    local temp_sql
    temp_sql=$(mktemp)
    cleanup_temp() { rm -f "$temp_sql"; }
    trap cleanup_temp RETURN
    
    # Use MySQL variables to prevent SQL injection
    cat > "$temp_sql" << EOF
SET @ip = '$ip_addr';
SET @hostname = '$hostname_val';
SET @aide = '$aide_val';
SET @fapolicyd = '$fapolicyd_val';
SET @selinux = '$selinux_val';
SET @openscap = '$openscap_val';
SET @logwatch = '$logwatch_val';
SET @fail2ban = '$fail2ban_val';
SET @firewalld = '$firewalld_val';
SET @fips = '$fips_val';
SET @sssd = '$sssd_val';

INSERT INTO $TABLE_NAME (ip_address, hostname, aide, fapolicyd, selinux, openscap, logwatch, fail2ban, firewalld, fips, sssd)
VALUES (@ip, @hostname, @aide, @fapolicyd, @selinux, @openscap, @logwatch, @fail2ban, @firewalld, @fips, @sssd)
ON DUPLICATE KEY UPDATE
    hostname = VALUES(hostname),
    aide = VALUES(aide),
    fapolicyd = VALUES(fapolicyd),
    selinux = VALUES(selinux),
    openscap = VALUES(openscap),
    logwatch = VALUES(logwatch),
    fail2ban = VALUES(fail2ban),
    firewalld = VALUES(firewalld),
    fips = VALUES(fips),
    sssd = VALUES(sssd),
    last_updated = CURRENT_TIMESTAMP;
EOF
    
    if mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
            --database="$DB_NAME" < "$temp_sql" 2>/dev/null; then
        log "INFO" "Database update successful"
        
        # Verify the update
        local verify_sql="SELECT ip_address, hostname, aide, fapolicyd, selinux, openscap, logwatch, fail2ban, firewalld, fips, sssd, last_updated 
                         FROM $TABLE_NAME WHERE ip_address = '$ip_addr';"
        
        log "INFO" "Verifying database record:"
        mysql --host="$DB_HOST" --port="$DB_PORT" --user="$DB_USER" --password="$DB_PASS" \
              --database="$DB_NAME" --table --execute="$verify_sql" 2>/dev/null
        
        return 0
    else
        log "ERROR" "Database update failed"
        return 1
    fi
}

# Main execution function
main() {
    local target_ip="$1"
    local status_data
    
    log "INFO" "Starting system status checker for IP: $target_ip"
    
    # Validate input
    validate_arguments "$@"
    
    # Collect system status
    if ! status_data=$(collect_system_status "$target_ip"); then
        log "ERROR" "Failed to collect system status"
        exit 2
    fi
    
    # Test database connection
    if ! test_database_connection; then
        log "ERROR" "Database connection failed"
        exit 3
    fi
    
    # Ensure table exists
    if ! ensure_table_exists; then
        log "ERROR" "Failed to create/verify database table"
        exit 3
    fi
    
    # Update database
    if ! update_database "$status_data"; then
        log "ERROR" "Database update failed"
        exit 4
    fi
    
    log "INFO" "System status check and database update completed successfully"
    exit 0
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
