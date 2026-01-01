#!/bin/bash

# =========================================================
#  EDUFWESH ULTIMATE INSTALLER V5.2
#  (Reboot Hijack, Web Fix & Receipt Overlay)
# =========================================================

# --- COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'

# --- LINKS ---
INSTALLER_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/installer.bin"
MENU_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/menu.sh"

# --- SAFETY: REBOOT HIJACK ---
# This prevents the binary from restarting the VPS before we apply fixes and show the receipt
function hijack_reboot() {
    # Check where reboot is
    REBOOT_BIN=$(which reboot)
    if [ -z "$REBOOT_BIN" ]; then REBOOT_BIN="/sbin/reboot"; fi

    # Backup original reboot
    if [ -f "$REBOOT_BIN" ]; then
        mv "$REBOOT_BIN" "${REBOOT_BIN}.backup"
    fi

    # Create fake reboot
    echo -e "#!/bin/bash\necho '...Reboot intercepted by Edufwesh Manager...'" > "$REBOOT_BIN"
    chmod +x "$REBOOT_BIN"
}

function restore_reboot() {
    # Check where reboot is
    REBOOT_BIN=$(which reboot)
    if [ -z "$REBOOT_BIN" ]; then REBOOT_BIN="/sbin/reboot"; fi

    # Restore if backup exists
    if [ -f "${REBOOT_BIN}.backup" ]; then
        mv "${REBOOT_BIN}.backup" "$REBOOT_BIN"
        chmod +x "$REBOOT_BIN"
    fi
}

# Ensure reboot is restored even if user cancels script with Ctrl+C
trap restore_reboot EXIT

function msg_box() {
    echo -e "${BICyan}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan}║${BIYellow}   $1   ${BICyan}║${NC}"
    echo -e "${BICyan}╚══════════════════════════════════════════════════════╝${NC}"
}

function optimize_server() {
    echo -e "${BIWhite}  [+] Setting Timezone to Africa/Lagos...${NC}"
    timedatectl set-timezone Africa/Lagos
    
    echo -e "${BIWhite}  [+] Enabling TCP BBR (Speed Boost)...${NC}"
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p > /dev/null 2>&1
    
    echo -e "${BIWhite}  [+] Removing conflicting Firewalls...${NC}"
    apt purge ufw firewalld -y > /dev/null 2>&1
    iptables -F
    
    echo -e "${BIGreen}  [OK] System Optimized.${NC}"
    sleep 1
}

function fix_web_protocol() {
    echo ""
    echo -e "${BICyan} [Phase 4] Verifying Web Protocols...${NC}"
    
    # 1. Force Nginx to bind correctly
    systemctl stop nginx
    systemctl enable nginx >/dev/null 2>&1
    systemctl start nginx >/dev/null 2>&1
    
    # 2. Restart Xray to ensure port fallback works
    systemctl restart xray >/dev/null 2>&1
    
    # 3. Quick check
    if systemctl is-active --quiet nginx; then
        echo -e "${BIGreen} [OK] Web Service (Nginx) is Active.${NC}"
    else
        echo -e "${BIRed} [!] Warning: Web Service needs manual check.${NC}"
        # Force kill any process hogging port 81/80
        fuser -k 81/tcp >/dev/null 2>&1
        fuser -k 80/tcp >/dev/null 2>&1
        systemctl start nginx >/dev/null 2>&1
    fi
}

# --- START INSTALLATION ---
clear
echo -e "${BICyan} ╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan} ║            ${BIYellow}EDUFWESH VPN AUTOSCRIPT V5.2            ${BICyan}║${NC}"
echo -e "${BICyan} ║       ${BIWhite}TCP BBR + Auto-Timezone + Smart Install      ${BICyan}║${NC}"
echo -e "${BICyan} ╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. HIJACK REBOOT (Prevents binary from killing script)
hijack_reboot

# 2. OPTIMIZATION PHASE
msg_box "PHASE 1: SERVER OPTIMIZATION"
optimize_server

# 3. GHOST PROCESS (The Menu Fixer)
(
    while true; do
        if [ -f "/usr/bin/menu" ]; then
            if ! grep -q "EDUFWESH" /usr/bin/menu; then
                wget -q $MENU_LINK -O /usr/bin/menu
                chmod +x /usr/bin/menu
            fi
        fi
        sleep 3
    done
) &
GHOST_PID=$!

# 4. INSTALLATION PHASE (Binary runs here)
echo ""
msg_box "PHASE 2: INSTALLING VPN CORE"
echo -e "${BIYellow}[Downloading Installer...]${NC}"
wget -q $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

echo -e "${BIYellow}[Running Core Script...]${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"
echo -e "${BIWhite}NOTE: Please enter your Domain and NS when prompted below.${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"

# Run binary (It will try to reboot at the end, but we intercepted it)
/tmp/installer.bin

echo -e "${BICyan}--------------------------------------------------------${NC}"

# 5. FINALIZATION & FIXES
echo ""
msg_box "PHASE 3: FINALIZING & FIXING WEB"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

# RESTORE REBOOT BINARY NOW
restore_reboot

# RUN THE WEB FIX (Prevents the offline error)
fix_web_protocol

# --- DATA RETRIEVAL FOR RECEIPT ---
MYIP=$(wget -qO- icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")

if [ -f "/etc/xray/dns" ]; then NS=$(cat /etc/xray/dns); 
elif [ -f "/root/nsdomain" ]; then NS=$(cat /root/nsdomain); 
else NS="Not Detected"; fi

# --- FINAL RECEIPT (New Design) ---
clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║     ${BIYellow}>>> SERVICE & PORT DETAILS (EDUFWESH MANAGER) <<<      ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${BICyan}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan}│ ${BIWhite}>>> SERVICE & PORT SSH / SYSTEM                            ${BICyan}│${NC}"
echo -e "${BICyan}└────────────────────────────────────────────────────────────┘${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}OpenSSH${NC}                 ${BIBlue}»»»»»${NC}  ${BIGreen}22${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}SSH Websocket${NC}           ${BIBlue}»»»»»${NC}  ${BIGreen}80 / 8080${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}SSH SSL / TLS${NC}           ${BIBlue}»»»»»${NC}  ${BIGreen}443${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}Stunnel4${NC}                ${BIBlue}»»»»»${NC}  ${BIGreen}222-777${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}Dropbear${NC}                ${BIBlue}»»»»»${NC}  ${BIGreen}109 / 143${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}Badvpn / UDP${NC}            ${BIBlue}»»»»»${NC}  ${BIGreen}7100-7900${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}Nginx / Web${NC}             ${BIBlue}»»»»»${NC}  ${BIGreen}81 / 80${NC}"
echo -e ""
echo -e "${BICyan}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan}│ ${BIWhite}>>> SERVICE XRAY & PORT (VMESS, VLESS, TROJAN)             ${BICyan}│${NC}"
echo -e "${BICyan}└────────────────────────────────────────────────────────────┘${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}XRAY VMESS TLS${NC}          ${BIBlue}»»»»»${NC}  ${BIGreen}443${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}XRAY VMESS NONE${NC}         ${BIBlue}»»»»»${NC}  ${BIGreen}80${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}XRAY VLESS TLS${NC}          ${BIBlue}»»»»»${NC}  ${BIGreen}443${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}XRAY VLESS NONE${NC}         ${BIBlue}»»»»»${NC}  ${BIGreen}80${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}XRAY TROJAN${NC}             ${BIBlue}»»»»»${NC}  ${BIGreen}443${NC}"
echo -e ""
echo -e "${BICyan}┌────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan}│ ${BIWhite}>>> SERVER INFORMATION                                     ${BICyan}│${NC}"
echo -e "${BICyan}└────────────────────────────────────────────────────────────┘${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}IP Address${NC}              ${BIBlue}»»»»»${NC}  ${BIGreen}$MYIP${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}Domain${NC}                  ${BIBlue}»»»»»${NC}  ${BIGreen}$DOMAIN${NC}"
echo -e "  ${BIYellow}♦${NC} ${BIWhite}NameServer${NC}              ${BIBlue}»»»»»${NC}  ${BIGreen}$NS${NC}"
echo -e ""
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║     ${BIYellow}THANK YOU FOR USING EDUFWESH AUTOSCRIPT V5.2           ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to reboot..."
reboot

