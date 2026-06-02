#!/bin/bash

# ==============================================================================
# Script Name: server_check.sh
# Description: Checks the status of a service (e.g., nginx, ssh).
#              Optimized for Linux systemd but features a cross-platform fallback.
# Task: Day 16 Task 5 - Combine It All
# ==============================================================================

# 1. Store service name in a variable
SERVICE_NAME="nginx"

echo "=== DevOps Service Status Dashboard ==="
echo "Target Service: ${SERVICE_NAME}"
echo ""

# 2. Ask the user for confirmation
read -p "Do you want to check the status of '${SERVICE_NAME}'? (y/n): " ANSWER

# Convert answer to lowercase using 'tr' for max compatibility (works on macOS and Linux)
ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')

# 3. Handle conditionals based on input
if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "yes" ]; then
    echo "Initiating service health audit for '${SERVICE_NAME}'..."
    echo ""
    
    # Check if systemctl utility is installed
    if command -v systemctl &> /dev/null; then
        # Run standard systemd command
        systemctl status "$SERVICE_NAME" --no-pager
        
        # Check systemctl's exit code
        if [ $? -eq 0 ]; then
            echo ""
            echo "Result: Service '${SERVICE_NAME}' is ACTIVE and RUNNING! 🟢"
        else
            echo ""
            echo "Result: Service '${SERVICE_NAME}' is INACTIVE or FAILED! 🔴"
        fi
    else
        # Graceful cross-platform simulation (useful for macOS or containers without systemd)
        echo "Note: 'systemctl' command not found on this machine."
        echo "Checking local process table as a fallback..."
        echo ""
        
        # Check if any process matches the service name
        if ps aux | grep -v grep | grep -q -i "$SERVICE_NAME"; then
            ps aux | grep -v grep | grep -i "$SERVICE_NAME" | head -n 3
            echo ""
            echo "Result: Active processes matching '${SERVICE_NAME}' were found! 🟢"
        else
            # Simulation placeholder for learning representation
            echo "Result: Service '${SERVICE_NAME}' is NOT running (no local processes found). 🔴"
        fi
    fi
elif [ "$ANSWER" = "n" ] || [ "$ANSWER" = "no" ]; then
    echo "Skipped. 🟡"
else
    echo "Error: Invalid selection '${ANSWER}'. Please enter 'y' or 'n'."
    exit 1
fi
