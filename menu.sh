#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - PREMIUM DASHBOARD EDITION v7.0
# =========================================================

# --- BRANDING COLORS ---
# We use a tighter palette for a professional look
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
# INTERNAL FUNCTIONS (LOGIC)
# =========================================================

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

function status_report() {
    clear; status; echo ""; read -n 1 -s -r -p "Press any key..."; menu;
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
    # Calculate Live Stats
    RAM_USED=$(free -m | awk 'NR==2{print $3}')
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)
    UPTIME=$(uptime -p | cut -d " " -f 2-10 | cut -c 1-20)
    
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │ ${BIWhite}●${NC}           ${BIYellow}EDUFWESH VPN MANAGER ${BIWhite}PRO v7.0${NC}             ${BICyan}│${NC}"
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
    echo -e "   ${BICyan}• 05${NC}  Detailed System Status"
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
        05 | 5) clear ; status_report ;;          
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

function clear_cache() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}      OPTIMIZING SERVER PERFORMANCE      ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    sleep 1
    echo -e "${BIWhite}[1/3] Clearing RAM Cache...${NC}"
    sync; echo 3 > /proc/sys/vm/drop_caches
    echo -e "${BIWhite}[2/3] Resetting Swap Memory...${NC}"
    swapoff -a && swapon -a
    echo -e "${BIWhite}[3/3] Deleting Old Log Files...${NC}"
    echo "" > /var/log/syslog
    echo -e "${BIGreen}SUCCESS! Server is now fresh.${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function auto_reboot() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}        AUTO-REBOOT SCHEDULER            ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "   [1] Set Auto-Reboot (Every Midnight 00:00)"
    echo -e "   [2] Disable Auto-Reboot"
    echo ""
    read -p "Select Option: " x
    if [[ "$x" == "1" ]]; then
        echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu
        service cron restart
        echo -e "${BIGreen}Enabled! Server will reboot daily at 00:00.${NC}"
    elif [[ "$x" == "2" ]]; then
        rm -f /etc/cron.d/auto_reboot_edu
        service cron restart
        echo -e "${BIRed}Disabled! Auto-reboot turned off.${NC}"
    else
        echo "Invalid Option"
    fi
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function fix_services() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}      FIXING SSL & RESTARTING SERVICES   ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIWhite}Restarting Xray, Nginx, and SSH...${NC}"
    systemctl restart nginx
    systemctl restart xray
    systemctl restart ssh
    echo -e "${BIGreen}Done! Connections refreshed.${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function change_domain() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}         CHANGE VPS HOST / DOMAIN        ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIWhite}Current Domain: ${BIGreen}$DOMAIN${NC}"
    echo ""
    echo -e "${BIRed}WARNING: Make sure your new domain is already pointed"
    echo -e "to this VPS IP Address ($MYIP) on Cloudflare!${NC}"
    echo ""
    read -p "Enter New Domain: " new_domain
    if [[ -z "$new_domain" ]]; then
        menu
    fi
    echo -e "${BIWhite}Updating config files...${NC}"
    echo "$new_domain" > /etc/xray/domain
    echo "$new_domain" > /root/domain
    echo -e "${BIWhite}Restarting services...${NC}"
    systemctl restart nginx
    systemctl restart xray
    echo -e "${BIGreen}Domain updated to: $new_domain${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function backup_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       BACKUP VPN CONFIGURATIONS         ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "Backing up /etc/xray and important configs..."
    mkdir -p /root/backup_edu
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    zip -r /root/vpn_backup.zip /root/backup_edu > /dev/null 2>&1
    echo -e "${BIGreen}Backup created at: /root/vpn_backup.zip${NC}"
    rm -rf /root/backup_edu
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

# =========================================================
# MAIN MENU DISPLAY
# =========================================================
function show_menu() {
    clear
    echo -e "${BICyan} ╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan} ║          ${BIYellow}EDUFWESH VPN MANAGER PREMIUM v5.0          ${BICyan}║${NC}"
    echo -e "${BICyan} ╚═════════════════════════════════════════════════════╝${NC}"
    echo -e "${BIWhite}   ISP Provider : ${BIPurple}$ISP${NC}"
    echo -e "${BIWhite}   Server IP    : ${BIPurple}$MYIP${NC}"
    echo -e "${BIWhite}   Domain       : ${BIPurple}$DOMAIN${NC}"
    echo -e "${BIWhite}   Name Server  : ${BIPurple}$NS_DOMAIN${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    
    echo -e "${BIYellow}   [ USER MANAGEMENT ]${NC}"
    echo -e "   ${BICyan}[01]${NC} ${BIWhite}Create SSH/WS Account${NC}"
    echo -e "   ${BICyan}[02]${NC} ${BIWhite}Create V2Ray/Xray Account${NC}"
    echo -e "   ${BICyan}[03]${NC} ${BIWhite}Check User Login / Info${NC}"
    echo -e "   ${BICyan}[04]${NC} ${BIWhite}Delete / Lock User${NC}"

    echo -e " "
    echo -e "${BIYellow}   [ SERVER MAINTENANCE ]${NC}"
    echo -e "   ${BICyan}[05]${NC} ${BIWhite}Check System Status${NC}"
    echo -e "   ${BICyan}[06]${NC} ${BIWhite}Speedtest${NC}"
    echo -e "   ${BICyan}[07]${NC} ${BIWhite}Reboot Server${NC}"
    echo -e "   ${BICyan}[08]${NC} ${BIGreen}Clear RAM & Logs (Boost)${NC}"
    echo -e "   ${BICyan}[09]${NC} ${BIGreen}Fix SSL / Restart Services${NC}"
    
    echo -e " "
    echo -e "${BIYellow}   [ ADVANCED ]${NC}"
    echo -e "   ${BICyan}[10]${NC} ${BIGreen}Auto-Reboot Settings${NC}"
    echo -e "   ${BICyan}[11]${NC} ${BIGreen}Change Host / Domain${NC}"
    echo -e "   ${BICyan}[12]${NC} ${BIGreen}Backup Configs${NC}"
    
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    echo -e "   ${BICyan}[00]${NC} ${BIRed}Exit Panel${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    read -p "   Select Menu :  " opt

    case $opt in
        01 | 1) clear ; usernew ;;         
        02 | 2) clear ; add-ws ;;          
        03 | 3) clear ; cek ;;             
        04 | 4) clear ; member ;;          
        
        # FIXED: Now runs internal function instead of external command
        05 | 5) clear ; status_report ;;          
        
        06 | 6) clear ; speedtest ;;
        07 | 7) clear ; reboot ;;
        08 | 8) clear ; clear_cache ;;
        09 | 9) clear ; fix_services ;;
        10 | 10) clear ; auto_reboot ;;
        11 | 11) clear ; change_domain ;;
        12 | 12) clear ; backup_configs ;;
        00 | 0) clear ; exit 0 ;;
        *) clear ; echo "Invalid Option" ; sleep 1 ; show_menu ;;
    esac
}

# Start the menu
show_menu
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}         CHANGE VPS HOST / DOMAIN        ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIWhite}Current Domain: ${BIGreen}$DOMAIN${NC}"
    echo ""
    echo -e "${BIRed}WARNING: Make sure your new domain is already pointed"
    echo -e "to this VPS IP Address ($MYIP) on Cloudflare!${NC}"
    echo ""
    read -p "Enter New Domain: " new_domain
    
    if [[ -z "$new_domain" ]]; then
        echo "Aborted."
        sleep 2
        menu
    fi

    echo -e "${BIWhite}Updating config files...${NC}"
    echo "$new_domain" > /etc/xray/domain
    echo "$new_domain" > /root/domain
    
    # Attempt to use standard acme/certbot if available
    echo -e "${BIWhite}Attempting to renew SSL...${NC}"
    if command -v certv2ray &> /dev/null; then
        certv2ray
    else
        systemctl restart nginx
        systemctl restart xray
    fi
    
    echo -e "${BIGreen}Domain updated to: $new_domain${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function backup_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       BACKUP VPN CONFIGURATIONS         ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "Backing up /etc/xray and important configs..."
    
    # Create a backup folder
    mkdir -p /root/backup_edu
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /root/backup_edu/passwd_backup 2>/dev/null
    
    # Zip it
    zip -r /root/vpn_backup.zip /root/backup_edu > /dev/null 2>&1
    
    echo -e "${BIGreen}Backup created at: /root/vpn_backup.zip${NC}"
    echo -e "You can download this file using SFTP."
    
    # Clean up temp folder
    rm -rf /root/backup_edu
    
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

# =========================================================
# MAIN MENU DISPLAY
# =========================================================
function show_menu() {
    clear
    echo -e "${BICyan} ╔═════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan} ║          ${BIYellow}EDUFWESH VPN MANAGER PREMIUM v4.0          ${BICyan}║${NC}"
    echo -e "${BICyan} ╚═════════════════════════════════════════════════════╝${NC}"
    echo -e "${BIWhite}   ISP Provider : ${BIPurple}$ISP${NC}"
    echo -e "${BIWhite}   Server IP    : ${BIPurple}$MYIP${NC}"
    echo -e "${BIWhite}   Domain       : ${BIPurple}$DOMAIN${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    
    echo -e "${BIYellow}   [ USER MANAGEMENT ]${NC}"
    echo -e "   ${BICyan}[01]${NC} ${BIWhite}Create SSH/WS Account${NC}"
    echo -e "   ${BICyan}[02]${NC} ${BIWhite}Create V2Ray/Xray Account${NC}"
    echo -e "   ${BICyan}[03]${NC} ${BIWhite}Check User Login / Info${NC}"
    echo -e "   ${BICyan}[04]${NC} ${BIWhite}Delete / Lock User${NC}"

    echo -e " "
    echo -e "${BIYellow}   [ SERVER MAINTENANCE ]${NC}"
    echo -e "   ${BICyan}[05]${NC} ${BIWhite}Check System Status${NC}"
    echo -e "   ${BICyan}[06]${NC} ${BIWhite}Speedtest${NC}"
    echo -e "   ${BICyan}[07]${NC} ${BIWhite}Reboot Server${NC}"
    echo -e "   ${BICyan}[08]${NC} ${BIGreen}Clear RAM & Logs (Boost)${NC}"
    echo -e "   ${BICyan}[09]${NC} ${BIGreen}Fix SSL / Restart Services${NC}"
    
    echo -e " "
    echo -e "${BIYellow}   [ ADVANCED ]${NC}"
    echo -e "   ${BICyan}[10]${NC} ${BIGreen}Auto-Reboot Settings${NC}"
    echo -e "   ${BICyan}[11]${NC} ${BIGreen}Change Host / Domain${NC}"
    echo -e "   ${BICyan}[12]${NC} ${BIGreen}Backup Configs${NC}"
    
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    echo -e "   ${BICyan}[00]${NC} ${BIRed}Exit Panel${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    read -p "   Select Menu :  " opt

    case $opt in
        01 | 1) clear ; usernew ;;         
        02 | 2) clear ; add-ws ;;          
        03 | 3) clear ; cek ;;             
        04 | 4) clear ; member ;;          
        05 | 5) clear ; status ;;          
        06 | 6) clear ; speedtest ;;
        07 | 7) clear ; reboot ;;
        
        # New Internal Functions
        08 | 8) clear ; clear_cache ;;
        09 | 9) clear ; fix_services ;;
        10 | 10) clear ; auto_reboot ;;
        11 | 11) clear ; change_domain ;;
        12 | 12) clear ; backup_configs ;;
        
        00 | 0) clear ; exit 0 ;;
        *) clear ; echo "Invalid Option" ; sleep 1 ; show_menu ;;
    esac
}

# Start the menu
show_menu
    echo -e "${BIWhite}Stopping Services...${NC}"
    systemctl stop nginx
    systemctl stop xray
    
    echo -e "${BIWhite}Reloading Network Stack...${NC}"
    sysctl -p
    
    echo -e "${BIWhite}Restarting Services...${NC}"
    systemctl restart nginx
    systemctl restart xray
    
    echo -e "${BIGreen}Done! If connection failed, it should work now.${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

# =========================================================
# MAIN MENU DISPLAY
# =========================================================
function show_menu() {
    clear
    echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │             ${BIYellow}EDUFWESH VPN MANAGER V2.0             ${BICyan}│${NC}"
    echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
    echo -e "${BIWhite}  Server IP   : ${BIGreen}$MYIP${NC}"
    echo -e "${BIWhite}  Domain      : ${BIGreen}$DOMAIN${NC}"
    echo -e "${BIWhite}  RAM Usage   : ${BIPurple}$RAM${NC}"
    echo -e "${BIWhite}  Uptime      : ${BIPurple}$UPTIME${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    
    echo -e "  ${BICyan}[01]${NC} ${BIWhite}Create SSH Account${NC}"
    echo -e "  ${BICyan}[02]${NC} ${BIWhite}Create V2Ray/Xray Account${NC}"
    echo -e "  ${BICyan}[03]${NC} ${BIWhite}Check User Login${NC}"
    echo -e "  ${BICyan}[04]${NC} ${BIWhite}Check System Status${NC}"
    echo -e "  ${BICyan}[05]${NC} ${BIWhite}Speedtest${NC}"
    echo -e "  ${BICyan}[06]${NC} ${BIWhite}Reboot Server (Now)${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    echo -e "  ${BIYellow}[07]${NC} ${BIGreen}Clear RAM & Logs (Boost Speed)${NC}"
    echo -e "  ${BIYellow}[08]${NC} ${BIGreen}Auto-Reboot Settings${NC}"
    echo -e "  ${BIYellow}[09]${NC} ${BIGreen}Fix SSL / Restart Services${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    echo -e "  ${BICyan}[00]${NC} ${BIRed}Exit${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
    read -p "  Select Menu :  " opt

    case $opt in
        01 | 1) clear ; usernew ;;         
        02 | 2) clear ; add-ws ;;          
        03 | 3) clear ; cek ;;             
        04 | 4) clear ; status ;;          
        05 | 5) clear ; speedtest ;;
        06 | 6) clear ; reboot ;;
        
        # New Internal Functions
        07 | 7) clear ; clear_cache ;;
        08 | 8) clear ; auto_reboot ;;
        09 | 9) clear ; fix_services ;;
        
        00 | 0) clear ; exit 0 ;;
        *) clear ; echo "Invalid Option" ; sleep 1 ; show_menu ;;
    esac
}

# Start the menu
show_menu
