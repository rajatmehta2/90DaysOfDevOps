#!/usr/bin/env bash

# Day 18: Task 2 - Functions with Return Values
# Checking disk space and system memory (with macOS fallback support)

# Function to check disk usage of /
check_disk() {
    echo "Disk Usage for root directory (/):"
    df -h /
    return $?
}

# Function to check free memory
check_memory() {
    echo "System Memory Usage:"
    if command -v free &> /dev/null; then
        # Linux standard
        free -h
    elif command -v vm_stat &> /dev/null; then
        # macOS Darwin fallback
        echo "[macOS Detected: Using vm_stat and sysctl for memory statistics]"
        
        # Get physical memory
        local phys_mem_bytes
        phys_mem_bytes=$(sysctl -n hw.memsize)
        local phys_mem_gb=$(( phys_mem_bytes / 1024 / 1024 / 1024 ))
        
        # Page size
        local page_size
        page_size=$(vm_stat | grep "page size of" | awk '{print $8}')
        
        # Free pages
        local free_pages
        free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        
        local free_mem_bytes=$(( free_pages * page_size ))
        local free_mem_mb=$(( free_mem_bytes / 1024 / 1024 ))
        
        echo "Total Physical Memory: ${phys_mem_gb} GB"
        echo "Approximate Free Memory: ${free_mem_mb} MB"
        vm_stat | head -n 5
    else
        echo "Error: Neither 'free' nor 'vm_stat' command is available."
        return 1
    fi
    return $?
}

main() {
    echo "=== Disk and Memory Diagnostics ==="
    check_disk
    local disk_status=$?
    
    echo "----------------------------------------"
    
    check_memory
    local mem_status=$?
    
    echo "----------------------------------------"
    echo "Diagnostics complete with exit codes: Disk Check [${disk_status}], Memory Check [${mem_status}]"
}

main
