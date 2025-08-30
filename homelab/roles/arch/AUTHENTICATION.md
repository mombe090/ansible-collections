# Arch Linux Role - Authentication Setup Guide

## Fixing "Missing sudo password" Error

When you encounter the error `"Task failed: Missing sudo password"`, you have several options:

### Option 1: Run with Password Prompt (Recommended)

Use the provided script:
```bash
./run_arch_playbook.sh
# Select option 1
```

Or run manually:
```bash
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass
```

### Option 2: Configure Passwordless Sudo (Advanced)

On your Arch Linux target machine:

1. **Edit sudoers file:**
   ```bash
   sudo visudo
   ```

2. **Add this line (replace `username` with your actual username):**
   ```
   username ALL=(ALL) NOPASSWD:ALL
   ```

3. **Or for more security, allow only specific commands:**
   ```
   username ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/systemctl, /usr/bin/makepkg
   ```

### Option 3: Use SSH Key Authentication with sudo

1. **Ensure SSH key authentication is working:**
   ```bash
   ssh-copy-id username@arch-server
   ```

2. **Test connection:**
   ```bash
   ansible archlinux -i hosts.ini -m ping
   ```

### Option 4: Set Ansible Become Password in Environment

```bash
export ANSIBLE_BECOME_PASS='your_sudo_password'
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml
```

## Running the Playbook

### Quick Start
```bash
cd homelab/
./run_arch_playbook.sh
```

### Manual Execution
```bash
# With password prompt
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass

# With specific user
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass -u your_username

# Dry run (check mode)
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass --check

# Verbose output
ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass -vvv
```

## Customizing the Installation

### Edit Variables
Modify `playbooks/arch.playbook.yaml` or create host/group specific variables:

```yaml
# In group_vars/archlinux.yaml or host_vars/arch-server.yaml
install_dev_tools: true
install_multimedia: false
install_gaming: true

aur_packages:
  - visual-studio-code-bin
  - spotify
  - discord

pacman_packages:
  - firefox
  - vlc
  - docker
```

### Disable Specific Features
```yaml
install_yay: false        # Skip AUR helper installation
update_mirrors: false     # Skip mirror optimization
install_dev_tools: false  # Skip development packages
```

## Troubleshooting

### Common Issues

1. **"Host unreachable"**
   - Check IP address in hosts.ini
   - Verify SSH access: `ssh username@ip_address`

2. **"Permission denied"**
   - Verify SSH key authentication
   - Check username in ansible_user variable

3. **"Package not found"**
   - Some AUR packages may have different names
   - Check package availability: `yay -Ss package_name`

4. **"makepkg failed"**
   - Ensure base-devel is installed
   - Check disk space
   - Some AUR packages require manual intervention

### Debug Commands

```bash
# Test connectivity
ansible archlinux -i hosts.ini -m ping

# Check facts
ansible archlinux -i hosts.ini -m setup

# Test sudo access
ansible archlinux -i hosts.ini -m shell -a "sudo whoami" --ask-become-pass

# List variables
ansible-inventory -i hosts.ini --list --yaml
```

## Security Notes

- The role installs packages from both official repositories and AUR
- AUR packages are built from source and may require review
- Docker installation adds user to docker group (security consideration)
- Consider using a dedicated user for automation rather than your main user account
