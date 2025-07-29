# TrueNAS NFS Systemd Automation Role

This Ansible role automates the creation of a systemd service and timer to start the NFS service on a TrueNAS server via its REST API after every reboot.

## Features

- Deploys a systemd service and timer to run a custom shell script at boot
- The script attempts to start the NFS service on TrueNAS up to 3 times via the API
- Uses Ansible variables for host and credentials
- Ensures `curl` is installed

## Usage

Add the role to your playbook and provide the required variables:

```yaml
roles:
  - name: truenas_nfs
    vars:
      truenas_host: '{{ lookup("env", "TRUENAS_HOST") }}'
      truenas_auth: '{{ lookup("env", "TRUENAS_AUTH") }}'
```

## Variables

- `truenas_host`: The hostname or IP of your TrueNAS server (without protocol)
- `truenas_auth`: The base64-encoded credentials for the TrueNAS API (use `echo -n 'username:password' | base64`)

## Service Health Check

After running the role, verify that the automation is working:

```sh
systemctl status start-truenas-nfs.timer
systemctl status start-truenas-nfs.service
```

Both should show `active` (for the timer) and `active (exited)` or `success` (for the service). If the service fails, check the logs:

```sh
journalctl -u start-truenas-nfs.service
```

## Troubleshooting

- If the service fails, check the HTTP code in the logs. Codes other than 2xx indicate an API or network issue.
- Ensure your credentials and host are correct.
- The script will retry up to 3 times before failing.

## Security

- Credentials are passed via environment variables or Ansible vars. Protect your secrets!
- The script is deployed to `/usr/local/bin/start-truenas-nfs.sh` and made executable.

## Customization

- You can adjust the timer interval or retry logic by editing the role templates.

---
Maintained by mombe090
