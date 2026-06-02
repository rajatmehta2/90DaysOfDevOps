#!/bin/bash

# ==============================================================================
# Script Name: greet.sh
# Description: Prompts user for name and favourite tool, then prints a greeting.
# Task: Day 16 Task 3 - User Input with read
# ==============================================================================

# Prompt user for their name (-p specifies a prompt string)
read -p "Enter your name: " USER_NAME

# Prompt user for their favourite DevOps tool
read -p "Enter your favourite DevOps tool: " FAV_TOOL

# Print the result
echo ""
echo "Hello ${USER_NAME}, your favourite tool is ${FAV_TOOL}!"
