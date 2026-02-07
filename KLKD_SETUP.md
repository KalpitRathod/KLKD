# KLKD Lab Setup - Step-by-Step Guide

This document details the exact steps and commands used to set up the **Kalpit's Linux Kernel Development (KLKD)** environment on Debian 13 (Trixie).

## 1. Environment Analysis & Dependencies

First, we verified the OS version and installed the necessary build tools and dependencies.

**Commands:**

```bash
# Check OS version
cat /etc/debian_version
uname -a

# Install Build Dependencies
sudo apt update
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev \
    libelf-dev qemu-system-x86 dwarves bc rsync git
```

## 2. Directory Structure

We created a dedicated directory structure to keep the environment organized.

**Commands:**

```bash
# Create main project directories
mkdir -p /media/kalpit/DRIVE1/Code/KLKD
cd /media/kalpit/DRIVE1/Code/KLKD
mkdir -p linux busybox rootfs scripts output
```

## 3. Kernel Source Setup

We cloned the **Stable** Linux kernel source code.

**Commands:**

```bash
# Clone the stable Linux kernel repository (default branch, typically mainline/master)
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git linux
```

## 4. Root Filesystem Setup (BusyBox)

We used BusyBox to create a minimal, static user space.

**Commands:**

```bash
# Clone BusyBox
git clone --depth 1 https://git.busybox.net/busybox busybox

# Configure BusyBox
cd busybox
make defconfig

# Force Static Linking (Crucial for initramfs to work without external libs)
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
# Disable TC (Traffic Control) to avoid build errors with modern GCC
sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' .config

# Build and Install
make oldconfig
make -j$(nproc)
make install

# Copy built binaries to our staging area (rootfs)
# Note: Since we are running commands from the root KLKD dir:
cp -a busybox/_install/* rootfs/
```

## 5. Initramfs Creation

We created the directory structure for the root filesystem and a custom init script.

**Commands:**

```bash
# Create standard directories
mkdir -p rootfs/bin rootfs/sbin rootfs/etc rootfs/proc rootfs/sys rootfs/usr/bin rootfs/usr/sbin

# Create the /init script
cat <<EOF > rootfs/init
#!/bin/sh

# Mount minimal filesystems
mount -t proc none /proc
mount -t sysfs none /sys

# Welcome message
echo "-----------------------------------"
echo "Welcome to KLKD (Kalpit's Linux Kernel Dev) Lab!"
echo "Kernel: \$(uname -r)"
echo "-----------------------------------"

# Drop to a shell with job control and auto-restart
while true; do
    setsid cttyhack /bin/sh
    echo "Shell exited! Restarting..."
done

# Fallback
poweroff -f
EOF

# Make it executable
chmod +x rootfs/init

# Package into a CPIO archive (Initramfs)
cd rootfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..
```

## 6. QEMU Emulation Script

We created a helper script to easily boot the custom kernel with QEMU.

**Commands:**

```bash
# Create run_qemu.sh
cat <<EOF > run_qemu.sh
#!/bin/bash

# Get the absolute path to the directory containing this script
SCRIPT_DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

KERNEL="\$SCRIPT_DIR/linux/arch/x86/boot/bzImage"
INITRAMFS="\$SCRIPT_DIR/initramfs.cpio.gz"

if [ ! -f "\$KERNEL" ]; then
    echo "Error: Kernel image not found at \$KERNEL"
    exit 1
fi

if [ ! -f "\$INITRAMFS" ]; then
    echo "Error: Initramfs not found at \$INITRAMFS"
    exit 1
fi

echo "Booting Kernel with QEMU..."
qemu-system-x86_64 \\
    -kernel "\$KERNEL" \\
    -initrd "\$INITRAMFS" \\
    -enable-kvm \\
    -nographic \\
    -append "console=ttyS0 quiet" \\
    -m 512M
EOF

# Make executable
chmod +x run_qemu.sh
```

## 7. How to Use

To verify everything is working, you just need to:

1.  **Build the Kernel**:
    ```bash
    cd linux
    make defconfig
    make -j$(nproc)
    ```
2.  **Run**:

    ```bash
    ./run_qemu.sh

    ```

## 8. Tips

### Exiting QEMU

Since we use `-nographic`, QEMU captures your terminal. To exit:

1.  Press `Ctrl-a` (release both).
2.  Press `x`.

### Kernel Panic - "Attempted to kill init!"

If the `init` process exits, the kernel panics. Ensure your `rootfs/init` loops or calls `poweroff`.
