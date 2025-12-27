#!/bin/bash

# =========================================================
#  EDUFWESH UNIVERSAL INSTALLER V6.3
#  (Supports Debian 9-12, Ubuntu 18.04 - 24.04)
#  (FIXED: Download Links & Permissions)
# =========================================================

# --- COLORS ---
BIBlack='\033[1;90m'      BIRed='\033[1;91m'
BIGreen='\033[1;92m'      BIYellow='\033[1;93m'
BIBlue='\033[1;94m'       BIPurple='\033[1;95m'
BICyan='\033[1;96m'       BIWhite='\033[1;97m'
NC='\033[0m'

# --- LINKS (FIXED) ---
# We removed "refs/heads/" to ensure wget downloads the actual file, not a 404
INSTALLER_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/main/installer.bin"
MENU_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/main/menu.sh"

# --- HELPER FUNCTIONS ---
function msg_box() {
    echo -e "${BICyan}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan}║${BIYellow}   $1   ${BICyan}║${NC}"
    echo -e "${BICyan}╚══════════════════════════════════════════════════════╝${NC}"
}

# --- OS SPOOFING LOGIC (Makes 24.04 look like 20.04) ---
function fake_os_start() {
    # Backup real OS release file
    cp /etc/os-release /etc/os-release.bak
    
    # Detect if Ubuntu (Works for 20, 22, 24, etc)
    if grep -q "Ubuntu" /etc/os-release; then
        echo -e "${BIYellow}[!] Detected Ubuntu System...${NC}"
        echo -e "${BIYellow}[!] Masquerading as Ubuntu 20.04 LTS for compatibility...${NC}"
        cat > /etc/os-release <<EOF
PRETTY_NAME="Ubuntu 20.04.6 LTS"
NAME="Ubuntu"
VERSION_ID="20.04"
VERSION="20.04.6 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
EOF
    else
        # Pretend to be Debian 10 for any Debian version (9, 10, 11, 12)
        echo -e "${BIYellow}[!] Detected Debian System...${NC}"
        echo -e "${BIYellow}[!] Masquerading as Debian 10 (Buster) for compatibility...${NC}"
        cat > /etc/os-release <<EOF
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
EOF
    fi
}

function restore_os_end() {
    # Restore the real OS file immediately so system isn't confused later
    if [ -f "/etc/os-release.bak" ]; then
        mv /etc/os-release.bak /etc/os-release
        echo -e "${BIGreen}[✓] Real OS Identity Restored.${NC}"
    fi
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
echo -e "${BICyan} ║            ${BIYellow}EDUFWESH VPN AUTOSCRIPT V6.3            ${BICyan}║${NC}"
echo -e "${BICyan} ║       ${BIWhite}Ubuntu 24.04 Support + Link Fixes            ${BICyan}║${NC}"
echo -e "${BICyan} ╚══════════════════════════════════════════════════════╝${NC}"
echo ""

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

# 3. INSTALLATION PHASE (With OS Masquerade)
echo ""
msg_box "PHASE 2: INSTALLING VPN CORE"

# Enable Masquerade
fake_os_start

echo -e "${BIYellow}[Downloading Installer...]${NC}"
wget -q $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

echo -e "${BIYellow}[Running Core Script...]${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"
# Run the binary (It will now think the OS is compatible)
/tmp/installer.bin
echo -e "${BICyan}--------------------------------------------------------${NC}"

# Disable Masquerade (Restore Real OS)
restore_os_end

# 4. FINALIZATION
echo ""
msg_box "PHASE 3: FINALIZING"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu

# --- SAFETY FORCE PERMISSIONS ---
# This fixes the "Permission Denied" error permanently
chmod +x /usr/bin/menu
chmod 777 /usr/bin/menu

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

