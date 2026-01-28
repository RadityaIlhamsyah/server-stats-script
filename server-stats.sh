#!/bin/bash

# ==============================================================================
# Script Name: server-stats.sh
# Description: Menganalisis statistik kinerja server (CPU, RAM, Disk, Proses)
# ==============================================================================

# Warna untuk output agar lebih mudah dibaca
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Fungsi Pendukung ---

get_os_info() {
    printf "${BOLD}OS Version:${NC} %s\n" "$(grep -w "PRETTY_NAME" /etc/os-release | cut -d '"' -f2)"
    printf "${BOLD}Uptime:${NC} %s\n" "$(uptime -p)"
    printf "${BOLD}Load Average:${NC} %s\n" "$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')"
}

get_cpu_usage() {
    # Mengambil persentase idle dari 'top' dan menghitung selisihnya
    local idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d',' -f1)
    local usage=$(echo "100 - $idle" | bc 2>/dev/null || awk "BEGIN {print 100 - $idle}")
    printf "${BOLD}Total CPU Usage:${NC} %s%%\n" "$usage"
}

get_mem_usage() {
    printf "${BOLD}Memory Usage:${NC}\n"
    free -m | awk 'NR==2{
        printf "  Used: %dMB / Total: %dMB (%.2f%%)\n", $3, $2, $3*100/$2;
        printf "  Free: %dMB\n", $4
    }'
}

get_disk_usage() {
    printf "${BOLD}Disk Usage:${NC}\n"
    df -h --total | grep 'total' | awk '{
        printf "  Used: %s / Total: %s (%s)\n", $3, $2, $5;
        printf "  Available: %s\n", $4
    }'
}

get_top_processes_cpu() {
    printf "\n${BOLD}Top 5 Processes by CPU Usage:${NC}\n"
    printf "  %-8s %-10s %-20s %-5s\n" "PID" "USER" "COMMAND" "%CPU"
    ps -eo pid,user,comm,%cpu --sort=-%cpu | head -n 6 | tail -n 5 | awk '{printf "  %-8s %-10s %-20s %-5s\n", $1, $2, $3, $4}'
}

get_top_processes_mem() {
    printf "\n${BOLD}Top 5 Processes by Memory Usage:${NC}\n"
    printf "  %-8s %-10s %-20s %-5s\n" "PID" "USER" "COMMAND" "%MEM"
    ps -eo pid,user,comm,%mem --sort=-%mem | head -n 6 | tail -n 5 | awk '{printf "  %-8s %-10s %-20s %-5s\n", $1, $2, $3, $4}'
}

# --- Eksekusi Utama ---

clear
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}           SERVER PERFORMANCE REPORT              ${NC}"
echo -e "${GREEN}==================================================${NC}"

get_os_info
echo "--------------------------------------------------"
get_cpu_usage
get_mem_usage
get_disk_usage
echo "--------------------------------------------------"
get_top_processes_cpu
get_top_processes_mem

echo -e "${GREEN}==================================================${NC}"
