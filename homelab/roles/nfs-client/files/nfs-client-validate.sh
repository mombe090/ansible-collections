#!/bin/bash
# NFS Client Validation Script
# This script validates that the NFS client is properly configured and mounts are working

set -e

echo "=== NFS Client Validation ==="

# Check if NFS client packages are installed
echo "1. Checking NFS client packages..."
if dpkg -l | grep -q nfs-common || rpm -qa | grep -q nfs-utils; then
    echo "   ✓ NFS client packages are installed"
else
    echo "   ✗ NFS client packages are not installed"
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

# Check NFS mounts
echo "3. Checking NFS mounts..."
nfs_mounts=$(mount -t nfs,nfs4 2>/dev/null || true)
if [ -n "$nfs_mounts" ]; then
    echo "   ✓ NFS mounts found:"
    echo "$nfs_mounts" | while read line; do
        echo "     $line"
    done
else
    echo "   ⚠ No active NFS mounts found"
fi

# Check /etc/fstab for NFS entries
echo "4. Checking /etc/fstab for NFS entries..."
if grep -q "nfs\|nfs4" /etc/fstab 2>/dev/null; then
    echo "   ✓ NFS entries found in /etc/fstab:"
    grep "nfs\|nfs4" /etc/fstab | while read line; do
        echo "     $line"
    done
else
    echo "   ⚠ No NFS entries found in /etc/fstab"
fi

# Test connectivity to NFS servers
echo "5. Testing connectivity to NFS servers..."
if [ -n "$nfs_mounts" ]; then
    echo "$nfs_mounts" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u | while read server; do
        if ping -c 1 -W 3 "$server" >/dev/null 2>&1; then
            echo "   ✓ NFS server $server is reachable"
        else
            echo "   ✗ NFS server $server is not reachable"
        fi
    done
else
    echo "   ⚠ No NFS servers to test"
fi

# Check mount point accessibility
echo "6. Checking mount point accessibility..."
if [ -n "$nfs_mounts" ]; then
    echo "$nfs_mounts" | awk '{print $3}' | while read mountpoint; do
        if [ -d "$mountpoint" ] && mountpoint -q "$mountpoint"; then
            echo "   ✓ Mount point $mountpoint is accessible"
            # Test read access
            if timeout 5 ls "$mountpoint" >/dev/null 2>&1; then
                echo "     ✓ Read access confirmed"
            else
                echo "     ✗ Read access failed or timed out"
            fi
        else
            echo "   ✗ Mount point $mountpoint is not properly mounted"
        fi
    done
else
    echo "   ⚠ No mount points to check"
fi

# Check NFS client domain configuration
echo "7. Checking NFS client domain configuration..."
if [ -f /etc/idmapd.conf ]; then
    domain=$(grep "^Domain" /etc/idmapd.conf 2>/dev/null | cut -d'=' -f2 | tr -d ' ' || true)
    if [ -n "$domain" ]; then
        echo "   ✓ NFS domain configured: $domain"
    else
        echo "   ⚠ NFS domain not explicitly configured"
    fi
else
    echo "   ⚠ /etc/idmapd.conf not found"
fi

echo "=== Validation Complete ==="
