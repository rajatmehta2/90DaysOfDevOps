#!/usr/bin/env bash

# Day 18: Task 5 - System Info Reporter
# A comprehensive system diagnostic script with cross-platform (Linux & macOS) support
# Built with functions and protected by strict mode (set -euo pipefail)
# Uses awk to safely limit output rows without triggering SIGPIPE errors (Exit Code 141) under pipefail.

# Use strict mode
set -euo pipefail

# 1. Function to print hostname and OS info
print_os_info() {
    echo "=== Hostname & Operating System Info ==="
    echo "Hostname: $(hostname)"
    if [ -f /etc/os-release ]; then
        # Linux standard OS release info
        grep -E '^(NAME|VERSION)=' /etc/os-release | sed 's/"//g'
    elif command -v sw_vers &> /dev/null; then
        # macOS OS info
        sw_vers
    else
        echo "OS: $(uname -s) ($(uname -r))"
    fi
}

# 2. Function to print uptime
print_uptime() {
    echo "=== System Uptime ==="
    uptime
}

# 3. Function to print disk usage (top 5 by size)
print_disk_usage() {
    echo "=== Disk Usage (Top 5 Filesystems by Size) ==="
    # Display the df header first
    df -h | awk 'NR==1'
    # Sort filesystems by size in descending order (using numerical sort for size/capacity column)
    # We skip the header line using tail -n +2 and use awk instead of head to prevent SIGPIPE/141 error
    df -h | tail -n +2 | sort -rh -k 2 | awk 'NR<=5'
}

# 4. Function to print memory usage
print_memory_usage() {
    echo "=== Memory Usage ==="
    if command -v free &> /dev/null; then
        free -h
    elif [ "$(uname)" = "Darwin" ]; then
        # macOS specific memory retrieval
        top -l 1 | grep PhysMem
    else
        echo "Memory metrics: Not available (missing 'free' command)"
    fi
}

# 5. Function to print top 5 CPU-consuming processes
print_top_processes() {
    echo "=== Top 5 CPU-Consuming Processes ==="
    if [ "$(uname)" = "Darwin" ]; then
        # macOS ps sorting by CPU (-r flag) - use awk instead of head to avoid SIGPIPE
        ps -eo pid,ppid,pcpu,pmem,comm -r | awk 'NR<=6'
    else
        # Linux ps sorting by %cpu - use awk instead of head to avoid SIGPIPE
        ps -eo pid,ppid,%cpu,%mem,comm --sort=-%cpu | awk 'NR<=6'
    fi
}

# 6. Main function that calls all helper functions
main() {
    echo "=========================================================================="
    echo "                      SYSTEM PERFORMANCE REPORT                           "
    echo "              Generated on: $(date)"
    echo "=========================================================================="
    echo
    
    print_os_info
    echo
    
    print_uptime
    echo
    
    print_disk_usage
    echo
    
    print_memory_usage
    echo
    
    print_top_processes
    echo
    echo "=========================================================================="
}

# Execute main
main
