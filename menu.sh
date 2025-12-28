#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - MONITOR EDITION v12.6
# (Added: Discord/Telegram Auto-Backup, Settings Menu)
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
# BACKUP CONFIGURATION FUNCTIONS
# =========================================================

function backup_settings() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │          ${BIYellow}AUTO-BACKUP CLOUD SETTINGS${BICyan}           │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    
    # Check current status
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
    TYPE=$(cat /etc/edu_backup_type 2>/dev/null || echo "none")

    if [[ "$STATUS" == "on" ]]; then
        STATUS_TEXT="${BIGreen}ON${NC}"
    else
        STATUS_TEXT="${BIRed}OFF${NC}"
    fi

    echo -e "   Current Status: $STATUS_TEXT"
    echo -e "   Current Method: ${BIWhite}$TYPE${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────${NC}"
    echo -e "   ${BICyan}[1]${NC} Turn Auto-Backup ${BIGreen}ON${NC}"
    echo -e "   ${BICyan}[2]${NC} Turn Auto-Backup ${BIRed}OFF${NC}"
    echo -e "   ${BICyan}[3]${NC} Configure Telegram"
    echo -e "   ${BICyan}[4]${NC} Configure Discord"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC} Return to Menu"
    echo ""
    read -p "   Select > " b_opt

    case $b_opt in
        1) echo "on" > /etc/edu_backup_status; echo -e "${BIGreen}Auto-Backup Enabled!${NC}"; sleep 1; backup_settings ;;
        2) echo "off" > /etc/edu_backup_status; echo -e "${BIRed}Auto-Backup Disabled!${NC}"; sleep 1; backup_settings ;;
        3) 
            clear
            echo -e "${BIYellow}SETUP TELEGRAM${NC}"
            echo -e "Get Token from @BotFather"
            read -p "Enter Bot Token: " tg_token
            echo -e "Get Chat ID from @userinfobot"
            read -p "Enter Chat ID: " tg_id
            echo "$tg_token" > /etc/edu_backup_tg_token
            echo "$tg_id" > /etc/edu_backup_tg_id
            echo "telegram" > /etc/edu_backup_type
            echo -e "${BIGreen}Telegram Configured!${NC}"
            sleep 1; backup_settings ;;
        4)
            clear
            echo -e "${BIYellow}SETUP DISCORD${NC}"
            echo -e "Create a Webhook in your Discord Channel settings"
            read -p "Enter Webhook URL: " dc_url
            echo "$dc_url" > /etc/edu_backup_dc_url
            echo "discord" > /etc/edu_backup_type
            echo -e "${BIGreen}Discord Configured!${NC}"
            sleep 1; backup_settings ;;
        0) menu ;;
        *) backup_settings ;;
    esac
}

function upload_backup() {
    # Check if feature is enabled
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
    if [[ "$STATUS" != "on" ]]; then
        return
    fi

    TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
    FILE_PATH="/tmp/vpn_backup.zip"
    CAPTION="Auto-Backup: $(date '+%Y-%m-%d %H:%M:%S') | IP: $MYIP"

    echo -e "${GRAY}Uploading backup to $TYPE...${NC}"

    if [[ "$TYPE" == "telegram" ]]; then
        TG_TOKEN=$(cat /etc/edu_backup_tg_token)
        TG_ID=$(cat /etc/edu_backup_tg_id)
        if [[ -n "$TG_TOKEN" && -n "$TG_ID" ]]; then
            curl -s -F document=@"$FILE_PATH" -F caption="$CAPTION" "https://api.telegram.org/bot$TG_TOKEN/sendDocument?chat_id=$TG_ID" > /dev/null
            echo -e "${BIGreen}Sent to Telegram!${NC}"
        else
            echo -e "${BIRed}Telegram config missing!${NC}"
        fi
    
    elif [[ "$TYPE" == "discord" ]]; then
        DC_URL=$(cat /etc/edu_backup_dc_url)
        if [[ -n "$DC_URL" ]]; then
            curl -s -F "file=@$FILE_PATH" -F "content=$CAPTION" "$DC_URL" > /dev/null
            echo -e "${BIGreen}Sent to Discord!${NC}"
        else
            echo -e "${BIRed}Discord config missing!${NC}"
        fi
    fi
}

# =========================================================
# INTERNAL FUNCTIONS
# =========================================================

# --- SILENT AUTO BACKUP ---
function auto_backup() {
    echo -e ""
    echo -e "${GRAY}Auto-updating backup configuration...${NC}"
    
    mkdir -p /root/backup_edu
    mkdir -p /root/backup_edu/ssh_backup
    
    # Copy Data
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /root/backup_edu/ssh_backup/
    cp /etc/shadow /root/backup_edu/ssh_backup/
    cp /etc/group /root/backup_edu/ssh_backup/
    cp /etc/gshadow /root/backup_edu/ssh_backup/
    
    # Zip & Permission
    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    chmod 777 /tmp/vpn_backup.zip
    
    # Cleanup
    rm -rf /root/backup_edu
    
    # TRIGGER UPLOAD
    upload_backup
    
    echo -e "${BIGreen}Backup Synced!${NC}"
    sleep 1
    menu
}

# --- LIST ACTIVE USERS ---
function list_active() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │            ${BIGreen}ACTIVE USER ACCOUNTS${BICyan}               │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${BIYellow} [ SSH / TUNNEL (Active) ]${NC}"
    echo -e "${BIWhite} ───────────────────────────────────────────────${NC}"
    today=$(date +%s)
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" == *"never"* ]]; then
                 echo -e "  - ${BIGreen}$username${NC} (Lifetime)"
            else
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -ge $today ]]; then
                     echo -e "  - ${BIGreen}$username${NC} (Expires: $exp_date)"
                 fi
            fi
        fi
    done < /etc/passwd
    echo -e ""
    echo -e "${BIYellow} [ V2RAY / XRAY (Configured) ]${NC}"
    echo -e "${BIWhite} ───────────────────────────────────────────────${NC}"
    if [ -f "/etc/xray/config.json" ]; then
        grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  - ${BIGreen}/" | sed "s/$/${NC}/"
    else
        echo -e "  ${GRAY}(No active Xray config found)${NC}"
    fi
    echo -e ""
    echo -e "${BICyan}=================================================${NC}"
    read -n 1 -s -r -p "Press any key to return..."
    menu
}

# --- LIST EXPIRED USERS ---
function list_expired() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIRed}EXPIRED USER ACCOUNTS${BICyan}               │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e ""
    echo -e "${BIYellow} [ SSH / TUNNEL (Expired) ]${NC}"
    echo -e "${BIWhite} ───────────────────────────────────────────────${NC}"
    today=$(date +%s)
    count=0
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" != *"never"* ]]; then
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -lt $today && -n "$exp_sec" ]]; then
                     echo -e "  - ${BIRed}$username${NC} (Expired: $exp_date)"
                     ((count++))
                 fi
            fi
        fi
    done < /etc/passwd
    if [[ $count -eq 0 ]]; then
        echo -e "  ${BIGreen}(No expired SSH users found)${NC}"
    fi
    echo -e ""
    echo -e "${BIYellow} [ V2RAY / XRAY ]${NC}"
    echo -e "${BIWhite} ───────────────────────────────────────────────${NC}"
    if [ -f "/etc/xray/expired_users.db" ]; then
        cat /etc/xray/expired_users.db
    else
        echo -e "  ${GRAY}(Manual check required for V2Ray)${NC}"
    fi
    echo -e ""
    echo -e "${BICyan}=================================================${NC}"
    read -n 1 -s -r -p "Press any key to return..."
    menu
}

# --- RESTORE BACKUP ---
function restore_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       RESTORE BACKUP CONFIGURATION      ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    echo -e "Instructions:"
    echo -e "1. Upload ${BIWhite}'vpn_backup.zip'${NC} to ${BIWhite}/tmp${NC}."
    echo -e ""
    read -p "Have you uploaded the file? [y/n]: " ans
    if [[ "$ans" != "y" ]]; then menu; fi

    echo -e ""
    echo -e "${BIYellow}[Checking File...]${NC}"
    if [ ! -f "/tmp/vpn_backup.zip" ]; then
        echo -e "${BIRed}Error: File not found in /tmp/vpn_backup.zip${NC}"
        sleep 3
        menu
    fi

    echo -e "${BIGreen}File found! Restoring...${NC}"
    mkdir -p /root/restore_temp
    unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1

    echo -e "${BIWhite}  [+] Restoring Data...${NC}"
    rm -rf /etc/xray/*
    cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp -r /root/restore_temp/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null

    rm -rf /root/restore_temp
    echo -e "${BIWhite}  [+] Restarting Services...${NC}"
    systemctl restart ssh
    systemctl restart sshd
    systemctl restart xray
    
    echo -e "${BIGreen}       ✅ RESTORE COMPLETED   ${NC}"
    read -n 1 -s -r -p "Press any key to reload menu..."
    menu
}

function change_banner() {
    clear
    if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi
    nano /etc/issue.net
    service ssh restart
    service sshd restart
    menu
}

# --- SELECTORS WITH AUTO-BACKUP TRIGGER ---
function renew_selector() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}RENEW USER ACCOUNT${BICyan}                  │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e "   ${BICyan}[1]${NC}  Renew SSH / WS Account"
    echo -e "   ${BICyan}───────────────────────────────────────────────${NC}"
    echo -e "   ${BICyan}[2]${NC}  Renew VMess Account"
    echo -e "   ${BICyan}[3]${NC}  Renew VLESS Account"
    echo -e "   ${BICyan}[4]${NC}  Renew Trojan Account"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC}  ${BIRed}Cancel${NC}"
    echo ""
    read -p "   Select > " r_opt
    case $r_opt in
        1) clear ; renew ; auto_backup ;;        
        2) clear ; renew-ws ; auto_backup ;;     
        3) clear ; renew-vless ; auto_backup ;;  
        4) clear ; renew-tr ; auto_backup ;;     
        0) menu ;;
        *) menu ;;
    esac
}

function create_account_selector() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}SELECT PROTOCOL TYPE${BICyan}                │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e "   ${BICyan}[1]${NC}  VMess Account  ${GRAY}(Standard WebSocket)${NC}"
    echo -e "   ${BICyan}[2]${NC}  VLESS Account  ${GRAY}(Lightweight/Fast)${NC}"
    echo -e "   ${BICyan}[3]${NC}  Trojan Account ${GRAY}(Anti-Detection)${NC}"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC}  ${BIRed}Cancel${NC}"
    echo ""
    read -p "   Select > " p_opt
    case $p_opt in
        1) clear ; add-ws ; auto_backup ;;
        2) clear ; add-vless ; auto_backup ;;
        3) clear ; add-tr ; auto_backup ;;
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

function backup_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       BACKUP ALL USERS (SSH + VPN)      ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    mkdir -p /root/backup_edu
    mkdir -p /root/backup_edu/ssh_backup
    
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /root/backup_edu/ssh_backup/
    cp /etc/shadow /root/backup_edu/ssh_backup/
    cp /etc/group /root/backup_edu/ssh_backup/
    cp /etc/gshadow /root/backup_edu/ssh_backup/
    
    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    chmod 777 /tmp/vpn_backup.zip
    rm -rf /root/backup_edu
    
    echo -e "${BIGreen}Backup created successfully!${NC}"
    echo -e "${BIWhite}Location: ${BIYellow}/tmp/vpn_backup.zip${NC}"
    sleep 4
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
    
    # --- TIME & BANDWIDTH LOGIC ---
    SERVER_TIME=$(date "+%H:%M:%S")
    # Using vnstat for bandwidth (Requires vnstat installed)
    BW_TODAY=$(vnstat -d --oneline | awk -F\; '{print $6}' 2>/dev/null || echo "N/A")
    BW_MONTH=$(vnstat -m --oneline | awk -F\; '{print $11}' 2>/dev/null || echo "N/A")

    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │ ${BIWhite}●${NC}           ${BIYellow}EDUFWESH VPN MANAGER ${BIWhite}PRO v12.6${NC}            ${BICyan}│${NC}"
    echo -e "${BICyan} ├──────────────────────────────┬────────────────────────────┤${NC}"
    echo -e "${BICyan} │${NC} ${GRAY}NETWORK INFO${NC}                 ${BICyan}│${NC} ${GRAY}SYSTEM STATUS${NC}              ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}IP${NC}   : $MYIP       ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}RAM${NC}  : $RAM_USED / ${RAM_TOTAL}MB    ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}ISP${NC}  : $ISP   ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}TIME${NC} : $SERVER_TIME       ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}DOM${NC}  : $DOMAIN     ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}UP${NC}   : $UPTIME   ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC} ${BICyan}»${NC} ${BIWhite}NS${NC}   : $NS_DOMAIN    ${BICyan}│${NC} ${BICyan}»${NC} ${BIWhite}LOAD${NC} : $LOAD           ${BICyan}│${NC}"
    echo -e "${BICyan} ├──────────────────────────────┴────────────────────────────┤${NC}"
    echo -e "${BICyan} │${NC}              ${BIYellow}BANDWIDTH MONITORING (VNSTAT)${NC}               ${BICyan}│${NC}"
    echo -e "${BICyan} │${NC}     ${BIGreen}TODAY:${NC} $BW_TODAY           ${BIGreen}MONTH:${NC} $BW_MONTH          ${BICyan}│${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────────────────┘${NC}"
}

function show_menu() {
    show_dashboard
    echo -e ""
    echo -e "   ${BIYellow}USER ACCOUNTS${NC}"
    echo -e "   ${BICyan}• 01${NC}  Create SSH / WS Account"
    echo -e "   ${BICyan}• 02${NC}  Create V2Ray Account ${BIYellow}(Multi-Proto)${NC}"
    echo -e "   ${BICyan}• 03${NC}  Renew User Services ${GRAY}(SSH/Xray)${NC}"
    echo -e "   ${BICyan}• 04${NC}  User Details & Monitor"
    echo -e "   ${BICyan}• 05${NC}  List Active Users"
    echo -e "   ${BICyan}• 06${NC}  List Expired Users"
    echo -e "   ${BICyan}• 07${NC}  Delete / Lock User"
    echo -e ""
    echo -e "   ${BIYellow}SYSTEM TOOLS${NC}"
    echo -e "   ${BICyan}• 08${NC}  Detailed System Status"
    echo -e "   ${BICyan}• 09${NC}  Speedtest Benchmark"
    echo -e "   ${BICyan}• 10${NC}  Reboot Server"
    echo -e "   ${BICyan}• 11${NC}  Clear RAM & Logs"
    echo -e ""
    echo -e "   ${BIYellow}ADVANCED SETTINGS${NC}"
    echo -e "   ${BICyan}• 12${NC}  Fix SSL / Restart Services"
    echo -e "   ${BICyan}• 13${NC}  Auto-Reboot Scheduler"
    echo -e "   ${BICyan}• 14${NC}  Backup Configurations"
    echo -e "   ${BICyan}• 15${NC}  Restore Backup"
    echo -e "   ${BICyan}• 16${NC}  Change Domain / Host"
    echo -e "   ${BICyan}• 17${NC}  Change Name Server (NS)"
    echo -e "   ${BICyan}• 18${NC}  Change SSH Banner Message"
    echo -e "   ${BICyan}• 19${NC}  Auto-Backup Settings ${BIYellow}(NEW)${NC}"
    echo -e ""
    echo -e "   ${BICyan}• 00${NC}  ${BIRed}Exit Dashboard${NC}"
    echo -e ""
    echo -e "${BICyan} ─────────────────────────────────────────────────────────────${NC}"
    read -p "   Select Option »  " opt

    case $opt in
        01 | 1) clear ; usernew ; auto_backup ;; 
        02 | 2) clear ; create_account_selector ;;
        03 | 3) clear ; renew_selector ;;
        04 | 4) clear ; cek ;;             
        05 | 5) clear ; list_active ;;     
        06 | 6) clear ; list_expired ;;    
        07 | 7) clear ; member ;;          
        08 | 8) clear ; detailed_status ;;
        09 | 9) clear ; speedtest ;;
        10 | 10) clear ; reboot ;;
        11 | 11) clear ; clear_cache ;;
        12 | 12) clear ; fix_services ;;
        13 | 13) clear ; auto_reboot ;;
        14 | 14) clear ; backup_configs ;;
        15 | 15) clear ; restore_configs ;; 
        16 | 16) clear ; change_domain ;;
        17 | 17) clear ; change_ns ;;
        18 | 18) clear ; change_banner ;;
        19 | 19) clear ; backup_settings ;;
        00 | 0) clear ; exit 0 ;;
        *) show_menu ;;
    esac
}

# Start the menu
show_menu

