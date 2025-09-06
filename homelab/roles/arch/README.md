# Arch Linux Role

This Ansible role manages package installation on Arch Linux systems using both `pacman` (official repositories) and `yay` (AUR helper for Arch User Repository).

## Features

- Installs essential system packages via pacman
- Installs and configures yay AUR helper
- Installs packages from AUR via yay
- Configurable package groups (development, multimedia, gaming)
- Mirror management with reflector
- Docker setup and user configuration
- Package cache cleanup

## Requirements

- Arch Linux target system
- Ansible 2.9+
- Internet connection for package downloads

## Role Variables

### Default Variables (can be overridden)

```yaml
# AUR helper installation
install_yay: true

# Package group toggles
install_dev_tools: true
install_multimedia: true
install_gaming: false

# System configuration
update_mirrors: true

# Package lists
aur_packages:
  - yay-bin
  - visual-studio-code-bin
  - google-chrome
  # ... more AUR packages

pacman_packages:
  - base-devel
  - git
  - curl
  # ... more official packages

multimedia_packages:
  - vlc
  - firefox
  - gimp
  # ... more multimedia packages

gaming_packages:
  - steam
  - lutris
  - wine
  # ... more gaming packages
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: archlinux
  become: true
  roles:
    - role: arch
      vars:
        install_gaming: true
        install_multimedia: true
        aur_packages:
          - visual-studio-code-bin
          - discord
          - spotify
```

## Example Usage

### Basic Installation

```yaml
- name: Setup Arch Linux system
  hosts: arch_systems
  roles:
    - arch
```

### Custom Configuration

```yaml
- name: Setup Arch Linux development workstation
  hosts: workstations
  roles:
    - role: arch
      vars:
        install_dev_tools: true
        install_gaming: false
        install_multimedia: true
        aur_packages:
          - visual-studio-code-bin
          - postman-bin
          - docker-desktop
        pacman_packages:
          - base-devel
          - git
          - python
          - nodejs
          - docker
```

## Tasks Overview

1. **System Verification**: Ensures the target is an Arch Linux system
2. **Package Cache Update**: Updates pacman package cache
3. **Mirror Management**: Optionally updates pacman mirrors using reflector
4. **Core Package Installation**: Installs essential packages via pacman
5. **Development Tools**: Installs development packages (optional)
6. **Multimedia Packages**: Installs multimedia applications (optional)
7. **Gaming Packages**: Installs gaming-related packages (optional)
8. **Docker Configuration**: Sets up Docker service and user permissions
9. **Yay Installation**: Clones, builds, and installs yay AUR helper
10. **AUR Package Installation**: Installs packages from AUR using yay
11. **Cleanup**: Cleans package cache

## Security Considerations

- The role adds the user to the docker group (if Docker is installed)
- yay is built from source for security
- Package installations use `--noconfirm` for automation

## Troubleshooting

### Common Issues

1. **yay build fails**: Ensure `base-devel` is installed
2. **Mirror update fails**: Set `update_mirrors: false` if reflector isn't available
3. **Docker permission issues**: User needs to log out/in after being added to docker group

### Debug Mode

Run with verbose output:
```bash
ansible-playbook -vvv playbook.yml
```

## License

MIT

## Author Information

Created for homelab automation and Arch Linux system management.
