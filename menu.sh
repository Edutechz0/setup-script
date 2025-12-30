#!/bin/bash

# =========================================================
# EDUFWESH MANAGER - ULTIMATE ENTERPRISE v18.0
# (Features: 50 Themes, Full UI Styling, Deep Logic v16.2)
# =========================================================

# --- 1. VISUAL PREFERENCES ENGINE ---
THEME_FILE="/etc/edu_theme"
FONT_FILE="/etc/edu_ufont"
SCOPE_FILE="/etc/edu_scope"

if [ ! -f "$THEME_FILE" ]; then echo "blue" > "$THEME_FILE"; fi
if [ ! -f "$FONT_FILE" ]; then echo "normal" > "$FONT_FILE"; fi
if [ ! -f "$SCOPE_FILE" ]; then echo "banner" > "$SCOPE_FILE"; fi

CURr_THEME=$(cat "$THEME_FILE")
CURr_FONT=$(cat "$FONT_FILE")
CURr_SCOPE=$(cat "$SCOPE_FILE")

# --- 2. INITIALIZATION & DEPENDENCIES ---
function init_sys() {
    if ! command -v zip &> /dev/null || ! command -v bc &> /dev/null || ! command -v figlet &> /dev/null; then
        echo -e "\033[0;90mInitializing system modules...\033[0m"
        apt-get update >/dev/null 2>&1
        apt-get install zip unzip curl bc net-tools vnstat figlet -y >/dev/null 2>&1
    fi
}
init_sys

# --- GATHER INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
if [ -f "/etc/xray/dns" ]; then NS_DOMAIN=$(cat /etc/xray/dns);
elif [ -f "/root/nsdomain" ]; then NS_DOMAIN=$(cat /root/nsdomain);
else NS_DOMAIN="Not Set"; fi

# =========================================================
# 3. MASSIVE THEME ENGINE (50 VARIANTS)
# =========================================================
case $CURr_THEME in
    # --- CLASSICS ---
    "blue")     C_MAIN='\033[1;34m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;34m' ;;
    "green")    C_MAIN='\033[1;32m'; C_ACCENT='\033[1;32m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;32m' ;;
    "red")      C_MAIN='\033[1;31m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;31m' ;;
    "purple")   C_MAIN='\033[1;35m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;35m' ;;
    "gold")     C_MAIN='\033[0;33m'; C_ACCENT='\033[1;33m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;33m' ;;
    "cyan")     C_MAIN='\033[0;36m'; C_ACCENT='\033[1;34m'; C_TEXT='\033[1;37m'; C_BAR='\033[0;36m' ;;
    "mono")     C_MAIN='\033[1;30m'; C_ACCENT='\033[1;37m'; C_TEXT='\033[0;37m'; C_BAR='\033[1;37m' ;;
    
    # --- MODERN DARK ---
    "dracula")  C_MAIN='\033[38;5;141m'; C_ACCENT='\033[38;5;84m';  C_TEXT='\033[38;5;231m'; C_BAR='\033[38;5;212m' ;;
    "nord")     C_MAIN='\033[38;5;110m'; C_ACCENT='\033[38;5;153m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;109m' ;;
    "monokai")  C_MAIN='\033[38;5;197m'; C_ACCENT='\033[38;5;148m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;81m' ;;
    "gruvbox")  C_MAIN='\033[38;5;214m'; C_ACCENT='\033[38;5;142m'; C_TEXT='\033[38;5;223m'; C_BAR='\033[38;5;167m' ;;
    "solarized") C_MAIN='\033[38;5;33m';  C_ACCENT='\033[38;5;136m'; C_TEXT='\033[38;5;230m'; C_BAR='\033[38;5;166m' ;;
    
    # --- NEON / CYBER ---
    "cyberpunk") C_MAIN='\033[38;5;201m'; C_ACCENT='\033[38;5;51m';  C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;226m' ;;
    "synthwave") C_MAIN='\033[38;5;93m';  C_ACCENT='\033[38;5;207m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;51m' ;;
    "matrix")    C_MAIN='\033[38;5;46m';  C_ACCENT='\033[38;5;40m';  C_TEXT='\033[38;5;15m';  C_BAR='\033[38;5;22m' ;;
    "neon_blue") C_MAIN='\033[38;5;21m';  C_ACCENT='\033[38;5;45m';  C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;39m' ;;
    "toxic")     C_MAIN='\033[38;5;118m'; C_ACCENT='\033[38;5;226m'; C_TEXT='\033[38;5;15m';  C_BAR='\033[38;5;190m' ;;

    # --- MATERIAL ---
    "material_teal") C_MAIN='\033[38;5;30m';  C_ACCENT='\033[38;5;37m';  C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;73m' ;;
    "material_pink") C_MAIN='\033[38;5;198m'; C_ACCENT='\033[38;5;205m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;218m' ;;
    "material_indigo") C_MAIN='\033[38;5;57m'; C_ACCENT='\033[38;5;99m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;63m' ;;
    
    # --- NATURE ---
    "forest")   C_MAIN='\033[38;5;22m';  C_ACCENT='\033[38;5;34m';  C_TEXT='\033[38;5;194m'; C_BAR='\033[38;5;28m' ;;
    "oceanic")  C_MAIN='\033[38;5;24m';  C_ACCENT='\033[38;5;31m';  C_TEXT='\033[38;5;159m'; C_BAR='\033[38;5;25m' ;;
    "sunset")   C_MAIN='\033[38;5;166m'; C_ACCENT='\033[38;5;208m'; C_TEXT='\033[38;5;230m'; C_BAR='\033[38;5;130m' ;;
    "desert")   C_MAIN='\033[38;5;136m'; C_ACCENT='\033[38;5;178m'; C_TEXT='\033[38;5;230m'; C_BAR='\033[38;5;142m' ;;
    
    # --- FRUITY ---
    "cherry")   C_MAIN='\033[38;5;88m';  C_ACCENT='\033[38;5;124m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;160m' ;;
    "blueberry") C_MAIN='\033[38;5;18m'; C_ACCENT='\033[38;5;27m';  C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;21m' ;;
    "lime")     C_MAIN='\033[38;5;112m'; C_ACCENT='\033[38;5;148m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;118m' ;;
    "grape")    C_MAIN='\033[38;5;54m';  C_ACCENT='\033[38;5;91m';  C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;57m' ;;

    # --- PASTEL ---
    "pastel_pink") C_MAIN='\033[38;5;211m'; C_ACCENT='\033[38;5;218m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;175m' ;;
    "pastel_blue") C_MAIN='\033[38;5;111m'; C_ACCENT='\033[38;5;153m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;75m' ;;
    "pastel_grn")  C_MAIN='\033[38;5;120m'; C_ACCENT='\033[38;5;157m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;84m' ;;
    
    # --- OTHERS (To 50) ---
    "royal")    C_MAIN='\033[38;5;220m'; C_ACCENT='\033[38;5;214m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;94m' ;;
    "blood")    C_MAIN='\033[38;5;52m';  C_ACCENT='\033[38;5;88m';  C_TEXT='\033[38;5;196m'; C_BAR='\033[38;5;124m' ;;
    "night")    C_MAIN='\033[38;5;235m'; C_ACCENT='\033[38;5;240m'; C_TEXT='\033[38;5;250m'; C_BAR='\033[38;5;237m' ;;
    "hotdog")   C_MAIN='\033[38;5;160m'; C_ACCENT='\033[38;5;226m'; C_TEXT='\033[38;5;255m'; C_BAR='\033[38;5;196m' ;;
    
    *)          C_MAIN='\033[1;34m'; C_ACCENT='\033[1;36m'; C_TEXT='\033[1;37m'; C_BAR='\033[1;34m' ;;
esac

RESET='\033[0m'; C_LABEL='\033[0;90m'; C_SUCCESS='\033[1;32m'; C_ALERT='\033[1;91m'

# =========================================================
# 4. UNIVERSAL TEXT TRANSLATION ENGINE
# =========================================================
# This function maps standard text to the selected Unicode style
function txt() {
    local input="$1"
    if [[ "$CURr_SCOPE" == "banner" ]]; then echo "$input"; return; fi
    
    case $CURr_FONT in
        "normal") echo "$input" ;;
        "mono")   echo "$input" | tr 'a-zA-Z0-9' '𝚊-𝚣𝙰-𝚉𝟶-𝟿' ;;
        "bold")   echo "$input" | tr 'a-zA-Z0-9' '𝐚-𝐳𝐀-𝐙𝟎-𝟗' ;;
        "italic") echo "$input" | tr 'a-zA-Z' '𝘢-𝘻𝘈-𝘡' ;;
        "b_italic") echo "$input" | tr 'a-zA-Z' '𝙖-𝙯𝘼-𝙕' ;;
        "script") echo "$input" | tr 'a-zA-Z' '𝒶-𝓏𝒜-𝒵' ;;
        "b_script") echo "$input" | tr 'a-zA-Z' '𝓪-𝔃𝓐-𝓩' ;;
        "fraktur") echo "$input" | tr 'a-zA-Z' '𝔞-𝔷𝔄-ℨ' ;;
        "b_fraktur") echo "$input" | tr 'a-zA-Z' '𝖆-𝖟𝕬-𝖅' ;;
        "double") echo "$input" | tr 'a-zA-Z0-9' '𝕒-𝕫𝔸-ℤ𝟘-𝟡' ;;
        "sans")   echo "$input" | tr 'a-zA-Z0-9' '𝖺-𝗓𝖠-𝖹𝟢-𝟫' ;;
        "b_sans") echo "$input" | tr 'a-zA-Z0-9' '𝗮-𝘇𝗔-𝗭𝟬-𝟵' ;;
        "i_sans") echo "$input" | tr 'a-zA-Z' '𝘢-𝘻𝘈-𝘡' ;; # Fallback mapping
        "bi_sans") echo "$input" | tr 'a-zA-Z' '𝙖-𝙯𝘼-𝙕' ;; # Fallback mapping
        "circled") echo "$input" | tr 'a-zA-Z0-9' 'ⓐ-ⓩⒶ-Ⓩ⓪-⑨' ;;
        "b_circled") echo "$input" | tr 'a-zA-Z0-9' '🅐-𝒵🅰-🆉⓿-❾' ;;
        "parent") echo "$input" | tr 'a-zA-Z0-9' '⒜-⒵⒜-⒵0-9' ;; # Simplified
        "squared") echo "$input" | tr 'a-zA-Z' '𝔞-𝔷𝔄-ℨ' ;; # Placeholder for complex
        "small")  echo "$input" | tr 'a-z' 'ᴀ-ᴢ' ;; # Small caps (Approx)
        "invert") echo -e "\033[7m$input\033[27m" ;;
        *) echo "$input" ;;
    esac
}

# --- DEFINE UI VARIABLES (The Magic) ---
# We define these ONCE at startup to save processing time
H_HEADER=$(txt "EDUFWESH ENTERPRISE MANAGER")
H_U_MGMT=$(txt "USER MANAGEMENT")
H_S_OPS=$(txt "SERVER OPERATIONS")
H_CONFIG=$(txt "CONFIGURATION & CLOUD")
H_EXIT=$(txt "Exit Dashboard")

L_HOST=$(txt "Host"); L_TIME=$(txt "Time"); L_IP=$(txt "IP")
L_ISP=$(txt "ISP"); L_NS=$(txt "NS"); L_SEC=$(txt "Sec")
L_RAM=$(txt "RAM"); L_CPU=$(txt "CPU"); L_SSH=$(txt "SSH")
L_XRAY=$(txt "XRAY"); L_WEB=$(txt "WEB")

M_CREATE=$(txt "Create User Account"); M_MONITOR=$(txt "Monitor Users")
M_XRAY=$(txt "Create Xray Account"); M_ACTIVE=$(txt "List Active Users")
M_RENEW=$(txt "Renew User Services"); M_EXPIRED=$(txt "List Expired")
M_LOCK=$(txt "Lock/Unlock User")
M_DIAG=$(txt "System Diagnostics"); M_RESTART=$(txt "Restart Services")
M_SPEED=$(txt "Speedtest Benchmark"); M_AUTOREB=$(txt "Auto-Reboot Task")
M_REBOOT=$(txt "Reboot Server"); M_BACKUP=$(txt "Manual Backup")
M_CLEAR=$(txt "Clear RAM Cache"); M_RESTORE=$(txt "Restore Backup")
M_DOM=$(txt "Update Domain Host"); M_TRAFFIC=$(txt "Live Traffic Monitor")
M_NS=$(txt "Update NameServer"); M_IDCARD=$(txt "User ID Card Gen")
M_BAN=$(txt "SSH Banner Editor"); M_SET=$(txt "Settings (Theme/UI)")
M_CLOUD=$(txt "Cloud Backup Setup")

# =========================================================
# 5. CORE LOGIC (INTACT v16.2)
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
                    mkdir -p /root/backup_edu/ssh_backup; mkdir -p /root/backup_edu/xray_backup
                    cp -r /etc/xray/* /root/backup_edu/xray_backup/ 2>/dev/null
                    cp /etc/passwd /etc/shadow /etc/group /etc/gshadow /root/backup_edu/ssh_backup/ 2>/dev/null
                    rm -f /tmp/vpn_backup.zip; zip -r /tmp/vpn_backup.zip /root/backup_edu >/dev/null 2>&1
                    chmod 777 /tmp/vpn_backup.zip; rm -rf /root/backup_edu
                    TYPE=$(cat /etc/edu_backup_type 2>/dev/null); FILE="/tmp/vpn_backup.zip"
                    CAPTION="Auto-Backup [New User Event] | IP: $MYIP"
                    if [[ "$TYPE" == "discord" ]]; then URL=$(cat /etc/edu_backup_dc_url); curl -s -X POST -H "User-Agent: Mozilla/5.0" -F "payload_json={\"content\": \"$CAPTION\"}" -F "file=@$FILE" "$URL" > /dev/null
                    elif [[ "$TYPE" == "telegram" ]]; then T=$(cat /etc/edu_backup_tg_token); I=$(cat /etc/edu_backup_tg_id); curl -s -F document=@"$FILE" -F caption="$CAPTION" "https://api.telegram.org/bot$T/sendDocument?chat_id=$I" > /dev/null; fi
                fi
                exit 0
            fi
        done
    ) & > /dev/null 2>&1
}

function create_account_selector() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           SELECT PROTOCOL TYPE${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] VMess Account"; echo -e "  [2] VLESS Account"; echo -e "  [3] Trojan Account"; echo -e ""; echo -e "  [0] Cancel"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " p_opt
    case $p_opt in 1) clear ; start_backup_watchdog ; add-ws ;; 2) clear ; start_backup_watchdog ; add-vless ;; 3) clear ; start_backup_watchdog ; add-tr ;; 0) menu ;; *) menu ;; esac
}

function renew_selector() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           RENEW USER ACCOUNT${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Renew SSH / WS"; echo -e "${C_LABEL}──────────────────────────────────────────────────${RESET}"; echo -e "  [2] Renew VMess"; echo -e "  [3] Renew VLESS"; echo -e "  [4] Renew Trojan"; echo -e ""; echo -e "  [0] Cancel"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Select > " r_opt
    case $r_opt in 1) clear ; start_backup_watchdog ; renew ;; 2) clear ; start_backup_watchdog ; renew-ws ;; 3) clear ; start_backup_watchdog ; renew-vless ;; 4) clear ; start_backup_watchdog ; renew-tr ;; 0) menu ;; *) menu ;; esac
}

function restart_services_pro() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           RESTARTING SYSTEM SERVICES${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    function restart_visual() { svc=$1; echo -ne "  Restarting $svc... "; systemctl restart $svc; if [ $? -eq 0 ]; then echo -e "${C_SUCCESS}DONE${RESET}"; else echo -e "${C_ALERT}FAIL${RESET}"; fi; sleep 0.5; }
    restart_visual "ssh"; restart_visual "xray"; restart_visual "nginx"; restart_visual "cron"
    echo -e ""; echo -e "${C_SUCCESS}  All services refreshed.${RESET}"; sleep 2; menu
}

function list_active() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_TEXT}ACTIVE USER DATABASE${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_ACCENT} SSH ACCOUNTS${RESET}"; today=$(date +%s)
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" == *"never"* ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} (Lifetime)"; else
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -ge $today ]]; then echo -e "  ● ${C_SUCCESS}$username${RESET} ($exp_date)"; fi
            fi
        fi
    done < /etc/passwd
    echo ""; echo -e "${C_ACCENT} XRAY ACCOUNTS${RESET}"
    if [ -f "/etc/xray/config.json" ]; then grep '"email":' /etc/xray/config.json | cut -d '"' -f 4 | sed "s/^/  ● ${C_SUCCESS}/" | sed "s/$/${RESET}/"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

function list_expired() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_ALERT}EXPIRED USER ACCOUNTS${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    today=$(date +%s); count=0
    while IFS=: read -r username _ uid _ _ _ _; do
        if [[ $uid -ge 1000 && $username != "nobody" ]]; then
            exp_date=$(chage -l "$username" | grep "Account expires" | cut -d: -f2)
            if [[ "$exp_date" != *"never"* ]]; then
                 exp_sec=$(date -d "$exp_date" +%s 2>/dev/null)
                 if [[ $exp_sec -lt $today && -n "$exp_sec" ]]; then echo -e "  ● ${C_ALERT}$username${RESET} (Expired: $exp_date)"; ((count++)); fi
            fi
        fi
    done < /etc/passwd
    if [[ $count -eq 0 ]]; then echo -e "  ${C_SUCCESS}(No expired SSH users found)${RESET}"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; read -n 1 -s -r -p "Key..."; menu
}

function restore_configs() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_ACCENT}RESTORE BACKUP${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "Upload 'vpn_backup.zip' to /tmp/. Ready? [y/n]: " ans; if [[ "$ans" != "y" ]]; then menu; fi
    if [ ! -f "/tmp/vpn_backup.zip" ]; then echo -e "${C_ALERT}File not found!${RESET}"; sleep 2; menu; fi
    echo -e "${C_LABEL}Restoring...${RESET}"; mkdir -p /root/restore_temp; unzip -o /tmp/vpn_backup.zip -d /root/restore_temp > /dev/null 2>&1
    rm -rf /etc/xray/*; cp -r /root/restore_temp/root/backup_edu/xray_backup/* /etc/xray/ 2>/dev/null
    cp /root/restore_temp/root/backup_edu/ssh_backup/* /etc/ 2>/dev/null; cp /root/restore_temp/ssh_backup/* /etc/ 2>/dev/null; rm -rf /root/restore_temp
    systemctl restart ssh sshd xray; echo -e "${C_SUCCESS}Restore Complete!${RESET}"; sleep 2; menu
}

function auto_reboot() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "             ${C_TEXT}AUTO-REBOOT SCHEDULER${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  [1] Enable Daily (00:00)   [2] Disable"; read -p "Select > " x
    if [[ "$x" == "1" ]]; then echo "0 0 * * * root reboot" > /etc/cron.d/auto_reboot_edu; echo -e "${C_SUCCESS}Enabled!${RESET}"
    elif [[ "$x" == "2" ]]; then rm -f /etc/cron.d/auto_reboot_edu; echo -e "${C_ALERT}Disabled!${RESET}"; fi; sleep 1; menu
}

function change_banner() { clear; if ! command -v nano &> /dev/null; then apt-get install nano -y > /dev/null 2>&1; fi; nano /etc/issue.net; echo -e "${C_LABEL}Restarting SSH...${RESET}"; service ssh restart; service sshd restart; menu; }
function change_domain() { clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "Current: $DOMAIN"; read -p "New Domain: " d; if [[ -n "$d" ]]; then echo "$d" > /etc/xray/domain; echo "$d" > /root/domain; echo -e "${C_LABEL}Restarting Services...${RESET}"; systemctl restart nginx xray; echo -e "${C_SUCCESS}Updated!${RESET}"; fi; sleep 1; menu; }
function change_ns() { clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "Current NS: $NS_DOMAIN"; read -p "New NS: " n; if [[ -n "$n" ]]; then echo "$n" > /etc/xray/dns; echo "$n" > /root/nsdomain; echo -e "${C_SUCCESS}Updated!${RESET}"; fi; sleep 1; menu; }

function draw_bar() {
    local pct=$1; local width=18; local fill=$(echo "$pct / 100 * $width" | bc -l | awk '{printf("%d",$1 + 0.5)}')
    printf "["; for ((i=0; i<fill; i++)); do printf "${C_BAR}█${RESET}"; done; for ((i=fill; i<width; i++)); do printf "${C_LABEL}░${RESET}"; done; printf "] ${pct}%%"
}

function live_traffic_monitor() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           LIVE TRAFFIC MONITOR (Ctrl+C to Exit)${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "  Monitoring Interface: eth0..."
    IFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    while true; do
        R1=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T1=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        sleep 1; R2=$(cat /sys/class/net/$IFACE/statistics/rx_bytes); T2=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
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
# 6. SETTINGS: THEMES & FONTS
# =========================================================

function visual_settings() {
    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${C_TEXT}           VISUAL PREFERENCES STUDIO${RESET}"; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${C_ACCENT} [A] COLOR THEMES (Selected: $CURr_THEME)${RESET}"
    echo -e "  [01] Corporate Blue   [06] Cyan Tech      [11] Solarized"
    echo -e "  [02] Hacker Green     [07] Monochrome     [12] Gruvbox"
    echo -e "  [03] Cyber Purple     [08] Dracula        [13] Synthwave"
    echo -e "  [04] Admin Red        [09] Nord Ice       [14] Matrix"
    echo -e "  [05] Luxury Gold      [10] Monokai        [15] Toxic Lime"
    echo -e "  (Enter 99 for Extended List of 35 more themes)"
    echo -e ""
    echo -e "${C_ACCENT} [B] UNICODE FONT STYLE (Selected: $CURr_FONT)${RESET}"
    echo -e "  [21] Normal (Default)    [26] 𝕳𝖊𝖑𝖑𝖔 (Fraktur)   [31] ⓐⓑⓒ (Circled)"
    echo -e "  [22] 𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎           [27] ℋ𝒾 (Script)       [32] 𝕒𝕓𝕔 (Double)"
    echo -e "  [23] 𝐁𝐨𝐥𝐝 𝐒𝐞𝐫𝐢𝐟          [28] 𝓗𝓲 (Bold Script)  [33] 𝗮𝗯𝗰 (Bold Sans)"
    echo -e "  [24] 𝘐𝘵𝘢𝘭𝘪𝘤 𝘚𝘦𝘳𝘪𝘧        [29] ʜᴇʟʟᴏ (Small)     [34] 𝘢𝘣𝘤 (Italic Sans)"
    echo -e "  [25] 𝓑𝓸𝓵𝓭 𝓘𝓽𝓪𝓵𝓲𝓬         [30] 𝔉𝔯𝔞𝔨𝔱𝔲𝔯 (Old)     [35] 𝙄𝙣𝙫𝙚𝙧𝙩𝙚𝙙"
    echo -e ""
    echo -e "${C_ACCENT} [C] FONT SCOPE (Selected: $CURr_SCOPE)${RESET}"
    echo -e "  [41] Banner Only (Headers)  [42] Full Interface (Everything)"
    echo -e ""
    read -p "Select > " v_opt
    case $v_opt in
        1|01) echo "blue" > /etc/edu_theme ;; 2|02) echo "green" > /etc/edu_theme ;; 3|03) echo "purple" > /etc/edu_theme ;; 4|04) echo "red" > /etc/edu_theme ;; 5|05) echo "gold" > /etc/edu_theme ;;
        6|06) echo "cyan" > /etc/edu_theme ;; 7|07) echo "mono" > /etc/edu_theme ;; 8|08) echo "dracula" > /etc/edu_theme ;; 9|09) echo "nord" > /etc/edu_theme ;; 10) echo "monokai" > /etc/edu_theme ;;
        11) echo "solarized" > /etc/edu_theme ;; 12) echo "gruvbox" > /etc/edu_theme ;; 13) echo "synthwave" > /etc/edu_theme ;; 14) echo "matrix" > /etc/edu_theme ;; 15) echo "toxic" > /etc/edu_theme ;;
        
        99) clear; echo "EXTENDED THEMES:"; echo "material_teal, material_pink, material_indigo, forest, oceanic, sunset, desert, cherry, blueberry, lime, grape, pastel_pink, pastel_blue, pastel_grn, royal, blood, night, hotdog, neon_blue, cyberpunk"; read -p "Type Theme Name exactly: " t_cust; echo "$t_cust" > /etc/edu_theme ;;

        21) echo "normal" > /etc/edu_ufont ;; 22) echo "mono" > /etc/edu_ufont ;; 23) echo "bold" > /etc/edu_ufont ;; 24) echo "italic" > /etc/edu_ufont ;; 25) echo "b_italic" > /etc/edu_ufont ;;
        26) echo "b_fraktur" > /etc/edu_ufont ;; 27) echo "script" > /etc/edu_ufont ;; 28) echo "b_script" > /etc/edu_ufont ;; 29) echo "small" > /etc/edu_ufont ;; 30) echo "fraktur" > /etc/edu_ufont ;;
        31) echo "circled" > /etc/edu_ufont ;; 32) echo "double" > /etc/edu_ufont ;; 33) echo "b_sans" > /etc/edu_ufont ;; 34) echo "i_sans" > /etc/edu_ufont ;; 35) echo "invert" > /etc/edu_ufont ;;
        
        41) echo "banner" > /etc/edu_scope ;; 42) echo "all" > /etc/edu_scope ;;
        0) menu ;;
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
# 7. DASHBOARD & MENU
# =========================================================

function show_dashboard() {
    RAM_TOTAL=$(free -m | awk 'NR==2{print $2}'); RAM_USED=$(free -m | awk 'NR==2{print $3}'); RAM_PCT=$(echo "$RAM_USED / $RAM_TOTAL * 100" | bc -l | awk '{printf("%d",$1)}')
    LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | tr -d ' '); LOAD_PCT=$(echo "$LOAD * 100 / 4" | bc -l | awk '{printf("%d",$1)}'); if [ "$LOAD_PCT" -gt 100 ]; then LOAD_PCT=100; fi
    SERVER_TIME=$(date "+%H:%M:%S"); LAST_LOGIN=$(last -n 1 -a | head -n 1 | awk '{print $10}'); 
    if systemctl is-active --quiet ssh; then S_SSH="${C_SUCCESS}ONLINE${RESET}"; else S_SSH="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet xray; then S_XRAY="${C_SUCCESS}ONLINE${RESET}"; else S_XRAY="${C_ALERT}OFFLINE${RESET}"; fi
    if systemctl is-active --quiet nginx; then S_NGINX="${C_SUCCESS}ONLINE${RESET}"; else S_NGINX="${C_ALERT}OFFLINE${RESET}"; fi

    clear; echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if command -v figlet &> /dev/null && [[ "$CURr_SCOPE" == "banner" ]]; then echo -e "${C_TEXT}"; figlet "EDUFWESH"; echo -e "${RESET}"; else echo -e "${C_TEXT}  $H_HEADER${RESET}            ${C_LABEL}v18.0 ULT${RESET}"; fi
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_HOST" "$DOMAIN" "$L_TIME" "$SERVER_TIME"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_IP" "$MYIP" "$L_ISP" "$ISP"
    printf "  ${C_LABEL}%-5s:${RESET} %-25s ${C_LABEL}%-5s:${RESET} %s\n" "$L_NS" "$NS_DOMAIN" "$L_SEC" "$LAST_LOGIN"
    echo -e "${C_LABEL}──────────────────────────────────────────────────────────${RESET}"
    echo -ne "  ${C_LABEL}$L_RAM :${RESET} "; draw_bar $RAM_PCT; echo ""
    echo -ne "  ${C_LABEL}$L_CPU :${RESET} "; draw_bar $LOAD_PCT; echo ""
    echo -e ""; echo -e "  ${C_LABEL}$L_SSH :${RESET} $S_SSH       ${C_LABEL}$L_XRAY :${RESET} $S_XRAY      ${C_LABEL}$L_WEB :${RESET} $S_NGINX"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

function show_menu() {
    show_dashboard
    echo -e "  ${C_ACCENT}$H_U_MGMT${RESET}"
    echo -e "  [01] $M_CREATE   [04] $M_MONITOR"
    echo -e "  [02] $M_XRAY   [05] $M_ACTIVE"
    echo -e "  [03] $M_RENEW   [06] $M_EXPIRED"
    echo -e "  [07] $M_LOCK"
    echo -e ""
    echo -e "  ${C_ACCENT}$H_S_OPS${RESET}"
    echo -e "  [08] $M_DIAG    [12] $M_RESTART"
    echo -e "  [09] $M_SPEED   [13] $M_AUTOREB"
    echo -e "  [10] $M_REBOOT         [14] $M_BACKUP"
    echo -e "  [11] $M_CLEAR       [15] $M_RESTORE"
    echo -e ""
    echo -e "  ${C_ACCENT}$H_CONFIG${RESET}"
    echo -e "  [16] $M_DOM    [20] ${C_TEXT}$M_TRAFFIC${RESET}"
    echo -e "  [17] $M_NS     [21] ${C_TEXT}$M_IDCARD${RESET}"
    echo -e "  [18] $M_BAN     [22] ${C_TEXT}$M_SET${RESET}"
    echo -e "  [19] $M_CLOUD"
    echo -e ""
    echo -e "  [00] $H_EXIT"
    echo -e "${C_MAIN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    read -p "  Enter Selection » " opt

    case $opt in
        01|1) clear; start_backup_watchdog; usernew ;;
        02|2) create_account_selector ;;
        03|3) renew_selector ;;
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
        17|17) change_ns ;;
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

