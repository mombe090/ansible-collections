#!/bin/bash
# Generate a secure admin token for Vaultwarden
# Usage: ./generate_admin_token.sh

echo "Generating secure admin token for Vaultwarden..."
token=$(openssl rand -base64 48)
echo "Your admin token: $token"
echo ""
echo "Add this to your Ansible vault or variables:"
echo "vaultwarden_admin_token: \"$token\""
echo ""
echo "You can access the admin panel at: https://vaultwarden.yourdomain.com/admin"
