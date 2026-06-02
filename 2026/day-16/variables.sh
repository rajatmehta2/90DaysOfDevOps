#!/bin/bash

# ==============================================================================
# Script Name: variables.sh
# Description: Demonstrates Bash variables and single vs double quotes.
# Task: Day 16 Task 2 - Variables
# ==============================================================================

# 1. Define variables (No spaces around '=')
NAME="Rajat"
ROLE="DevOps Engineer"

# 2. Print greeting using double quotes (Allows variable interpolation)
echo "--- Double Quotes (Interpolation) ---"
echo "Hello, I am $NAME and I am a $ROLE"
echo ""

# 3. Print greeting using single quotes (Treats everything as literal string)
echo "--- Single Quotes (Literal Text) ---"
echo 'Hello, I am $NAME and I am a $ROLE'
echo ""

# 4. Brief summary of the difference
echo "--- Summary ---"
echo "Double quotes (\"\") allow variables to expand (interpolation) and process escape characters."
echo "Single quotes ('') preserve the literal value of each character, preventing expansion."
