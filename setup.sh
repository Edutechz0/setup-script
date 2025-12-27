#!/bin/bash

# =========================================================
#  EDUFWESH ULTIMATE INSTALLER V5.0
#  (Optimized for Speed, Stability & Premium Menu v12)
# =========================================================

# --- COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'

# --- LINKS ---
# Ensure these point to your repository
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

# --- START INSTALLATION ---
clear
echo -e "${BICyan} ╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan} ║            ${BIYellow}EDUFWESH VPN AUTOSCRIPT V5.0            ${BICyan}║${NC}"
echo -e "${BICyan} ║       ${BIWhite}TCP BBR + Auto-Timezone + Smart Install      ${BICyan}║${NC}"
echo -e "${BICyan} ╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. OPTIMIZATION PHASE
msg_box "PHASE 1: SERVER OPTIMIZATION"
optimize_server

# 2. GHOST PROCESS (The Menu Fixer)
# This watches the file system and kills the 'bad' menu immediately
(
    while true; do
        if [ -f "/usr/bin/menu" ]; then
            # If the menu file exists but doesn't have your brand, overwrite it
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
# Run the locked binary
/tmp/installer.bin
echo -e "${BICyan}--------------------------------------------------------${NC}"

# 4. FINALIZATION
echo ""
msg_box "PHASE 3: FINALIZING"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update (One last time to be 100% sure)
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

# --- DATA RETRIEVAL FOR RECEIPT ---
MYIP=$(wget -qO- icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
CITY=$(curl -s ipinfo.io/city)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null || echo "Not Set")

# Try to find Name Server (NS)
if [ -f "/etc/xray/dns" ]; then NS=$(cat /etc/xray/dns); 
elif [ -f "/etc/slowdns/nsdomain" ]; then NS=$(cat /etc/slowdns/nsdomain); 
elif [ -f "/root/nsdomain" ]; then NS=$(cat /root/nsdomain); 
else NS="Not Detected"; fi

# --- FINAL RECEIPT ---
clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║             ${BIGreen}INSTALLATION COMPLETED SUCCESSFULLY!           ${BICyan}║${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Server IP    : ${BIYellow}$MYIP${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}ISP / Region : ${BIYellow}$ISP ($CITY)${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Domain       : ${BIYellow}$DOMAIN${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Name Server  : ${BIYellow}$NS${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Type command: ${BIGreen}menu${NC} ${BIWhite}to open the Edufwesh Manager.    ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

