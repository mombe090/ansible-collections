# PhotoPrism Ansible Role

This Ansible role deploys PhotoPrism using Docker Compose, following the best practices from the official PhotoPrism documentation.

## Features

- **Secure deployment** with proper file permissions and environment variable handling
- **MariaDB integration** for optimal performance (better than SQLite)
- **Traefik integration** ready with customizable labels
- **AI features disabled** by default (no hardware requirements)
- **Flexible storage** configuration for originals, storage, and import directories
- **Environment-based configuration** following homelab patterns

## Requirements

- Docker and Docker Compose installed on target host
- Sufficient storage space for photos and database
- Optional: Traefik proxy for HTTPS termination

## Role Variables

### Required Variables

```yaml
photoprism_admin_password: "your-secure-admin-password"
photoprism_db_password: "your-secure-db-password"
photoprism_db_root_password: "your-secure-root-password"
```

### Important Configuration

```yaml
# Storage paths - customize for your setup
photoprism_originals_path: /mnt/photos  # Where your photos are stored
photoprism_storage_path: /opt/photoprism/storage  # Thumbnails, cache, config
photoprism_import_path: /opt/photoprism/import    # Optional import directory

# Admin configuration
photoprism_admin_user: admin
photoprism_site_url: "https://photos.example.com"
```

### Performance Settings

```yaml
photoprism_workers: 1  # Adjust based on CPU cores
photoprism_readonly: false  # Set to true to disable uploads/modifications
```

### AI Features (Disabled by Default)

```yaml
photoprism_disable_faces: true
photoprism_disable_classification: true
photoprism_disable_tensorflow: true
```

Set these to `false` when you have hardware capable of running AI features.

## Example Playbook

```yaml
- name: Deploy PhotoPrism
  hosts: photos
  become: true
  roles:
    - role: photoprism
      vars:
        photoprism_admin_password: "{{ lookup('env', 'PHOTOPRISM_ADMIN_PASSWORD') }}"
        photoprism_db_password: "{{ lookup('env', 'PHOTOPRISM_DB_PASSWORD') }}"
        photoprism_db_root_password: "{{ lookup('env', 'PHOTOPRISM_DB_ROOT_PASSWORD') }}"
        photoprism_originals_path: /mnt/nas/photos
        photoprism_site_url: "https://photos.{{ domain }}"
        photoprism_labels:
          - "traefik.enable=true"
          - "traefik.http.routers.photoprism.rule=Host(`photos.{{ domain }}`)"
          - "traefik.http.routers.photoprism.tls=true"
          - "traefik.http.routers.photoprism.tls.certresolver=cloudflare"
          - "traefik.http.services.photoprism.loadbalancer.server.port=2342"
```

## Storage Requirements

- **Originals**: Mount your existing photo collection here
- **Storage**: Should be on fast storage (SSD preferred) for thumbnails and cache
- **Import**: Optional directory for organizing new photos before moving to originals
- **Database**: MariaDB data stored in `{{ photoprism_dir }}/database`

## Security Considerations

- Environment file (`.env`) is created with 600 permissions
- Service directories have restricted access (750, root:docker)
- Database runs in isolated network
- Passwords should be managed via environment variables or Ansible Vault

## Performance Optimization

- Adjust `photoprism_workers` based on CPU cores
- Use SSD storage for the storage directory
- Consider enabling AI features only when you have adequate hardware
- MariaDB is pre-configured with optimized settings for PhotoPrism

## Traefik Integration

Add labels for automatic HTTPS and routing:

```yaml
photoprism_labels:
  - "traefik.enable=true"
  - "traefik.http.routers.photoprism.rule=Host(`photos.yourdomain.com`)"
  - "traefik.http.routers.photoprism.tls=true"
  - "traefik.http.routers.photoprism.tls.certresolver=letsencrypt"
  - "traefik.http.services.photoprism.loadbalancer.server.port=2342"
```

## Post-Installation

1. Access PhotoPrism at `http://your-server:2342` or your configured domain
2. Login with the admin credentials
3. Configure library settings in the web interface
4. Start indexing your photos

## Troubleshooting

- Check logs: `docker compose -f /opt/photoprism/compose.yaml logs`
- Ensure storage paths exist and are accessible
- Verify environment variables are properly set
- Check that the proxy network exists if using Traefik

## License

MIT

## Author Information

Created for homelab automation by mombe090.
