# NFS Client Role

This Ansible role configures and manages NFS client functionality on Linux systems, including mounting NFS shares and managing mount points.

## Features

- Install NFS client packages
- Configure NFS client settings
- Create and manage NFS mount points
- Support for persistent mounts via /etc/fstab
- Support for temporary/runtime mounts
- Mount validation and verification
- Support for multiple Linux distributions (Ubuntu/Debian, CentOS/RHEL)
- Idempotent operations with proper error handling

## Requirements

- Ansible 2.9 or higher
- Target system running a supported Linux distribution
- Root or sudo privileges on target systems
- Network connectivity to NFS servers

## Role Variables

### Default Variables

All default variables are defined in `defaults/main.yaml`:

```yaml
# NFS client service configuration
nfs_client_enabled: true

# NFS mounts configuration
nfs_mounts: []
  # - server: "192.168.1.100"
  #   path: "/srv/nfs/shared"
  #   mount_point: "/mnt/nfs-shared"
  #   fstype: "nfs"
  #   options: "defaults,rsize=8192,wsize=8192,timeo=14,intr"
  #   state: "mounted"
  #   persistent: true
  #   owner: root
  #   group: root
  #   mode: "0755"

# Client configuration
nfs_client_domain: "{{ ansible_domain | default('localdomain') }}"
nfs_client_timeout: 15
nfs_client_retrans: 3

# Service management
nfs_manage_services: true
nfs_client_services_enabled: true
```

### Mount Options

Common NFS mount options:
- `rsize=8192`: Read buffer size
- `wsize=8192`: Write buffer size
- `timeo=14`: Timeout for RPC requests
- `retrans=3`: Number of retries for RPC requests
- `intr`: Allow interruption of NFS requests
- `soft`/`hard`: Soft vs hard mounts
- `bg`: Retry mounts in background
- `nfsvers=4`: Specify NFS version

## Example Playbook

```yaml
- hosts: nfs_clients
  become: true
  roles:
    - role: nfs-client
      vars:
        nfs_mounts:
          - server: "192.168.1.100"
            path: "/srv/nfs/shared"
            mount_point: "/mnt/shared"
            fstype: "nfs"
            options: "defaults,nfsvers=4,rsize=8192,wsize=8192,timeo=14,intr"
            state: "mounted"
            persistent: true
            owner: root
            group: root
            mode: "0755"
          
          - server: "192.168.1.100"
            path: "/srv/nfs/data"
            mount_point: "/mnt/data"
            fstype: "nfs"
            options: "defaults,nfsvers=4,soft,timeo=30"
            state: "mounted"
            persistent: true
            owner: datauser
            group: datagroup
            mode: "0750"
```

## Advanced Usage

### Temporary Mounts

```yaml
nfs_mounts:
  - server: "192.168.1.100"
    path: "/srv/nfs/temp"
    mount_point: "/mnt/temp"
    state: "mounted"
    persistent: false  # Don't add to /etc/fstab
```

### Unmounting Shares

```yaml
nfs_mounts:
  - server: "192.168.1.100"
    path: "/srv/nfs/old"
    mount_point: "/mnt/old"
    state: "unmounted"
    persistent: false  # Remove from /etc/fstab
```

## Mount States

- `mounted`: Mount the NFS share
- `unmounted`: Unmount the NFS share
- `present`: Only create mount point and fstab entry
- `absent`: Remove mount point and fstab entry

## License

MIT

## Author Information

Created for homelab automation.
