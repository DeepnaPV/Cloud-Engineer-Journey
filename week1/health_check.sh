#!/bin/bash

DATE=$(date)

echo "=============================="
echo "       SYSTEM HEALTH CHECK"
echo "=============================="

echo "Report generated: $DATE"

# Hostname
HOSTNAME=$(hostname)
echo "Hostname: $HOSTNAME"

# Uptime
UPTIME=$(uptime)
echo "Uptime: $UPTIME"

# CPU Usage
IDLE_CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
CPU_USAGE=$(awk "BEGIN {printf \"%.1f\", 100 - $IDLE_CPU}")

echo "CPU Usage: $CPU_USAGE%"

# RAM Usage
TOTAL=$(free -m | awk '/Mem:/{print $2}')
USED=$(free -m | awk '/Mem:/{print $3}')
FREE=$(free -m | awk '/Mem:/{print $4}')
PCT=$((USED * 100 / TOTAL))

echo "RAM Usage: $PCT%"

# Disk Usage
DISK_USAGE=$(df -h / | awk '/overlay/ {print $5}')
DISK_PERCENT=${DISK_USAGE%\%}

echo "Disk Usage: $DISK_USAGE"

# Running Processes
PROCESS_COUNT=$(ps aux | awk 'NR>1' | wc -l)

echo "Running Processes: $PROCESS_COUNT"

# CPU Status
if [ "$CPU_USAGE" -ge 80 ]; then
    echo "CPU Status: WARNING"
else
    echo "CPU Status: OK"
fi

# RAM Status
if [ "$PCT" -ge 80 ]; then
    echo "RAM Status: WARNING"
else
    echo "RAM Status: OK"
fi

# Disk Status
if [ "$DISK_PERCENT" -ge 80 ]; then
    echo "Disk Status: WARNING"
else
    echo "Disk Status: OK"
fi

# Overall Status
if [ "$CPU_USAGE" -ge 80 ] || [ "$PCT" -ge 80 ] || [ "$DISK_PERCENT" -ge 80 ]; then
    echo "Overall Status: WARNING"
else
    echo "Overall Status: HEALTHY"
fi   