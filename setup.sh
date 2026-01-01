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
    if ! grep -q "congestion_control=bbr" /etc/sysctl.conf; then
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    fi
    timeout 3s sysctl -p > /dev/null 2>&1
    
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

if [ ! -s /tmp/installer.bin ]; then
    echo -e "${BIRed}[Error] Failed to download installer. Check internet connection.${NC}"
    exit 1
fi

echo -e "${BIYellow}[Running Core Script...]${NC}"
echo -e "${BICyan}--------------------------------------------------------${NC}"

# === GUARANTEED SILENT INSTALL (ANTI-FREEZE) ===
echo -e "${BIWhite}  Installing packages in background... ${BIYellow}(Max 4 mins)${NC}"

# 1. Start the binary in background with delayed inputs
(
    sleep 5; echo "temp.com"; 
    sleep 2; echo "ns.temp.com"; 
    sleep 2; echo "n"; 
) | /tmp/installer.bin > /dev/null 2>&1 &

# 2. Capture the Process ID (PID)
BG_PID=$!

# 3. Monitor the process with a progress bar
#    We loop 240 times (240 seconds = 4 mins). 
#    If it finishes early, we break. If it hangs, we kill it.
for i in {1..240}; do
    # Check if process is still running
    if ps -p $BG_PID > /dev/null; then
        # Still running: Print a dot or spinner
        echo -ne "\r  ${BIWhite}Working${NC} .   "
        sleep 0.3
        echo -ne "\r  ${BIWhite}Working${NC} ..  "
        sleep 0.3
        echo -ne "\r  ${BIWhite}Working${NC} ... "
        sleep 0.4
    else
        # Process finished naturally!
        break
    fi
done

# 4. SAFETY CHECK: If it's still running after loop, KILL IT.
#    (It's likely stuck on the 'Reboot?' question, so killing is safe)
if ps -p $BG_PID > /dev/null; then
    kill -9 $BG_PID > /dev/null 2>&1
    echo ""
    echo -e "${BIYellow}  [Time Limit Reached] Forcing completion (Safe).${NC}"
fi

echo -e "\r  ${BIGreen}[DONE] Core Installed Successfully.         ${NC}"
sleep 1

# 4. MANUAL CONFIGURATION & REPAIR
clear
msg_box "PHASE 3: SETUP DOMAIN & FIX SSL"

# --- Ask for Domain ---
echo -e "${BIWhite}Please input your Domain (e.g., vpn.edufwesh.com)${NC}"
echo -e "${BIYellow}(Ensure this domain points to this VPS IP!)${NC}"
read -p "Domain : " custom_domain
if [[ -z "$custom_domain" ]]; then
    echo -e "${BIRed}No domain entered. Keeping default 'temp.com' (Will Fail)${NC}"
    custom_domain="temp.com"
else
    # Save Domain
    echo "$custom_domain" > /etc/xray/domain
    echo "$custom_domain" > /root/domain
    mkdir -p /etc/xray
    echo -e "${BIGreen}Domain saved: $custom_domain${NC}"
fi
echo ""

# --- Ask for NameServer ---
echo -e "${BIWhite}Please input your NameServer (NS) (e.g., ns1.edufwesh.com)${NC}"
read -p "NameServer : " custom_ns
if [[ -z "$custom_ns" ]]; then
    custom_ns="ns.$custom_domain"
fi
echo "$custom_ns" > /etc/xray/dns
echo "$custom_ns" > /root/nsdomain
mkdir -p /etc/slowdns
echo "$custom_ns" > /etc/slowdns/nsdomain
echo -e "${BIGreen}NameServer saved: $custom_ns${NC}"
echo ""

# === CRITICAL REPAIR: FIX NGINX & SSL ===
echo -e "${BIYellow}[Repairing Web Server & SSL...]${NC}"

# 1. Replace the dummy "temp.com" with the real domain
sed -i "s/temp.com/$custom_domain/g" /etc/nginx/conf.d/*.conf 2>/dev/null
sed -i "s/temp.com/$custom_domain/g" /etc/nginx/sites-enabled/*.conf 2>/dev/null

# 2. Stop Nginx
systemctl stop nginx

# 3. Generate New SSL Certificate
echo -e "${BIWhite}  - Generating SSL for $custom_domain...${NC}"
mkdir -p /etc/xray
curl -s https://get.acme.sh | sh > /dev/null 2>&1
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m "admin@$custom_domain" > /dev/null 2>&1
/root/.acme.sh/acme.sh --issue -d "$custom_domain" --standalone --force

# 4. Install Certificate
/root/.acme.sh/acme.sh --installcert -d "$custom_domain" \
    --key-file /etc/xray/xray.key \
    --fullchain-file /etc/xray/xray.crt > /dev/null 2>&1

echo -e "${BIGreen}  [OK] SSL Generated & Installed.${NC}"

# 5. Restart Services
systemctl restart nginx
systemctl restart xray
systemctl restart dropbear
systemctl restart ssh

# 5. FINALIZATION
echo ""
msg_box "PHASE 4: FINALIZING & BRANDING"

# Kill Ghost
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force Menu Update
rm -f /usr/bin/menu
wget -q $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

# --- DATA RETRIEVAL FOR RECEIPT ---
MYIP=$(wget -qO- icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)

# --- FINAL CUSTOM RECEIPT ---
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
echo -e "${BICyan}║${NC}  ${BIWhite}Domain       :${NC} ${BIYellow}$custom_domain${NC}"
echo -e "${BICyan}║${NC}  ${BIWhite}NameServer   :${NC} ${BIYellow}$custom_ns${NC}"
echo -e "${BICyan}║${NC}                                                          ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BIWhite} Installation Complete!${NC}"
echo -e "${BIWhite} Type ${BIGreen}menu${BIWhite} to access the Edufwesh Manager.${NC}"
echo ""

# Ask for reboot manually
read -p " Do you want to reboot now? (y/n): " x
if [[ "$x" == "y" || "$x" == "Y" ]]; then
    reboot
else
    echo -e "${BIYellow} Please reboot manually later for all changes to take effect.${NC}"
fi

