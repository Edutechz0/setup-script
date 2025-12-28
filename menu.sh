#!/bin/bash

# =========================================================
# EDUFWESH VPN MANAGER - SAKURA STYLE EDITION v13.0
# =========================================================

# --- BRANDING COLORS (Exact Match to Screenshot) ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'              GRAY='\033[0;90m'

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
CITY=$(curl -s ipinfo.io/city)
OS_NAME=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/PRETTY_NAME//g' | sed 's/=//g' | sed 's/"//g')
KERNEL=$(uname -r)

# --- MEMORY & CPU ---
RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
RAM_USED=$(free -m | awk 'NR==2{print $3}')
RAM_FREE=$(free -m | awk 'NR==2{print $4}')
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%
UPTIME=$(uptime -p | cut -d " " -f 2-10 | cut -c 1-20)

# --- BANDWIDTH DATA (Simulated for display match) ---
# In a real scenario, this would pull from vnstat
BW_TODAY=$(vnstat -d --oneline | awk -F\; '{print $6}' 2>/dev/null || echo "N/A")
BW_YEST=$(vnstat -d --oneline | awk -F\; '{print $11}' 2>/dev/null || echo "N/A")
BW_MONTH=$(vnstat -m --oneline | awk -F\; '{print $11}' 2>/dev/null || echo "N/A")

# --- COUNT USERS ---
SSH_COUNT=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)
VMESS_COUNT=$(grep -c "vmess" /etc/xray/config.json 2>/dev/null || echo 0)
VLESS_COUNT=$(grep -c "vless" /etc/xray/config.json 2>/dev/null || echo 0)
TROJAN_COUNT=$(grep -c "trojan" /etc/xray/config.json 2>/dev/null || echo 0)

# --- CHECK SERVICE STATUS ---
function status_check() {
    if systemctl is-active --quiet $1; then echo -e "${BIGreen}ON${NC}"; else echo -e "${BIRed}OFF${NC}"; fi
}

# =========================================================
#  INTERNAL LOGIC (Auto-Backup & Functions)
# =========================================================

function auto_backup() {
    echo -e "${GRAY}Syncing Backup...${NC}"
    mkdir -p /root/backup_edu/ssh_backup
    cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null
    cp /etc/passwd /root/backup_edu/ssh_backup/
    cp /etc/shadow /root/backup_edu/ssh_backup/
    cp /etc/group /root/backup_edu/ssh_backup/
    cp /etc/gshadow /root/backup_edu/ssh_backup/
    zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
    chmod 777 /tmp/vpn_backup.zip
    rm -rf /root/backup_edu
    sleep 0.5
    menu
}

function restore_configs() {
    clear
    echo -e "${BICyan}=========================================${NC}"
    echo -e "${BIYellow}       RESTORE BACKUP CONFIGURATION      ${NC}"
    echo -e "${BICyan}=========================================${NC}"
    if [ ! -f "/tmp/vpn_backup.zip" ]; then
        echo -e "${BIRed}Error: Upload 'vpn_backup.zip' to /tmp first!${NC}"
        read -n 1 -s -r -p "Press any key..."
        menu
    fi
    mkdir -p /root/restore_temp
    unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*
    cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp -r /root/restore_temp/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null
    rm -rf /root/restore_temp
    systemctl restart ssh sshd xray
    echo -e "${BIGreen}RESTORE COMPLETED!${NC}"
    read -n 1 -s -r -p "Press any key..."
    menu
}

# --- LIST FUNCTIONS ---
function list_active() {
    clear; echo -e "${BIGreen}ACTIVE USERS${NC}"; awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd; read -n 1 -s -r -p "Press key..."; menu;
}
function list_expired() {
    clear; echo -e "${BIRed}EXPIRED USERS${NC}"; echo "(Feature requires user-expiration database)"; read -n 1 -s -r -p "Press key..."; menu;
}

# --- SELECTORS ---
function create_account_selector() {
    clear; echo "[1] VMess [2] VLESS [3] Trojan"; read -p "Select: " x
    case $x in 1) add-ws; auto_backup;; 2) add-vless; auto_backup;; 3) add-tr; auto_backup;; *) menu;; esac
}

# =========================================================
#  MAIN INTERFACE (The Sakura Look)
# =========================================================
function menu() {
    clear
    # --- HEADER ---
    echo -e "         ${BIWhite}SSH        VMESS        VLESS        TROJAN${NC}"
    echo -e "          ${BICyan}$SSH_COUNT           $VMESS_COUNT            $VLESS_COUNT            $TROJAN_COUNT${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    echo -e "                     ${BIBlue}INFORMATION VPS${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    # --- VPS INFO BOX ---
    echo -e "  ${BIYellow}Server Uptime${NC}       = $UPTIME"
    echo -e "  ${BIYellow}Current Time${NC}        = $(date "+%d-%m-%Y | %H:%M:%S")"
    echo -e "  ${BIYellow}Operating System${NC}    = $OS_NAME"
    echo -e "  ${BIYellow}Current Domain${NC}      = $DOMAIN"
    echo -e "  ${BIYellow}ISP / Region${NC}        = $ISP ($CITY)"
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

    # --- SERVICE STATUS ---
    S_SSH=$(status_check ssh)
    S_NGINX=$(status_check nginx)
    S_XRAY=$(status_check xray)
    S_CRON=$(status_check cron)
    
    echo -e "   ${BIBlue}SSH${NC} : $S_SSH  ${BIBlue}NGINX${NC} : $S_NGINX  ${BIBlue}XRAY${NC} : $S_XRAY  ${BIBlue}CRON${NC} : $S_CRON"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"

    # --- MENU GRID (Matches Screenshot Layout) ---
    echo -e "  ${BIPurple}[01]${NC} ${BIWhite}SSH${NC}       ${BICyan}[Menu]${NC}      ${BIPurple}[06]${NC} ${BIWhite}TRIAL${NC}       ${BICyan}[Menu]${NC}"
    echo -e "  ${BIPurple}[02]${NC} ${BIWhite}VMESS${NC}     ${BICyan}[Menu]${NC}      ${BIPurple}[07]${NC} ${BIWhite}BACKUP${NC}"
    echo -e "  ${BIPurple}[03]${NC} ${BIWhite}VLESS${NC}     ${BICyan}[Menu]${NC}      ${BIPurple}[08]${NC} ${BIWhite}RESTORE${NC}     ${BICyan}[NEW]${NC}"
    echo -e "  ${BIPurple}[04]${NC} ${BIWhite}TROJAN${NC}    ${BICyan}[Menu]${NC}      ${BIPurple}[09]${NC} ${BIWhite}CHECK USER${NC}"
    echo -e "  ${BIPurple}[05]${NC} ${BIWhite}SETTING${NC}   ${BICyan}[Menu]${NC}      ${BIPurple}[10]${NC} ${BIWhite}REBOOT VPS${NC}"

    echo -e "                    ${BIBlue}MENU TAMBAHAN${NC}"
    echo -e "  ${BIPurple}[11]${NC} ${BIWhite}ADD HOST/DOMAIN${NC}       ${BIPurple}[15]${NC} ${BIWhite}SPEEDTEST${NC}"
    echo -e "  ${BIPurple}[12]${NC} ${BIWhite}FIX SERVICES${NC}          ${BIPurple}[16]${NC} ${BIWhite}RENEW CERT${NC}"
    echo -e "  ${BIPurple}[13]${NC} ${BIWhite}NS DOMAIN${NC}             ${BIPurple}[17]${NC} ${BIWhite}CLEAR CACHE${NC}"
    echo -e "  ${BIPurple}[14]${NC} ${BIWhite}CHANGE BANNER${NC}"

    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    # --- FOOTER MONITORING ---
    echo -e "  ${BIYellow}Wadah Kasih,${NC}          ${BIBlue}( MONITORING BANDWIDTH )${NC}"
    echo -e "  ${BIPurple}Wadah Memberi,${NC}        ${BIWhite}TODAY      =${NC} ${BIGreen}$BW_TODAY${NC}"
    echo -e "  ${BIRed}Niat Di Hati,${NC}         ${BIWhite}YESTERDAY  =${NC} ${BIGreen}$BW_YEST${NC}"
    echo -e "  ${BICyan}Nawaitu Free.${NC}         ${BIWhite}MONTH      =${NC} ${BIGreen}$BW_MONTH${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    echo -e "  ${BIBlue}Autoscript By${NC}    :  Edufwesh Tunneling"
    echo -e "  ${BIBlue}Version${NC}          :  ${BIYellow}Sakura Edition v13.0${NC}"
    echo -e "  ${BIBlue}License Key${NC}      :  ${BIGreen}FREE-LICENSE-2025${NC}"
    echo -e "  ${BIBlue}Status${NC}           :  ${BIGreen}Lifetime Active${NC}"
    echo -e "${BICyan} ───────────────────────────────────────────────────────────${NC}"
    
    read -p " Select menu : " opt

    case $opt in
        01 | 1) clear ; usernew ; auto_backup ;;
        02 | 2) clear ; add-ws ; auto_backup ;;
        03 | 3) clear ; add-vless ; auto_backup ;;
        04 | 4) clear ; add-tr ; auto_backup ;;
        05 | 5) clear ; auto_reboot ;; # Mapped to Auto-Reboot settings
        06 | 6) clear ; usernew ;; # Mapped to SSH for now (or trial script if you have one)
        07 | 7) clear ; auto_backup ;;
        08 | 8) clear ; restore_configs ;;
        09 | 9) clear ; list_active ;;
        10 | 10) clear ; reboot ;;
        11 | 11) clear ; change_domain ;;
        12 | 12) clear ; systemctl restart ssh sshd xray nginx ; echo "Done"; sleep 1; menu ;;
        13 | 13) clear ; change_ns ;;
        14 | 14) clear ; nano /etc/issue.net ; menu ;;
        15 | 15) clear ; speedtest ;;
        16 | 16) clear ; certv2ray ; menu ;;
        17 | 17) clear ; echo 3 > /proc/sys/vm/drop_caches ; echo "RAM Cleared"; sleep 1; menu ;;
        *) menu ;;
    esac
}

# START
menu

