#!/usr/bin/env bash

# Day 18: Task 3 - Strict Mode Demo (set -euo pipefail)
# Demonstrating the behavior of strict mode using subshells so we can see all failures in one run.

demo_set_u() {
    echo "--- [set -u] Undefined Variable Demo ---"
    (
        # Enable set -u to treat unset variables as an error
        set -u
        echo "Attempting to reference an undefined variable \$UNSET_VAR..."
        echo "Value: $UNSET_VAR"
        echo "This line will NOT be executed."
    )
    echo "Subshell exited with status: $? (Indicates failure)"
}

demo_set_e() {
    echo "--- [set -e] Fail Immediately Demo ---"
    (
        # Enable set -e to exit immediately if a command exits with a non-zero status
        set -e
        echo "Executing a command that fails (non-existent command)..."
        non_existent_command
        echo "This line will NOT be executed."
    )
    echo "Subshell exited with status: $? (Indicates failure)"
}

demo_pipefail() {
    echo "--- [set -o pipefail] Piped Command Demo ---"
    
    echo "1. WITHOUT pipefail (Standard Bash behavior):"
    (
        set -e
        # The non-existent command fails, but since the last command in the pipe (grep) succeeds/passes, 
        # the overall pipeline exit code is 0 (success).
        non_existent_command | echo "Piping to echo (which succeeds)"
        echo "Pipeline finished! This line IS executed because the pipe exit code was 0."
    )
    echo "Subshell exited with status: $?"
    
    echo "2. WITH pipefail enabled:"
    (
        set -eo pipefail
        # Now, if any command in the pipeline fails, the entire pipeline fails with that exit status.
        non_existent_command | echo "Piping to echo (which succeeds)"
        echo "This line will NOT be executed because the pipeline failed."
    )
    echo "Subshell exited with status: $? (Indicates failure)"
}

main() {
    echo "=== Strict Mode (set -euo pipefail) Live Demonstration ==="
    echo
    demo_set_u
    echo
    demo_set_e
    echo
    demo_pipefail
    echo
    echo "=========================================================="
    echo "Summary of Strict Mode Flags:"
    echo "  -e (errexit): Abort script at first command failure (non-zero exit code)."
    echo "  -u (nounset): Treat references to unset/undefined variables as errors and exit."
    echo "  -o pipefail: Pipeline's return status is the status of the last command to exit with non-zero."
    echo "=========================================================="
}

main
