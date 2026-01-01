#!/bin/bash

# =========================================================
#  EDUFWESH ULTIMATE INSTALLER V5.0
#  (Optimized for Speed, Stability & Premium Menu v17)
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

# =========================================================
# MODIFIED BYPASS LOGIC
# =========================================================
# We feed "n" into the binary so it doesn't pause for reboot.
# We redirect output slightly so we can clear the screen immediately.
echo "n" | /tmp/installer.bin

# IMMEDIATELY Clear the screen to hide the old design
clear

# 4. FINALIZATION
msg_box "PHASE 3: FINALIZING & BRANDING"

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

# --- FINAL CUSTOM RECEIPT (REPLACES OLD SCREEN) ---
clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║   ${BIYellow}           EDUFWESH AUTOSCRIPT INSTALLER            ${BICyan}   ║${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC} ${BIWhite}>>> SERVICE & PORT DETAILS <<<                           ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}                                                          ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}OpenSSH${NC}       :  ${BIYellow}22${NC}                                  ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}SSH Websocket${NC} :  ${BIYellow}80 [HTTP]${NC}                           ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}SSH SSL${NC}       :  ${BIYellow}443 [HTTPS]${NC}                         ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}Stunnel4${NC}      :  ${BIYellow}447, 777${NC}                            ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}Dropbear${NC}      :  ${BIYellow}109, 143${NC}                            ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}BadVPN UDP${NC}    :  ${BIYellow}7100, 7200, 7300${NC}                    ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}Nginx${NC}         :  ${BIYellow}81${NC}                                  ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}XRAY Vmess${NC}    :  ${BIYellow}443, 80${NC}                             ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}XRAY Vless${NC}    :  ${BIYellow}443, 80${NC}                             ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIGreen}♦${NC} ${BIWhite}XRAY Trojan${NC}   :  ${BIYellow}443${NC}                                 ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}                                                          ${BICyan}║${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC} ${BIWhite}>>> SERVER INFORMATION <<<                               ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}                                                          ${BICyan}║${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}IP Address   :${NC} ${BIYellow}$MYIP${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}ISP / Region :${NC} ${BIYellow}$ISP${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Domain       :${NC} ${BIYellow}$DOMAIN${NC}"
echo -e "${BICyan}║${NC}                                                          ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BIWhite} Installation Complete!${NC}"
echo -e "${BIWhite} Type ${BIGreen}menu${BIWhite} to access the Edufwesh Manager.${NC}"
echo ""

# Ask for reboot manually since we skipped the binary's reboot
read -p " Do you want to reboot now? (y/n): " x
if [[ "$x" == "y" || "$x" == "Y" ]]; then
    reboot
else
    echo -e "${BIYellow} Please reboot manually later for all changes to take effect.${NC}"
fi

