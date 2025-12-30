#!/bin/bash

# =========================================================
# EDUFWESH MANAGER - ULTIMATE ENTERPRISE v14.3
# (UI: Extended Dashboard Header | Logic: v14.2 Core)
# =========================================================

# --- 1. THEME ENGINE ---
THEME_FILE="/etc/edu_theme"
if [ ! -f "$THEME_FILE" ]; then echo "blue" > "$THEME_FILE"; fi
CURr_THEME=$(cat "$THEME_FILE")

# Define Colors based on Theme
case $CURr_THEME in
    "green") # Hacker Matrix
        C_MAIN='\033[1;32m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;32m' ;;
    "purple") # Cyber Punk
        C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;35m' ;;
    "red") # Admin Alert
        C_MAIN='\033[1;31m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    *) # Corporate Blue (Default)
        C_MAIN='\033[1;34m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;34m' ;;
esac

RESET='\033[0m'; C_LABEL='\033[0;90m'; C_SUCCESS='\033[1;32m'; C_ALERT='\033[1;91m'

# --- 2. INITIALIZATION & DEPENDENCIES ---
function init_sys() {
    if ! command -v zip &> /dev/null || ! command -v bc &> /dev/null; then
        echo -e "${C_LABEL}Initializing system modules...${RESET}"
        apt-get update >/dev/null 2>&1
        apt-get install zip unzip curl bc net-tools -y >/dev/null 2>&1
    fi
}
init_sys

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/etc/slowdns/nsdomain" ]; then NS_DOMAIN=$(cat /etc/slowdns/nsdomain);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# 3. BACKGROUND WATCHDOG (The "Auto-Backup" Fix)
# =========================================================
function start_backup_watchdog() {
    (
        SUM_BEFORE=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
        for i in {1..18}; do
            sleep 5
            SUM_AFTER=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
            if [[ "$SUM_BEFORE" != "$SUM_AFTER" ]]; then
                STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
                if [[ "$STATUS" == "on" ]]; then
                    mkdir -p /root/backup_edu/ssh_backup
                    mkdir -p /root/backup_edu/xray_backup
                    cp -r /etc/xray/* /root/backup_edu/xray_backup/ 2>/dev/null
                    cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
                    rm -f /tmp/vpn_backup.zip
                    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
                    chmod 777 /tmp/vpn_backup.zip
                    rm -rf /root/backup_edu

                    TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
                    CAPTION="Auto-Backup [New User Event] | IP: $MYIP"
                    FILE="/tmp/vpn_backup.zip"

                    if [[ "$TYPE" == "discord" ]]; then
                        URL=$(cat /etc/edu_backup_dc_url)
                        curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null
                    elif [[ "$TYPE" == "telegram" ]]; then
                        T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id)
                        curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null
                    fi
                fi
                exit 0
            fi
        done
    ) & > /dev/null 2>&1
}

# =========================================================
# 4. VISUAL GAUGE FUNCTION
# =========================================================
function draw_bar() {
    # Usage: draw_bar <percentage>
    local pct=$1
    local width=18
    local fill=$(echo "$pct / 100 * $width" | bc -l | awk '{printf("%d",$1 + 0.5)}')
    
    printf "["
    for ((i=0; i<fill; i++)); do printf "${C_BAR}█${RESET}"; done
    for ((i=fill; i<width; i++)); do printf "${C_LABEL}░${RESET}"; done
    printf "] ${pct}%%"
}

# =========================================================
# 5. RESTORED LOGIC FUNCTIONS (Feature Parity v12.9)
# =========================================================

function list_active() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_TEXT}ACTIVE USER DATABASE${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_ACCENT} SSH ACCOUNTS${RESET}"
    today=$(date +%s)
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" == *"never"* ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} (Lifetime)";
            else
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -ge $today ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} ($exp_date)"; fi
            fi
        fi
    done < /etc/passwd
    echo ""
    echo -e "${C_ACCENT} XRAY PROTOCOLS${RESET}"
    if [ -f "/etc/xray/config.json" ]; then
        grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  ● ${C_SUCCESS}/" | sed "s/$/${RESET}/"
    fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -n 1 -s -r -p "Press any key to return..."
    menu
}

function list_expired() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_ALERT}EXPIRED USER ACCOUNTS${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    today=$(date +%s); count=0
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" != *"never"* ]]; then
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -lt $today && -n "$exp_sec" ]]; then
                     echo -e "  ● ${C_ALERT}$username${RESET} (Expired: $exp_date)"
                     ((count++))
                 fi
            fi
        fi
    done < /etc/passwd
    if [[ $count -eq 0 ]]; then echo -e "  ${C_SUCCESS}(No expired SSH users found)${RESET}"; fi
    echo ""
    echo -e "${C_ACCENT} XRAY PROTOCOLS${RESET}"
    if [ -f "/etc/xray/expired_users.db" ]; then cat /etc/xray/expired_users.db; else echo "  (No expired Xray users)"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -n 1 -s -r -p "Press any key to return..."
    menu
}

function restore_configs() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_ACCENT}RESTORE BACKUP${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "1. Upload 'vpn_backup.zip' to /tmp/ folder."
    read -p "Are you ready? [y/n]: " ans
    if [[ "$ans" != "y" ]]; then menu; fi
    
    if [ ! -f "/tmp/vpn_backup.zip" ]; then
        echo -e "${C_ALERT}File not found in /tmp/vpn_backup.zip!${RESET}"
        sleep 2; menu
    fi
    
    echo -e "${C_LABEL}Restoring...${RESET}"
    mkdir -p /root/restore_temp
    unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*
    cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null
    rm -rf /root/restore_temp
    
    systemctl restart ssh sshd xray
    echo -e "${C_SUCCESS}Restore Complete! Services Restarted.${RESET}"
    sleep 2; menu
}

function auto_reboot() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_TEXT}AUTO-REBOOT SCHEDULER${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Enable Daily Reboot (00:00)"
    echo -e "  [2] Disable Auto-Reboot"
    echo ""
    read -p "Select > " x
    if [[ "$x" == "1" ]]; then
        echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu
        echo -e "${C_SUCCESS}Enabled!${RESET}"
    elif [[ "$x" == "2" ]]; then
        rm -f /etc/cron.d/auto_reboot_edu
        echo -e "${C_ALERT}Disabled!${RESET}"
    fi
    sleep 1; menu
}

function change_banner() {
    clear
    if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi
    nano /etc/issue.net
    echo -e "${C_LABEL}Restarting SSH...${RESET}"
    service ssh restart
    service sshd restart
    menu
}

function change_domain() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "Current: $DOMAIN"
    read -p "New Domain: " d
    if [[ -n "$d" ]]; then
        echo "$d" > /etc/xray/domain
        echo "$d" > /root/domain
        echo -e "${C_LABEL}Restarting Xray/Nginx...${RESET}"
        systemctl restart nginx xray
        echo -e "${C_SUCCESS}Updated!${RESET}"
    fi
    sleep 1; menu
}

function detailed_status() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}           SYSTEM DIAGNOSTICS${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # 1. Services
    echo -e "${C_ACCENT}SERVICE STATUS:${RESET}"
    if systemctl is-active --quiet ssh; then echo -e "  SSH Service: ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  SSH Service: ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet xray; then echo -e "  Xray Core  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Xray Core  : ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet nginx; then echo -e "  Nginx Web  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Nginx Web  : ${C_ALERT}STOPPED${RESET}"; fi

    # 2. Protocols
    echo -e ""
    echo -e "${C_ACCENT}ACTIVE PROTOCOLS (In Config):${RESET}"
    CONFIG="/etc/xray/config.json"
    if [ -f "$CONFIG" ]; then
        if grep -q "vmess" "$CONFIG"; then echo -e "  VMess      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VMess      : ${C_LABEL}NOT FOUND${RESET}"; fi
        if grep -q "vless" "$CONFIG"; then echo -e "  VLESS      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VLESS      : ${C_LABEL}NOT FOUND${RESET}"; fi
        if grep -q "trojan" "$CONFIG"; then echo -e "  Trojan     : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  Trojan     : ${C_LABEL}NOT FOUND${RESET}"; fi
    else
        echo -e "${C_ALERT}  Config file missing!${RESET}"
    fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -n 1 -s -r -p "Press any key to return..."
    menu
}

# =========================================================
# 6. SETTINGS & THEMES
# =========================================================
function theme_switcher() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}           INTERFACE THEME SELECTOR${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Corporate Blue (Default)"
    echo -e "  [2] Hacker Green"
    echo -e "  [3] Cyber Purple"
    echo -e "  [4] Admin Red"
    echo -e ""
    read -p "Select > " t_opt
    case $t_opt in
        1) echo "blue" > /etc/edu_theme ;;
        2) echo "green" > /etc/edu_theme ;;
        3) echo "purple" > /etc/edu_theme ;;
        4) echo "red" > /etc/edu_theme ;;
    esac
    echo -e "${C_SUCCESS}Theme Applied! Reloading...${RESET}"
    sleep 1
    exec "$0"
}

function backup_settings() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}       CLOUD SYNC CONFIGURATION${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
    TYPE=$(cat /etc/edu_backup_type 2>/dev/null || echo "none")
    if [[ "$STATUS" == "on" ]]; then S_TXT="${C_SUCCESS}● ENABLED${RESET}"; else S_TXT="${C_ALERT}● DISABLED${RESET}"; fi
    echo -e "  Status: $S_TXT    Method: ${C_ACCENT}${TYPE^^}${RESET}"
    echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"
    echo -e "  [1] Enable Sync        [3] Setup Telegram"
    echo -e "  [2] Disable Sync       [4] Setup Discord"
    echo -e "  [5] ${C_ACCENT}Test Connection Now${RESET}"
    echo -e "  [6] ${C_MAIN}Change Interface Theme${RESET}"
    echo -e ""
    echo -e "  [0] Return"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " b_opt
    case $b_opt in
        1) echo "on" > /etc/edu_backup_status; backup_settings ;;
        2) echo "off" > /etc/edu_backup_status; backup_settings ;;
        3) clear; read -p "Token: " t; read -p "Chat ID: " i; echo "$t" > /etc/edu_backup_tg_token; echo "$i" > /etc/edu_backup_tg_id; echo "telegram" > /etc/edu_backup_type; backup_settings ;;
        4) clear; read -p "Webhook: " d; echo "$d" > /etc/edu_backup_dc_url; echo "discord" > /etc/edu_backup_type; backup_settings ;;
        5) auto_backup "force"; read -n 1 -s -r -p "Key..."; backup_settings ;;
        6) theme_switcher ;;
        0) menu ;;
        *) backup_settings ;;
    esac
}

function auto_backup() {
    MODE=$1
    if [[ "$MODE" == "force" ]]; then
        echo -e "${C_LABEL}Snapshotting system...${RESET}"
        mkdir -p /root/backup_edu/ssh_backup
        cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
        cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
        rm -f /tmp/vpn_backup.zip
        zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
        rm -rf /root/backup_edu
        
        TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
        FILE="/tmp/vpn_backup.zip"
        CAPTION="Manual Test: $(date) | IP: $MYIP"
        if [[ "$TYPE" == "discord" ]]; then
            URL=$(cat /etc/edu_backup_dc_url)
            curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null
            echo -e "${C_SUCCESS}Sent to Discord.${RESET}"
        elif [[ "$TYPE" == "telegram" ]]; then
            T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id)
            curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null
            echo -e "${C_SUCCESS}Sent to Telegram.${RESET}"
        fi
        sleep 1
    fi
}

# =========================================================
# 7. DASHBOARD & MENU
# =========================================================

function show_dashboard() {
    # -- CALC METRICS --
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    RAM_USED=$(free -m | awk 'NR==2{print $3}')
    RAM_PCT=$(echo "$RAM_USED / $RAM_TOTAL * 100" | bc -l | awk '{printf("%d",$1)}')
    
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' ')
    LOAD_PCT=$(echo "$LOAD * 100 / 4" | bc -l | awk '{printf("%d",$1)}')
    if [ "$LOAD_PCT" -gt 100 ]; then LOAD_PCT=100; fi

    # -- SECURITY AUDIT & TIME --
    SERVER_TIME=$(date "+%H:%M:%S")
    LAST_LOGIN=$(last -n 1 -a | head -n 1 | awk '{print $10 " (" $3 ")"}') # Shortened for layout
    
    # -- SERVICE CHECK --
    if systemctl is-active --quiet ssh; then S_SSH="${C_SUCCESS}ONLINE${RESET}"; else S_SSH="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet xray; then S_XRAY="${C_SUCCESS}ONLINE${RESET}"; else S_XRAY="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet nginx; then S_NGINX="${C_SUCCESS}ONLINE${RESET}"; else S_NGINX="${C_ALERT}OFFLINE${RESET}"; fi

    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}  EDUFWESH ENTERPRISE MANAGER${RESET}            ${C_LABEL}v14.3 ULT${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    # -- UPDATED HEADER LAYOUT --
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "Host" "$DOMAIN" "Time" "$SERVER_TIME"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "IP" "$MYIP" "ISP" "$ISP"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "NS" "$NS_DOMAIN" "Sec" "$LAST_LOGIN"
    echo -e "${C_LABEL}──────────────────────────────────────────────────────────${RESET}"
    
    # -- VISUAL GAUGES --
    echo -ne "  ${C_LABEL}RAM :${RESET} "; draw_bar $RAM_PCT; echo ""
    echo -ne "  ${C_LABEL}CPU :${RESET} "; draw_bar $LOAD_PCT; echo ""
    
    echo -e ""
    echo -e "  ${C_LABEL}SSH :${RESET} $S_SSH       ${C_LABEL}XRAY :${RESET} $S_XRAY      ${C_LABEL}WEB :${RESET} $S_NGINX"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

function show_menu() {
    show_dashboard
    echo -e "  ${C_ACCENT}USER MANAGEMENT${RESET}"
    echo -e "  [01] Create User Account   [04] Monitor Users"
    echo -e "  [02] Create Xray Account   [05] List Active Users"
    echo -e "  [03] Renew User Services   [06] List Expired"
    echo -e "  [07] Lock/Unlock User"
    echo -e ""
    echo -e "  ${C_ACCENT}SERVER OPERATIONS${RESET}"
    echo -e "  [08] System Diagnostics    [12] Restart Services"
    echo -e "  [09] Speedtest Benchmark   [13] Auto-Reboot Task"
    echo -e "  [10] Reboot Server         [14] Manual Backup"
    echo -e "  [11] Clear RAM Cache       [15] Restore Backup"
    echo -e ""
    echo -e "  ${C_ACCENT}CONFIGURATION & CLOUD${RESET}"
    echo -e "  [16] Update Domain Host    [18] SSH Banner Editor"
    echo -e "  [17] Update NameServer     [19] ${C_TEXT}Settings & Cloud${RESET}"
    echo -e ""
    echo -e "  [00] Exit Dashboard"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "  Enter Selection » " opt

    case $opt in
        01|1) clear; start_backup_watchdog; usernew ;;
        02|2) clear; start_backup_watchdog; add-ws ;;
        03|3) clear; start_backup_watchdog; renew ;;
        04|4) clear; cek ;;
        05|5) list_active ;;
        06|6) list_expired ;;
        07|7) clear; member ;;
        08|8) detailed_status ;;
        09|9) clear; speedtest ;;
        10|10) reboot ;;
        11|11) sync; echo 3 > /proc/sys/vm/drop_caches; menu ;;
        12|12) systemctl restart ssh xray nginx; menu ;;
        13|13) auto_reboot ;;
        14|14) auto_backup "force"; menu ;;
        15|15) restore_configs ;;
        16|16) change_domain ;;
        17|17) clear; read -p "New NS: " n; echo "$n" > /etc/xray/dns; menu ;;
        18|18) change_banner ;;
        19|19) backup_settings ;;
        00|0) exit 0 ;;
        *) menu ;;
    esac
}

# --- ALIAS ---
function menu() { show_menu; }

# Start
show_menu
