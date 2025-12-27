#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - DEEP STATUS EDITION v8.0
# =========================================================

# --- BRANDING COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'              GRAY='\033[0;90m'

# --- GATHER STATIC INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/etc/slowdns/nsdomain" ]; then NS_DOMAIN=$(cat /etc/slowdns/nsdomain);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# INTERNAL FUNCTIONS
# =========================================================

function check_service() {
    # Usage: check_service "Display Name" "service_name"
    name=$1
    service=$2
    if systemctl is-active --quiet $service; then
        echo -e "  ${BICyan}»${NC} $name ${GRAY}..................${NC} ${BIGreen}RUNNING${NC}"
    else
        echo -e "  ${BICyan}»${NC} $name ${GRAY}..................${NC} ${BIRed}STOPPED${NC}"
    fi
}

function detailed_status() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}DETAILED SYSTEM DIAGNOSTICS${BICyan}         │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e ""
    
    echo -e " ${BIYellow}[ CORE SERVICES ]${NC}"
    check_service "SSH Service" "ssh"
    check_service "VPN Core (Xray)" "xray"
    check_service "Web Server (Nginx)" "nginx"
    check_service "Task Scheduler" "cron"
    
    echo -e ""
    echo -e " ${BIYellow}[ OPTIONAL SERVICES ]${NC}"
    # We check these silently; if they don't exist, we assume 'Not Installed' or skip
    if systemctl list-units --all -t service --full --no-legend | grep -q "dropbear"; then
        check_service "Dropbear SSH" "dropbear"
    fi
    if systemctl list-units --all -t service --full --no-legend | grep -q "stunnel4"; then
        check_service "SSL Tunnel (Stunnel)" "stunnel4"
    fi
    if systemctl list-units --all -t service --full --no-legend | grep -q "squid"; then
        check_service "Squid Proxy" "squid"
    fi
    if systemctl list-units --all -t service --full --no-legend | grep -q "fail2ban"; then
        check_service "Fail2Ban Protection" "fail2ban"
    fi

    echo -e ""
    echo -e " ${BIYellow}[ PROTOCOL DETECTION ]${NC}"
    # Check Xray Config for Protocols
    CONFIG="/etc/xray/config.json"
    if [ -f "$CONFIG" ]; then
        if grep -q "vmess" "$CONFIG"; then echo -e "  ${BICyan}»${NC} VMess ....................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} VMess ....................... ${GRAY}NOT FOUND${NC}"; fi
        
        if grep -q "vless" "$CONFIG"; then echo -e "  ${BICyan}»${NC} VLESS ....................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} VLESS ....................... ${GRAY}NOT FOUND${NC}"; fi
        
        if grep -q "trojan" "$CONFIG"; then echo -e "  ${BICyan}»${NC} Trojan ...................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} Trojan ...................... ${GRAY}NOT FOUND${NC}"; fi
        
        if grep -q "shadowsocks" "$CONFIG"; then echo -e "  ${BICyan}»${NC} Shadowsocks ................. ${BIGreen}ACTIVE${NC}"; fi
    else
        echo -e "  ${BIRed}Error: Xray Config Not Found ($CONFIG)${NC}"
    fi

    echo -e ""
    echo -e " ${BIYellow}[ SERVER HEALTH ]${NC}"
    RAM=$(free -m | awk 'NR==2{printf "%s/%s MB (%.2f%%)", $3,$2,$3*100/$2 }')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
    echo -e "  ${BICyan}»${NC} RAM Usage : $RAM"
    echo -e "  ${BICyan}»${NC} CPU Load  :$LOAD"
    
    echo -e ""
    echo -e "${BICyan}=================================================${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function create_account_selector() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}SELECT PROTOCOL TYPE${BICyan}                │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e "   ${BIWhite}[1]${NC}  VMess Account  ${GRAY}(Standard WebSocket)${NC}"
    echo -e "   ${BIWhite}[2]${NC}  VLESS Account  ${GRAY}(Lightweight/Fast)${NC}"
    echo -e "   ${BIWhite}[3]${NC}  Trojan Account ${GRAY}(Anti-Detection)${NC}"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC}  ${BIRed}Cancel${NC}"
    echo ""
    read -p "   Select > " p_opt
    case $p_opt in
        1) clear ; add-ws ;;
        2) clear ; add-vless ;;
        3) clear ; add-tr ;;
        0) menu ;;
        *) menu ;;
    esac
}

function change_ns() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       CHANGE NAME SERVER (NS)           ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIWhite}Current NS: ${BIGreen}$NS_DOMAIN${NC}"
    echo ""
    read -p "Enter New NS: " new_ns
    if [[ -z "$new_ns" ]]; then menu; fi
    echo "$new_ns" > /etc/xray/dns
    echo "$new_ns" > /root/nsdomain
    echo -e "${BIGreen}Updated!${NC}"
    sleep 1
    menu
}

function clear_cache() {
    clear; echo "Cleaning RAM..."; sync; echo 3 > /proc/sys/vm/drop_caches; swapoff -a && swapon -a; sleep 1; menu;
}

function auto_reboot() {
    clear
    echo -e "${BIYellow}AUTO-REBOOT SETTINGS${NC}"
    echo -e "[1] Enable (00:00 Daily)  [2] Disable"
    read -p "Select > " x
    if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo "Enabled.";
    elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo "Disabled."; fi
    sleep 1; menu
}

function fix_services() {
    clear; echo "Restarting Services..."; systemctl restart nginx xray ssh; echo "Done."; sleep 1; menu;
}

function change_domain() {
    clear; echo "Current: $DOMAIN"; read -p "New Domain: " d; if [[ -z "$d" ]]; then menu; fi
    echo "$d" > /etc/xray/domain; echo "$d" > /root/domain;
    systemctl restart nginx xray; echo "Updated."; sleep 1; menu;
}

function backup_configs() {
    clear; echo "Backing up..."; mkdir -p /root/backup_edu; cp -r /etc/xray /root/backup_edu/xray_backup;
    zip -r /root/vpn_backup.zip /root/backup_edu >/dev/null 2>&1; rm -rf /root/backup_edu;
    echo "Saved: /root/vpn_backup.zip"; sleep 2; menu;
}

# =========================================================
# DASHBOARD UI
# =========================================================
function show_dashboard() {
    RAM_USED=$(free -m | awk 'NR==2{print $3}')
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)
    UPTIME=$(uptime -p | cut -d " " -f 2-10 | cut -c 1-20)
    
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │ ${BIWhite}●${NC}           ${BIYellow}EDUFWESH VPN MANAGER ${BIWhite}PRO v8.0${NC}             ${BICyan}│${NC}"
    echo -e "${BICyan} ├──────────────────────────────┬────────────────────────────┤${NC}"
    echo -e "${BICyan} │${NC} ${GRAY}NETWORK INFO${NC}                 ${BICyan}│${NC} ${GRAY}SYSTEM STATUS${NC}              ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}IP${NC}   : $MYIP       ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}RAM${NC}  : $RAM_USED / ${RAM_TOTAL}MB    ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}ISP${NC}  : $ISP   ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}LOAD${NC} : $LOAD           ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}DOM${NC}  : $DOMAIN     ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}TIME${NC} : $UPTIME   ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}NS${NC}   : $NS_DOMAIN    ${BICyan}│${NC}                            ${BICyan}│${NC}"
    echo -e "${BICyan} └──────────────────────────────┴────────────────────────────┘${NC}"
}

function show_menu() {
    show_dashboard
    echo -e ""
    echo -e "   ${BIYellow}USER ACCOUNTS${NC}"
    echo -e "   ${BICyan}• 01${NC}  Create SSH / WS Account"
    echo -e "   ${BICyan}• 02${NC}  Create V2Ray Account ${BIYellow}(Multi-Proto)${NC}"
    echo -e "   ${BICyan}• 03${NC}  User Details & Monitor"
    echo -e "   ${BICyan}• 04${NC}  Delete / Lock User"
    echo -e ""
    echo -e "   ${BIYellow}SYSTEM TOOLS${NC}"
    echo -e "   ${BICyan}• 05${NC}  Detailed System Status ${BIGreen}(NEW)${NC}"
    echo -e "   ${BICyan}• 06${NC}  Speedtest Benchmark"
    echo -e "   ${BICyan}• 07${NC}  Reboot Server"
    echo -e "   ${BICyan}• 08${NC}  Clear RAM & Logs ${BIGreen}(Optimized)${NC}"
    echo -e ""
    echo -e "   ${BIYellow}ADVANCED SETTINGS${NC}"
    echo -e "   ${BICyan}• 09${NC}  Fix SSL / Restart Services"
    echo -e "   ${BICyan}• 10${NC}  Auto-Reboot Scheduler"
    echo -e "   ${BICyan}• 11${NC}  Change Domain / Host"
    echo -e "   ${BICyan}• 12${NC}  Backup Configurations"
    echo -e "   ${BICyan}• 13${NC}  Change Name Server (NS)"
    echo -e ""
    echo -e "   ${BICyan}• 00${NC}  ${BIRed}Exit Dashboard${NC}"
    echo -e ""
    echo -e "${BICyan} ─────────────────────────────────────────────────────────────${NC}"
    read -p "   Select Option »  " opt

    case $opt in
        01 | 1) clear ; usernew ;;         
        02 | 2) clear ; create_account_selector ;;          
        03 | 3) clear ; cek ;;             
        04 | 4) clear ; member ;;          
        05 | 5) clear ; detailed_status ;;  # Using the new deep checker
        06 | 6) clear ; speedtest ;;
        07 | 7) clear ; reboot ;;
        08 | 8) clear ; clear_cache ;;
        09 | 9) clear ; fix_services ;;
        10 | 10) clear ; auto_reboot ;;
        11 | 11) clear ; change_domain ;;
        12 | 12) clear ; backup_configs ;;
        13 | 13) clear ; change_ns ;;
        00 | 0) clear ; exit 0 ;;
        *) show_menu ;;
    esac
}

# Start the menu
show_menu

