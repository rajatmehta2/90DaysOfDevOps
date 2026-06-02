#!/bin/bash

# ==============================================================================
# Script Name: install_packages.sh
# Description: Defines a list of packages: nginx, curl, wget, checks if they
#              are installed and installs them if missing. Must run as root.
# Task: Day 17 Task 4 & Task 5.2 - Package Installer with Privilege Escalation
# ==============================================================================

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root. Please run with sudo (e.g., sudo ./install_packages.sh)"
    exit 1
fi

# Define list of packages
PACKAGES=("nginx" "curl" "wget")

echo "=== DevOps Package Installer ==="
echo "Checking packages: ${PACKAGES[*]}"
echo ""

# Detect OS type
OS_TYPE=$(uname -s)

for pkg in "${PACKAGES[@]}"; do
    echo -n "Checking package '$pkg'... "
    
    # Check installation status
    is_installed=0
    
    if [ "$OS_TYPE" = "Darwin" ]; then
        # macOS fallback simulation since brew is not run as root
        # Check if command exists in system path
        if command -v "$pkg" &> /dev/null; then
            is_installed=1
        fi
    else
        # Linux standard checking
        if command -v dpkg &> /dev/null; then
            if dpkg -s "$pkg" &> /dev/null; then
                is_installed=1
            fi
        elif command -v rpm &> /dev/null; then
            if rpm -q "$pkg" &> /dev/null; then
                is_installed=1
            fi
        else
            # Generic binary existence check
            if command -v "$pkg" &> /dev/null; then
                is_installed=1
            fi
        fi
    fi

    if [ $is_installed -eq 1 ]; then
        echo "ALREADY INSTALLED. Skipping. 🟢"
    else
        echo "MISSING. 🔴"
        echo "Installing '$pkg'..."
        
        # Installation routines
        if [ "$OS_TYPE" = "Darwin" ]; then
            # macOS simulation because Homebrew prohibits sudo usage
            echo "[SIMULATION] Executing macOS Homebrew mock installation: brew install $pkg"
            sleep 0.5
            echo "Successfully installed '$pkg' (Simulated macOS package install)! 🟢"
        else
            # Linux real installation
            if command -v apt-get &> /dev/null; then
                apt-get update -y &> /dev/null
                apt-get install -y "$pkg" &> /dev/null
            elif command -v yum &> /dev/null; then
                yum install -y "$pkg" &> /dev/null
            elif command -v dnf &> /dev/null; then
                dnf install -y "$pkg" &> /dev/null
            else
                echo "Error: Package manager not detected. Failed to install."
                exit 1
            fi
            
            # Verify exit status of installation
            if [ $? -eq 0 ]; then
                echo "Successfully installed '$pkg'! 🟢"
            else
                echo "Failed to install '$pkg'. ❌"
                exit 1
            fi
        fi
    fi
    echo "----------------------------------------"
done

echo "Package verification audit complete."
