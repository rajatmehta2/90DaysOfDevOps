#!/usr/bin/env bash

# ==============================================================================
# Day 19 – Task 2: Server Backup Script (backup.sh)
#
# Description: Archives a source directory into a compressed .tar.gz file in a
#              destination directory, verifies the archive, and prunes old
#              backups older than 14 days.
#
# Safeties:    Runs under set -euo pipefail. Validates directories and verifies
#              archive creation integrity explicitly.
# ==============================================================================

set -euo pipefail

# Print usage instructions
usage() {
    echo "Error: Missing arguments." >&2
    echo "Usage: $0 <source_directory> <backup_destination>" >&2
    exit 1
}

# Check if correct arguments are provided
if [ $# -lt 2 ]; then
    usage
fi

SRC_DIR="$1"
DEST_DIR="$2"

# Verify source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory '${SRC_DIR}' does not exist." >&2
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Info: Creating backup destination directory: ${DEST_DIR}"
    mkdir -p "$DEST_DIR"
fi

echo "=========================================================================="
echo "🛡️ SERVER BACKUP ENGINE STARTING"
echo "Source Directory:      ${SRC_DIR}"
echo "Destination Directory: ${DEST_DIR}"
echo "Timestamp:             $(date)"
echo "=========================================================================="

# Create unique timestamped backup filename
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
BACKUP_PATH="${DEST_DIR}/${BACKUP_FILENAME}"

echo "Step 1: Compressing and archiving source directory..."
# Run tar:
# -c: create a new archive
# -z: compress archive using gzip
# -f: use archive file
# Note: To avoid absolute path warnings from tar, we can change directory or use standard tar flags.
# We change directory to the parent of the source directory, then archive the basename.
SRC_PARENT=$(dirname "$SRC_DIR")
SRC_BASE=$(basename "$SRC_DIR")

# We run tar in a subshell or pushd/popd to maintain current working directory context.
(
    cd "$SRC_PARENT"
    tar -czf "$BACKUP_PATH" "$SRC_BASE"
)

# Step 2: Verification
echo "Step 2: Verifying backup archive integrity..."
if [ -f "$BACKUP_PATH" ] && [ -s "$BACKUP_PATH" ]; then
    # Extract size and print success
    FILE_SIZE=$(du -sh "$BACKUP_PATH" | awk '{print $1}')
    echo "  [SUCCESS] Backup file created successfully!"
    echo "  [ARCHIVE] Filename: ${BACKUP_FILENAME}"
    echo "  [SIZE]    Size:     ${FILE_SIZE}"
else
    echo "  [ERROR] Backup archive creation failed or file is empty!" >&2
    exit 1
fi

# Step 3: Deleting backups older than 14 days
echo "Step 3: Pruning backups older than 14 days..."
pruned_count=0
while IFS= read -r -d '' old_backup; do
    if [ -f "$old_backup" ]; then
        echo "  [PRUNE] Removing expired backup: $(basename "$old_backup")"
        rm "$old_backup"
        pruned_count=$((pruned_count + 1))
    fi
done < <(find "$DEST_DIR" -type f -name "backup-*.tar.gz" -mtime +14 -print0)

echo "------------------------------------------------------------------------"
echo "📊 Backup Summary:"
echo "  - Backup Status:   Success"
echo "  - Archive Name:    ${BACKUP_FILENAME}"
echo "  - Archive Size:    ${FILE_SIZE}"
echo "  - Backups Pruned:  ${pruned_count}"
echo "=========================================================================="
echo "✅ Server backup sequence finished successfully."
