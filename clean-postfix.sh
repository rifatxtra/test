#!/bin/bash
# clean-postfix.sh
# Removes conflicting MySQL mappings from Postfix configuration (remnants of CyberPanel)

echo "Checking Postfix configuration for conflicts..."
POSTFIX_MAIN="/etc/postfix/main.cf"

if [ ! -f "$POSTFIX_MAIN" ]; then
    echo "Error: Postfix config file not found at $POSTFIX_MAIN"
    exit 1
fi

# Backup config
cp "$POSTFIX_MAIN" "$POSTFIX_MAIN.bak"

# Remove mysql-virtual_forwardings
if grep -q "virtual_alias_maps.*mysql" "$POSTFIX_MAIN"; then
    echo "Found conflicting MySQL map in virtual_alias_maps. Removing..."
    sed -i '/virtual_alias_maps.*mysql/d' "$POSTFIX_MAIN"
fi

if grep -q "virtual_mailbox_maps.*mysql" "$POSTFIX_MAIN"; then
    echo "Found conflicting MySQL map in virtual_mailbox_maps. Removing..."
    sed -i '/virtual_mailbox_maps.*mysql/d' "$POSTFIX_MAIN"
fi

if grep -q "virtual_mailbox_domains.*mysql" "$POSTFIX_MAIN"; then
    echo "Found conflicting MySQL map in virtual_mailbox_domains. Removing..."
    sed -i '/virtual_mailbox_domains.*mysql/d' "$POSTFIX_MAIN"
fi

# Restart services
echo "Restarting Postfix..."
systemctl restart postfix

echo "Restarting MySQL/MariaDB..."
systemctl restart mysql || systemctl restart mariadb

echo "Done! Postfix should now use standard files."
