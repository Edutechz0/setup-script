#!/bin/bash

# =========================================================
#  EDUFWESH PREMIUM INSTALLER V3.0
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

# --- BRANDING FUNCTION ---
function print_logo() {
    clear
    echo -e "${BICyan} ╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BICyan} ║            ${BIYellow}EDUFWESH VPN AUTOSCRIPT V3.0            ${BICyan}║${NC}"
    echo -e "${BICyan} ║         ${BIWhite}Premium Installer & Manager Edition        ${BICyan}║${NC}"
    echo -e "${BICyan} ╚══════════════════════════════════════════════════════╝${NC}"
    echo -e ""
}

# --- START INSTALLATION ---
print_logo
echo -e "${BIYellow}[1/4]${NC} ${BIWhite}Initializing Environment...${NC}"
sleep 2

# ----------------------------------------------------
# 1. GHOST PROCESS (Silent Fixer)
# ----------------------------------------------------
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

# ----------------------------------------------------
# 2. RUN LOCKED INSTALLER
# ----------------------------------------------------
echo -e "${BIYellow}[2/4]${NC} ${BIWhite}Downloading Core Files...${NC}"
wget -q $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

echo -e "${BIYellow}[3/4]${NC} ${BIWhite}Running Main Installer...${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"
# Run the binary
/tmp/installer.bin
echo -e "${BICyan}--------------------------------------------------------${NC}"

# ----------------------------------------------------
# 3. FINALIZATION & DATA FETCH
# ----------------------------------------------------
echo -e "${BIYellow}[4/4]${NC} ${BIWhite}Finalizing & Branding...${NC}"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

# --- DATA RETRIEVAL ---
# We try to find where the locked script saved the info
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Not Set")

# Try to find Name Server (NS) in common paths
if [ -f "/etc/xray/dns" ]; then
    NS_DOMAIN=$(cat /etc/xray/dns)
elif [ -f "/etc/slowdns/nsdomain" ]; then
    NS_DOMAIN=$(cat /etc/slowdns/nsdomain)
elif [ -f "/root/nsdomain" ]; then
    NS_DOMAIN=$(cat /root/nsdomain)
else
    NS_DOMAIN="Not Set / Unknown"
fi

# ----------------------------------------------------
# 4. PREMIUM SUMMARY DISPLAY
# ----------------------------------------------------
clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║             ${BIGreen}INSTALLATION COMPLETED SUCCESSFULLY!           ${BICyan}║${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Server IP    : ${BIYellow}$MYIP${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Domain       : ${BIYellow}$DOMAIN${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}Name Server  : ${BIYellow}$NS_DOMAIN${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}To open the panel, type command: ${BIGreen}menu${NC}                  ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
