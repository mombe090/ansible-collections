# Ansible Role: pihole

This role installs and configures Pi-hole on a target host, following best practices inspired by geerlingguy roles.

## Requirements

- Target host must be Debian-based (e.g., Ubuntu) or RedHat-based (e.g., CentOS, Rocky Linux).
- Sudo privileges required for package installation and service management.
- Docker is recommended for containerized deployment.

## Role Variables

Variables can be set in your playbook or via group/host vars. Example defaults:

```yaml
project: ansible-collections
pihole_dir: /opt/pihole
```

## Dependencies

- `common` (role): Provides base system configuration and user setup.
- `geerlingguy.pip` (role): Installs Python packages, including Docker SDK for Python.
  - Installs: `docker` (Python package)
- `geerlingguy.docker` (role): Installs and configures Docker.
  - Adds `{{ ansible_user }}` to the `docker` group for non-root usage.

## Example Playbook

```yaml
- name: Install DNS server with Pihole and Cloudflared
  hosts:
    - dns-principal
    # - dns
    # - dns2
  gather_facts: true
  become: true
  vars:
    virtualization_type: standard
  roles:
    - name: pihole
      vars:
        project: '{{ lookup("env", "PROJECT_NAME") }}'
        dns_hosts:
          - 192.168.10.1 router
          - 192.168.10.253 pve
          - 192.168.10.253 pve2
          - 192.168.10.2 truenas-srv.{{ domain }}
          - 192.168.10.3 pbs-srv.{{ domain }}
          - 192.168.10.5 {{ proxy_host }}
          - 192.168.10.100 principal-dns.{{ domain }}
          - 192.168.10.200 secondary-dns.{{ domain }}
        cnameRecords:
          - homepage.{{ domain }},{{ proxy_host }}
          - truenas.{{ domain }},{{ proxy_host }}
          - nas.{{ domain }},{{ proxy_host }}
          - pbs.{{ domain }},{{ proxy_host }}
          - dns.{{ domain }},{{ proxy_host }}
          - dns2.{{ domain }},{{ proxy_host }}
          - pve.{{ domain }},{{ proxy_host }}
          - pve2.{{ domain }},{{ proxy_host }}
          - n8n.{{ domain }},{{ proxy_host }}
```

## Handlers

- `restart pihole`: Restarts the Pi-hole container/service.

## Templates

- `compose.yaml.j2`: Docker Compose file for Pi-hole deployment.

## Idempotency & Privilege Escalation

- All tasks use `become: true` where required.
- Idempotency is ensured via Ansible modules and Docker Compose.

## Environment Variables

- Sensitive values (e.g., web password) should use `lookup('env', ...)` pattern.

## License

MIT

## Author Information

This role was created by mombe090, inspired by geerlingguy best practices.
