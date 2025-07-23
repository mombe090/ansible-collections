# Nix Package Manager Role

This Ansible role installs and configures the Nix package manager on Ubuntu/Debian systems following the latest NixOS documentation and best practices. It provides a comprehensive homelab automation solution with dotfiles management and Home Manager integration.

## Features

- **Multiple Installation Methods**: Supports Determinate Nix installer (recommended), upstream Nix installer, and native package installation
- **Flakes Support**: Enables Nix flakes by default for modern Nix development
- **Home Manager Integration**: Automated Home Manager setup with flakes support
- **Dotfiles Management**: Automated GitHub dotfiles repository cloning and setup with GNU Stow
- **Systemd Integration**: Configures and manages the Nix daemon via systemd
- **User Profile Setup**: Automatically configures shell profiles for Nix environment
- **Environment-Aware**: Dynamic configuration based on environment variables (production/development/testing)
- **Security Hardened**: Follows security best practices with proper user permissions
- **Idempotent**: Safe to run multiple times without side effects
- **Comprehensive Verification**: Includes thorough installation and functionality testing

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

### Core Configuration

```yaml
# Installation method: "determinate", "upstream", or "native"
nix_installation_method: "determinate"

# Enable Nix flakes (recommended)
nix_flakes_enabled: true
nix_experimental_features:
  - "nix-command"
  - "flakes"

# Configure user shell profiles
nix_user_profile_setup: true

# Enable systemd daemon service
nix_systemd_service: true

# Home Manager configuration
nix_home_manager_enabled: true
nix_home_manager_channel: "release-24.05"
nix_home_manager_flake_enabled: true
```

### Installation Configuration

```yaml
# Determinate Nix specific settings
nix_determinate_version: "latest"
nix_installer_url: "https://install.determinate.systems/nix"
nix_no_confirm: true
nix_daemon_start: true

# Build users configuration
nix_build_group_name: "nixbld"
nix_build_group_id: 30000
nix_build_user_count: 32
nix_build_user_prefix: "nixbld"
nix_build_user_id_base: 30000
```

### Advanced Configuration

```yaml
# Extra Nix configuration
nix_extra_config:
  - "auto-optimise-store = true"
  - "experimental-features = nix-command flakes"
  - "max-jobs = auto"
  - "trusted-users = root @wheel"
  - "accept-flake-config = true"
  - "warn-dirty = false"

# Flakes registry configuration
nix_flake_registry:
  nixpkgs: "github:NixOS/nixpkgs/nixos-unstable"
  home-manager: "github:nix-community/home-manager"
  nixpkgs-stable: "github:NixOS/nixpkgs/nixos-24.05"

# Optional features
nix_enable_gc_timer: false
nix_user_trusted: false
nix_install_global_packages: false

# Global packages (if enabled)
nix_global_packages:
  - git
  - vim
  - curl
  - wget
  - htop
  - tree
  - jq
```

### Environment-Specific Variables

The role supports environment variables for homelab automation and automatically configures based on environment:

```bash
export HOMELAB_USER="ubuntu"
export HOMELAB_DOMAIN="home.local"
export NIX_ENVIRONMENT="production"  # production, development, testing
export HOMELAB_GITHUB_TOKEN="ghp_..."  # For dotfiles repository access
export GITHUB_TOKEN="ghp_..."  # Alternative token variable
```

The role dynamically selects installation methods based on environment:

- **Production**: Determinate installer (stable, reliable)
- **Development**: Upstream installer (official NixOS)
- **Testing**: Native packages (fast, containerized)

## Architecture

The role follows a modular design with clear separation of concerns:

```text
User Request → Prerequisites → Installation → Configuration → Services → User Setup → Verification
     ↓              ↓              ↓             ↓           ↓           ↓            ↓
  Packages    →   Nix Install  →  Nix Config → Systemd  → Profiles → Home Manager → Tests
     ↓              ↓              ↓             ↓           ↓           ↓            ↓
  curl,git    →   Determinate  →  /etc/nix  → nix-daemon → .bashrc → dotfiles   → nix --version
```

### Workflow Components

1. **Prerequisites**: System packages and dependencies
2. **Installation**: Nix package manager installation  
3. **Configuration**: Nix daemon and user configuration
4. **Systemd**: Service management and daemon setup
5. **User Profile**: Shell integration and PATH setup
6. **Dotfiles**: GitHub repository cloning and GNU Stow setup
7. **Home Manager**: Declarative user environment management
8. **Post-Install**: Registry setup and global packages
9. **Verification**: Comprehensive functionality testing

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
    nix_home_manager_enabled: true
    nix_extra_config:
      - "trusted-users = root @wheel {{ ansible_user }}"
      - "auto-optimise-store = true"
  
  roles:
    - role: nix
      tags: ['nix', 'package-manager']
```

### Advanced Playbook Example

```yaml
---
- hosts: development
  become: false
  gather_facts: true
  
  vars:
    # Development environment configuration
    nix_installation_method: "determinate"
    nix_home_manager_enabled: true
    nix_home_manager_flake_enabled: true
    nix_install_global_packages: true
    nix_global_packages:
      - git
      - neovim
      - docker
      - nodejs
      - python3
    
    # Custom Nix configuration
    nix_extra_config:
      - "trusted-users = root @wheel {{ ansible_user }}"
      - "auto-optimise-store = true"
      - "keep-outputs = true"
      - "keep-derivations = true"
  
  roles:
    - role: nix
      tags: ['nix', 'development']
```
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

# Test Home Manager (if enabled)
home-manager --version
home-manager switch
```

### Common Nix Commands

```bash
# Search for packages
nix search nixpkgs python3

# Install packages (legacy)
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

# Modern flakes approach
nix run nixpkgs#cowsay hello
nix shell nixpkgs#python3 nixpkgs#nodejs
```

### Home Manager Usage

```bash
# Edit configuration
vim ~/.config/home-manager/home.nix

# Apply changes
home-manager switch

# List generations
home-manager generations

# Rollback to previous generation
home-manager switch --rollback
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

```text
homelab/roles/nix/
├── defaults/main.yaml         # Default configuration variables
├── vars/main.yaml            # Role variables (higher precedence)
├── meta/main.yaml            # Role metadata and dependencies
├── tasks/
│   ├── main.yaml            # Main task orchestration
│   ├── prerequisites.yaml   # System prerequisites
│   ├── install.yaml         # Nix installation methods
│   ├── configure.yaml       # Nix configuration
│   ├── systemd.yaml         # Systemd service setup
│   ├── user_profile.yaml    # User environment setup
│   ├── dotfiles.yaml        # GitHub dotfiles management
│   ├── home_manager.yaml    # Home Manager setup
│   ├── post_install.yaml    # Post-installation tasks
│   └── verify.yaml          # Installation verification
├── templates/
│   ├── nix.conf.j2                    # Main Nix configuration
│   ├── nix-profile.sh.j2              # Shell profile setup
│   ├── nix-daemon-override.conf.j2    # Systemd overrides
│   ├── user-nix.conf.j2               # User-specific config
│   ├── home.nix.j2                    # Home Manager config
│   └── home-manager-flake.nix.j2      # Home Manager flake
└── handlers/
    └── main.yaml            # Service restart handlers
```

## Task Flow

The role executes in this order:

1. **Main** (`main.yaml`) - Orchestrates the entire installation process
2. **Prerequisites** (`prerequisites.yaml`) - Installs system dependencies
3. **Install** (`install.yaml`) - Installs Nix using selected method
4. **Configure** (`configure.yaml`) - Sets up Nix configuration files
5. **Systemd** (`systemd.yaml`) - Configures and starts the Nix daemon
6. **User Profile** (`user_profile.yaml`) - Sets up shell integration
7. **Dotfiles** (`dotfiles.yaml`) - Clones and sets up user dotfiles
8. **Home Manager** (`home_manager.yaml`) - Installs and configures Home Manager
9. **Post Install** (`post_install.yaml`) - Registry setup and global packages
10. **Verify** (`verify.yaml`) - Tests installation and functionality

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

5. **Home Manager Issues**

   ```bash
   # Check Home Manager installation
   home-manager --version
   
   # Rebuild configuration
   home-manager switch --show-trace
   
   # Check for conflicts
   home-manager switch --dry-run
   ```

6. **Dotfiles Setup Issues**

   ```bash
   # Check GitHub authentication
   gh auth status
   
   # Manual dotfiles setup
   cd ~/.dotfiles && stow .
   ```

### Debug Mode

Run the playbook with increased verbosity:

```bash
ansible-playbook playbooks/nix.playbook.yaml -vvv
```

### Manual Verification

```bash
# Test Nix installation
nix --version
nix-env --version

# Test flakes
nix flake --help

# Test Home Manager
home-manager --version

# Check services
sudo systemctl status nix-daemon
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

### Clean Up Home Manager

```bash
# Remove Home Manager
nix-env -e home-manager

# Remove configuration
rm -rf ~/.config/home-manager
rm -rf ~/.local/state/home-manager
```

## Best Practices

### Nix Package Manager

- Use flakes for reproducible builds and environments
- Enable auto-optimization to save disk space
- Regular garbage collection to manage store size
- Use `nix shell` instead of `nix-env` for temporary packages
- Pin dependencies with flake locks for reproducibility

### Home Manager

- Keep configuration in version control
- Use modules for organized configuration
- Test changes with `--dry-run` before applying
- Create generations before major changes
- Use flakes for better dependency management

### Security

- Limit trusted users to necessary accounts only
- Use user-specific configurations instead of global when possible
- Regular updates of channels and flakes
- Monitor nix-daemon logs for suspicious activity
- Use sandbox builds (enabled by default)

### Performance

- Enable auto-optimization in nix.conf
- Use binary caches to avoid rebuilding
- Configure appropriate max-jobs based on system resources
- Regular garbage collection and store optimization
- Use shared stores for multi-user environments

## Security Considerations

- Build users are isolated with unique UIDs
- Nix store is read-only for security
- Trusted users are explicitly configured
- Systemd service runs with minimal privileges
- Regular garbage collection recommended
- Sandbox builds enabled by default
- User configurations isolated from system

## Performance Optimization

- Auto-optimization enabled by default
- Build parallelization configured
- Store deduplication active
- Shared store for multiple users
- Binary cache utilization
- Efficient garbage collection strategies

## Integration Features

### Dotfiles Management

- Automatic GitHub repository cloning
- GNU Stow integration for symlink management
- Support for both public and private repositories
- GitHub CLI authentication handling

### Home Manager Integration

- Flakes-based configuration
- Automatic installation and setup
- Template-based initial configuration
- Support for both standalone and flaked configurations

### Environment Awareness

- Dynamic configuration based on deployment environment
- Homelab-specific variable integration
- Flexible installation method selection
- Production-ready defaults with development overrides

## Contributing

1. Follow the existing code style and patterns
2. Test on supported Ubuntu/Debian versions
3. Update documentation for new features
4. Add appropriate tags to tasks
5. Use `ansible.builtin.*` module names
6. Ensure idempotency in all tasks
7. Add verification steps for new features
8. Follow homelab conventions for environment variables

## Version Compatibility

| Nix Role Version | Ansible Version | Home Manager | Nix Version |
|------------------|-----------------|--------------|-------------|
| 1.0.x           | >= 2.9          | 24.05        | >= 2.18     |
| main            | >= 2.12         | 24.05+       | >= 2.20     |

## Known Limitations

- Currently supports Debian-based systems only
- Requires systemd for service management
- GitHub authentication needed for private dotfiles
- Home Manager flakes require experimental features
- Multi-user installations only (no single-user mode)

## Related Documentation

- [NixOS Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Determinate Nix Installer](https://install.determinate.systems/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Homelab Ansible Collections](../../../README.md)

## License

MIT License - see the project root for details.

## Author

Created for the homelab automation project. Based on the latest NixOS documentation and community best practices.
