#!/bin/bash
# Linux Audit Pro Installer v2.0
# Secure GPG-Verified Installation Script
# Author: Deka1918
# Repository: https://github.com/deka1918/Linux-Audit-Pro-v2.0

# Configuration
APP_URL="https://github.com/deka1918/Linux-Audit-Pro-v2.0/releases/download/v2.0.0/Linux_Audit_Pro-x86_64.AppImage"
SIG_URL="https://github.com/deka1918/Linux-Audit-Pro-v2.0/releases/download/v2.0.0/Linux_Audit_Pro-x86_64.AppImage.asc"
KEY_URL="https://github.com/deka1918/Linux-Audit-Pro-v2.0/releases/download/v2.0.0/public-key.asc"
ICON_URL="https://github.com/deka1918/Linux-Audit-Pro-v2.0/raw/main/audit-icon.png"

INSTALL_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/share/applications"
APP_NAME="audit-pro"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}" >&2
    echo -e "Please run with sudo or as root user"
    exit 1
fi

cleanup() {
    rm -f "/tmp/${APP_NAME}.AppImage" "/tmp/${APP_NAME}.AppImage.asc" "/tmp/public-key.asc"
}
trap cleanup EXIT

echo -e "${YELLOW}[1/4] Downloading files...${NC}"
echo -e "• AppImage"
wget --show-progress -q -O "/tmp/${APP_NAME}.AppImage" "$APP_URL" || {
    echo -e "${RED}Error: Failed to download AppImage${NC}" >&2
    exit 1
}

echo -e "• Signature"
wget --show-progress -q -O "/tmp/${APP_NAME}.AppImage.asc" "$SIG_URL" || {
    echo -e "${RED}Error: Failed to download signature${NC}" >&2
    exit 1
}

echo -e "• GPG Key"
wget --show-progress -q -O "/tmp/public-key.asc" "$KEY_URL" || {
    echo -e "${RED}Error: Failed to download GPG key${NC}" >&2
    exit 1
}

echo -e "${YELLOW}[2/4] Verifying authenticity...${NC}"
gpg --import "/tmp/public-key.asc" >/dev/null 2>&1

if ! gpg --verify "/tmp/${APP_NAME}.AppImage.asc" "/tmp/${APP_NAME}.AppImage" >/dev/null 2>&1; then
    echo -e "${RED}SECURITY WARNING: GPG verification failed!${NC}" >&2
    echo -e "The downloaded file may have been tampered with."
    echo -e "Do NOT proceed with installation."
    exit 1
fi
echo -e "${GREEN}✓ GPG verification passed${NC}"

echo -e "${YELLOW}[3/4] Installing...${NC}"

install -v -m 755 "/tmp/${APP_NAME}.AppImage" "${INSTALL_DIR}/${APP_NAME}"

wget -q -O "${INSTALL_DIR}/audit-icon.png" "$ICON_URL"

cat > "${DESKTOP_DIR}/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Name=Linux Audit Pro
Comment=Professional Linux Security Audit Tool
Exec=${INSTALL_DIR}/${APP_NAME}
Icon=${INSTALL_DIR}/audit-icon.png
Type=Application
Categories=Utility;Security;System;
Terminal=true
EOF

update-desktop-database "$DESKTOP_DIR"

echo -e "${YELLOW}[4/4] Performing final checks...${NC}"
if [ -x "${INSTALL_DIR}/${APP_NAME}" ]; then
    echo -e "${GREEN}Installation successful!${NC}"
    echo -e "\nYou can now run:"
    echo -e "• Terminal: ${GREEN}${APP_NAME}${NC}"
    echo -e "• Desktop: Search for 'Linux Audit Pro' in your application menu"
else
    echo -e "${RED}Installation failed!${NC}" >&2
    exit 1
fi

exit 0
