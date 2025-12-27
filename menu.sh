#!/bin/bash

# --- BRANDING COLORS ---
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
NC='\033[0m'              # No Color

# --- INFO ---
MYIP=$(wget -qO- icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "Domain Not Found")

# --- MENU HEADER ---
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan} │                  ${BIYellow}EDUFWESH VPN MANAGER               ${BICyan}│${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BIWhite}  Server IP   : ${BIGreen}$MYIP${NC}"
echo -e "${BIWhite}  Domain      : ${BIGreen}$DOMAIN${NC}"
echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"

# --- MENU OPTIONS ---
echo -e "  ${BICyan}[01]${NC} ${BIWhite}Create SSH Account${NC}"
echo -e "  ${BICyan}[02]${NC} ${BIWhite}Create V2Ray/Xray Account${NC}"
echo -e "  ${BICyan}[03]${NC} ${BIWhite}Check User Login${NC}"
echo -e "  ${BICyan}[04]${NC} ${BIWhite}Check System Status${NC}"
echo -e "  ${BICyan}[05]${NC} ${BIWhite}Speedtest${NC}"
echo -e "  ${BICyan}[06]${NC} ${BIWhite}Reboot Server${NC}"
echo -e "  ${BICyan}[00]${NC} ${BIRed}Exit${NC}"
echo -e "${BICyan} ───────────────────────────────────────────────────────${NC}"
read -p "  Select Menu :  " opt

# --- COMMAND LOGIC ---
# We point these to the standard script names often used in these installers.
# If these don't work, we can check /usr/bin later to find the real names.

case $opt in
01 | 1) clear ; usernew ;;         # Often named 'usernew'
02 | 2) clear ; add-ws ;;          # Often named 'add-ws' or 'add-vless'
03 | 3) clear ; cek ;;             # Often named 'cek' or 'user-login'
04 | 4) clear ; status ;;          # Often named 'status' or 'info'
05 | 5) clear ; speedtest ;;
06 | 6) clear ; reboot ;;
00 | 0) clear ; exit 0 ;;
*) clear ; echo "Invalid Option" ; sleep 1 ; menu ;;
esac
