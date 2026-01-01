#!/bin/bash

# =========================================================
#  EDUFWESH ULTIMATE INSTALLER V5.1
#  (Redesigned Receipt, Input Styling & Nginx Safety Fix)
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

# --- HELPER FUNCTIONS ---
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

function setup_inputs() {
    clear
    echo -e "${BICyan} ╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan} ║            ${BIYellow}EDUFWESH VPN AUTOSCRIPT V5.1            ${BICyan}║${NC}"
    echo -e "${BICyan} ║       ${BIWhite}TCP BBR + Auto-Timezone + Smart Install      ${BICyan}║${NC}"
    echo -e "${BICyan} ╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # --- DOMAIN INPUT (Replaces the ugly binary prompt) ---
    echo -e "${BICyan}┌──────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan}│ ${BIWhite}              INPUT DOMAIN CONFIGURATION             ${BICyan}│${NC}"
    echo -e "${BICyan}└──────────────────────────────────────────────────────┘${NC}"
    echo -e "${BIYellow}  Please enter your domain (e.g., vpn.example.com)${NC}"
    read -p "  Domain : " domain_input
    
    if [[ -z "$domain_input" ]]; then
        echo -e "${BIRed}  [!] No domain entered. Using default random.${NC}"
    else
        # Pre-save domain so the core script might find it and skip asking
        mkdir -p /etc/xray
        mkdir -p /root
        echo "$domain_input" > /etc/xray/domain
        echo "$domain_input" > /root/domain
        echo -e "${BIGreen}  [OK] Domain Saved.${NC}"
    fi
    echo ""

    # --- NAMESERVER INPUT ---
    echo -e "${BICyan}┌──────────────────────────────────────────────────────┐${NC}"
    echo -e "${BICyan}│ ${BIWhite}            INPUT NAMESERVER (NS) CONFIG             ${BICyan}│${NC}"
    echo -e "${BICyan}└──────────────────────────────────────────────────────┘${NC}"
    echo -e "${BIYellow}  Please enter your NameServer (NS) (e.g., ns.example.com)${NC}"
    echo -e "${BIYellow}  Leave empty if you don't use SlowDNS.${NC}"
    read -p "  NS Domain : " ns_input
    
    if [[ -n "$ns_input" ]]; then
        echo "$ns_input" > /etc/xray/dns
        echo "$ns_input" > /root/nsdomain
        echo -e "${BIGreen}  [OK] NameServer Saved.${NC}"
    else
        echo -e "${BIWhite}  [!] Skipping NS Setup.${NC}"
    fi
    sleep 1
}

function fix_web_protocol() {
    # FIX: This function prevents the "Web Offline" issue
    # It forces Nginx to restart and bind correctly after the heavy installation
    echo ""
    echo -e "${BICyan} [Phase 4] Verifying Web Protocols...${NC}"
    
    # 1. Restart Nginx to pick up new certs/domain
    systemctl enable nginx >/dev/null 2>&1
    systemctl restart nginx >/dev/null 2>&1
    
    # 2. Restart Xray to ensure port fallback works
    systemctl restart xray >/dev/null 2>&1
    
    # 3. Quick check
    if systemctl is-active --quiet nginx; then
        echo -e "${BIGreen} [OK] Web Service (Nginx) is Active.${NC}"
    else
        echo -e "${BIRed} [!] Warning: Web Service needs manual check.${NC}"
        systemctl start nginx >/dev/null 2>&1 # One last try
    fi
}

# --- START INSTALLATION ---
setup_inputs

# 1. OPTIMIZATION PHASE
msg_box "PHASE 1: SERVER OPTIMIZATION"
optimize_server

# 2. GHOST PROCESS (The Menu Fixer)
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

# 3. INSTALLATION PHASE
echo ""
msg_box "PHASE 2: INSTALLING VPN CORE"
echo -e "${BIYellow}[Downloading Installer...]${NC}"
wget -q $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

echo -e "${BIYellow}[Running Core Script...]${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"
# Run binary
/tmp/installer.bin
echo -e "${BICyan}--------------------------------------------------------${NC}"

# 4. FINALIZATION
echo ""
msg_box "PHASE 3: FINALIZING"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

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
echo -e "${BICyan}║   ${BIYellow}>>> SERVICE & PORT DETAILS (EDUFWESH MANAGER) <<<      ${BICyan}║${NC}"
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
echo -e "${BICyan}║     ${BIYellow}THANK YOU FOR USING EDUFWESH AUTOSCRIPT V5.1           ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
read -n 1 -s -r -p "Press any key to reboot..."
reboot

