# PhotoPrism Deployment Guide

## Quick Start

1. **Set Environment Variables**

   ```bash
   # Copy the example and customize
   cp .envrc.photoprism.example .envrc.local
   # Edit .envrc.local with your passwords
   source .envrc.local
   ```

2. **Customize Storage Paths**

   Edit the playbook to point to your photo collection:

   ```yaml
   photoprism_originals_path: /path/to/your/photos
   ```

3. **Deploy PhotoPrism**

   ```bash
   # Development deployment
   uv run ansible-playbook playbooks/photoprism.playbook.yaml
   
   # Production deployment
   uv run ansible-playbook playbooks/prod/photoprism.yaml
   ```

4. **Access PhotoPrism**
   - Direct access: `http://your-server:2342`
   - With Traefik: `https://photos.yourdomain.com`
   - Login with admin credentials from environment variables

## Required Environment Variables

- `PHOTOPRISM_ADMIN_PASSWORD` - Admin user password
- `PHOTOPRISM_DB_PASSWORD` - Database user password  
- `PHOTOPRISM_DB_ROOT_PASSWORD` - Database root password
- `HOMELAB_DOMAIN` - Your domain name
- `HOMELAB_USER_FULLNAME` - Site author name

## Storage Configuration

The role creates three main storage areas:

1. **Originals** (`/mnt/photos`) - Your existing photo collection
2. **Storage** (`/opt/photoprism/storage`) - Thumbnails, cache, config
3. **Import** (`/opt/photoprism/import`) - Temporary import directory

## AI Features

AI features are disabled by default for performance. To enable when you have adequate hardware:

```yaml
photoprism_disable_faces: false
photoprism_disable_classification: false
photoprism_disable_tensorflow: false
```

## Performance Tuning

- Adjust `photoprism_workers` based on CPU cores
- Use SSD storage for the storage directory
- Increase `photoprism_workers` for faster indexing
- Consider MariaDB optimization for large libraries

## Troubleshooting

```bash
# Check container logs
docker compose -f /opt/photoprism/compose.yaml logs photoprism

# Check database logs  
docker compose -f /opt/photoprism/compose.yaml logs mariadb

# Restart services
docker compose -f /opt/photoprism/compose.yaml restart

# Complete redeployment
uv run ansible-playbook playbooks/photoprism.playbook.yaml --tags photoprism
```

## Security Notes

- Environment file is created with 600 permissions
- Database runs in isolated network
- Use strong passwords for all services
- Consider adding authentication middleware with Traefik
