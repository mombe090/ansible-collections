#!/bin/bash

# Quick test script for Arch Linux package database
# Run this on your Arch server to test pacman database status

echo "🔍 Checking Arch Linux package database status..."

# Check if pacman database exists
if [ ! -d "/var/lib/pacman/sync" ] || [ -z "$(ls -A /var/lib/pacman/sync)" ]; then
    echo "❌ Pacman database is empty or missing"
    echo "🔧 Initializing pacman database..."
    sudo pacman -Sy
else
    echo "✅ Pacman database exists"
fi

# Test pacman query
echo "🧪 Testing pacman query..."
if sudo pacman -Q base-devel &>/dev/null; then
    echo "✅ base-devel is installed"
else
    echo "⚠️  base-devel is not installed"
fi

# Check pacman keyring
echo "🔑 Checking pacman keyring..."
if [ -f "/etc/pacman.d/gnupg/trustdb.gpg" ]; then
    echo "✅ Pacman keyring is initialized"
else
    echo "❌ Pacman keyring needs initialization"
    echo "🔧 Run: sudo pacman-key --init && sudo pacman-key --populate archlinux"
fi

# Test simple package query
echo "🧪 Testing simple package installation check..."
if sudo pacman -Ss git &>/dev/null; then
    echo "✅ Package search works"
else
    echo "❌ Package search failed - database may be corrupted"
fi

echo ""
echo "💡 If you see any failures above, run the Ansible playbook with:"
echo "   ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml --ask-become-pass"
echo ""
echo "🏁 Database check complete!"
