# NFS Server Role

This Ansible role configures and manages an NFS (Network File System) server on Linux systems.

## Features

- Install and configure NFS server packages
- Create and manage NFS exports
- Configure firewall rules for NFS
- Support for multiple Linux distributions (Ubuntu/Debian, CentOS/RHEL)
- Secure NFS configuration with proper permissions
- Idempotent operations

## Requirements

- Ansible 2.9 or higher
- Target system running a supported Linux distribution
- Root or sudo privileges on target systems

## Role Variables

### Default Variables

All default variables are defined in `defaults/main.yaml`:

```yaml
# NFS service configuration
nfs_server_enabled: true
nfs_server_state: started

# NFS exports configuration
nfs_exports: []
  # - path: /srv/nfs/shared
  #   hosts: "192.168.1.0/24"
  #   options: "rw,sync,no_subtree_check,no_root_squash"
  #   owner: root
  #   group: root
  #   mode: "0755"

# Firewall configuration
nfs_configure_firewall: true
nfs_allowed_networks:
  - "192.168.1.0/24"

# Security settings
nfs_rpcbind_enabled: true
nfs_idmapd_enabled: true
```

### Export Options

Common NFS export options:

- `rw` / `ro`: Read-write / Read-only access
- `sync` / `async`: Synchronous / Asynchronous writes
- `no_subtree_check`: Disable subtree checking (recommended)
- `no_root_squash` / `root_squash`: Root privilege handling
- `all_squash`: Map all users to anonymous user
- `anonuid=X` / `anongid=X`: Set anonymous user/group ID

## Example Playbook

```yaml
- hosts: nfs-servers
  become: true
  roles:
    - role: nfs-server
      vars:
        nfs_exports:
          - path: /srv/nfs/data
            hosts: "192.168.1.0/24"
            options: "rw,sync,no_subtree_check,root_squash"
            owner: nfsnobody
            group: nfsnobody
            mode: "0755"
          - path: /srv/nfs/backup
            hosts: "192.168.1.100"
            options: "rw,sync,no_subtree_check,no_root_squash"
            owner: root
            group: root
            mode: "0700"
        nfs_allowed_networks:
          - "192.168.1.0/24"
          - "10.0.0.0/8"
```

## License

MIT

## Author Information

Created for homelab automation.
