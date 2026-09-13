#!/bin/bash

# ==============================================================================
# Student Name : David Tobias
# Date         : 13th of September 2026
# Script Name  : devops-health-check.sh
# Version      : 1.0
# Purpose      : Linux server health monitoring
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e
# Pipelines return the exit status of the last command to fail
set -o pipefail

# ------------------------------------------------------------------------------
# BONUS TASK 2: TRAP
# Clean-up / Exit trap function that executes when the script completes/exits.
# ------------------------------------------------------------------------------
cleanup() {
    echo "======================================================================"
    echo "         HEALTH CHECK COMPLETED SUCCESSFULLY - EXITING TRAP"
    echo "======================================================================"
}
trap cleanup EXIT

echo "======================================================================"
echo "                   DEVOPS NODE HEALTH REPORT                          "
echo "======================================================================"

# ------------------------------------------------------------------------------
# TASK 4: BASIC SYSTEM INFORMATION
# ------------------------------------------------------------------------------
echo -e "\n[+] BASIC SYSTEM INFORMATION"
echo "----------------------------------------------------------------------"
echo "Hostname     : $(hostname)"
echo "Current User : $(whoami)"
echo "Date & Time  : $(date)"
echo "Uptime       : $(uptime -p 2>/dev/null || uptime)"
echo "CPU Count    : $(nproc) Core(s)"

# ------------------------------------------------------------------------------
# TASK 4 & CHALLENGE: DISK USAGE & AUTOMATED THRESHOLD CHECK
# ------------------------------------------------------------------------------
echo -e "\n[+] DISK USAGE & HEALTH ASSESSMENT"
echo "----------------------------------------------------------------------"
df -h / | awk 'NR==1 || NR==2'

# Challenge Logic: Extract root partition usage percentage using awk & sub
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
DISK_THRESHOLD=80

echo -n "Disk Status  : "
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    echo "WARNING: Root disk usage is dangerously high (${DISK_USAGE}%)!"
else
    echo "OK: Root disk usage is at ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)."
fi

# ------------------------------------------------------------------------------
# TASK 4: MEMORY USAGE
# ------------------------------------------------------------------------------
echo -e "\n[+] MEMORY USAGE"
echo "----------------------------------------------------------------------"
free -h

# ------------------------------------------------------------------------------
# TASK 5 & 7: PIPES & AWK
# Pipe ps -> sort -> head, then use awk to extract PIDs of top memory consumers.
# ------------------------------------------------------------------------------
echo -e "\n[+] TOP 3 MEMORY-CONSUMING PROCESS PIDs (TASK 5 & 7)"
echo "----------------------------------------------------------------------"
echo "PID      USER     %MEM   COMMAND"
ps -eo pid,user,%mem,comm --sort=-%mem | head -n 4 | tail -n 3 | awk '{print $1 "    " $2 "    " $3 "    " $4}'

# ------------------------------------------------------------------------------
# TASK 6 & 9: GREP & FOR LOOP
# Iterate through essential system services and check running state using grep.
# ------------------------------------------------------------------------------
echo -e "\n[+] SYSTEM SERVICE MONITORING (TASK 6 & 9)"
echo "----------------------------------------------------------------------"
SERVICES=("sshd" "docker" "nginx" "cron")

for SERVICE in "${SERVICES[@]}"; do
    if ps -ef | grep -v grep | grep -q "$SERVICE"; then
        echo "Service [$SERVICE]: RUNNING"
    else
        echo "Service [$SERVICE]: NOT RUNNING / NOT INSTALLED"
    fi
done

# ------------------------------------------------------------------------------
# TASK 8: IF/ELSE CONDITION
# Evaluate network connection / local port availability.
# ------------------------------------------------------------------------------
echo -e "\n[+] CRITICAL SERVICE AUDIT (TASK 8)"
echo "----------------------------------------------------------------------"
if ps -ef | grep -v grep | grep -q "sshd"; then
    echo "CRITICAL: SSH Service is active. Remote management enabled."
else
    echo "CRITICAL WARNING: SSH Service is NOT running on this node!"
fi

# ------------------------------------------------------------------------------
# TASK 10: REMOTE CHECK WITH CURL
# Probe external endpoint headers to verify network egress functionality.
# ------------------------------------------------------------------------------
echo -e "\n[+] REMOTE ENDPOINT EGRESS CHECK (TASK 10)"
echo "----------------------------------------------------------------------"
TARGET_URL="https://example.com"
echo "Pinging endpoint: $TARGET_URL"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$TARGET_URL" || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "HTTP Status  : 200 OK (Remote connectivity functional)"
else
    echo "HTTP Status  : $HTTP_STATUS (Failed to connect or non-200 response)"
fi

# ------------------------------------------------------------------------------
# BONUS TASK 1: FIND
# Locate configuration files securely without cluttering standard output.
# ------------------------------------------------------------------------------
echo -e "\n[+] BONUS: CONFIGURATION FILE AUDIT (BONUS TASK 1)"
echo "----------------------------------------------------------------------"
echo "Searching for essential .conf files in /etc (First 5 results):"
find /etc -maxdepth 2 -name "*.conf" 2>/dev/null | head -n 5

	echo ""
