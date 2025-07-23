#!/bin/bash

#===============================================================================
# Script Name: secure_template.sh
# Description:
#   A secure and robust Bash script template with:
#     - Command-line argument parsing (getopts)
#     - Built-in versioning
#     - Error handling and input validation
#     - Logging and debugging support
#     - Secure programming practices (set options, safe variable usage)
#
# Usage:
#   ./secure_template.sh [-v version] [-h] [-d] [-o output_file] [--] [extra_args...]
#
# Options:
#   -v VERSION   Specify version number or show script version
#   -h           Show this help message and exit
#   -d           Enable debug mode (verbose output)
#   -o FILE      Specify output file (example usage)
#
# Positional arguments (after --):
#   Extra arguments passed through for custom handling
#
# Author: Your Name
# Date: YYYY-MM-DD
# Version: 1.0.0
#===============================================================================

set -o errexit      # Exit immediately if a command exits with a non-zero status
set -o nounset      # Treat unset variables as an error
set -o pipefail     # Detect errors in pipelines

#----------------------------------------
# Script metadata and versioning
#----------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"

#----------------------------------------
# Globals and defaults
#----------------------------------------
DEBUG=0
OUTPUT_FILE=""
EXTRA_ARGS=()

#----------------------------------------
# Logging helper functions
#----------------------------------------
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

debug() {
  if [[ $DEBUG -eq 1 ]]; then
    log "[DEBUG] $*"
  fi
}

error_exit() {
  echo "ERROR: $*" >&2
  exit 1
}

show_help() {
    cat <<EOF
$SCRIPT_NAME - Version $SCRIPT_VERSION

Usage: $SCRIPT_NAME [options] [-- extra_args]

Options:
  -v VERSION   Show version or specify a version argument
  -h           Show this help message and exit
  -d           Enable debug mode (verbose output)
  -o FILE      Specify output file (example argument)
  
Examples:
  $ $SCRIPT_NAME -d -o output.txt -- arg1 arg2
EOF
}

#----------------------------------------
# Command line parsing
#----------------------------------------
parse_args() {
  while getopts ":v:hdo:" opt; do
    case "$opt" in
      v)
        # Show version or handle version parameter
        if [[ "$OPTARG" == "show" ]]; then
          echo "$SCRIPT_NAME version $SCRIPT_VERSION"
          exit 0
        else
          version_arg="$OPTARG"
          debug "Version argument set to: $version_arg"
        fi
        ;;
      h)
        show_help
        exit 0
        ;;
      d)
        DEBUG=1
        ;;
      o)
        OUTPUT_FILE="$OPTARG"
        ;;
      \?)
        error_exit "Invalid option: -$OPTARG"
        ;;
      :)
        error_exit "Option -$OPTARG requires an argument."
        ;;
    esac
  done
  shift $((OPTIND -1))

  # Collect positional parameters after -- or remaining arguments
  while (( "$#" )); do
    EXTRA_ARGS+=("$1")
    shift
  done
  debug "Extra args: ${EXTRA_ARGS[*]:-None}"
}

#----------------------------------------
# Validate inputs or environment
#----------------------------------------
validate_inputs() {
  if [[ -n "$OUTPUT_FILE" ]]; then
    # Example validation: Check if output file path is writable or can be created
    touch "$OUTPUT_FILE" 2>/dev/null || error_exit "Cannot write to specified output file: $OUTPUT_FILE"
  fi
}

#----------------------------------------
# Main functionality placeholder
#----------------------------------------
main() {
  log "Starting $SCRIPT_NAME version $SCRIPT_VERSION"
  debug "Debug mode enabled"
  
  # Example main logic using passed arguments
  if [[ -n "$OUTPUT_FILE" ]]; then
    log "Would process output to file: $OUTPUT_FILE"
  else
    log "No output file specified."
  fi

  if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
    log "Processing extra arguments: ${EXTRA_ARGS[*]}"
  else
    log "No extra arguments provided."
  fi

  # Insert core script logic here, using secure coding practices:
  # - Quote variables
  # - Validate inputs
  # - Use functions for modularity
  # - Handle errors properly
}

#----------------------------------------
# Script entry point
#----------------------------------------
parse_args "$@"
validate_inputs
main

# Notes on Secure Programming Techniques used in this template:
# set -o errexit -o nounset -o pipefail stops script on errors, unset variables, and pipeline failures.
# readonly variables for constants to prevent accidental modification.
# Logging functions to centralize output messaging.
# Input validation example for output file writability.
# Command line argument parsing with getopts with error handling.
# Quoting all variable expansions to prevent word splitting and globbing.
# Modular functions like parse_args, validate_inputs, and main improve readability and maintainability.
# Debug mode toggle makes it easier to diagnose issues without changing the script code.
# Help screen for user guidance and version display.
# You can extend this template for specific tasks like file processing, system interaction, or database operations by adding appropriate functions inside main or additional helper functions.