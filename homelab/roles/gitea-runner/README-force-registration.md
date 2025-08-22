# Gitea Runner Role - Force Registration Feature

## Overview

The `gitea_runner_force_registration` option allows you to force re-registration of a Gitea Actions runner, even if it's already registered. This is useful when:

- Changing runner configuration (name, labels, etc.)
- Migrating runners between Gitea instances  
- Troubleshooting registration issues
- Updating runner tokens

## Usage

### Basic Force Registration

```yaml
# In your playbook
- hosts: runner_hosts
  vars:
    gitea_runner_force_registration: true
  roles:
    - gitea-runner
```

### Command Line Override

```bash
# Force re-registration via command line
ansible-playbook playbooks/gitea-runner.yaml -e "gitea_runner_force_registration=true"

# Force re-registration with new runner name
ansible-playbook playbooks/gitea-runner.yaml -e "gitea_runner_force_registration=true gitea_runner_name=new-runner-name"
```

### Force Registration with Configuration Changes

```yaml
# Re-register with different configuration
- hosts: runner_hosts
  vars:
    gitea_runner_force_registration: true
    gitea_runner_name: "updated-runner-name"
    gitea_runner_labels: "self-hosted:host,linux:host,updated:true"
  roles:
    - gitea-runner
```

## What Happens During Force Registration

### Binary Installation Method
1. Checks if runner is registered (`.runner` file exists)
2. If force registration is enabled and runner exists:
   - Removes `.runner` data file
   - Removes `config.yaml` file
3. Proceeds with fresh registration process
4. Creates new registration with updated configuration

### Docker Installation Method  
1. Checks if runner is registered (`data/.runner` file exists)
2. If force registration is enabled and runner exists:
   - Removes `data/.runner` file
   - Restarts Docker container to apply changes
3. Proceeds with fresh registration process

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `gitea_runner_force_registration` | `false` | Enable force re-registration |
| `gitea_runner_name` | `homelab-runner` | Runner name for registration |
| `gitea_runner_labels` | Auto-detected | Runner labels/capabilities |

## Examples

### Example 1: Fix Registration Issues
```bash
# When runner registration is corrupted or invalid
ansible-playbook playbooks/gitea-runner.yaml -e "gitea_runner_force_registration=true"
```

### Example 2: Update Runner Labels
```yaml
- hosts: runner_hosts
  vars:
    gitea_runner_force_registration: true
    gitea_runner_labels: "self-hosted:host,linux:host,docker:available,gpu:nvidia"
  roles:
    - gitea-runner
```

### Example 3: Migrate Runner to New Gitea Instance
```yaml
- hosts: runner_hosts
  vars:
    gitea_runner_force_registration: true
    domain: "new-gitea.example.com"
    registration_token: "{{ new_gitea_token }}"
  roles:
    - gitea-runner
```

## Safety Considerations

- **Backup**: Consider backing up `.runner` files before force registration
- **Downtime**: Runner will be temporarily unavailable during re-registration
- **Token**: Ensure you have a valid registration token for the target Gitea instance
- **Connectivity**: Verify network connectivity to Gitea instance before running

## Troubleshooting

### Force Registration Not Working
1. Check if `gitea_runner_force_registration` is set to `true`
2. Verify registration token is valid
3. Ensure connectivity to Gitea instance
4. Check ansible logs for specific error messages

### Runner Still Shows Old Configuration
1. Restart the runner service after force registration
2. Check Gitea admin panel for duplicate runners
3. Verify new registration completed successfully

## Related Variables

```yaml
# Complete force registration configuration example
gitea_runner_force_registration: true
gitea_runner_install_method: binary  # or 'docker'
gitea_runner_name: "production-runner-01"
gitea_runner_labels: "self-hosted:host,linux:host,production:true"
gitea_instance_url: "https://gitea.example.com"
gitea_runner_registration_token: "{{ secret_registration_token }}"
```
