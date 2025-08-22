# Gitea Runner Role

This Ansible role sets up a Gitea Actions runner that can execute workflows for your Gitea instance. The role supports two installation methods: Docker containers and native binary installation.

## Features

- **Dual Installation Methods**: Choose between Docker-based deployment or native binary installation
- **Docker Mode**: Runs the act_runner in a Docker container with full Docker-in-Docker support
- **Binary Mode**: Installs act_runner as a native Linux service with systemd management
- **Docker Job Execution**: Binary mode can use Docker containers for job execution (recommended)
- **Automatic Registration**: Handles runner registration with your Gitea instance
- **Flexible Configuration**: Supports custom labels, runner names, and environment variables
- **LXC Container Support**: Binary mode is perfect for LXC containers and lightweight Linux environments
- **Force Registration**: Option to force re-registration of existing runners
- **Ephemeral Runners**: Support for disposable runners for enhanced security

## Requirements

### Docker Mode
- Docker Engine
- Docker Compose V2
- community.docker Ansible collection

### Binary Mode
- Linux system with systemd
- Network access to download act_runner binary
- Sufficient permissions to create users and systemd services

## Role Variables

### Common Variables

```yaml
# Service configuration
gitea_runner_enabled: true
gitea_runner_version: "nightly"

# Installation method: 'docker' or 'binary'
gitea_runner_install_method: "docker"  # or "binary"

# Runner configuration
gitea_runner_name: "homelab-runner"
gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,self-hosted:host"
gitea_runner_log_level: "info"

# Gitea instance configuration
gitea_instance_url: "https://gitea.example.com"
gitea_runner_registration_token: "your-registration-token"
```

## Usage

### Docker Mode

For container-based execution using Docker:

```yaml
---
- name: Deploy Gitea Actions Runner (Docker)
  hosts: docker_hosts
  become: true
  vars:
    domain: "example.com"
    registration_token: "your-registration-token"

  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "docker"
        gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,self-hosted:host"
```

### Binary Mode

For native Linux execution without Docker:

```yaml
---
- name: Deploy Gitea Actions Runner (Binary)
  hosts: linux_hosts
  become: true
  vars:
    domain: "example.com"
    registration_token: "your-registration-token"

  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "binary"
        domain: "example.com"
        registration_token: "your-registration-token"
        gitea_runner_labels: "self-hosted:host,linux:host"
```

### Binary Mode with Docker Job Execution (Recommended)

For native binary installation that uses Docker containers for job execution:

```yaml
---
- name: Deploy Gitea Actions Runner (Binary + Docker Jobs)
  hosts: linux_hosts
  become: true
  vars:
    domain: "example.com"
    registration_token: "your-registration-token"

  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "binary"
        gitea_runner_use_docker_for_jobs: true
        domain: "example.com"
        registration_token: "your-registration-token"
        gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,self-hosted:docker,linux:docker"
        gitea_runner_docker_network: "bridge"
        gitea_runner_docker_volumes:
          - "/var/run/docker.sock:/var/run/docker.sock"
```

## Runner Labels

The `gitea_runner_labels` variable determines which workflows the runner can execute:

- **Docker Mode**: Use labels like `ubuntu-latest:docker://catthehacker/ubuntu:act-latest`
- **Binary Mode**: Use labels like `self-hosted:host`, `linux:host`, or custom labels

### Examples:

```yaml
# For Docker mode with multiple container images
gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,ubuntu-22.04:docker://ubuntu:22.04"

# For binary mode with host execution
gitea_runner_labels: "self-hosted:host,linux:host,custom-runner:host"

# For Docker mode with fallback to host
gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,self-hosted:host"

# Gitea instance configuration
gitea_instance_url: "https://gitea.example.com"
gitea_runner_registration_token: "your-registration-token"
domain: "example.com"  # Used to construct gitea URL
registration_token: "your-registration-token"
```

### Docker Mode Variables

```yaml
# Docker specific configuration
gitea_runner_dir: "/opt/gitea-runner"
gitea_force_pull: "missing"
```

### Binary Mode Variables

```yaml
# Binary installation configuration
gitea_runner_user: "act_runner"
gitea_runner_group: "act_runner"
gitea_runner_home: "/var/lib/act_runner"
gitea_runner_config_file: "/var/lib/act_runner/config.yaml"
gitea_runner_data_file: "/var/lib/act_runner/.runner"

# Privilege escalation (set to false if already running as root in LXC)
gitea_runner_become: true  # Set to false for LXC containers

# Docker for job execution (when using binary installation)
gitea_runner_use_docker_for_jobs: true  # Use Docker containers for running jobs
gitea_runner_docker_network: "bridge"   # Docker network for job containers
gitea_runner_docker_volumes: []         # Additional volumes to mount in job containers

# Force registration and ephemeral options
gitea_runner_force_registration: false  # Force re-registration of existing runners
gitea_runner_ephemeral: false          # Enable ephemeral runners for enhanced security

# Default architecture (will be detected at runtime)
gitea_runner_arch: "amd64"
```

## Installation Methods

### Docker Mode (Default)

Best for environments where Docker is already available and you want isolated runner execution.

```yaml
- hosts: docker_hosts
  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "docker"
        gitea_runner_dir: "/opt/gitea-runner"
        domain: "example.com"
        registration_token: "your-registration-token"
```

### Binary Mode

Perfect for LXC containers, lightweight environments, or when you prefer native system services.

```yaml
- hosts: lxc_containers
  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "binary"
        domain: "example.com"
        registration_token: "your-registration-token"
        gitea_runner_labels: "self-hosted:host,linux:host"
```

## Runner Labels

The `gitea_runner_labels` variable determines which workflows the runner can execute:

- **Docker Mode**: Use labels like `ubuntu-latest:docker://catthehacker/ubuntu:act-latest`
- **Binary Mode**: Use labels like `self-hosted:host`, `linux:host`, or custom labels

### Examples:

```yaml
# For Docker mode with multiple container images
gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,ubuntu-22.04:docker://ubuntu:22.04"

# For binary mode running jobs directly on host
gitea_runner_labels: "self-hosted:host,linux:host,custom-runner:host"

# Mixed mode (Docker mode with some host execution)
gitea_runner_labels: "ubuntu-latest:docker://catthehacker/ubuntu:act-latest,self-hosted:host"
```

## Example Playbooks

### LXC Container Deployment (Running as Root)

```yaml
---
- name: Deploy Gitea runner in LXC containers (as root)
  hosts: lxc_containers
  become: false  # Already running as root
  vars:
    domain: "homelab.local"
    registration_token: "{{ vault_gitea_runner_token }}"
  
  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "binary"
        gitea_runner_become: false  # Disable privilege escalation
        gitea_runner_name: "lxc-runner-{{ inventory_hostname }}"
        gitea_runner_labels: "self-hosted:host,lxc:host,{{ ansible_architecture }}:host"
```

### LXC Container Deployment

```yaml
---
- name: Deploy Gitea runner in LXC containers
  hosts: lxc_containers
  become: true
  vars:
    domain: "homelab.local"
    registration_token: "{{ vault_gitea_runner_token }}"
  
  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "binary"
        gitea_runner_name: "lxc-runner-{{ inventory_hostname }}"
        gitea_runner_labels: "self-hosted:host,lxc:host,{{ ansible_architecture }}:host"
```

### Docker Host Deployment

```yaml
---
- name: Deploy Gitea runner with Docker
  hosts: docker_hosts
  become: true
  vars:
    domain: "homelab.local"
    registration_token: "{{ vault_gitea_runner_token }}"
  
  roles:
    - role: gitea-runner
      vars:
        gitea_runner_install_method: "docker"
        gitea_runner_name: "docker-runner-{{ inventory_hostname }}"
        gitea_force_pull: "always"
```

## Service Management

### Docker Mode

```bash
# View runner status
docker ps | grep gitea-runner

# View runner logs
docker logs gitea-runner

# Restart runner
docker-compose -f /opt/gitea-runner/compose.yaml restart
```

### Binary Mode

```bash
# View runner status
sudo systemctl status act_runner

# View runner logs
sudo journalctl -u act_runner -f

# Restart runner
sudo systemctl restart act_runner
```

## Troubleshooting

### Registration Issues

1. Verify the registration token is correct
2. Check network connectivity to Gitea instance
3. Ensure the Gitea instance has Actions enabled

### Binary Mode Issues

- Check binary download URL and architecture
- Verify user permissions
- Check systemd service logs

### Docker Mode Issues

- Verify Docker daemon is running
- Check Docker socket permissions
- Verify network connectivity within containers

## Security Considerations

### Docker Mode
- Runs with privileged access for Docker-in-Docker
- Mounts Docker socket for container execution

### Binary Mode
- Runs as unprivileged `act_runner` user
- Uses systemd security features (NoNewPrivileges, PrivateTmp, etc.)
- Better isolation for LXC container environments

## License

MIT

## Author Information

Created for homelab automation and Gitea Actions support.
