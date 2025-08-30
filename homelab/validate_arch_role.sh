#!/bin/bash

# Arch Linux role validation script
# This script validates the syntax of the Arch Linux Ansible role

echo "Validating Arch Linux Ansible role..."

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook command not found. Please install Ansible."
    exit 1
fi

# Change to the homelab directory
cd "$(dirname "$0")"

echo "Checking playbook syntax..."
ansible-playbook --syntax-check playbooks/arch.playbook.yaml

if [ $? -eq 0 ]; then
    echo "✅ Playbook syntax is valid"
else
    echo "❌ Playbook syntax has errors"
    exit 1
fi

echo "Checking role syntax with ansible-lint (if available)..."
if command -v ansible-lint &> /dev/null; then
    ansible-lint roles/arch/
    if [ $? -eq 0 ]; then
        echo "✅ Role passes ansible-lint checks"
    else
        echo "⚠️  Role has linting warnings (may be acceptable)"
    fi
else
    echo "ℹ️  ansible-lint not available, skipping lint checks"
fi

echo "Checking YAML syntax..."
python3 -c "
import yaml
import sys
import os

files_to_check = [
    'roles/arch/defaults/main.yaml',
    'roles/arch/tasks/main.yaml',
    'roles/arch/tasks/yay_setup.yaml',
    'roles/arch/tasks/system_config.yaml',
    'roles/arch/vars/main.yaml',
    'roles/arch/meta/main.yaml',
    'roles/arch/handlers/main.yaml',
    'playbooks/arch.playbook.yaml'
]

all_valid = True
for file_path in files_to_check:
    try:
        with open(file_path, 'r') as f:
            yaml.safe_load(f)
        print(f'✅ {file_path} - Valid YAML')
    except yaml.YAMLError as e:
        print(f'❌ {file_path} - YAML Error: {e}')
        all_valid = False
    except FileNotFoundError:
        print(f'❌ {file_path} - File not found')
        all_valid = False

if all_valid:
    print('✅ All YAML files are valid')
    sys.exit(0)
else:
    print('❌ Some YAML files have errors')
    sys.exit(1)
"

if [ $? -eq 0 ]; then
    echo "✅ All YAML files are syntactically correct"
else
    echo "❌ Some YAML files have syntax errors"
    exit 1
fi

echo ""
echo "🎉 Arch Linux role validation completed successfully!"
echo ""
echo "To use this role:"
echo "1. Add your Arch Linux hosts to the [archlinux] group in hosts.ini"
echo "2. Run: ansible-playbook -i hosts.ini playbooks/arch.playbook.yaml"
echo "3. Or include the role in your existing playbooks"
