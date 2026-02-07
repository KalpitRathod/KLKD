#!/bin/bash

# Get the absolute path to the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

KERNEL="$SCRIPT_DIR/linux/arch/x86/boot/bzImage"
INITRAMFS="$SCRIPT_DIR/initramfs.cpio.gz"

if [ ! -f "$KERNEL" ]; then
    echo "Error: Kernel image not found at $KERNEL"
    exit 1
fi

if [ ! -f "$INITRAMFS" ]; then
    echo "Error: Initramfs not found at $INITRAMFS"
    exit 1
fi

echo "Booting Kernel with QEMU..."
qemu-system-x86_64 \
    -kernel "$KERNEL" \
    -initrd "$INITRAMFS" \
    -enable-kvm \
    -nographic \
    -append "console=ttyS0 quiet" \
    -m 512M
