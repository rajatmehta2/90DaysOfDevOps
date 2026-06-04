#!/bin/bash

# ==============================================================================
# Script Name: safe_script.sh
# Description: Uses 'set -e' for exit-on-error behavior. Attempts to create and
#              navigate into /tmp/devops-test, create a file, and handle errors.
# Task: Day 17 Task 5.1 - Error Handling & Shell Safeguards
# ==============================================================================

# Exit immediately if any command exits with a non-zero status
set -e

echo "=== Running Safe Script ==="
echo "Enabling 'set -e' safeguard."

# Define target test directory and file
TEST_DIR="/tmp/devops-test"
TEST_FILE="devops-log.txt"

# Attempt to create the directory. If it already exists, mkdir returns status 1.
# Under set -e, this would crash the script. Using '||' prevents the crash because
# the exit status of the overall OR expression is 0 (the echo succeeds).
echo "Creating directory: $TEST_DIR"
mkdir "$TEST_DIR" 2>/dev/null || echo "Directory already exists (handled gracefully via '||')."

echo "Navigating to directory: $TEST_DIR"
cd "$TEST_DIR" || { echo "Error: Failed to enter directory $TEST_DIR"; exit 1; }

echo "Creating test file: $TEST_FILE"
echo "Day 17 - DevOps Automation Check: Success!" > "$TEST_FILE"

echo ""
echo "Listing directory contents:"
ls -la "$TEST_FILE"

echo ""
echo "Safe script execution completed successfully! 🟢"
