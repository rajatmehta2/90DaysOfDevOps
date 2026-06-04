#!/usr/bin/env bash

# ==============================================================================
# Day 20 – Bash Scripting Challenge: Log Analyzer and Report Generator
#
# Description: Automates the process of analyzing log files, extracting critical
#              events, identifying top error messages, generating a daily
#              summary report, and optionally archiving the processed logs.
#
# Safeties:    Runs under set -euo pipefail for absolute error safety.
#              Ensures non-zero grep matches do not trigger premature script exits.
# ==============================================================================

set -euo pipefail

# Define Colors for Beautiful Console Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Helper function to print headers
print_header() {
    echo -e "${BLUE}${BOLD}==========================================================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${BLUE}${BOLD}==========================================================================${NC}"
}

# Print usage instructions
usage() {
    echo -e "${RED}${BOLD}Error: Missing or incorrect arguments.${NC}" >&2
    echo -e "Usage: $0 <path_to_log_file> [archive_flag]" >&2
    echo -e "  - <path_to_log_file> : Absolute or relative path to the log file to analyze" >&2
    echo -e "  - [archive_flag]      : (Optional) Set to 'archive' to automatically archive the log file after processing" >&2
    exit 1
}

# Task 1: Input and Validation
if [ $# -lt 1 ]; then
    usage
fi

LOG_FILE="$1"
ARCHIVE_OPTION="${2:-""}"

# Verify log file exists and is a regular file
if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}${BOLD}Error: Log file '${LOG_FILE}' does not exist or is not a regular file.${NC}" >&2
    exit 1
fi

# Verify log file is readable and not empty
if [ ! -r "$LOG_FILE" ]; then
    echo -e "${RED}${BOLD}Error: Log file '${LOG_FILE}' is not readable due to permission settings.${NC}" >&2
    exit 1
fi

if [ ! -s "$LOG_FILE" ]; then
    echo -e "${YELLOW}${BOLD}Warning: Log file '${LOG_FILE}' is empty. Generating empty report.${NC}"
fi

# Determine core details for reporting
LOG_FILENAME=$(basename "$LOG_FILE")
ANALYSIS_DATE=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="log_report_${ANALYSIS_DATE}.txt"

print_header "📊 LOG ANALYZER ENGINE STARTED"
echo -e "${BOLD}Log File Path:${NC}  ${LOG_FILE}"
echo -e "${BOLD}Log File Name:${NC}  ${LOG_FILENAME}"
echo -e "${BOLD}Analysis Date:${NC}  ${ANALYSIS_DATE}"
echo -e "${BOLD}Target Report:${NC}  ${REPORT_FILE}"
echo

# Task 2: Error Count
# Count lines containing case-sensitive keyword "ERROR" or "Failed"
# Using grep -E with || true so that an exit code of 1 (no lines found) doesn't abort the script.
TOTAL_ERRORS=$(grep -E -c "ERROR|Failed" "$LOG_FILE" || true)

# Task 3: Critical Events (Find lines containing "CRITICAL")
# Capture them into an array or variable safely
CRITICAL_EVENTS=""
CRITICAL_COUNT=0
while IFS= read -r line; do
    if [ -n "$line" ]; then
        CRITICAL_EVENTS+="${line}\n"
        CRITICAL_COUNT=$((CRITICAL_COUNT + 1))
    fi
done < <(grep -n "CRITICAL" "$LOG_FILE" | sed -E 's/^([0-9]+):(.*)/Line \1: \2/' || true)

# Task 4: Top 5 Error Messages
# We extract lines with "ERROR" and count occurrences of the message part.
# To make it robust and friendly with the sample log generator (which adds " - <random_number>"),
# we'll strip the timestamp/level prefix and the random number suffix if they match the pattern.
TOP_ERRORS=""
if [ -s "$LOG_FILE" ]; then
    TOP_ERRORS=$(grep "ERROR" "$LOG_FILE" | \
                 sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} \[ERROR\] //; s/ - [0-9]+$//' | \
                 sort | uniq -c | sort -rn | head -5 || true)
fi

# Calculate total lines processed
TOTAL_LINES=$(wc -l < "$LOG_FILE" | tr -d ' ')

# ------------------------------------------------------------------------------
# Print Results to Console
# ------------------------------------------------------------------------------
echo -e "${GREEN}${BOLD}--- Analysis Results ---${NC}"
echo -e "${BOLD}Total Lines Processed:${NC} ${TOTAL_LINES}"
echo -e "${BOLD}Total Error Count:${NC}     ${TOTAL_ERRORS}"
echo

# Print Critical Events
echo -e "${RED}${BOLD}--- Critical Events (${CRITICAL_COUNT}) ---${NC}"
if [ $CRITICAL_COUNT -gt 0 ]; then
    echo -e -n "$CRITICAL_EVENTS"
else
    echo -e "${GREEN}No critical events detected.${NC}"
fi
echo

# Print Top 5 Error Messages
echo -e "${YELLOW}${BOLD}--- Top 5 Error Messages ---${NC}"
if [ -n "$TOP_ERRORS" ]; then
    echo "$TOP_ERRORS"
else
    echo -e "${GREEN}No error messages containing 'ERROR' found.${NC}"
fi
echo

# ------------------------------------------------------------------------------
# Task 5: Summary Report Generation
# ------------------------------------------------------------------------------
{
    echo "=========================================================================="
    echo "                 📝 LOG ANALYSIS SUMMARY REPORT"
    echo "=========================================================================="
    echo "Date of Analysis:    ${TIMESTAMP}"
    echo "Log File Analyzed:   ${LOG_FILENAME}"
    echo "Total Lines:         ${TOTAL_LINES}"
    echo "Total Errors/Failed: ${TOTAL_ERRORS}"
    echo "--------------------------------------------------------------------------"
    echo "🏆 TOP 5 ERROR MESSAGES (Descending Order)"
    echo "--------------------------------------------------------------------------"
    if [ -n "$TOP_ERRORS" ]; then
        echo "$TOP_ERRORS"
    else
        echo "No error messages found."
    fi
    echo "--------------------------------------------------------------------------"
    echo "🚨 CRITICAL EVENTS DETECTED (${CRITICAL_COUNT})"
    echo "--------------------------------------------------------------------------"
    if [ $CRITICAL_COUNT -gt 0 ]; then
        echo -e -n "$CRITICAL_EVENTS"
    else
        echo "No critical events found."
    fi
    echo "=========================================================================="
    echo "Report generated by Auto-LogAnalyzer Suite."
} > "$REPORT_FILE"

echo -e "${GREEN}${BOLD}✅ Summary report written to: ${NC}${REPORT_FILE}"

# ------------------------------------------------------------------------------
# Task 6: Archive Processed Logs (Optional)
# ------------------------------------------------------------------------------
if [ "$ARCHIVE_OPTION" == "archive" ]; then
    ARCHIVE_DIR="archive"
    if [ ! -d "$ARCHIVE_DIR" ]; then
        echo -e "${CYAN}Creating archive directory '${ARCHIVE_DIR}'...${NC}"
        mkdir -p "$ARCHIVE_DIR"
    fi
    
    # Generate timestamped filename for archived log to prevent collision
    ARCHIVED_FILE="${ARCHIVE_DIR}/${LOG_FILENAME%.log}_${ANALYSIS_DATE}.log"
    cp "$LOG_FILE" "$ARCHIVED_FILE"
    rm "$LOG_FILE"
    
    echo -e "${GREEN}${BOLD}📦 Log file successfully archived to: ${NC}${ARCHIVED_FILE}"
fi

print_header "🏁 LOG ANALYSIS RUN COMPLETED SUCCESSFULLY"
