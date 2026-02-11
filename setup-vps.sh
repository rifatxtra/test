#!/bin/bash

# Virtualmin Custom Install Script
# Usage: ./setup-vps.sh

# 1. SET YOUR REPO URL HERE
# Replace this with your actual GitHub URL
REPO_URL="https://github.com/rifatxtra/test.git"

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

# Detect if we are running INSIDE the repo
if [ -f "./module.info" ] && [ -f "./virtual-server-lib.pl" ]; then
    echo "Detected running from within the repository. Installing from CURRENT DIRECTORY..."
    INSTALL_FROM_LOCAL=true
else
    echo "Installing by CLONING from GitHub..."
    INSTALL_FROM_LOCAL=false
fi

cd "$WEBMIN_DIR" || exit

# Backup original
if [ -d "virtual-server" ]; then
    if [ -d "virtual-server.official" ]; then
        rm -rf virtual-server
    else
        mv virtual-server virtual-server.official
    fi
fi

if [ "$INSTALL_FROM_LOCAL" = true ]; then
    # Copy from the location where the script was launched ($OLDPWD is unreliable, use saved path)
    # Actually, we can just copy from the script's dir.
    # We need to go back to where we started.
    cd - > /dev/null
    
    # Copy files to Webmin dir, excluding .git and installer script itself
    cp -r . "$WEBMIN_DIR/virtual-server" || { echo "Failed to copy module files"; exit 1; }
    
    # Clean up git artifacts from production dir
    rm -rf "$WEBMIN_DIR/virtual-server/.git"
    rm -rf "$WEBMIN_DIR/virtual-server/setup-vps.sh"
else
    # Clone your repo
    # Ensure git is installed
    if ! command -v git &> /dev/null; then
        apt-get install -y git || yum install -y git
    fi

    echo "Cloning from $REPO_URL..."
    git clone "$REPO_URL" virtual-server
    
    if [ $? -ne 0 ]; then
        echo "Git clone failed. Please check your URL or internet connection."
        # Restore backup if available
        if [ -d "virtual-server.official" ]; then
             mv virtual-server.official virtual-server
             echo "Restored official module."
        fi
        exit 1
    fi
fi

# 4. Restart Webmin to load changes
echo "Restarting Webmin..."
/etc/webmin/restart

echo "================================================================="
echo "  SUCCESS! Virtualmin installed with your custom module."
echo "  Access at https://$(hostname -I | awk '{print $1}'):10000"
echo "================================================================="
