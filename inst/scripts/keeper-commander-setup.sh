#!/usr/bin/env bash

# Keeper Commander Device Setup Script
#
# This script will install the Keeper Commander CLI and set up a new device for
# use with the CLI.

# Set up the environment
set -e

KEEPER_CONFIG_FILE="{{ config_file }}"

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo "curl is required to run this script."
    exit 1
fi

# Check for required environment variables
if [ -z "$KEEPER_REST_SERVER" ]; then
    echo "The KEEPER_REST_SERVER environment variable is required."
    exit 1
fi
