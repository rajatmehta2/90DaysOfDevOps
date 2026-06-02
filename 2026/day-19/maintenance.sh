#!/usr/bin/env bash

# ==============================================================================
# Day 19 – Task 4: Scheduled Maintenance Script (maintenance.sh)
#
# Description: Orchestrates system maintenance by running the log rotation script
#              and server backup script. Captures all outputs and logs them with
#              individual timestamps.
#
# Safeties:    Runs under set -euo pipefail. Checks script permissions and path
#              existence dynamically. Autodetects log file writability, falling
#              back gracefully to the local workspace if /var/log is locked.
# ==============================================================================

set -euo pipefail

# 1. Paths and Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_ROTATE_SCRIPT="${SCRIPT_DIR}/log_rotate.sh"
BACKUP_SCRIPT="${SCRIPT_DIR}/backup.sh"

# Default Log File
DEFAULT_LOG="/var/log/maintenance.log"
MAINTENANCE_LOG=""

# Autodetect log file writability
if touch "$DEFAULT_LOG" &>/dev/null; then
    MAINTENANCE_LOG="$DEFAULT_LOG"
else
    # Fallback to local directory if root permissions are missing
    MAINTENANCE_LOG="${SCRIPT_DIR}/maintenance.log"
fi

# Ensure executable permissions on helper scripts
chmod +x "$LOG_ROTATE_SCRIPT" "$BACKUP_SCRIPT"

# 2. Logging Orchestrator
# Helper function to format logs with timestamps
log_format() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message"
}

# Redirect all stdout & stderr of a block to the log file AND stdout (using tee)
# with prepended timestamps for every line of execution.
log_tee() {
    while IFS= read -r line; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') | $line" | tee -a "$MAINTENANCE_LOG"
    done
}

# 3. Execution Block
run_maintenance() {
    echo "=========================================================================="
    echo "⚙️  SYSTEM MAINTENANCE RUNNER"
    echo "Started at: $(date)"
    echo "=========================================================================="
    echo

    # Accept directories as arguments, or default to mock sandbox for demonstration
    local log_dir="${1:-${SCRIPT_DIR}/mock_environment/logs}"
    local src_dir="${2:-${SCRIPT_DIR}/mock_environment/source}"
    local dest_dir="${3:-${SCRIPT_DIR}/mock_environment/backups}"

    # Verify and run Log Rotation
    echo "[STEP 1/2] Invoking Log Rotation Script..."
    if [ -f "$LOG_ROTATE_SCRIPT" ]; then
        "$LOG_ROTATE_SCRIPT" "$log_dir"
    else
        echo "Error: Log rotation script not found at ${LOG_ROTATE_SCRIPT}" >&2
        exit 1
    fi
    echo

    # Verify and run Server Backup
    echo "[STEP 2/2] Invoking Server Backup Script..."
    if [ -f "$BACKUP_SCRIPT" ]; then
        "$BACKUP_SCRIPT" "$src_dir" "$dest_dir"
    else
        echo "Error: Backup script not found at ${BACKUP_SCRIPT}" >&2
        exit 1
    fi
    echo

    echo "=========================================================================="
    echo "✅ MAINTENANCE SEQUENCE COMPLETED SUCCESSFULLY"
    echo "Log file persisted: ${MAINTENANCE_LOG}"
    echo "Finished at: $(date)"
    echo "=========================================================================="
}

# Execute maintenance orchestration block through the logging stream
run_maintenance "$@" 2>&1 | log_tee
