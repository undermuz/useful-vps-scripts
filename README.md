# useful-vps-scripts

A collection of useful Bash scripts for managing and securing VPS (Virtual Private Server) instances. These scripts are designed to simplify common administrative tasks and enhance server security.

## Scripts Overview

### `init.sh`
Initializes a new VPS with essential security configurations:
- Updates the system packages
- Creates a new user with sudo privileges
- Configures SSH to disable root login and password authentication
- Sets up UFW (Uncomplicated Firewall) with basic rules
- Installs and enables Fail2Ban for intrusion prevention

**Usage:**
```bash
sudo ./init.sh
```
*Note: Edit the variables at the top of the script (NEW_USER, SSH_PORT) before running.*

### `security-checkup.sh`
Performs a comprehensive security audit of your VPS:
- Checks SSH configuration (root login, password authentication)
- Verifies firewall (UFW) status
- Checks Fail2Ban service status and banned IP count
- Validates SSH directory permissions

**Usage:**
```bash
./security-checkup.sh
```

### `ssh-tools.sh`
A utility script for managing SSH configuration in `~/.ssh/config`:
- Add new hosts with custom settings
- List all configured hosts

**Usage:**
```bash
# Add a host (short format)
./ssh-tools.sh add user@ip hostname

# Add a host (full format)
./ssh-tools.sh add host hostname --ip 192.168.1.1 --user username --port 22 --id ~/.ssh/key

# List hosts
./ssh-tools.sh list
```

## Prerequisites

- Ubuntu/Debian-based Linux distribution
- Root or sudo access for `init.sh`
- Bash shell

## Installation

1. Clone the repository:
```bash
git clone https://github.com/undermuz/useful-vps-scripts.git
cd useful-vps-scripts
```

2. Make scripts executable:
```bash
chmod +x *.sh
```

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve these scripts.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

[@undermuz](https://github.com/undermuz)