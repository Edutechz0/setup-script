#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - ULTIMATE FIX
# =========================================================

# --- BRANDING COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'

# --- SYSTEM INFO GATHERING ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FIND NAME SERVER (NS) ---
# We check all possible locations where the installer hides the NS
if [ -f "/etc/xray/dns" ]; then
    NS_DOMAIN=$(cat /etc/xray/dns)
elif [ -f "/etc/slowdns/nsdomain" ]; then
    NS_DOMAIN=$(cat /etc/slowdns/nsdomain)
elif [ -f "/root/nsdomain" ]; then
    NS_DOMAIN=$(cat /root/nsdomain)
else
    NS_DOMAIN="Not Detected"
fi

# =========================================================
# INTERNAL FUNCTIONS
# =========================================================

# --- 1. NEW STATUS CHECKER (Replaces broken 'status' command) ---
function status_report() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}         SYSTEM STATUS REPORT            ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    
    # Check Services
    echo -e "${BIWhite}Checking Services...${NC}"
    
    # NGINX
    if systemctl is-active --quiet nginx; then 
        echo -e "  HTTP Service (Nginx) : ${BIGreen}RUNNING${NC}"
    else 
        echo -e "  HTTP Service (Nginx) : ${BIRed}STOPPED${NC}"
    fi

    # XRAY / V2RAY
    if systemctl is-active --quiet xray; then 
        echo -e "  VPN Core (Xray)      : ${BIGreen}RUNNING${NC}"
    else 
        echo -e "  VPN Core (Xray)      : ${BIRed}STOPPED${NC}"
    fi

    # SSH
    if systemctl is-active --quiet ssh; then 
        echo -e "  SSH Service          : ${BIGreen}RUNNING${NC}"
    else 
        echo -e "  SSH Service          : ${BIRed}STOPPED${NC}"
    fi
    
    echo -e "${BICyan}-----------------------------------------${NC}"
    
    # Check Resources
    RAM_USED=$(free -m | awk 'NR==2{print $3}')
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    DISK_USED=$(df -h / | awk 'NR==2{print $3}')
    DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    
    echo -e "  RAM Usage  : ${BIYellow}$RAM_USED MB / $RAM_TOTAL MB${NC}"
    echo -e "  Disk Usage : ${BIYellow}$DISK_USED / $DISK_TOTAL${NC}"
    echo -e "  System Load: ${BIYellow}$(uptime | awk -F'load average:' '{ print $2 }')${NC}"
    
    echo -e "${BICyan}=========================================${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

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
