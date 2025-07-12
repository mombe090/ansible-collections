<!-- markdownlint-disable MD013 -->
# ansible-collections

A curated set of Ansible roles and playbooks for automating and managing a homelab environment, including infrastructure provisioning, service deployment, and configuration management.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Roles](#roles)
- [Playbooks](#playbooks)
- [Playbooks](#playbooks)
- [Inventory & Configuration](#inventory--configuration)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository provides reusable Ansible roles and playbooks to automate the setup and management of a homelab, including:

- Proxmox LXC container provisioning
- Docker and Pip installation
- Downloading and managing cloud images
- Pihole and Traefik deployment via Docker Compose
- Centralized configuration and inventory management

## Project Structure

```bash
homelab/
  ansible.cfg
  galaxy.yaml
  hosts.ini
  playbook.yaml
  group_vars/
  roles/
    common/
    geerlingguy.docker/
    geerlingguy.pip/
    get_cloud_images_proxmox/
    lxc/
    pihole/
    traefik/
```

- **roles/**: Contains all Ansible roles, each with its own tasks, defaults, vars, and templates.
- **playbook.yaml**: Main playbook to orchestrate role execution.
- **hosts.ini**: Inventory file listing all managed hosts.
- **group_vars/**: Group variables for inventory groups.
- **ansible.cfg**: Ansible configuration for this project.

## Getting Started

### Prerequisites

- Ansible 2.10+ installed
- Python 3.x
- Access to your homelab infrastructure (e.g., Proxmox, Docker hosts)
- Required Python packages (see `requirements.txt`)

### Installation

1. Clone this repository:

   ```sh
   git clone https://github.com/mombe090/ansible-collections.git
   cd ansible-collections
   ```

2. Install Python dependencies:

   ```sh
   pip install -r requirements.txt
   ```

3. Install required Ansible collections:

   ```sh
   ansible-galaxy install -r homelab/galaxy.yaml
   ```

### Usage

Run the main playbook:

```sh
ansible-playbook -i homelab/hosts.ini homelab/playbook.yaml
```

## Roles

### `common`

- Sets up essential tools and environment variables (e.g., kubeconfig).

### `geerlingguy.docker`

- Installs and configures Docker CE/EE on Linux hosts.

### `geerlingguy.pip`

- Installs Python pip and manages pip packages.

### `get_cloud_images_proxmox`

- Downloads cloud images for various distributions to Proxmox storage.

### `lxc`

- Provisions LXC containers on Proxmox nodes using the `community.general.proxmox` module.

### `pihole`

- Deploys Pihole using Docker Compose, manages DNS configuration.

### `traefik`

- Deploys Traefik as a reverse proxy using Docker Compose, manages configuration and certificates.

## Playbooks

- **playbook.yaml**: Example tasks include installing Proxmoxer, provisioning LXC containers, downloading images, and installing Docker.

## Inventory & Configuration

- **hosts.ini**: Defines groups and hosts (e.g., proxmox, dns, proxy).
- **group_vars/all.yaml**: Global variables (e.g., `ansible_user`, `domain`, `proxy_host`).
- **ansible.cfg**: Sets Ansible defaults, inventory path, and roles path.

## Dependencies

- See `requirements.txt` for Python dependencies (e.g., `proxmoxer`).
- See `galaxy.yaml` for Ansible collection dependencies.

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements or new roles.

## License

This project is licensed under the MIT License.

---
