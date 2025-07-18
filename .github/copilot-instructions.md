# Copilot Instructions for Ansible Collections

## Architecture Overview

This is a homelab automation project using Ansible to manage infrastructure across Proxmox hypervisors. The architecture follows a layered approach:

- **Infrastructure Layer**: Proxmox hosts (`pve`, `pve2`) for VM/LXC management
- **Service Layer**: DNS servers (`dns`, `dns2`) and proxy (`proxy.home.mombesoft.com`)
- **Application Layer**: Containerized services (Pihole, Traefik, Netbird) deployed via Docker Compose

## Project Structure Conventions

### Role Organization

```
homelab/roles/{role_name}/
├── defaults/main.yaml    # Default variables (lowest precedence)
├── vars/main.yaml        # Role variables (higher precedence)
├── tasks/main.yml        # Main task entry point
├── templates/            # Jinja2 templates (.j2 files)
└── meta/main.yaml        # Role metadata and dependencies
```

### Playbook Structure

- **Main playbooks**: `homelab/playbooks/{service}.playbook.yaml`
- **Service-specific**: Each service gets its own playbook (e.g., `pihole.playbook.yaml`)
- **Inventory**: Single `hosts.ini` with host groups (`[proxmox]`, `[proxy]`)

## Environment Variable Patterns

All sensitive data and environment-specific values use `lookup("env", "VAR_NAME")`:

```yaml
# homelab/group_vars/all.yaml
ansible_user: '{{ lookup("env", "HOMELAB_USER")}}'
domain: '{{ lookup("env", "HOMELAB_DOMAIN") }}'
proxy_host: 'proxy.{{ lookup("env", "HOMELAB_DOMAIN") }}'

# Role-specific vars
api_password: "{{ lookup('env', 'PROXMOX_VE_PASSWORD') }}"
netbird_auth_token: '{{ lookup("env", "NETBIRD_HOMELAB_KEY") }}'
```

## Critical Developer Workflows

### Running Playbooks

```bash
cd homelab/
ansible-playbook playbooks/pihole.playbook.yaml
ansible-playbook playbooks/netbird.playbook.yaml
```

### Role Development

- Always use `ansible.builtin.*` module names (not shortcuts)
- Add `when: ansible_os_family == "Debian"` for Debian-specific tasks
- Use `become: true` for privilege escalation
- Include `creates:` parameter for idempotency in shell tasks

### Docker Compose Integration

Services use Jinja2 templates for compose files:

```yaml
# In tasks/main.yml
- name: Copy service config
  ansible.builtin.template:
    src: '{{ role_path }}/templates/compose.yaml.j2'
    dest: '{{ service_dir }}/compose.yaml'
```

## Service-Specific Patterns

### Proxmox LXC Management

- Uses `community.general.proxmox` module
- Variables in `roles/lxc/vars/main.yaml` define container specs
- SSH keys injected via `pub_key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"`

### DNS Architecture (Pihole)

- Pihole + Cloudflared setup for DNS-over-HTTPS
- Custom network `dns_net` with static IPs (172.30.0.x)
- DNS records and CNAMEs managed via role variables

### Reverse Proxy (Traefik)

- Automatic HTTPS with Let's Encrypt (Cloudflare DNS challenge)
- External service routing via `traefik.external.yaml.j2`
- Middleware configuration for authentication

## Integration Points

### Proxmox API

- Requires `proxmoxer` Python package
- API credentials via environment variables
- Node names match inventory hostnames

### Network Layout

- `192.168.10.0/24` subnet for all services
- Static IP assignments in inventory (`ansible_host=192.168.10.x`)
- Gateway at `192.168.10.1`

### Container Networking

- `proxy` Docker network for Traefik integration
- Service-specific networks (e.g., `dns_net` for Pihole)

## Common Pitfalls

1. **Environment Variables**: Always use `lookup("env", "VAR")` pattern, not direct references
2. **File Paths**: Use `{{ role_path }}` for role-relative paths in templates
3. **Host Targeting**: Playbooks target host groups, not individual hosts
4. **Privilege Escalation**: Required for package installation and service management

## Package Management

Uses `uv` for Python dependency management:

```bash
uv run ansible-playbook playbooks/service.playbook.yaml
```

Dependencies in `pyproject.toml` include `ansible>=11.7.0` and `proxmoxer>=2.2.0`.
