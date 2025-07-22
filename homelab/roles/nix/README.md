# Nix Package Manager Role

This Ansible role installs and configures the Nix package manager on Ubuntu/Debian systems following the latest NixOS documentation and best practices.

## Features

- **Multiple Installation Methods**: Supports Determinate Nix installer (recommended), upstream Nix installer, and native package installation
- **Flakes Support**: Enables Nix flakes by default for modern Nix development
- **Systemd Integration**: Configures and manages the Nix daemon via systemd
- **User Profile Setup**: Automatically configures shell profiles for Nix environment
- **Security Hardened**: Follows security best practices with proper user permissions
- **Idempotent**: Safe to run multiple times without side effects
- **Verification**: Includes comprehensive installation verification tests

## Supported Systems

- Ubuntu 20.04 (Focal)
- Ubuntu 22.04 (Jammy)  
- Ubuntu 24.04 (Noble)
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)

## Installation Methods

### 1. Determinate Nix Installer (Recommended)
- Modern, reliable installer with excellent Ubuntu support
- Includes flakes enabled by default
- Supports uninstallation
- Maintained by Determinate Systems

### 2. Upstream Nix Installer
- Official NixOS installer
- Multi-user installation with systemd
- Fallback option if Determinate installer fails

### 3. Native Package Installation (Experimental)
- Uses distribution-native .deb packages
- Provided by nix-community
- Good for containerized environments

## Role Variables

### Installation Configuration

```yaml
# Installation method: "determinate", "upstream", or "native"
nix_installation_method: "determinate"

# Enable Nix flakes (recommended)
nix_flakes_enabled: true

# Configure user shell profiles
nix_user_profile_setup: true

# Enable systemd daemon service
nix_systemd_service: true
```

### Advanced Configuration

```yaml
# Build users configuration
nix_build_group_name: "nixbld"
nix_build_group_id: 30000
nix_build_user_count: 32
nix_build_user_prefix: "nixbld"
nix_build_user_id_base: 30000

# Extra Nix configuration
nix_extra_config:
  - "auto-optimise-store = true"
  - "experimental-features = nix-command flakes"
  - "max-jobs = auto"
  - "trusted-users = root @wheel"
  - "keep-outputs = true"
  - "keep-derivations = true"
```

### Environment-Specific Variables

The role supports environment variables for homelab automation:

```bash
export HOMELAB_USER="ubuntu"
export HOMELAB_DOMAIN="home.local"
export NIX_ENVIRONMENT="production"  # production, development, testing
```

## Dependencies

This role depends on:
- `geerlingguy.docker` - For container runtime support

## Example Playbook

```yaml
---
- hosts: homelab
  become: false
  gather_facts: true
  
  vars:
    nix_installation_method: "determinate"
    nix_flakes_enabled: true
    nix_extra_config:
      - "trusted-users = root @wheel {{ ansible_user }}"
      - "auto-optimise-store = true"
  
  roles:
    - role: nix
      tags: ['nix', 'package-manager']
```

## Usage Examples

### Install and Test Nix

```bash
# Run the playbook
cd homelab/
ansible-playbook playbooks/nix.playbook.yaml

# Test Nix installation
nix --version
nix run nixpkgs#hello
```

### Common Nix Commands

```bash
# Search for packages
nix search nixpkgs python3

# Install packages
nix-env -iA nixpkgs.git
nix-env -iA nixpkgs.neovim

# List installed packages  
nix-env -q

# Upgrade packages
nix-env -u

# Remove packages
nix-env -e git

# Garbage collection
nix-collect-garbage
nix-collect-garbage -d  # Delete old generations

# With flakes (modern approach)
nix run nixpkgs#cowsay hello
nix shell nixpkgs#python3 nixpkgs#nodejs
```

### Development Environments

```bash
# Create a temporary shell with packages
nix shell nixpkgs#python3 nixpkgs#nodejs nixpkgs#git

# Enter development environment
nix develop

# Use flakes for reproducible environments
echo 'use flake' > .envrc && direnv allow
```

## Directory Structure

```
homelab/roles/nix/
├── defaults/main.yaml       # Default configuration variables
├── vars/main.yaml          # Role variables (higher precedence)
├── meta/main.yaml          # Role metadata and dependencies
├── tasks/
│   ├── main.yaml          # Main task orchestration
│   ├── prerequisites.yaml # System prerequisites
│   ├── install.yaml       # Nix installation
│   ├── configure.yaml     # Nix configuration
│   ├── systemd.yaml       # Systemd service setup
│   ├── user_profile.yaml  # User environment setup
│   └── verify.yaml        # Installation verification
├── templates/
│   ├── nix.conf.j2                    # Main Nix configuration
│   ├── nix-profile.sh.j2              # Shell profile setup
│   └── nix-daemon-override.conf.j2    # Systemd overrides
└── handlers/
    └── main.yaml          # Service restart handlers
```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   ```bash
   sudo systemctl status nix-daemon
   sudo journalctl -u nix-daemon
   ```

2. **PATH Issues**
   ```bash
   source ~/.bashrc
   # or
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

3. **Systemd Service Not Starting**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart nix-daemon
   ```

4. **Build User Issues**
   ```bash
   # Check build users exist
   getent group nixbld
   getent passwd nixbld1
   ```

### Uninstallation

If using Determinate installer:
```bash
sudo /nix/nix-installer uninstall
```

Manual removal:
```bash
sudo systemctl stop nix-daemon
sudo systemctl disable nix-daemon
sudo rm -rf /nix
sudo groupdel nixbld
sudo userdel nixbld1  # repeat for all build users
```

## Security Considerations

- Build users are isolated with unique UIDs
- Nix store is read-only for security
- Trusted users are explicitly configured
- Systemd service runs with minimal privileges
- Regular garbage collection recommended

## Performance Optimization

- Auto-optimization enabled by default
- Build parallelization configured
- Store deduplication active
- Shared store for multiple users

## Contributing

1. Follow the existing code style and patterns
2. Test on supported Ubuntu/Debian versions
3. Update documentation for new features
4. Add appropriate tags to tasks
5. Use `ansible.builtin.*` module names

## License

MIT License - see the project root for details.

## Author

Created for the homelab automation project. Based on the latest NixOS documentation and community best practices.
