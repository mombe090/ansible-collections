#!/bin/bash

# Script to run the Arch Linux playbook with proper authentication
# Usage: ./run_arch_playbook.sh [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_PATH="$SCRIPT_DIR/playbooks/arch.playbook.yaml"
INVENTORY_PATH="$SCRIPT_DIR/hosts.ini"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Arch Linux Ansible Playbook Runner${NC}"
echo "================================================"

# Check if files exist
if [[ ! -f "$PLAYBOOK_PATH" ]]; then
    echo -e "${RED}❌ Playbook not found: $PLAYBOOK_PATH${NC}"
    exit 1
fi

if [[ ! -f "$INVENTORY_PATH" ]]; then
    echo -e "${RED}❌ Inventory not found: $INVENTORY_PATH${NC}"
    exit 1
fi

# Check if there are any hosts in the archlinux group
if ! grep -A 10 "\[archlinux\]" "$INVENTORY_PATH" | grep -v "^#" | grep -v "^\[" | grep -q "ansible_host"; then
    echo -e "${YELLOW}⚠️  No active hosts found in [archlinux] group in hosts.ini${NC}"
    echo "Please uncomment or add your Arch Linux hosts to the inventory file."
    exit 1
fi

echo -e "${YELLOW}📋 Available options:${NC}"
echo "1. Run with sudo password prompt (recommended)"
echo "2. Run assuming passwordless sudo is configured"
echo "3. Run with custom ansible options"
echo "4. Check playbook syntax only"
echo "5. Show inventory hosts"

read -p "Choose an option (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}🔐 Running with sudo password prompt...${NC}"
        echo "You will be prompted for the sudo password."
        ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" --ask-become-pass
        ;;
    2)
        echo -e "${GREEN}🔓 Running assuming passwordless sudo...${NC}"
        ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH"
        ;;
    3)
        read -p "Enter additional ansible-playbook options: " custom_options
        echo -e "${GREEN}⚙️  Running with custom options: $custom_options${NC}"
        ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" $custom_options
        ;;
    4)
        echo -e "${GREEN}✅ Checking syntax only...${NC}"
        ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" --syntax-check
        echo -e "${GREEN}✅ Syntax check completed!${NC}"
        ;;
    5)
        echo -e "${GREEN}📊 Inventory hosts in [archlinux] group:${NC}"
        echo "================================================"
        grep -A 20 "\[archlinux\]" "$INVENTORY_PATH" | grep -v "^\[" | head -20
        ;;
    *)
        echo -e "${RED}❌ Invalid option selected${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Script completed!${NC}"
