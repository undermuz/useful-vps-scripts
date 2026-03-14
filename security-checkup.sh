#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

YOUR_USER=undermuz

echo -e "${YELLOW}--- VPS SECURITY REPORT ---${NC}\n"

# 1. Check SSH for Root Login
ROOT_SSH=$(grep "^PermitRootLogin" /etc/ssh/sshd_config | awk '{print $2}')
if [[ "$ROOT_SSH" == "no" ]]; then
    echo -e "[${GREEN}OK${NC}] Root login via SSH is disabled."
else
    echo -e "[${RED}!!${NC}] Root login via SSH is enabled ($ROOT_SSH). Recommended: no"
fi

# 2. Check SSH for Password Authentication
PASS_SSH=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
if [[ "$PASS_SSH" == "no" ]]; then
    echo -e "[${GREEN}OK${NC}] Password authentication via SSH is disabled."
else
    echo -e "[${YELLOW}!!${NC}] Password authentication is enabled. Recommended to use keys only."
fi

# 3. Check Firewall (UFW)
if command -v ufw >/dev/null; then
    UFW_STATUS=$(sudo ufw status | grep "Status" | awk '{print $2}')
    if [[ "$UFW_STATUS" == "active" ]]; then
        echo -e "[${GREEN}OK${NC}] Firewall (UFW) is active."
        echo "     Open ports:"
        sudo ufw status | grep ALLOW | grep -v '(v6)' | awk '{print $1}' | sed 's/^/       - /'
    else
        echo -e "[${RED}!!${NC}] Firewall (UFW) is disabled!"
    fi
else
    echo -e "[${YELLOW}??${NC}] UFW is not installed."
fi

# 4. Check Fail2Ban
if systemctl is-active --quiet fail2ban; then
    echo -e "[${GREEN}OK${NC}] Fail2Ban is running."
    BANNED_COUNT=$(sudo fail2ban-client status sshd | grep "Currently banned" | awk '{print $4}')
    echo -e "     Currently banned IPs: $BANNED_COUNT"
    if [ -f /etc/fail2ban/jail.local ]; then
        IGNORE_IP=$(grep "^ignoreip" /etc/fail2ban/jail.local | cut -d'=' -f2 | sed 's/^ *//')
    else
        IGNORE_IP=$(grep "^ignoreip" /etc/fail2ban/jail.conf | cut -d'=' -f2 | sed 's/^ *//')
    fi
    echo -e "     Ignored IPs: $IGNORE_IP"
else
    echo -e "[${RED}!!${NC}] Fail2Ban is not running or not installed."
fi

# 5. Check permissions on .ssh for current user
if [ -d "$HOME/.ssh" ]; then
    SSH_DIR_PERM=$(stat -c "%a" "$HOME/.ssh")
    if [[ "$SSH_DIR_PERM" == "700" ]]; then
        echo -e "[${GREEN}OK${NC}] Permissions on .ssh directory are correct (700)."
    else
        echo -e "[${YELLOW}!!${NC}] Incorrect permissions on .ssh ($SSH_DIR_PERM). Should be 700."
    fi
else
    echo -e "[${YELLOW}??${NC}] .ssh directory not found."
fi

# 6. SSH users with authorized_keys
SSH_KEY_USERS=$(getent passwd | while IFS=: read -r user _ uid _ _ home _; do
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ "$uid" -lt 1000 ]] && continue
    [[ -f "$home/.ssh/authorized_keys" && -s "$home/.ssh/authorized_keys" ]] && echo "$user"
done)
if [[ -n "$SSH_KEY_USERS" ]]; then
    SSH_KEY_COUNT=$(echo "$SSH_KEY_USERS" | wc -l)
    if [[ "$SSH_KEY_COUNT" -eq 1 && "$SSH_KEY_USERS" == "$YOUR_USER" ]]; then
        echo -e "[${GREEN}OK${NC}] Only $YOUR_USER has SSH key authentication."
    else
        echo -e "[${YELLOW}INFO${NC}] SSH users with key authentication:"
        echo "$SSH_KEY_USERS" | sed 's/^/       - /'
    fi
else
    echo -e "[${YELLOW}??${NC}] No users with SSH keys found (or no access to read)."
fi

# 7. Check for security updates
if [ -f /var/run/reboot-required ]; then
    echo -e "[${YELLOW}!!${NC}] Server requires reboot to apply updates."
fi

# 8. Check sudo users
SUDO_USERS=$(getent group sudo | cut -d: -f4 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -z "$SUDO_USERS" ]]; then
    echo -e "[${GREEN}OK${NC}] No sudo users found."
elif [[ "$SUDO_USERS" == "$YOUR_USER" ]]; then
    echo -e "[${GREEN}OK${NC}] Only $YOUR_USER has sudo privileges."
else
    echo -e "[${YELLOW}INFO${NC}] Users with sudo privileges: $SUDO_USERS"
fi

echo -e "\n${YELLOW}--- CHECK COMPLETED ---${NC}"
