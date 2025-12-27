#!/bin/bash

# ==========================================
# EDUFWESH AUTO-SCRIPT (WITH GHOST FIXER)
# ==========================================

# Link to your locked installer
INSTALLER_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/installer.bin"

# Link to your new menu
MENU_LINK="https://raw.githubusercontent.com/Edutechz0/setup-script/refs/heads/main/menu.sh"

# ----------------------------------------------------
# 1. START THE "GHOST" (Background Process)
# This runs secretly while the installer is working.
# It checks every 3 seconds if the bad menu has appeared.
# ----------------------------------------------------
(
    while true; do
        # Check if the menu file exists
        if [ -f "/usr/bin/menu" ]; then
            # Check if it is the OLD one (Does not contain 'EDUFWESH')
            if ! grep -q "EDUFWESH" /usr/bin/menu; then
                # BLAM! Overwrite it immediately.
                wget -q $MENU_LINK -O /usr/bin/menu
                chmod +x /usr/bin/menu
            fi
        fi
        # Wait 3 seconds and check again
        sleep 3
    done
) &
GHOST_PID=$!
# ----------------------------------------------------

# 2. RUN THE LOCKED INSTALLER
echo "Downloading Core Files..."
wget $INSTALLER_LINK -O /tmp/installer.bin
chmod +x /tmp/installer.bin

echo "Running Installation..."
# We run this, but our Ghost is watching in the background!
/tmp/installer.bin

# ----------------------------------------------------
# 3. CLEANUP
# ----------------------------------------------------
kill $GHOST_PID 2>/dev/null
rm -f /tmp/installer.bin

# Force apply the menu one last time to be sure
rm -f /usr/bin/menu
wget $MENU_LINK -O /usr/bin/menu
chmod +x /usr/bin/menu

clear
echo "=================================================="
echo "  EDUFWESH MANAGER INSTALLED SUCCESSFULLY!"
echo "=================================================="
echo "  Type 'menu' to access your panel."
echo "=================================================="

