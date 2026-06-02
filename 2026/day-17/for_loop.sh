#!/bin/bash

# ==============================================================================
# Script Name: for_loop.sh
# Description: Loops through a list of 5 fruits and prints each one.
# Task: Day 17 Task 1.1 - For Loop over List
# ==============================================================================

# Define a list of fruits
FRUITS=("Apple" "Banana" "Mango" "Orange" "Grapes")

echo "=== Iterating through Fruits List ==="
for fruit in "${FRUITS[@]}"; do
    echo "Fruit: $fruit 🍎"
done
