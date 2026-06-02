#!/bin/bash

# ==============================================================================
# Script Name: countdown.sh
# Description: Takes a number from the user and counts down to 0 using a while loop.
# Task: Day 17 Task 2 - Countdown with While Loop
# ==============================================================================

# Prompt user for a starting number
read -p "Enter a number to start the countdown: " COUNT

# Validate that input is not empty
if [ -z "$COUNT" ]; then
    echo "Error: No starting number provided. Please enter a positive integer."
    exit 1
fi

# Validate that input is a valid positive integer
if [[ ! "$COUNT" =~ ^[0-9]+$ ]]; then
    echo "Error: '$COUNT' is not a valid positive integer."
    exit 1
fi

echo ""
echo "=== Initiating Countdown from $COUNT ==="
while [ "$COUNT" -ge 0 ]; do
    echo "T-minus: $COUNT"
    let COUNT--
    sleep 0.1 # Slight sleep delay for standard countdown pacing
done

echo "Done! 🎉"
