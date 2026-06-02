#!/usr/bin/env bash

# Day 18: Task 4 - Local Variables Demo
# Demonstrating variable scoping inside Bash functions (local vs global)

# A function that defines a standard (global) variable
global_scope_fn() {
    echo "[global_scope_fn] Setting GLO_VAR..."
    GLO_VAR="I was created inside global_scope_fn"
    echo "[global_scope_fn] GLO_VAR is: '${GLO_VAR}'"
}

# A function that defines a local variable using the 'local' keyword
local_scope_fn() {
    echo "[local_scope_fn] Setting LOC_VAR..."
    local LOC_VAR="I was created inside local_scope_fn with 'local'"
    echo "[local_scope_fn] LOC_VAR is: '${LOC_VAR}'"
}

main() {
    echo "=== Local vs Global Scoping in Bash Functions ==="
    
    # Ensure they are unset/empty at first
    unset GLO_VAR
    unset LOC_VAR
    
    echo "Before calling functions:"
    echo "  \$GLO_VAR value: '${GLO_VAR:-[NOT SET]}'"
    echo "  \$LOC_VAR value: '${LOC_VAR:-[NOT SET]}'"
    echo "----------------------------------------"
    
    # 1. Calling the global scope function
    global_scope_fn
    echo "After calling global_scope_fn:"
    echo "  \$GLO_VAR value: '${GLO_VAR:-[NOT SET]}'  <-- LEAKED!"
    echo "----------------------------------------"
    
    # 2. Calling the local scope function
    local_scope_fn
    echo "After calling local_scope_fn:"
    echo "  \$LOC_VAR value: '${LOC_VAR:-[NOT SET]}'  <-- SAFE! Scoped only to the function."
    echo "----------------------------------------"
}

main
