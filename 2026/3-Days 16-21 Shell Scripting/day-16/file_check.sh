#!/bin/bash

# ==============================================================================
# Script Name: file_check.sh
# Description: Prompts user for a filename and checks if it exists on disk.
# Task: Day 16 Task 4.2 - File Existence Check
# ==============================================================================

# Prompt user for a filename/path
read -p "Enter a filename or path to check: " FILE_PATH

# Check if input is empty
if [ -z "$FILE_PATH" ]; then
    echo "Error: No file path provided."
    exit 1
fi

# Check if the path exists AND is a regular file using -f operator
if [ -f "$FILE_PATH" ]; then
    echo "Success: File '${FILE_PATH}' exists and is a regular file. 📂"
    
    # Optional metadata: display file size
    FILE_SIZE=$(wc -c < "$FILE_PATH" | tr -d ' ')
    echo "File details: size is ${FILE_SIZE} bytes."
else
    # Check if it exists but is a directory instead
    if [ -d "$FILE_PATH" ]; then
        echo "Note: '${FILE_PATH}' exists but it is a DIRECTORY, not a regular file. 📁"
    else
        echo "Warning: File '${FILE_PATH}' does NOT exist. ❌"
    fi
fi
