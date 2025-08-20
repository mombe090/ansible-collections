#!/bin/bash
# NFS Server Validation Script
# This script validates that the NFS server is properly configured and running

set -e

echo "=== NFS Server Validation ==="

# Check if NFS server is running
echo "1. Checking NFS server status..."
if systemctl is-active --quiet nfs-server || systemctl is-active --quiet nfs-kernel-server; then
    echo "   ✓ NFS server is running"
else
    echo "   ✗ NFS server is not running"
    exit 1
fi

# Check if rpcbind is running
echo "2. Checking rpcbind status..."
if systemctl is-active --quiet rpcbind; then
    echo "   ✓ rpcbind is running"
else
    echo "   ✗ rpcbind is not running"
    exit 1
fi

# Check exports
echo "3. Checking NFS exports..."
if exportfs -v &>/dev/null; then
    echo "   ✓ NFS exports are configured"
    exportfs -v | while read line; do
        echo "     $line"
    done
else
    echo "   ✗ No NFS exports configured or exportfs failed"
fi

# Check if exports are visible via showmount
echo "4. Testing showmount..."
if showmount -e localhost &>/dev/null; then
    echo "   ✓ showmount works"
    showmount -e localhost | tail -n +2 | while read line; do
        echo "     $line"
    done
else
    echo "   ✗ showmount failed"
fi

# Check listening ports
echo "5. Checking NFS listening ports..."
for port in 111 2049 20048; do
    if netstat -ln | grep -q ":$port "; then
        echo "   ✓ Port $port is listening"
    else
        echo "   ✗ Port $port is not listening"
    fi
done

# Check NFS versions
echo "6. Checking supported NFS versions..."
if rpcinfo -p localhost | grep -q nfs; then
    echo "   ✓ NFS service is registered with rpcbind"
    rpcinfo -p localhost | grep nfs | while read line; do
        echo "     $line"
    done
else
    echo "   ✗ NFS service is not registered with rpcbind"
fi

echo "=== Validation Complete ==="
