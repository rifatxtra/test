#!/bin/bash

# Virtualmin Custom Install Script
# Usage: ./setup-vps.sh

# 1. SET YOUR REPO URL HERE
# Replace this with your actual GitHub URL
REPO_URL="https://github.com/YOUR_USERNAME/virtualmin-gpl.git"

echo "================================================================="
echo "  Virtualmin Custom Installer"
echo "  1. Installs official stack (LAMP/LEMP)"
echo "  2. Swaps 'virtual-server' module with your custom version"
echo "================================================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# 2. Download and Run Official Installer
echo "Downloading official installer..."
wget https://software.virtualmin.com/gpl/scripts/install.sh
chmod +x install.sh

echo "Running official installer (LAMP stack)..."
# Pass -y to assume yes, -f (force) if needed, -b LEMP if you prefer Nginx
/bin/sh install.sh -y

if [ $? -ne 0 ]; then
    echo "Official installer failed. Exiting."
    exit 1
fi

# 3. Swap the Module
echo "Installing your custom 'virtual-server' module..."

# Location of Webmin modules (usually /usr/share/webmin or /usr/libexec/webmin)
if [ -d "/usr/share/webmin" ]; then
    WEBMIN_DIR="/usr/share/webmin"
elif [ -d "/usr/libexec/webmin" ]; then
    WEBMIN_DIR="/usr/libexec/webmin"
else
    echo "Could not find Webmin directory. Please check installation."
    exit 1
fi

cd "$WEBMIN_DIR" || exit

# Backup original
if [ -d "virtual-server" ]; then
    mv virtual-server virtual-server.official
fi

# Clone your repo
# Ensure git is installed
if ! command -v git &> /dev/null; then
    apt-get install -y git || yum install -y git
fi

echo "Cloning from $REPO_URL..."
git clone "$REPO_URL" virtual-server

# 4. Restart Webmin to load changes
echo "Restarting Webmin..."
/etc/webmin/restart

echo "================================================================="
echo "  SUCCESS! Virtualmin installed with your custom module."
echo "  Access at https://$(hostname -I | awk '{print $1}'):10000"
echo "================================================================="
