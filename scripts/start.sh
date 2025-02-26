#!/bin/bash

# Path to the disk image and ISO
HDD_PATH="/hdd/alt-linux.qcow2"
ISO_PATH="/iso/alt-education.iso"

# Check if ISO exists when needed
if [ ! -f "$ISO_PATH" ]; then
    echo "Error: ISO file not found at $ISO_PATH"
    echo "Please make sure alt-education.iso is in the iso directory"
    exit 1
fi

# Create disk image if it doesn't exist
if [ ! -f "$HDD_PATH" ]; then
    echo "Creating virtual disk image ($HDD_PATH)..."
    qemu-img create -f qcow2 "$HDD_PATH" 70G
fi

# Get actual disk usage in bytes
DISK_USAGE=$(qemu-img info "$HDD_PATH" | grep 'disk size' | grep -o '[0-9]*' || echo "0")
FIVE_GB=$((5 * 1024 * 1024 * 1024))  # 5GB in bytes

# Check if we can use KVM
if [ -e "/dev/kvm" ]; then
    ACCEL_FLAGS="-enable-kvm -cpu host"
else
    ACCEL_FLAGS="-accel tcg,thread=multi -cpu max"
fi

if [ "$DISK_USAGE" -lt "$FIVE_GB" ]; then
    # Installation mode - disk usage less than 5GB
    echo "Starting in installation mode..."
    echo "You can connect to the VM using VNC viewer at localhost:5900"
    exec qemu-system-x86_64 \
        -m 4096 \
        $ACCEL_FLAGS \
        -smp 2 \
        -drive file="$HDD_PATH",format=qcow2 \
        -cdrom "$ISO_PATH" \
        -boot d \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -vnc :0
else
    # Normal boot mode - disk usage more than 5GB
    echo "Starting from installed system..."
    echo "You can connect to the VM using VNC viewer at localhost:5900"
    exec qemu-system-x86_64 \
        -m 4096 \
        $ACCEL_FLAGS \
        -smp 2 \
        -drive file="$HDD_PATH",format=qcow2 \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -vnc :0
fi
