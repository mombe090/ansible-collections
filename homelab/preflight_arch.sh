#!/bin/bash

# Quick fix for pacman lock issues before running Ansible
echo "🔧 Pre-flight check for pacman..."

# Check if we're on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "❌ This script is for Arch Linux systems only"
    exit 1
fi

# Check for pacman lock
if [ -f /var/lib/pacman/db.lck ]; then
    echo "⚠️  Found pacman lock file"
    read -p "Remove pacman lock file? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -f /var/lib/pacman/db.lck
        echo "✅ Removed pacman lock"
    fi
fi

# Check for running pacman processes
if pgrep pacman > /dev/null; then
    echo "⚠️  Found running pacman processes:"
    pgrep -l pacman
    echo "Please wait for them to finish or kill them manually"
    exit 1
fi

# Test pacman access
echo "🧪 Testing pacman access..."
if sudo pacman -Sy --noconfirm; then
    echo "✅ Pacman database sync successful"
else
    echo "❌ Pacman database sync failed"
    exit 1
fi

echo "🎉 Pre-flight check complete! You can now run the Ansible playbook."
