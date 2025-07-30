# Multipass Ansible Role

Provision Ubuntu VMs on your local machine using [Multipass](https://multipass.run/) and [cloud-init](https://cloud-init.io/), with full network customization.

## Features

- Launch VMs with custom image, name, CPU, memory, disk
- Configure static IP, gateway, DNS via cloud-init/netplan
- Inject SSH keys and user credentials
- Idempotent: only creates VMs if not present
- Works on macOS, Linux, Windows (Multipass required)

## Requirements

- Multipass installed on the control host
- Ansible >= 2.9

## Role Variables

| Variable                | Default         | Description                       |
|------------------------ |----------------|-----------------------------------|
| `vm_image`              | `jammy`        | Ubuntu image to use               |
| `vm_name`               | `homelab-vm`   | Name of the VM                    |
| `vm_allocated_cpu`      | `1`            | Number of CPUs                    |
| `vm_allocated_memory`   | `1G`           | Memory size                       |
| `vm_allocated_disk`     | `1G`           | Disk size                         |
| `ip_address`            |                | Static IP for VM                  |
| `gateway`               |                | Gateway IP                        |
| `nameservers`           | `["192.168.10.1", "8.8.8.8", "1.1.1.1"]` | List of DNS servers |
| `network_interface`     | `enp0s2`       | Network interface name            |
| `dhcp4`                 | `false`        | Use DHCP for interface            |

## Example Playbook

```yaml
- name: Deploy Multipass VM instances with cloud-init
  hosts:
    - localhost
  gather_facts: true
  become: false
  vars:
    virtual_machines:
      - name: primary-dns
        image: "jammy"
        ip: "{{ lookup('env', 'HOMELAB_PRIMARY_DNS_IP') }}"
  tasks:
    - name: Create Multipass VMs
      include_role:
        name: multipass
      with_items: "{{ virtual_machines }}"
      vars:
        vm_image: "{{ item.image }}"
        vm_name: "{{ item.name }}"
        user: '{{ lookup("env", "HOMELAB_USER") }}'
        password: '{{ lookup("env", "HOMELAB_UNIX_PASSWORD") }}'
        ssh_public_key: '{{ lookup("env", "HOMELAB_PUBLIC_KEY") }}'
        vm_allocated_cpu: 1
        vm_allocated_memory: "1G"
        vm_allocated_disk: "5G"
        ip_address: "{{ item.ip }}"
        gateway: "{{ lookup('env', 'HOMELAB_GATEWAY') }}"
        network_interface: "enp0s2"
        nameservers:
          - "192.168.10.1"
          - "8.8.8.8"
          - "1.1.1.1"
        dhcp4: false
```

## Usage Tips

- Use environment variables for secrets and IPs
- Adjust `network_interface` to match your VM's default interface
- For multiple VMs, use Ansible's `with_items` or `loop` in a task, not in the `roles` section

## License

MIT

## Author

Mamadou Yaya DIALLO / @mombe090
