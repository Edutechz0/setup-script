#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - DUAL BACKUP EDITION v12.7
# (Added: Discord Support + Backup Platform Selector)
# =========================================================

# --- BRANDING COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'              GRAY='\033[0;90m'

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- BACKUP CONFIG FILES ---
BACKUP_CONF="/etc/edu_backup.conf"
# Structure of conf file:
# PLATFORM="telegram" or "discord"
# TG_TOKEN="xxx"
# TG_ID="xxx"
# DC_WEBHOOK="xxx"
# ACTIVE="yes" or "no"

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/etc/slowdns/nsdomain" ]; then NS_DOMAIN=$(cat /etc/slowdns/nsdomain);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# INTERNAL BACKUP LOGIC
# =========================================================

function send_to_telegram() {
    source "$BACKUP_CONF"
    MSG="<b>📦 VPS AUTO-BACKUP (TG)</b>%0A"
    MSG+="<b>━━━━━━━━━━━━━━━━━━</b>%0A"
    MSG+="<b>DOMAIN :</b> <code>$DOMAIN</code>%0A"
    MSG+="<b>IP VPS :</b> <code>$MYIP</code>%0A"
    MSG+="<b>DATE   :</b> <code>$(date)</code>%0A"
    MSG+="<b>━━━━━━━━━━━━━━━━━━</b>"
    
    curl -s -F chat_id="$TG_ID" -F document=@"/tmp/vpn_backup.zip" -F caption="$MSG" -F parse_mode="HTML" "https://api.telegram.org/bot$TG_TOKEN/sendDocument" > /dev/null 2>&1 &
}

function send_to_discord() {
    source "$BACKUP_CONF"
    # Discord Webhook Upload
    curl -s -F "file=@/tmp/vpn_backup.zip" -F "content=**📦 VPS AUTO-BACKUP (Discord)**
> **Domain:** $DOMAIN
> **IP:** $MYIP
> **Date:** $(date)" "$DC_WEBHOOK" > /dev/null 2>&1 &
}

function auto_backup() {
    echo -e ""
    echo -e "${GRAY}Syncing backup data...${NC}"
    
    mkdir -p /root/backup_edu/ssh_backup
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /root/backup_edu/ssh_backup/
    cp /etc/shadow /root/backup_edu/ssh_backup/
    cp /etc/group /root/backup_edu/ssh_backup/
    cp /etc/gshadow /root/backup_edu/ssh_backup/
    
    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    chmod 777 /tmp/vpn_backup.zip
    rm -rf /root/backup_edu
    
    # CHECK CONFIG & SEND
    if [ -f "$BACKUP_CONF" ]; then
        source "$BACKUP_CONF"
        if [[ "$ACTIVE" == "yes" ]]; then
            if [[ "$PLATFORM" == "discord" && -n "$DC_WEBHOOK" ]]; then
                echo -e "${BIPurple}Sending to Discord...${NC}"
                send_to_discord
            elif [[ "$PLATFORM" == "telegram" && -n "$TG_TOKEN" ]]; then
                echo -e "${BIPurple}Sending to Telegram...${NC}"
                send_to_telegram
            fi
        fi
    fi
    
    echo -e "${BIGreen}Done!${NC}"
    sleep 0.5
    menu
}

# --- BACKUP SETTINGS MANAGER ---
function backup_setup() {
    clear
    # Load current config
    if [ -f "$BACKUP_CONF" ]; then source "$BACKUP_CONF"; else 
        PLATFORM="none"; ACTIVE="no"; 
    fi

    echo -e "${BICyan} ┌───────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan} │           ${BIYellow}AUTO-BACKUP MANAGER${BICyan}                 │${NC}"
    echo -e "${BICyan} └───────────────────────────────────────────────┘${NC}"
    echo -e "  Current Platform : ${BIGreen}${PLATFORM^^}${NC}"
    echo -e "  Feature Status   : ${BIGreen}${ACTIVE^^}${NC}"
    echo -e ""
    echo -e "  ${BIWhite}[1]${NC} Select Telegram & Setup"
    echo -e "  ${BIWhite}[2]${NC} Select Discord & Setup"
    echo -e "  ${BIWhite}[3]${NC} Toggle ON/OFF Feature"
    echo -e "  ${BIWhite}[4]${NC} Test Backup (Send Now)"
    echo -e ""
    echo -e "  ${BIWhite}[0]${NC} Back to Main Menu"
    echo -e "${BICyan} ───────────────────────────────────────────────${NC}"
    read -p " Select > " b_opt

    case $b_opt in
        1)
            clear
            echo -e "${BIYellow}SETUP TELEGRAM${NC}"
            read -p "Enter Bot Token : " t_token
            read -p "Enter Chat ID   : " t_id
            echo "PLATFORM=\"telegram\"" > "$BACKUP_CONF"
            echo "TG_TOKEN=\"$t_token\"" >> "$BACKUP_CONF"
            echo "TG_ID=\"$t_id\"" >> "$BACKUP_CONF"
            echo "DC_WEBHOOK=\"$DC_WEBHOOK\"" >> "$BACKUP_CONF"
            echo "ACTIVE=\"yes\"" >> "$BACKUP_CONF"
            echo -e "${BIGreen}Telegram Selected & Saved!${NC}"
            sleep 2; backup_setup
            ;;
        2)
            clear
            echo -e "${BIYellow}SETUP DISCORD${NC}"
            echo -e "1. Create a Discord Server -> Channel Settings -> Integrations -> Webhooks."
            echo -e "2. Copy the Webhook URL."
            echo ""
            read -p "Enter Webhook URL : " d_url
            echo "PLATFORM=\"discord\"" > "$BACKUP_CONF"
            echo "TG_TOKEN=\"$TG_TOKEN\"" >> "$BACKUP_CONF"
            echo "TG_ID=\"$TG_ID\"" >> "$BACKUP_CONF"
            echo "DC_WEBHOOK=\"$d_url\"" >> "$BACKUP_CONF"
            echo "ACTIVE=\"yes\"" >> "$BACKUP_CONF"
            echo -e "${BIGreen}Discord Selected & Saved!${NC}"
            sleep 2; backup_setup
            ;;
        3)
            if [[ "$ACTIVE" == "yes" ]]; then
                sed -i 's/ACTIVE="yes"/ACTIVE="no"/' "$BACKUP_CONF"
            else
                sed -i 's/ACTIVE="no"/ACTIVE="yes"/' "$BACKUP_CONF"
            fi
            backup_setup
            ;;
        4)
            echo -e "Generating Test File..."
            zip -r /tmp/vpn_backup.zip /etc/passwd > /dev/null 2>&1
            if [[ "$PLATFORM" == "discord" ]]; then send_to_discord; 
            elif [[ "$PLATFORM" == "telegram" ]]; then send_to_telegram; fi
            echo -e "${BIGreen}Sent! Check your App.${NC}"
            read -n 1 -s -r -p "Press key..."
            backup_setup
            ;;
        0) menu ;;
        *) backup_setup ;;
    esac
}

# --- LIST & RESTORE FUNCTIONS (Existing) ---
function list_active() {
    clear; echo -e "${BIGreen}ACTIVE USERS${NC}"; awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd; read -n 1 -s -r -p "Press key..."; menu;
}
function list_expired() {
    clear; echo -e "${BIRed}EXPIRED USERS${NC}"; echo "(Use user database for accuracy)"; read -n 1 -s -r -p "Press key..."; menu;
}
function restore_configs() {
    clear; echo "${BICyan}RESTORE${NC}"; if [ ! -f "/tmp/vpn_backup.zip" ]; then echo "${BIRed}No file in /tmp!${NC}"; sleep 2; menu; fi
    mkdir -p /root/restore_temp; unzip -o /tmp/vpn_backup.zip -d /root/restore_temp >/dev/null 2>&1
    rm -rf /etc/xray/*; cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp -r /root/restore_temp/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null
    rm -rf /root/restore_temp; systemctl restart ssh sshd xray
    echo "${BIGreen}Restored!${NC}"; sleep 2; menu
}

# --- SELECTORS ---
function renew_selector() {
    clear; echo "[1] SSH [2] VMess [3] VLESS [4] Trojan"; read -p "Select: " x
    case $x in 1) renew; auto_backup;; 2) renew-ws; auto_backup;; 3) renew-vless; auto_backup;; 4) renew-tr; auto_backup;; *) menu;; esac
}
function create_account_selector() {
    clear; echo "[1] VMess [2] VLESS [3] Trojan"; read -p "Select: " x
    case $x in 1) add-ws; auto_backup;; 2) add-vless; auto_backup;; 3) add-tr; auto_backup;; *) menu;; esac
}
function check_service() { if systemctl is-active --quiet $1; then echo -e "${BIGreen}ON${NC}"; else echo -e "${BIRed}OFF${NC}"; fi; }

# --- SETTINGS SUBMENU ---
function settings_menu() {
    clear
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "                    ${BIBlue}SYSTEM SETTINGS${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BIPurple}[01]${NC} ${BIWhite}Auto-Reboot Scheduler${NC}"
    echo -e "  ${BIPurple}[02]${NC} ${BIWhite}Fix SSL / Restart Services${NC}"
    echo -e "  ${BIPurple}[03]${NC} ${BIWhite}Speedtest Benchmark${NC}"
    echo -e "  ${BIPurple}[04]${NC} ${BIWhite}Clear RAM & Cache${NC}"
    echo -e "  ${BIPurple}[05]${NC} ${BIWhite}Change Domain${NC}"
    echo -e "  ${BIPurple}[06]${NC} ${BIWhite}Change NS Domain${NC}"
    echo -e "  ${BIPurple}[07]${NC} ${BIWhite}Change Banner${NC}"
    echo -e ""
    echo -e "  ${BIPurple}[00]${NC} ${BIRed}Back to Main Menu${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    read -p " Select: " s_opt
    case $s_opt in
        1) clear; echo "Auto-Reboot Settings"; read -p "Key..."; settings_menu ;;
        2) clear; systemctl restart ssh sshd xray nginx; echo "Fixed"; sleep 1; settings_menu ;;
        3) clear; speedtest; settings_menu ;;
        4) clear; echo 3 > /proc/sys/vm/drop_caches; echo "Cleared"; sleep 1; settings_menu ;;
        5) clear; read -p "New Domain: " d; echo "$d" > /etc/xray/domain; settings_menu ;;
        6) clear; read -p "New NS: " n; echo "$n" > /etc/xray/dns; settings_menu ;;
        7) clear; nano /etc/issue.net; settings_menu ;;
        0) menu ;;
        *) settings_menu ;;
    esac
}

# --- MAIN DASHBOARD (Sakura Style) ---
function menu() {
    clear
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    RAM_USED=$(free -m | awk 'NR==2{print $3}')
    RAM_FREE=$(free -m | awk 'NR==2{print $4}')
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
    UPTIME=$(uptime -p | cut -d " " -f 2-10 | cut -c 1-20)
    SERVER_TIME=$(date "+%H:%M:%S")
    
    SSH_COUNT=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)
    VMESS_COUNT=$(grep -c "vmess" /etc/xray/config.json 2>/dev/null || echo 0)
    VLESS_COUNT=$(grep -c "vless" /etc/xray/config.json 2>/dev/null || echo 0)
    TROJAN_COUNT=$(grep -c "trojan" /etc/xray/config.json 2>/dev/null || echo 0)
    
    BW_TODAY=$(vnstat -d --oneline | awk -F\; '{print $6}' 2>/dev/null || echo "N/A")
    BW_MONTH=$(vnstat -m --oneline | awk -F\; '{print $11}' 2>/dev/null || echo "N/A")

    echo -e "         ${BIWhite}SSH        VMESS        VLESS        TROJAN${NC}"
    echo -e "          ${BICyan}$SSH_COUNT           $VMESS_COUNT            $VLESS_COUNT            $TROJAN_COUNT${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "                     ${BIBlue}INFORMATION VPS${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "  ${BIYellow}Server Uptime${NC}       = $UPTIME"
    echo -e "  ${BIYellow}Current Time${NC}        = $SERVER_TIME"
    echo -e "  ${BIYellow}Current Domain${NC}      = $DOMAIN"
    echo -e "  ${BIYellow}NS Domain${NC}           = $NS_DOMAIN"
    echo -e "  ${BIYellow}Total Ram${NC}           = ${BIWhite}$RAM_TOTAL MB${NC}"
    echo -e "  ${BIYellow}Total Used Ram${NC}      = ${BIRed}$RAM_USED MB${NC}"
    echo -e "  ${BIYellow}Total Free Ram${NC}      = ${BIGreen}$RAM_FREE MB${NC}"
    echo -e "  ${BIYellow}CPU Usage${NC}           = $CPU_LOAD"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "                     ${BIWhite}EDUFWESH TUNNELING${NC}"
    echo -e "  ${BIYellow}Use Core${NC}             : Xray-Core v1.8.1"
    echo -e "  ${BIYellow}IP-VPS${NC}               : $MYIP"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "      ${BIRed}TERIMA KASIH SUDAH MENGGUNAKAN AUTOSCRIPT EDUFWESH${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"

    S_SSH=$(check_service ssh); S_NGINX=$(check_service nginx)
    S_XRAY=$(check_service xray); S_CRON=$(check_service cron)
    
    echo -e "   ${BIBlue}SSH${NC} : $S_SSH  ${BIBlue}NGINX${NC} : $S_NGINX  ${BIBlue}XRAY${NC} : $S_XRAY  ${BIBlue}CRON${NC} : $S_CRON"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    echo -e "  ${BIPurple}[01]${NC} ${BIWhite}SSH${NC}       ${BICyan}[Menu]${NC}      ${BIPurple}[06]${NC} ${BIWhite}TRIAL${NC}       ${BICyan}[Menu]${NC}"
    echo -e "  ${BIPurple}[02]${NC} ${BIWhite}VMESS${NC}     ${BICyan}[Menu]${NC}      ${BIPurple}[07]${NC} ${BIWhite}BACKUP${NC}"
    echo -e "  ${BIPurple}[03]${NC} ${BIWhite}VLESS${NC}     ${BICyan}[Menu]${NC}      ${BIPurple}[08]${NC} ${BIWhite}RESTORE${NC}"
    echo -e "  ${BIPurple}[04]${NC} ${BIWhite}TROJAN${NC}    ${BICyan}[Menu]${NC}      ${BIPurple}[09]${NC} ${BIWhite}CHECK USER${NC}"
    echo -e "  ${BIPurple}[05]${NC} ${BIWhite}SETTING${NC}   ${BICyan}[Menu]${NC}      ${BIPurple}[10]${NC} ${BIWhite}REBOOT VPS${NC}"
    echo -e "                    ${BIBlue}MENU TAMBAHAN${NC}"
    echo -e "  ${BIPurple}[11]${NC} ${BIWhite}ACTIVE USERS${NC}          ${BIPurple}[15]${NC} ${BIWhite}UNLOCK USER${NC}"
    echo -e "  ${BIPurple}[12]${NC} ${BIWhite}EXPIRED USERS${NC}         ${BIPurple}[16]${NC} ${BIWhite}RENEW CERT${NC}"
    echo -e "  ${BIPurple}[13]${NC} ${BIWhite}NS DOMAIN${NC}             ${BIPurple}[17]${NC} ${BIWhite}CLEAR CACHE${NC}"
    echo -e "  ${BIPurple}[14]${NC} ${BIWhite}LOCK USER${NC}             ${BIPurple}[18]${NC} ${BIWhite}BACKUP SETTINGS${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    echo -e "  ${BIYellow}Wadah Kasih,${NC}          ${BIBlue}( MONITORING BANDWIDTH )${NC}"
    echo -e "  ${BIPurple}Wadah Memberi,${NC}        ${BIWhite}TODAY      =${NC} ${BIGreen}$BW_TODAY${NC}"
    echo -e "  ${BIRed}Niat Di Hati,${NC}         ${BIWhite}YESTERDAY  =${NC} ${BIGreen}N/A${NC}"
    echo -e "  ${BICyan}Nawaitu Free.${NC}         ${BIWhite}MONTH      =${NC} ${BIGreen}$BW_MONTH${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    read -p " Select menu : " opt
    case $opt in
        01 | 1) clear ; usernew ; auto_backup ;;
        02 | 2) clear ; add-ws ; auto_backup ;;
        03 | 3) clear ; add-vless ; auto_backup ;;
        04 | 4) clear ; add-tr ; auto_backup ;;
        05 | 5) settings_menu ;;
        06 | 6) clear ; usernew ;; 
        07 | 7) clear ; auto_backup ;;
        08 | 8) clear ; restore_configs ;;
        09 | 9) clear ; cek ;;
        10 | 10) clear ; reboot ;;
        11 | 11) list_active ;;
        12 | 12) list_expired ;;
        13 | 13) clear ; read -p "New NS: " n; echo "$n" > /etc/xray/dns; menu ;;
        14 | 14) clear ; member ;;
        15 | 15) clear ; member ;;
        16 | 16) clear ; certv2ray ; menu ;;
        17 | 17) clear ; echo 3 > /proc/sys/vm/drop_caches ; echo "RAM Cleared"; sleep 1; menu ;;
        18 | 18) backup_setup ;;
        *) menu ;;
    esac
}

# START
menu

