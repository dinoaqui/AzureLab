#!/bin/bash
# Script for use testing connect Azure Arc Endpoint - Hosts Linux
# You can find this endpoint by log in /var/opt/azcmagent/log

# List of Azure Arc endpoints to check
endpoints=(
    "management.azure.com" # Azure Resource Manager
    "login.microsoftonline.com" # Azure Active Directory
    "dc.services.visualstudio.com" # Application Insights
    # Add more endpoints as needed
    "aka.ms"
    "download.microsoft.com"
    "packages.microsoft.com"
    "login.windows.net"
    "login.microsoftonline.com"
    "pas.windows.net"
    "management.azure.com"
    "guestnotificationservice.azure.com"
)

# Port for connection test (443 is the default port for HTTPS)
port=443

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# Check each endpoint
for endpoint in "${endpoints[@]}"; do
    echo "Testing connection to: $endpoint:$port"
    # Attempt a TCP handshake using the nc command
    if nc -zw3 "$endpoint" $port; then
        echo -e "${GREEN}Successful connection to $endpoint${NO_COLOR}"
    else
        echo -e "${RED}Failed to connect to $endpoint${NO_COLOR}"
    fi
    echo # Adds a blank line for separation
done

echo "Connectivity test completed."
