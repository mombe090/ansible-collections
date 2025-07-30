# GetHomepage Ansible Role

This role installs and configures [Homepage](https://gethomepage.dev/) using Docker Compose, with custom configuration via Jinja2 templates.

## Features

- Deploys Homepage container using Docker Compose
- Customizes config via Jinja2 templates (`config.yaml.j2`)
- Integrates with Traefik proxy network
- Example services and widgets included

## Usage

Add to your playbook:

```yaml
roles:
  - name: gethomepage
    vars:
      homepage_port: 3000
      homepage_timezone: "America/Toronto"
      homepage_custom_dir: "/opt/homepage/custom"
      homepage_compose_dir: "/opt/homepage"
      homepage_data_dir: "/opt/homepage/data"
      homepage_labels:
        - "traefik.enable=true"
        - "traefik.http.routers.homepage.rule=Host(`homepage.{{ domain }}`)"
        - "traefik.http.routers.homepage.entrypoints=websecure"
        - "traefik.http.routers.homepage.tls.certresolver=letsencrypt"
      domain: "yourdomain.com"
```

## Customization

- Edit `config.yaml.j2` to add your own services, widgets, and settings.
- Use Ansible variables to override ports, directories, and labels.

## Starting Homepage

After running the role, check the container:

```sh
docker ps | grep homepage
```

## Health Check

Visit `https://homepage.<yourdomain>` in your browser.

## Troubleshooting

- Check logs: `docker logs homepage`
- Check config: `/opt/homepage/custom/config.yaml`
- Check compose file: `/opt/homepage/compose.yaml`

---
Inspired by <https://gethomepage.dev/>
