#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER (PREMIUM EDITION)
# =========================================================

# --- BRANDING COLORS ---
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
NC='\033[0m'              # No Color

# --- SYSTEM INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Domain Not Found")
RAM=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
UPTIME=$(uptime -p | cut -d " " -f 2-10)

# =========================================================
# INTERNAL FUNCTIONS
# =========================================================

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
    echo "" > /var/log/auth.log
    echo "" > /var/log/kern.log
    
    echo -e "${BIGreen}SUCCESS! Server is now fresh.${NC}"
    read -n 1 -s -r -p "Press any key to return to menu"
    menu
}

function auto_reboot() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}        AUTO-REBOOT SCHEDULER            ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "Scheduled reboots keep your VPN stable."
    echo ""
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
