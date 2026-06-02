#!/bin/bash

# ==============================================================================
# Script Name: args_demo.sh
# Description: Prints total number of arguments (\$#), all arguments (\$@),
#              and the script name (\$0).
# Task: Day 17 Task 3.2 - Command-Line Argument Metadata
# ==============================================================================

echo "=== Argument Demonstration ==="
echo "Script Name (\$0)          : $0"
echo "Total Arguments (\$#)      : $#"
echo "All Arguments (\$@)        : $@"

# Loop through each argument to show them individually
echo ""
echo "Iterating through arguments:"
count=1
for arg in "$@"; do
    echo "  Argument $count: $arg"
    let count++
done
