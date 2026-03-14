#!/bin/bash

# Variables — edit as needed
NEW_USER="undermuz"
SSH_PORT="22"

# 1. System update
apt update && apt upgrade -y
apt install curl
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt install speedtest

# 2. Create user and configure sudo
useradd -m -s /bin/bash $NEW_USER
usermod -aG sudo $NEW_USER
echo "$NEW_USER ALL=(ALL) ALL" > /etc/sudoers.d/$NEW_USER

# 3. SSH setup (Copy keys from root if they exist)
mkdir -p /home/$NEW_USER/.ssh
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
fi
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# 4. Harden SSH config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart ssh

# 5. Firewall setup (UFW)
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# 6. Install Fail2Ban
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

echo "Setup completed.\nUser: $NEW_USER.\nPassword login disabled!\nSet password for sudo: passwd $NEW_USER"

echo "\nDon't forget to add your IP to Fail2Ban whitelist:"
echo "nano /etc/fail2ban/jail.local"
echo ""
echo "[DEFAULT]"
echo "ignoreip = 127.0.0.1/8 ::1 YOUR_IP"
