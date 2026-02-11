#!/bin/bash

# Virtualmin GPL Deployment Script
# This script packages the current directory into a Webmin Module (.wbm) file.

MODULE_NAME="virtual-server"
ARCHIVE_NAME="virtual-server-gpl-custom.wbm"

echo "Packaging $MODULE_NAME into $ARCHIVE_NAME..."

# Create a temporary directory specific to this build
TMP_DIR="/tmp/virtualmin_build_$$"
mkdir -p "$TMP_DIR/$MODULE_NAME"

# Copy all files to the temp dir, excluding git and dev files
rsync -av --exclude='.git' \
          --exclude='.github' \
          --exclude='.gitignore' \
          --exclude='deploy.sh' \
          --exclude='task.md' \
          --exclude='walkthrough.md' \
          --exclude='implementation_plan.md' \
          ./ "$TMP_DIR/$MODULE_NAME/"

# Create the tarball (Webmin modules are just .tar.gz files renamed to .wbm)
tar -czf "$ARCHIVE_NAME" -C "$TMP_DIR" "$MODULE_NAME"

# Clean up
rm -rf "$TMP_DIR"

echo "Success! Package created: $ARCHIVE_NAME"
echo ""
echo "To install this on your VPS:"
echo "1. Upload '$ARCHIVE_NAME' to your server."
echo "2. Log in to Webmin."
echo "3. Go to Webmin -> Webmin Configuration -> Webmin Modules."
echo "4. Select 'From local file' and choose the uploaded .wbm file."
echo "5. Click 'Install Module'."
echo ""
echo "Alternatively, install via CLI on the VPS:"
echo "webmin install-module $ARCHIVE_NAME"
