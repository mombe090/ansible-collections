# Vaultwarden Role

Ce rôle Ansible déploie Vaultwarden (serveur Bitwarden auto-hébergé) avec Docker Compose, incluant une base de données PostgreSQL.

## Fonctionnalités

- Déploiement de Vaultwarden avec Docker Compose
- Base de données PostgreSQL intégrée
- Support WebSocket pour les notifications en temps réel
- Configuration Traefik pour l'accès HTTPS
- Système de sauvegarde automatique
- Planification des sauvegardes avec cron

## Variables

### Configuration de base

- `vaultwarden_enabled`: Active/désactive le déploiement (défaut: `true`)
- `vaultwarden_dir`: Répertoire d'installation (défaut: `/opt/vaultwarden`)
- `vaultwarden_version`: Version de Vaultwarden (défaut: `1.32.7`)
- `vaultwarden_domain`: Domaine d'accès (défaut: `vaultwarden.{{ domain }}`)

### Configuration de la base de données

- `postgres_host`: Hôte PostgreSQL (défaut: `postgres`)
- `postgres_port`: Port PostgreSQL (défaut: `5432`)
- `postgres_db`: Nom de la base de données (défaut: `vaultwarden`)
- `username`: Nom d'utilisateur de la base (défaut: `vaultwarden`)
- `password`: Mot de passe de la base (défaut: `vaultwarden`)

### Configuration Vaultwarden

- `vaultwarden_admin_token`: Token d'administration (obligatoire)
- `vaultwarden_signups_allowed`: Autoriser les inscriptions (défaut: `false`)
- `vaultwarden_invitations_allowed`: Autoriser les invitations (défaut: `true`)
- `vaultwarden_emergency_access_allowed`: Accès d'urgence (défaut: `true`)
- `vaultwarden_sends_allowed`: Autoriser les envois (défaut: `true`)
- `vaultwarden_web_vault_enabled`: Interface web activée (défaut: `true`)
- `vaultwarden_websocket_enabled`: WebSocket activé (défaut: `true`)


## Utilisation

### Playbook basique

```yaml
- name: Deploy Vaultwarden
  hosts: vaultwarden_servers
  roles:
    - vaultwarden
  vars:
    vaultwarden_admin_token: "your-secure-admin-token-here"
    domain: "example.com"
```

### Génération du token d'administration

Générez un token sécurisé avec :

```bash
openssl rand -base64 48
```

### Mode sauvegarde

Pour exécuter uniquement les sauvegardes :

```bash
ansible-playbook playbook.yml --tags backup -e vaultwarden_backup_mode=true
```

## Accès

- Interface web : `https://vaultwarden.{{ domain }}`
- Interface d'administration : `https://vaultwarden.{{ domain }}/admin`

## Prérequis

- Docker et Docker Compose installés
- Traefik configuré comme reverse proxy
- Réseau Docker `proxy` existant

## Structure des fichiers

```text
/opt/vaultwarden/
├── compose.yaml          # Configuration Docker Compose
├── .env                  # Variables d'environnement
├── data/                 # Données Vaultwarden
└── postgres_data/        # Données PostgreSQL
```
