#!/usr/bin/env bash

# Day 18: Task 1 - Basic Functions
# Greet a user and add two numbers

# Function to greet a user by name
greet() {
    local name="$1"
    echo "Hello, ${name}!"
}

# Function to add two numbers and print the sum
add() {
    local num1="$1"
    local num2="$2"
    local sum=$((num1 + num2))
    echo "Sum: ${num1} + ${num2} = ${sum}"
}

echo "=== Shell Scripting: Basic Functions Demo ==="
# Calling functions
greet "Rajat"
greet "DevOps Engineer"

echo "----------------------------------------"
add 15 27
add 100 250
