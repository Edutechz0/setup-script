#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - COMPLETE BACKUP EDITION v12.0
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

function change_banner() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │          ${BIYellow}EDIT SSH CONNECTION BANNER${BICyan}           │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e " ${BIWhite}This message appears when users connect via SSH/VPN.${NC}"
    echo -e ""
    echo -e " ${BIYellow}INSTRUCTIONS:${NC}"
    echo -e " 1. The editor will open automatically."
    echo -e " 2. Type or paste your new message."
    echo -e " 3. Press ${BIWhite}Ctrl + X${NC}, then ${BIWhite}Y${NC}, then ${BIWhite}Enter${NC} to save."
    echo -e ""
    read -n 1 -s -r -p " Press any key to open editor..."
    if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi
    nano /etc/issue.net
    echo -e ""
    echo -e "${BIWhite}Restarting SSH Service to apply changes...${NC}"
    service ssh restart
    service sshd restart
    echo -e "${BIGreen}Success! New banner is active.${NC}"
    sleep 2
    menu
}

function renew_selector() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}RENEW USER ACCOUNT${BICyan}                  │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e "   ${BIWhite}[1]${NC}  Renew SSH / WS Account"
    echo -e "   ${BICyan}───────────────────────────────────────────────${NC}"
    echo -e "   ${BIWhite}[2]${NC}  Renew VMess Account"
    echo -e "   ${BIWhite}[3]${NC}  Renew VLESS Account"
    echo -e "   ${BIWhite}[4]${NC}  Renew Trojan Account"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC}  ${BIRed}Cancel${NC}"
    echo ""
    read -p "   Select > " r_opt
    case $r_opt in
        1) clear ; renew ;;        
        2) clear ; renew-ws ;;     
        3) clear ; renew-vless ;;  
        4) clear ; renew-tr ;;     
        0) menu ;;
        *) menu ;;
    esac
}

function check_service() {
    name=$1; service=$2
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
    echo -e " ${BIYellow}[ PROTOCOL DETECTION ]${NC}"
    CONFIG="/etc/xray/config.json"
    if [ -f "$CONFIG" ]; then
        if grep -q "vmess" "$CONFIG"; then echo -e "  ${BICyan}»${NC} VMess ....................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} VMess ....................... ${GRAY}NOT FOUND${NC}"; fi
        if grep -q "vless" "$CONFIG"; then echo -e "  ${BICyan}»${NC} VLESS ....................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} VLESS ....................... ${GRAY}NOT FOUND${NC}"; fi
        if grep -q "trojan" "$CONFIG"; then echo -e "  ${BICyan}»${NC} Trojan ...................... ${BIGreen}ACTIVE${NC}"; 
        else echo -e "  ${BICyan}»${NC} Trojan ...................... ${GRAY}NOT FOUND${NC}"; fi
    else
        echo -e "  ${BIRed}Error: Xray Config Not Found${NC}"
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
    clear; echo -e "${BICyan}=========================================${NC}"; echo -e "${BIYellow}       CHANGE NAME SERVER (NS)           ${NC}"; echo -e "${BICyan}=========================================${NC}"; echo -e "${BIWhite}Current NS: ${BIGreen}$NS_DOMAIN${NC}"; echo ""; read -p "Enter New NS: " new_ns; if [[ -z "$new_ns" ]]; then menu; fi; echo "$new_ns" > /etc/xray/dns; echo "$new_ns" > /root/nsdomain; echo -e "${BIGreen}Updated!${NC}"; sleep 1; menu;
}

function clear_cache() {
    clear; echo "Cleaning RAM..."; sync; echo 3 > /proc/sys/vm/drop_caches; swapoff -a && swapon -a; sleep 1; menu;
}

function auto_reboot() {
    clear; echo -e "${BIYellow}AUTO-REBOOT SETTINGS${NC}"; echo -e "[1] Enable (00:00 Daily)  [2] Disable"; read -p "Select > " x; if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo "Enabled."; elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo "Disabled."; fi; sleep 1; menu;
}

function fix_services() {
    clear; echo "Restarting Services..."; systemctl restart nginx xray ssh; echo "Done."; sleep 1; menu;
}

function change_domain() {
    clear; echo "Current: $DOMAIN"; read -p "New Domain: " d; if [[ -z "$d" ]]; then menu; fi; echo "$d" > /etc/xray/domain; echo "$d" > /root/domain; systemctl restart nginx xray; echo "Updated."; sleep 1; menu;
}

# --- UPDATED BACKUP FUNCTION ---
function backup_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       BACKUP ALL USERS (SSH + VPN)      ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "Gathering files..."
    
    # Create temp folder
    mkdir -p /root/backup_edu
    mkdir -p /root/backup_edu/ssh_backup
    
    # 1. Backup Xray/V2Ray
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    
    # 2. Backup SSH Users (Passwd, Shadow, Group)
    cp /etc/passwd /root/backup_edu/ssh_backup/
    cp /etc/shadow /root/backup_edu/ssh_backup/
    cp /etc/group /root/backup_edu/ssh_backup/
    cp /etc/gshadow /root/backup_edu/ssh_backup/
    
    # Zip it all
    zip -r /root/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    
    # Cleanup
    rm -rf /root/backup_edu
    
    echo -e "${BIGreen}Backup created at: /root/vpn_backup.zip${NC}"
    echo -e "${BIWhite}Contains: Xray Configs + SSH User Database${NC}"
    sleep 3
    menu
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
    echo -e "${BICyan} │ ${BIWhite}●${NC}           ${BIYellow}EDUFWESH VPN MANAGER ${BIWhite}PRO v12.0${NC}            ${BICyan}│${NC}"
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
    echo -e "   ${BICyan}• 03${NC}  Renew User Services ${GRAY}(SSH/Xray)${NC}"
    echo -e "   ${BICyan}• 04${NC}  User Details & Monitor"
    echo -e "   ${BICyan}• 05${NC}  Delete / Lock User"
    echo -e ""
    echo -e "   ${BIYellow}SYSTEM TOOLS${NC}"
    echo -e "   ${BICyan}• 06${NC}  Detailed System Status"
    echo -e "   ${BICyan}• 07${NC}  Speedtest Benchmark"
    echo -e "   ${BICyan}• 08${NC}  Reboot Server"
    echo -e "   ${BICyan}• 09${NC}  Clear RAM & Logs"
    echo -e ""
    echo -e "   ${BIYellow}ADVANCED SETTINGS${NC}"
    echo -e "   ${BICyan}• 10${NC}  Fix SSL / Restart Services"
    echo -e "   ${BICyan}• 11${NC}  Auto-Reboot Scheduler"
    echo -e "   ${BICyan}• 12${NC}  Backup Configurations"
    echo -e "   ${BICyan}• 13${NC}  Change Domain / Host"
    echo -e "   ${BICyan}• 14${NC}  Change Name Server (NS)"
    echo -e "   ${BICyan}• 15${NC}  Change SSH Banner Message"
    echo -e ""
    echo -e "   ${BICyan}• 00${NC}  ${BIRed}Exit Dashboard${NC}"
    echo -e ""
    echo -e "${BICyan} ─────────────────────────────────────────────────────────────${NC}"
    read -p "   Select Option »  " opt

    case $opt in
        01 | 1) clear ; usernew ;;         
        02 | 2) clear ; create_account_selector ;;
        03 | 3) clear ; renew_selector ;;
        04 | 4) clear ; cek ;;             
        05 | 5) clear ; member ;;          
        06 | 6) clear ; detailed_status ;;
        07 | 7) clear ; speedtest ;;
        08 | 8) clear ; reboot ;;
        09 | 9) clear ; clear_cache ;;
        10 | 10) clear ; fix_services ;;
        11 | 11) clear ; auto_reboot ;;
        12 | 12) clear ; backup_configs ;;
        13 | 13) clear ; change_domain ;;
        14 | 14) clear ; change_ns ;;
        15 | 15) clear ; change_banner ;;
        00 | 0) clear ; exit 0 ;;
        *) show_menu ;;
    esac
}

# Start the menu
show_menu

