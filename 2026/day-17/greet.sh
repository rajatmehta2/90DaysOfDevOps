#!/bin/bash

# ==============================================================================
# Script Name: greet.sh
# Description: Accepts a name as \$1 and prints "Hello, <name>!"
#              If no argument is passed, prints usage instructions.
# Task: Day 17 Task 3.1 - Command-Line Arguments
# ==============================================================================

# Check if the name argument is provided
if [ -z "$1" ]; then
    echo "Usage: ./greet.sh <name>"
    exit 1
fi

echo "Hello, $1! 👋"
