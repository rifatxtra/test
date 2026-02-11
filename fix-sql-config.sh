#!/bin/bash
# fix-sql-config.sh
# Fixes the "Column 'email' specified twice" error by disabling SQL storage for mail aliases/users

CONFIG_FILE="/etc/webmin/virtual-server/config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Virtualmin config file not found at $CONFIG_FILE"
    exit 1
fi

echo "Disabling SQL storage for mail aliases and users..."

# Backup config
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Disable mysql_mail
if grep -q "mysql_mail=" "$CONFIG_FILE"; then
    sed -i 's/^mysql_mail=.*/mysql_mail=0/' "$CONFIG_FILE"
else
    echo "mysql_mail=0" >> "$CONFIG_FILE"
fi

# Disable spam_user_db
if grep -q "spam_user_db=" "$CONFIG_FILE"; then
    sed -i 's/^spam_user_db=.*/spam_user_db=0/' "$CONFIG_FILE"
else
    echo "spam_user_db=0" >> "$CONFIG_FILE"
fi

# Disable spam_alias_db
if grep -q "spam_alias_db=" "$CONFIG_FILE"; then
    sed -i 's/^spam_alias_db=.*/spam_alias_db=0/' "$CONFIG_FILE"
else
    echo "spam_alias_db=0" >> "$CONFIG_FILE"
fi

echo "Restarting Webmin..."
if command -v systemctl &> /dev/null; then
    systemctl restart webmin
else
    /etc/init.d/webmin restart
fi

echo "Done! Please try creating the virtual server again."
