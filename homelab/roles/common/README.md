# Ansible Role: common

This role provides essential system configuration and user environment setup for Linux hosts. It is designed to be reusable and modular.

## Features

- Installs base packages and development tools
- Configures Homebrew (Linuxbrew) and installs packages
- Sets up dotfiles and user shell configuration (zsh)
- Installs Starship prompt
- Configures git and SSH keys
- Optionally installs go-task and other developer tools

## Requirements

- Linux host (Debian, Ubuntu, RedHat, Rocky, etc.)
- Sudo privileges for package installation and system changes
- User account with home directory

## Role Variables

Variables can be set in your playbook or via group/host vars. Example defaults:

```yaml
ansible_user: "{{ lookup('env', 'HOMELAB_USER') }}"
install_brew: true
install_dev_tools: true
initialization: true
install_starship: true
```

## Dependencies

None (but designed to be used before other roles)

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: common
      vars:
        ansible_user: "{{ lookup('env', 'HOMELAB_USER') }}"
        install_brew: true
        install_dev_tools: true
        initialization: true
        install_starship: true
```

## Handlers

None

## Templates & Files

- `gitconfig.j2`: User git configuration
- `brew-packages.sh`: Homebrew package install script

## Idempotency & Privilege Escalation

- All tasks use `become: true` or `become_user` where required
- Idempotency is ensured via Ansible modules and file checks

## Environment Variables

- Sensitive values (e.g., SSH keys, git user/email) should use `lookup('env', ...)` pattern

## License

MIT

## Author Information

This role was created by mombe090, inspired by best practices from geerlingguy.
