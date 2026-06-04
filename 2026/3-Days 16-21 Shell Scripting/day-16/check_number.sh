#!/bin/bash

# ==============================================================================
# Script Name: check_number.sh
# Description: Prompts user for a number and checks if it's positive, negative, or zero.
# Task: Day 16 Task 4.1 - If-Else Conditions
# ==============================================================================

# Prompt user for a number
read -p "Enter a number to analyze: " NUMBER

# Check if input is empty
if [ -z "$NUMBER" ]; then
    echo "Error: No input provided. Please enter a valid number."
    exit 1
fi

# Validate if input is a valid integer (positive, negative, or zero)
# Using regular expression validation
if [[ ! "$NUMBER" =~ ^-?[0-9]+$ ]]; then
    echo "Error: '$NUMBER' is not a valid integer. Please enter integers only."
    exit 1
fi

# Compare the number using arithmetic conditions (-gt, -lt, -eq)
if [ "$NUMBER" -gt 0 ]; then
    echo "The number ${NUMBER} is POSITIVE. 🟢"
elif [ "$NUMBER" -lt 0 ]; then
    echo "The number ${NUMBER} is NEGATIVE. 🔴"
else
    echo "The number is ZERO. ⚪"
fi
