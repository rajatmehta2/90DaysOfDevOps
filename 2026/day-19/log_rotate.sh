#!/usr/bin/env bash

# ==============================================================================
# Day 19 – Task 1: Log Rotation Script (log_rotate.sh)
#
# Description: Compresses *.log files older than 7 days using gzip, and deletes
#              *.gz files older than 30 days from a target directory.
#
# Safeties:    Runs under set -euo pipefail for maximum infrastructure protection.
#              Employs null-delimited streams (find -print0) to safely handle
#              filenames containing spaces or exotic characters.
# ==============================================================================

set -euo pipefail

# Print usage details
usage() {
    echo "Error: Missing argument." >&2
    echo "Usage: $0 <log_directory>" >&2
    exit 1
}

# Check if directory argument is provided
if [ $# -lt 1 ]; then
    usage
fi

LOG_DIR="$1"

# Verify target directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Target directory '${LOG_DIR}' does not exist." >&2
    exit 1
fi

echo "=========================================================================="
echo "🌀 LOG ROTATION ENGINE STARTING"
echo "Target Directory: ${LOG_DIR}"
echo "Timestamp:        $(date)"
echo "=========================================================================="

compressed_count=0
deleted_count=0

# 1. Compressing .log files older than 7 days
echo "Step 1: Compressing *.log files older than 7 days..."
while IFS= read -r -d '' log_file; do
    if [ -f "$log_file" ]; then
        echo "  [COMPRESS] Compressing: $(basename "$log_file")"
        gzip "$log_file"
        compressed_count=$((compressed_count + 1))
    fi
done < <(find "$LOG_DIR" -type f -name "*.log" -mtime +7 -print0)

# 2. Deleting .gz files older than 30 days
echo "Step 2: Pruning *.gz archives older than 30 days..."
while IFS= read -r -d '' gz_file; do
    if [ -f "$gz_file" ]; then
        echo "  [DELETE] Removing expired archive: $(basename "$gz_file")"
        rm "$gz_file"
        deleted_count=$((deleted_count + 1))
    fi
done < <(find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -print0)

echo "------------------------------------------------------------------------"
echo "📊 Rotation Summary:"
echo "  - Logs compressed:  ${compressed_count}"
echo "  - Archives deleted: ${deleted_count}"
echo "=========================================================================="
echo "✅ Log rotation sequence finished successfully."
