#!/bin/bash

# =========================================================
# EDUFWESH MANAGER - ULTIMATE ENTERPRISE v16.2
# (Logic: 100% v12.9 Parity | Visuals: v16.0 Engine)
# =========================================================

# --- 1. VISUAL PREFERENCES ENGINE ---
THEME_FILE="/etc/edu_theme"
FONT_FILE="/etc/edu_font"

# Set Defaults
if [ ! -f "$THEME_FILE" ]; then echo "blue" > "$THEME_FILE"; fi
if [ ! -f "$FONT_FILE" ]; then echo "standard" > "$FONT_FILE"; fi

CURr_THEME=$(cat "$THEME_FILE")
CURr_FONT=$(cat "$FONT_FILE")

# --- THEME DEFINITIONS ---
case $CURr_THEME in
    "green")    C_MAIN='\033[1;32m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;32m' ;;
    "purple")   C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;35m' ;;
    "red")      C_MAIN='\033[1;31m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    "gold")     C_MAIN='\033[0;33m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;33m' ;;
    "ocean")    C_MAIN='\033[0;36m'; C_ACCENT='\033[1;34m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;36m' ;;
    "retro")    C_MAIN='\033[0;31m'; C_ACCENT='\033[0;33m'; C_TEXT='\033[1;33m'; C_BAR='\033[0;33m' ;;
    "mono")     C_MAIN='\033[1;30m'; C_ACCENT='\033[1;37m'; C_TEXT='\033[0;37m'; C_BAR='\033[1;37m' ;;
    "dracula")  C_MAIN='\033[1;35m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    "nord")     C_MAIN='\033[1;34m'; C_ACCENT='\033[1;37m'; C_TEXT='\033[0;36m'; C_BAR='\033[1;34m' ;;
    "gruvbox")  C_MAIN='\033[0;33m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;32m' ;;
    "synth")    C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;36m' ;;
    "toxic")    C_MAIN='\033[1;92m'; C_ACCENT='\033[1;93m'; C_TEXT='\033[1;97m'; C_BAR='\033[1;92m' ;;
    "solar")    C_MAIN='\033[1;34m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;33m' ;;
    "royal")    C_MAIN='\033[1;35m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;33m' ;;
    *)          C_MAIN='\033[1;34m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;34m' ;;
esac

RESET='\033[0m'; C_LABEL='\033[0;90m'; C_SUCCESS='\033[1;32m'; C_ALERT='\033[1;91m'

# --- 2. INITIALIZATION & DEPENDENCIES ---
function init_sys() {
    if ! command -v zip &> /dev/null || ! command -v bc &> /dev/null || ! command -v figlet &> /dev/null; then
        echo -e "${C_LABEL}Initializing system modules...${RESET}"
        apt-get update >/dev/null 2>&1
        apt-get install zip unzip curl bc net-tools vnstat figlet -y >/dev/null 2>&1
    fi
}
init_sys

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FIND NAME SERVER (NS) ---
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# 3. BACKGROUND WATCHDOG (Preserved)
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
# 4. RESTORED v12.9 SELECTORS (The "Missing" Link)
# =========================================================

function create_account_selector() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}           SELECT PROTOCOL TYPE${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] VMess Account   (Standard)"
    echo -e "  [2] VLESS Account   (Lightweight)"
    echo -e "  [3] Trojan Account  (Anti-Detect)"
    echo -e ""
    echo -e "  [0] Cancel"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " p_opt
    case $p_opt in
        1) clear ; start_backup_watchdog ; add-ws ;;
        2) clear ; start_backup_watchdog ; add-vless ;;
        3) clear ; start_backup_watchdog ; add-tr ;;
        0) menu ;;
        *) menu ;;
    esac
}

function renew_selector() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_TEXT}           RENEW USER ACCOUNT${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Renew SSH / WS Account"
    echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"
    echo -e "  [2] Renew VMess Account"
    echo -e "  [3] Renew VLESS Account"
    echo -e "  [4] Renew Trojan Account"
    echo -e ""
    echo -e "  [0] Cancel"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
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
    echo -e "${C_ACCENT} XRAY ACCOUNTS${RESET}"
    if [ -f "/etc/xray/config.json" ]; then
        grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  ● ${C_SUCCESS}/" | sed "s/$/${RESET}/"
    fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -n 1 -s -r -p "Key..."; menu
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
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -n 1 -s -r -p "Key..."; menu
}

function restore_configs() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_ACCENT}RESTORE BACKUP${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Have you uploaded 'vpn_backup.zip' to /tmp/? [y/n]: " ans
    if [[ "$ans" != "y" ]]; then menu; fi
    if [ ! -f "/tmp/vpn_backup.zip" ]; then echo -e "${C_ALERT}File not found!${RESET}"; sleep 2; menu; fi
    echo -e "${C_LABEL}Restoring...${RESET}"
    mkdir -p /root/restore_temp
    unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*
    cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null
    cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null
    rm -rf /root/restore_temp
    systemctl restart ssh sshd xray
    echo -e "${C_SUCCESS}Restore Complete!${RESET}"; sleep 2; menu
}

function auto_reboot() {
    clear
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "             ${C_TEXT}AUTO-REBOOT SCHEDULER${RESET}"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Enable Daily (00:00)   [2] Disable"
    read -p "Select > " x
    if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo -e "${C_SUCCESS}Enabled!${RESET}"
    elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo -e "${C_ALERT}Disabled!${RESET}"; fi
    sleep 1; menu
}

function change_banner() {
    clear; if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi
    nano /etc/issue.net; echo -e "${C_LABEL}Restarting SSH...${RESET}"; service ssh restart; service sshd restart; menu
}

function change_domain() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "Current: $DOMAIN"; read -p "New Domain: " d
    if [[ -n "$d" ]]; then echo "$d" > /etc/xray/domain; echo "$d" > /root/domain; echo -e "${C_LABEL}Restarting Services...${RESET}"; systemctl restart nginx xray; echo -e "${C_SUCCESS}Updated!${RESET}"; fi
    sleep 1; menu
}

function change_ns() {
    # FIXED: Now updates BOTH files like v12.9
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "Current NS: $NS_DOMAIN"; read -p "New NS: " n
    if [[ -n "$n" ]]; then 
        echo "$n" > /etc/xray/dns
        echo "$n" > /root/nsdomain
        echo -e "${C_SUCCESS}Updated!${RESET}"
    fi
    sleep 1; menu
}

# =========================================================
# 6. VISUAL UTILITIES
# =========================================================

function draw_bar() {
    local pct=$1; local width=18
    local fill=$(echo "$pct / 100 * $width" | bc -l | awk '{printf("%d",$1 + 0.5)}')
    printf "["; for ((i=0; i<fill; i++)); do printf "${C_BAR}█${RESET}"; done; for ((i=fill; i<width; i++)); do printf "${C_LABEL}░${RESET}"; done; printf "] ${pct}%%"
}

function live_traffic_monitor() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           LIVE TRAFFIC MONITOR (Ctrl+C to Exit)${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "  Monitoring Interface: eth0..."
    IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    while true; do
        R1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        sleep 1
        R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        RKBPS=$(expr $R2 - $R1); RKBPS=$(expr $RKBPS / 1024); TKBPS=$(expr $T2 - $T1); TKBPS=$(expr $TKBPS / 1024)
        echo -ne "\r  ${C_SUCCESS}↓ DOWN:${RESET} ${RKBPS} KB/s    ${C_ALERT}↑ UP:${RESET} ${TKBPS} KB/s   "
    done
}

function generate_id_card() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           USER ID CARD GENERATOR${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "Enter username:"; read -p "Username: " user
    if ! id "$user" &>/dev/null; then echo -e "${C_ALERT}User not found!${RESET}"; sleep 2; menu; fi
    EXP=$(chage -l "$user" | grep "Account expires" | cut -d: -f2)
    clear
    echo -e "${C_MAIN}╔════════════════════════════════════════════╗${RESET}"; echo -e "${C_MAIN}║${RESET}           ${C_TEXT}PREMIUM VPN ACCESS${RESET}               ${C_MAIN}║${RESET}"; echo -e "${C_MAIN}╠════════════════════════════════════════════╣${RESET}"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Username :${RESET} ${C_ACCENT}$user${RESET}"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Password :${RESET} (Hidden/Encrypted)"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Expiry   :${RESET} $EXP"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}Host IP  :${RESET} $MYIP"; echo -e "${C_MAIN}║${RESET} ${C_LABEL}ISP      :${RESET} $ISP"; echo -e "${C_MAIN}╠════════════════════════════════════════════╣${RESET}"; echo -e "${C_MAIN}║${RESET}         ${C_SUCCESS}● STATUS: ACTIVE${RESET}                   ${C_MAIN}║${RESET}"; echo -e "${C_MAIN}╚════════════════════════════════════════════╝${RESET}"; echo -e ""
    read -n 1 -s -r -p "Key..."; menu
}

function restart_services_pro() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           RESTARTING SYSTEM SERVICES${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    function restart_visual() { svc=$1; echo -ne "  Restarting $svc... "; systemctl restart $svc; if [ $? -eq 0 ]; then echo -e "${C_SUCCESS}DONE${RESET}"; else echo -e "${C_ALERT}FAIL${RESET}"; fi; sleep 0.5; }
    restart_visual "ssh"; restart_visual "xray"; restart_visual "nginx"; restart_visual "cron"
    echo -e ""; echo -e "${C_SUCCESS}  All services refreshed.${RESET}"; sleep 2; menu
}

function detailed_status() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           SYSTEM DIAGNOSTICS${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if systemctl is-active --quiet ssh; then echo -e "  SSH Service: ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  SSH Service: ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet xray; then echo -e "  Xray Core  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Xray Core  : ${C_ALERT}STOPPED${RESET}"; fi
    if systemctl is-active --quiet nginx; then echo -e "  Nginx Web  : ${C_SUCCESS}RUNNING${RESET}"; else echo -e "  Nginx Web  : ${C_ALERT}STOPPED${RESET}"; fi
    echo -e ""; echo -e "${C_ACCENT}ACTIVE PROTOCOLS:${RESET}"
    CONFIG="/etc/xray/config.json"
    if [ -f "$CONFIG" ]; then
        if grep -q "vmess" "$CONFIG"; then echo -e "  VMess      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VMess      : ${C_LABEL}MISSING${RESET}"; fi
        if grep -q "vless" "$CONFIG"; then echo -e "  VLESS      : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  VLESS      : ${C_LABEL}MISSING${RESET}"; fi
        if grep -q "trojan" "$CONFIG"; then echo -e "  Trojan     : ${C_SUCCESS}ACTIVE${RESET}"; else echo -e "  Trojan     : ${C_LABEL}MISSING${RESET}"; fi
    fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

# =========================================================
# 7. SETTINGS & THEMES
# =========================================================

function visual_settings() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           VISUAL PREFERENCES STUDIO${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [01] Corporate Blue   [06] Ocean Teal     [11] Solarized"
    echo -e "  [02] Hacker Green     [07] Retro Amber    [12] Gruvbox"
    echo -e "  [03] Cyber Purple     [08] Monochrome     [13] Synthwave"
    echo -e "  [04] Admin Red        [09] Dracula        [14] Toxic Lime"
    echo -e "  [05] Luxury Gold      [10] Nord Ice       [15] Royal Gold"
    echo -e ""; echo -e "${C_ACCENT} FONT STYLES (FIGlet)${RESET}"; echo -e "  [16] Standard         [18] Slant (Pro)"; echo -e "  [17] Big 3D           [19] Banner (Wide)"; echo -e ""; read -p "Select > " v_opt
    case $v_opt in
        1|01) echo "blue" > /etc/edu_theme ;; 2|02) echo "green" > /etc/edu_theme ;; 3|03) echo "purple" > /etc/edu_theme ;; 4|04) echo "red" > /etc/edu_theme ;; 5|05) echo "gold" > /etc/edu_theme ;;
        6|06) echo "ocean" > /etc/edu_theme ;; 7|07) echo "retro" > /etc/edu_theme ;; 8|08) echo "mono" > /etc/edu_theme ;; 9|09) echo "dracula" > /etc/edu_theme ;; 10) echo "nord" > /etc/edu_theme ;;
        11) echo "solar" > /etc/edu_theme ;; 12) echo "gruvbox" > /etc/edu_theme ;; 13) echo "synth" > /etc/edu_theme ;; 14) echo "toxic" > /etc/edu_theme ;; 15) echo "royal" > /etc/edu_theme ;;
        16) echo "standard" > /etc/edu_font ;; 17) echo "big" > /etc/edu_font ;; 18) echo "slant" > /etc/edu_font ;; 19) echo "banner" > /etc/edu_font ;; 0) menu ;;
    esac
    echo -e "${C_SUCCESS}Updating Visuals...${RESET}"; sleep 1; exec "$0"
}

function backup_settings() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}       CLOUD SYNC CONFIGURATION${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    STATUS=$(cat /etc/edu_backup_status 2>/dev/null || echo "off"); TYPE=$(cat /etc/edu_backup_type 2>/dev/null || echo "none")
    if [[ "$STATUS" == "on" ]]; then S_TXT="${C_SUCCESS}● ENABLED${RESET}"; else S_TXT="${C_ALERT}● DISABLED${RESET}"; fi
    echo -e "  Status: $S_TXT    Method: ${C_ACCENT}${TYPE^^}${RESET}"; echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"
    echo -e "  [1] Enable Sync        [3] Setup Telegram"; echo -e "  [2] Disable Sync       [4] Setup Discord"; echo -e "  [5] ${C_ACCENT}Test Connection Now${RESET}"; echo -e ""; echo -e "  [0] Return"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " b_opt
    case $b_opt in
        1) echo "on" > /etc/edu_backup_status; backup_settings ;; 2) echo "off" > /etc/edu_backup_status; backup_settings ;;
        3) clear; read -p "Token: " t; read -p "Chat ID: " i; echo "$t" > /etc/edu_backup_tg_token; echo "$i" > /etc/edu_backup_tg_id; echo "telegram" > /etc/edu_backup_type; backup_settings ;;
        4) clear; read -p "Webhook: " d; echo "$d" > /etc/edu_backup_dc_url; echo "discord" > /etc/edu_backup_type; backup_settings ;;
        5) auto_backup "force"; read -n 1 -s -r -p "Key..."; backup_settings ;; 0) menu ;;
    esac
}

function auto_backup() {
    MODE=$1
    if [[ "$MODE" == "force" ]]; then
        mkdir -p /root/backup_edu/ssh_backup; cp -r /etc/xray /root/backup_edu/xray_backup 2>/dev/null; cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null; rm -f /tmp/vpn_backup.zip; zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1; rm -rf /root/backup_edu
        TYPE=$(cat /etc/edu_backup_type 2>/dev/null); FILE="/tmp/vpn_backup.zip"; CAPTION="Manual Test: $(date) | IP: $MYIP"
        if [[ "$TYPE" == "discord" ]]; then URL=$(cat /etc/edu_backup_dc_url); curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null; echo -e "${C_SUCCESS}Sent to Discord.${RESET}"; elif [[ "$TYPE" == "telegram" ]]; then T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id); curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null; echo -e "${C_SUCCESS}Sent to Telegram.${RESET}"; fi; sleep 1
    fi
}

# =========================================================
# 8. DASHBOARD & MENU
# =========================================================

function show_dashboard() {
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}'); RAM_USED=$(free -m | awk 'NR==2{print $3}'); RAM_PCT=$(echo "$RAM_USED / $RAM_TOTAL * 100" | bc -l | awk '{printf("%d",$1)}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' '); LOAD_PCT=$(echo "$LOAD * 100 / 4" | bc -l | awk '{printf("%d",$1)}'); if [ "$LOAD_PCT" -gt 100 ]; then LOAD_PCT=100; fi
    SERVER_TIME=$(date "+%H:%M:%S"); LAST_LOGIN=$(last -n 1 -a | head -n 1 | awk '{print $10}'); CURr_FONT=$(cat /etc/edu_font 2>/dev/null || echo "standard")
    if systemctl is-active --quiet ssh; then S_SSH="${C_SUCCESS}ONLINE${RESET}"; else S_SSH="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet xray; then S_XRAY="${C_SUCCESS}ONLINE${RESET}"; else S_XRAY="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet nginx; then S_NGINX="${C_SUCCESS}ONLINE${RESET}"; else S_NGINX="${C_ALERT}OFFLINE${RESET}"; fi
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if command -v figlet &> /dev/null; then echo -e "${C_TEXT}"; figlet -f "$CURr_FONT" "EDUFWESH"; echo -e "${RESET}"; else echo -e "${C_TEXT}  EDUFWESH ENTERPRISE MANAGER${RESET}"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "Host" "$DOMAIN" "Time" "$SERVER_TIME"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "IP" "$MYIP" "ISP" "$ISP"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "NS" "$NS_DOMAIN" "Sec" "$LAST_LOGIN"
    echo -e "${C_LABEL}──────────────────────────────────────────────────────────${RESET}"
    echo -ne "  ${C_LABEL}RAM :${RESET} "; draw_bar $RAM_PCT; echo ""
    echo -ne "  ${C_LABEL}CPU :${RESET} "; draw_bar $LOAD_PCT; echo ""
    echo -e ""; echo -e "  ${C_LABEL}SSH :${RESET} $S_SSH       ${C_LABEL}XRAY :${RESET} $S_XRAY      ${C_LABEL}WEB :${RESET} $S_NGINX"
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
    echo -e "  [16] Update Domain Host    [20] ${C_TEXT}Live Traffic Monitor${RESET}"
    echo -e "  [17] Update NameServer     [21] ${C_TEXT}User ID Card Gen${RESET}"
    echo -e "  [18] SSH Banner Editor     [22] ${C_TEXT}Settings (Theme/UI)${RESET}"
    echo -e "  [19] Cloud Backup Setup"
    echo -e ""
    echo -e "  [00] Exit Dashboard"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "  Enter Selection » " opt
    case $opt in
        01|1) clear; start_backup_watchdog; usernew ;;
        02|2) create_account_selector ;; # RESTORED SELECTOR
        03|3) renew_selector ;; # RESTORED SELECTOR
        04|4) clear; cek ;;
        05|5) list_active ;;
        06|6) list_expired ;;
        07|7) clear; member ;;
        08|8) detailed_status ;;
        09|9) clear; speedtest ;;
        10|10) reboot ;;
        11|11) sync; echo 3 > /proc/sys/vm/drop_caches; menu ;;
        12|12) restart_services_pro ;;
        13|13) auto_reboot ;; 
        14|14) auto_backup "force"; menu ;;
        15|15) restore_configs ;;
        16|16) change_domain ;;
        17|17) change_ns ;; # FIXED (Updates both files)
        18|18) change_banner ;;
        19|19) backup_settings ;;
        20|20) live_traffic_monitor ;;
        21|21) generate_id_card ;;
        22|22) visual_settings ;;
        00|0) exit 0 ;;
        *) menu ;;
    esac
}

function menu() { show_menu; }
show_menu

