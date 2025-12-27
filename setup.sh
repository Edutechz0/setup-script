#!/bin/bash

# ==========================================
# EDUFWESH VPN AUTO-SCRIPT
# ==========================================

# 1. DOWNLOAD AND RUN THE LOCKED CORE INSTALLER
# This pulls your encrypted file from GitHub
INSTALLER_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/installer.bin"

echo "Downloading Core Files..."
wget $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

# Run the locked installer
echo "Running Installation..."
/tmp/installer.bin

# ==========================================
# 2. APPLY EDUFWESH BRANDING FIX
# This runs AUTOMATICALLY after the locked installer finishes
# ==========================================

echo "Applying Edufwesh Branding..."

# Delete the 'Error 404' menu the locked script installed
rm -f /usr/bin/menu

# Download YOUR custom menu
wget https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/menu.sh -O /usr/bin/menu
chmod +x /usr/bin/menu

# Clean up temporary files
rm -f /tmp/installer.bin
clear

echo "=================================================="
echo "  EDUFWESH MANAGER INSTALLED SUCCESSFULLY!"
echo "=================================================="
echo "  Type 'menu' to access your panel."
echo "=================================================="
