#!/bin/bash

#---------------------------------------------------
# Script: save_oscap_version.sh
# Purpose: Save the output of `oscap --version` into a MySQL database table `versions` in database `security`.
# Database: MySQL
# Table schema:
#   CREATE TABLE versions (
#       id INT AUTO_INCREMENT PRIMARY KEY,
#       version_text TEXT NOT NULL,
#       recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
#   );
# Requirements:
#   - MySQL client installed (mysql CLI)
#   - Proper MySQL user permissions to access DB and insert data
#   - Secure handling of passwords and input validation
#
# Usage:
#   ./save_oscap_version.sh
#
# Optional: Configure to run via cron for scheduled logging.
#---------------------------------------------------

set -o errexit  # Exit script on any error
set -o nounset  # Treat unset variables as errors
set -o pipefail # Catch errors in pipelines

# Configuration - set your MySQL credentials securely
# It is recommended to use a MySQL option file (~/.my.cnf) for credentials, e.g.:
# [client]
# user=your_user
# password=your_password
# host=localhost
# Or use environment variables securely.

DB_NAME="security"
TABLE_NAME="versions"
MYSQL_USER="your_mysql_user"
MYSQL_HOST="localhost"
MYSQL_PORT=3306

# Either read password from an environment variable or external file securely
# Example: export MYSQL_PWD='your_password'
# or configure ~/.my.cnf instead of passing password in CLI for security.
if [[ -z "${MYSQL_PWD:-}" ]]; then
  echo "Error: MYSQL_PWD environment variable is not set. Exiting."
  exit 1
fi

# Function to check if the versions table exists; create it if it doesn't
function create_table_if_missing() {
  local table_exists
  table_exists=$(mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -D "$DB_NAME" -sse \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name = '$TABLE_NAME';")

  if [[ "$table_exists" -eq 0 ]]; then
    echo "Table '$TABLE_NAME' does not exist; creating..."
    mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -D "$DB_NAME" <<SQL
CREATE TABLE $TABLE_NAME (
  id INT AUTO_INCREMENT PRIMARY KEY,
  version_text TEXT NOT NULL,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SQL
    echo "Table created."
  else
    echo "Table '$TABLE_NAME' exists."
  fi
}

# Function to safely escape input for MySQL insertion
function mysql_escape() {
  local raw="$1"
  # Escape single quotes and backslashes for SQL safely
  raw="${raw//\\/\\\\}"  # backslash to double backslash
  raw="${raw//\'/\\\'}"  # single quote to escaped single quote
  echo "$raw"
}

# Main execution starts here

# Fetch `oscap --version` output, capture stderr if any
version_output=$(oscap --version 2>&1) || {
  echo "Error: Failed to run 'oscap --version'." >&2
  exit 1
}

# Escape output for safe MySQL insertion
escaped_version_output=$(mysql_escape "$version_output")

# Check and create table if missing
create_table_if_missing

# Insert the version output into the table
insert_query="INSERT INTO $TABLE_NAME (version_text) VALUES ('$escaped_version_output');"

mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" -P"$MYSQL_PORT" -D "$DB_NAME" -e "$insert_query"

echo "oscap version successfully saved to database '$DB_NAME', table '$TABLE_NAME'."#!/usr/bin/env bash

# Exit script successfully