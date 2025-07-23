#!/usr/bin/env bash
#===================================================
# Script Name: secure_template.sh
# Description:
#   A secure, robust bash script template designed to:
#     - Support command-line arguments parsing (flags and options)
#     - Demonstrate secure programming practices (input validation, error handling)
#     - Include functions, conditional logic, and logging
#     - Use best practices for safe variable handling and external commands
#
# Usage:
#   ./secure_template.sh [-h|--help] [-v|--verbose] -i|--input <input_file> [-o|--output <output_file>]
#
# Command line arguments:
#   -h, --help       Show this help message and exit
#   -v, --verbose    Enable verbose mode (detailed logging)
#   -i, --input      Path to the input file (required, must exist and be readable)
#   -o, --output     Path to the output file (optional)
#
# Author: Your Name
# Date: YYYY-MM-DD
#===================================================

set -o errexit    # Exit on error
set -o nounset    # Treat unset variables as errors
set -o pipefail   # Capture failures within pipelines

#===================================================
# Global variables
VERBOSE=0
INPUT_FILE=""
OUTPUT_FILE=""

#===================================================
# Logging functions

log() {
  # Log normal info messages
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*"
}

log_verbose() {
  # Log only if VERBOSE enabled
  if [[ $VERBOSE -eq 1 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [VERBOSE] $*"
  fi
}

log_error() {
  # Log error messages to stderr
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >&2
}

#===================================================
# Usage/help function

usage() {
  cat <<EOF
Usage: $0 [-h|--help] [-v|--verbose] -i|--input <input_file> [-o|--output <output_file>]

Options:
  -h, --help       Show this help message and exit
  -v, --verbose    Enable verbose mode (detailed logging)
  -i, --input      Path to the input file (required, must exist and be readable)
  -o, --output     Path to the output file (optional)

Example:
  $0 --input /path/to/file.txt --output /path/to/out.txt --verbose
EOF
}

#===================================================
# Validate that input file exists and is readable

validate_input_file() {
  if [[ ! -f "$INPUT_FILE" ]]; then
    log_error "Input file '$INPUT_FILE' does not exist."
    exit 1
  fi
  if [[ ! -r "$INPUT_FILE" ]]; then
    log_error "Input file '$INPUT_FILE' is not readable."
    exit 1
  fi
  log_verbose "Input file '$INPUT_FILE' exists and is readable."
}

#===================================================
# Parse command-line arguments securely

parse_args() {
  # Temporary arrays to handle long options with getopt if available
  # Using builtin getopts does not support long options, so this uses a while case loop
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      -i|--input)
        if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
          INPUT_FILE="$2"
          shift 2
        else
          log_error "Argument for $1 is missing"
          exit 1
        fi
        ;;
      -o|--output)
        if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
          OUTPUT_FILE="$2"
          shift 2
        else
          log_error "Argument for $1 is missing"
          exit 1
        fi
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Input file is mandatory
  if [[ -z "$INPUT_FILE" ]]; then
    log_error "Input file is required."
    usage
    exit 1
  fi
}

#===================================================
# Main processing function

process_files() {
  log_verbose "Starting processing with input file: $INPUT_FILE"
  if [[ -n "$OUTPUT_FILE" ]]; then
    log_verbose "Output will be saved to: $OUTPUT_FILE"
  else
    log_verbose "No output file specified; default output (stdout) will be used."
  fi

  # Example processing: count number of lines in input file
  local line_count
  line_count=$(wc -l < "$INPUT_FILE") || {
    log_error "Failed to count lines in input file."
    exit 1
  }
  log_verbose "Line count in $INPUT_FILE is $line_count"

  # Output result
  if [[ -n "$OUTPUT_FILE" ]]; then
    echo "Input file: $INPUT_FILE" > "$OUTPUT_FILE"
    echo "Line count: $line_count" >> "$OUTPUT_FILE"
  else
    echo "Input file: $INPUT_FILE"
    echo "Line count: $line_count"
  fi

  log "Processing complete."
}

#===================================================
# Entry point

main() {
  parse_args "$@"
  validate_input_file
  process_files
}

main "$@"




# Explanation / Highlights:
# Strict Shell Options:

# set -o errexit to stop on any command error
# set -o nounset to error on unset vars
# set -o pipefail to fail if any command in pipe fails
# Argument Parsing:

# Handles both short and long options without using external tools
# Checks for missing option arguments and unknown options
# Input Validation:

# Explicit check that input file exists and is readable before proceeding
# Logging:

# Timestamped logs with different levels (INFO, VERBOSE, ERROR)
# Verbose mode enabled only if -v or --verbose used
# Safe variable usage:

# Quotes around variable expansions to avoid word splitting and globbing
# Function modularization:

# Clear separation of logic into function blocks (parse, validate, process)
# Usage info:

# Self-documenting usage message
# Use this template as a starting point for building secure, maintainable bash scripts with robust argument parsing and logging.