#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - MONITOR EDITION v12.8
# (Fixed: Background Watchdog for Reliable Auto-Uploads)
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

# --- ENSURE DEPENDENCIES ---
if ! command -v zip &> /dev/null; then
    echo -e "${GRAY}Installing dependencies...${NC}"
    apt-get update >/dev/null 2>&1
    apt-get install zip unzip curl -y >/dev/null 2>&1
fi

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/etc/slowdns/nsdomain" ]; then NS_DOMAIN=$(cat /etc/slowdns/nsdomain);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# 1. INTELLIGENT BACKUP WATCHDOG (THE FIX)
# =========================================================

function start_backup_watchdog() {
    # This function spawns a background process that survives menu reloads.
    # It monitors /etc/passwd and config.json for changes.
    (
        # 1. Snapshot state before user creation
        SUM_BEFORE=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
        
        # 2. Loop for 90 seconds (Time given to create user)
        for i in {1..18}; do
            sleep 5
            SUM_AFTER=$(md5sum /etc/passwd /etc/xray/config.json 2>/dev/null)
            
            # 3. If files changed, trigger upload immediately
            if [[ "$SUM_BEFORE" != "$SUM_AFTER" ]]; then
                
                # Check if Backup is ON
                STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
                if [[ "$STATUS" == "on" ]]; then
                    
                    # Prepare Backup
                    mkdir -p /root/backup_edu/ssh_backup
                    mkdir -p /root/backup_edu/xray_backup
                    cp -r /etc/xray/* /root/backup_edu/xray_backup/ 2>/dev/null
                    cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
                    
                    rm -f /tmp/vpn_backup.zip
                    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
                    chmod 777 /tmp/vpn_backup.zip
                    rm -rf /root/backup_edu

                    # Upload
                    TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
                    CAPTION="Auto-Backup (New User Added): $(date '+%Y-%m-%d %H:%M:%S') | IP: $MYIP"
                    FILE_PATH="/tmp/vpn_backup.zip"

                    if [[ "$TYPE" == "discord" ]]; then
                        DC_URL=$(cat /etc/edu_backup_dc_url)
                        curl -s -X POST -H "User-Agent: Mozilla/5.0" \
                             -F "payload_json={\"content\": \"$CAPTION\"}" \
                             -F "file=@$FILE_PATH" "$DC_URL" > /dev/null
                    elif [[ "$TYPE" == "telegram" ]]; then
                        TG_TOKEN=$(cat /etc/edu_backup_tg_token)
                        TG_ID=$(cat /etc/edu_backup_tg_id)
                        curl -s -F document=@"$FILE_PATH" -F caption="$CAPTION" \
                             "https://api.telegram.org/bot$TG_TOKEN/sendDocument?chat_id=$TG_ID" > /dev/null
                    fi
                fi
                exit 0 # Stop monitoring after success
            fi
        done
    ) & > /dev/null 2>&1
}

# =========================================================
# 2. BACKUP SETTINGS & MANUAL TRIGGER
# =========================================================

function backup_settings() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │          ${BIYellow}AUTO-BACKUP CLOUD SETTINGS${BICyan}           │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
    TYPE=$(cat /etc/edu_backup_type 2>/dev/null || echo "none")

    if [[ "$STATUS" == "on" ]]; then STATUS_TEXT="${BIGreen}ON${NC}"; else STATUS_TEXT="${BIRed}OFF${NC}"; fi

    echo -e "   Current Status: $STATUS_TEXT"
    echo -e "   Current Method: ${BIWhite}$TYPE${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────${NC}"
    echo -e "   ${BICyan}[1]${NC} Turn Auto-Backup ${BIGreen}ON${NC}"
    echo -e "   ${BICyan}[2]${NC} Turn Auto-Backup ${BIRed}OFF${NC}"
    echo -e "   ${BICyan}[3]${NC} Configure Telegram"
    echo -e "   ${BICyan}[4]${NC} Configure Discord"
    echo -e "   ${BICyan}[5]${NC} ${BIYellow}TEST BACKUP NOW${NC}"
    echo -e ""
    echo -e "   ${BICyan}[0]${NC} Return to Menu"
    echo ""
    read -p "   Select > " b_opt

    case $b_opt in
        1) echo "on" > /etc/edu_backup_status; echo -e "${BIGreen}Auto-Backup Enabled!${NC}"; sleep 1; backup_settings ;;
        2) echo "off" > /etc/edu_backup_status; echo -e "${BIRed}Auto-Backup Disabled!${NC}"; sleep 1; backup_settings ;;
        3) 
            clear; echo -e "${BIYellow}SETUP TELEGRAM${NC}"; read -p "Bot Token: " tg_token; read -p "Chat ID: " tg_id;
            echo "$tg_token" > /etc/edu_backup_tg_token; echo "$tg_id" > /etc/edu_backup_tg_id; echo "telegram" > /etc/edu_backup_type;
            echo -e "${BIGreen}Saved!${NC}"; sleep 1; backup_settings ;;
        4)
            clear; echo -e "${BIYellow}SETUP DISCORD${NC}"; read -p "Webhook URL: " dc_url;
            echo "$dc_url" > /etc/edu_backup_dc_url; echo "discord" > /etc/edu_backup_type;
            echo -e "${BIGreen}Saved!${NC}"; sleep 1; backup_settings ;;
        5)
            auto_backup "force"; echo -e "" ; read -n 1 -s -r -p "Press any key..."; backup_settings ;;
        0) menu ;;
        *) backup_settings ;;
    esac
}

function auto_backup() {
    MODE=$1
    echo -e ""; echo -e "${GRAY}Syncing backup configuration...${NC}"
    mkdir -p /root/backup_edu/ssh_backup
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
    rm -f /tmp/vpn_backup.zip
    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    chmod 777 /tmp/vpn_backup.zip
    rm -rf /root/backup_edu
    
    # MANUAL/FORCE UPLOAD LOGIC
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off")
    if [[ "$MODE" == "force" ]]; then
        TYPE=$(cat /etc/edu_backup_type 2>/dev/null)
        FILE_PATH="/tmp/vpn_backup.zip"
        CAPTION="Manual Backup Test: $(date '+%Y-%m-%d %H:%M:%S')"
        
        if [[ "$TYPE" == "discord" ]]; then
            DC_URL=$(cat /etc/edu_backup_dc_url)
            curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE_PATH" "$DC_URL" > /dev/null
            if [ $? -eq 0 ]; then echo -e "${BIGreen}Sent to Discord!${NC}"; else echo -e "${BIRed}Failed! Check URL.${NC}"; fi
        elif [[ "$TYPE" == "telegram" ]]; then
            TG_TOKEN=$(cat /etc/edu_backup_tg_token); TG_ID=$(cat /etc/edu_backup_tg_id)
            curl -s -F document=@"$FILE_PATH" -F caption="$CAPTION" "https://api.telegram.org/bot$TG_TOKEN/sendDocument?chat_id=$TG_ID" > /dev/null
            echo -e "${BIGreen}Sent to Telegram!${NC}"
        fi
    fi
    if [[ "$MODE" == "force" ]]; then sleep 1; fi
}

function backup_configs() {
    auto_backup "force"; sleep 2; menu
}

# =========================================================
# 3. STANDARD SYSTEM FUNCTIONS (Preserved)
# =========================================================

function list_active() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │            ${BIGreen}ACTIVE USER ACCOUNTS${BICyan}               │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    today=$(date +%s)
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" == *"never"* ]]; then echo -e "  - ${BIGreen}$username${NC} (Lifetime)";
            else
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -ge $today ]]; then echo -e "  - ${BIGreen}$username${NC} (Expires: $exp_date)"; fi
            fi
        fi
    done < /etc/passwd
    echo -e ""
    if [ -f "/etc/xray/config.json" ]; then
        grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  - ${BIGreen}/" | sed "s/$/${NC}/"
    fi
    echo -e "${BICyan}=================================================${NC}"
    read -n 1 -s -r -p "Press any key..."
    menu
}

function list_expired() {
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIRed}EXPIRED USER ACCOUNTS${BICyan}               │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    today=$(date +%s); count=0
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
    if [[ $count -eq 0 ]]; then echo -e "  ${BIGreen}(No expired SSH users found)${NC}"; fi
    echo -e ""
    if [ -f "/etc/xray/expired_users.db" ]; then cat /etc/xray/expired_users.db; fi
    echo -e "${BICyan}=================================================${NC}"
    read -n 1 -s -r -p "Press any key..."
    menu
}

function restore_configs() {
    clear; echo -e "${BIYellow}RESTORE BACKUP${NC}"; echo "Upload 'vpn_backup.zip' to /tmp/"; read -p "Ready? [y/n]: " ans
    if [[ "$ans" != "y" ]]; then menu; fi
    if [ ! -f "/tmp/vpn_backup.zip" ]; then echo -e "${BIRed}File not found!${NC}"; sleep 2; menu; fi
    mkdir -p /root/restore_temp
    unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*
    cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null
    rm -rf /root/restore_temp
    systemctl restart ssh sshd xray
    echo -e "${BIGreen}Restore Complete!${NC}"; sleep 2; menu
}

function detailed_status() {
    clear; echo -e "${BIYellow}SYSTEM DIAGNOSTICS${NC}"; echo -e "--------------------------------"; 
    echo -ne "SSH Service: "; systemctl is-active ssh; 
    echo -ne "Xray Core:   "; systemctl is-active xray; 
    echo -ne "Nginx:       "; systemctl is-active nginx;
    echo -e ""; read -n 1 -s -r -p "Press any key..."; menu
}

function change_banner() {
    clear
    if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi
    nano /etc/issue.net
    service ssh restart; service sshd restart; menu
}

function change_ns() {
    clear; echo "Current NS: $NS_DOMAIN"; read -p "New NS: " new_ns; 
    if [[ -n "$new_ns" ]]; then echo "$new_ns" > /etc/xray/dns; echo "$new_ns" > /root/nsdomain; fi; menu
}

function clear_cache() {
    clear; echo "Cleaning RAM..."; sync; echo 3 > /proc/sys/vm/drop_caches; swapoff -a && swapon -a; sleep 1; menu
}

function auto_reboot() {
    clear; echo "[1] Enable (00:00)  [2] Disable"; read -p "Select > " x; 
    if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo "Enabled."; 
    elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo "Disabled."; fi; sleep 1; menu
}

function fix_services() {
    clear; echo "Restarting Services..."; systemctl restart nginx xray ssh; echo "Done."; sleep 1; menu
}

function change_domain() {
    clear; echo "Current: $DOMAIN"; read -p "New Domain: " d; 
    if [[ -n "$d" ]]; then echo "$d" > /etc/xray/domain; echo "$d" > /root/domain; systemctl restart nginx xray; fi; menu
}

# =========================================================
# 4. MENUS & SELECTORS (With Watchdog Triggers)
# =========================================================

function renew_selector() {
    clear; echo -e "${BIYellow}RENEW USER${NC}"; echo "[1] SSH/WS  [2] VMess  [3] VLESS  [4] Trojan  [0] Cancel"
    read -p "Select > " r_opt
    case $r_opt in
        1) clear ; start_backup_watchdog ; renew ;;
        2) clear ; start_backup_watchdog ; renew-ws ;;
        3) clear ; start_backup_watchdog ; renew-vless ;;
        4) clear ; start_backup_watchdog ; renew-tr ;;
        0) menu ;;
        *) menu ;;
    esac
}

function create_account_selector() {
    clear; echo -e "${BIYellow}CREATE ACCOUNT${NC}"; echo "[1] VMess  [2] VLESS  [3] Trojan  [0] Cancel"
    read -p "Select > " p_opt
    case $p_opt in
        1) clear ; start_backup_watchdog ; add-ws ;;
        2) clear ; start_backup_watchdog ; add-vless ;;
        3) clear ; start_backup_watchdog ; add-tr ;;
        0) menu ;;
        *) menu ;;
    esac
}

# =========================================================
# 5. DASHBOARD
# =========================================================

function show_dashboard() {
    RAM=$(free -m | awk 'NR==2{printf "%s/%s MB", $3,$2}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)
    
    clear
    echo -e "${BICyan} ┌───────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │ ${BIWhite}●${NC}           ${BIYellow}EDUFWESH VPN MANAGER ${BIWhite}PRO v12.8${NC}            ${BICyan}│${NC}"
    echo -e "${BICyan} ├───────────────────────────────────────────────────────────┤${NC}"
    echo -e "${BICyan} │${NC} ${BIGreen}IP:${NC} $MYIP  ${BICyan}│${NC} ${BIGreen}RAM:${NC} $RAM  ${BICyan}│${NC} ${BIGreen}LOAD:${NC} $LOAD ${BICyan}│${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────────────────┘${NC}"
}

function show_menu() {
    show_dashboard
    echo -e ""
    echo -e "   ${BIYellow}USER MANAGEMENT${NC}"
    echo -e "   ${BICyan}[01]${NC} Create SSH Account"
    echo -e "   ${BICyan}[02]${NC} Create Xray Account"
    echo -e "   ${BICyan}[03]${NC} Renew Services"
    echo -e "   ${BICyan}[04]${NC} User Monitor"
    echo -e "   ${BICyan}[05]${NC} Active Users"
    echo -e "   ${BICyan}[06]${NC} Expired Users"
    echo -e "   ${BICyan}[07]${NC} Lock/Unlock User"
    echo -e ""
    echo -e "   ${BIYellow}SYSTEM & SETTINGS${NC}"
    echo -e "   ${BICyan}[08]${NC} System Details    ${BICyan}[14]${NC} Manual Backup"
    echo -e "   ${BICyan}[09]${NC} Speedtest         ${BICyan}[15]${NC} Restore Backup"
    echo -e "   ${BICyan}[10]${NC} Reboot Server     ${BICyan}[16]${NC} Change Domain"
    echo -e "   ${BICyan}[11]${NC} Clear RAM         ${BICyan}[17]${NC} Change NS"
    echo -e "   ${BICyan}[12]${NC} Fix Services      ${BICyan}[18]${NC} Change Banner"
    echo -e "   ${BICyan}[13]${NC} Auto-Reboot       ${BICyan}[19]${NC} ${BIYellow}Auto-Backup Setup${NC}"
    echo -e ""
    echo -e "   ${BICyan}[00]${NC} Exit"
    echo -e "${BICyan} ─────────────────────────────────────────────────────────────${NC}"
    read -p "   Select Option »  " opt

    case $opt in
        01 | 1) clear ; start_backup_watchdog ; usernew ;;
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

show_menu

