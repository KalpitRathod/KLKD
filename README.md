# KLKD (Kalpit's Linux Kernel Development)

My specialized kernel development lab on Debian.

## Environment Status

- **OS**: Debian 13 (Trixie)
- **Kernel Source**: Stable Repo (Mainline/Master)
- **Rootfs**: BusyBox (static, minimal)
- **Emulator**: QEMU (x86_64)

## Directory Structure

- `linux/`: Kernel source code
- `busybox/`: BusyBox source code
- `rootfs/`: Staging directory for initramfs
- `scripts/`: Helper scripts (if any)
- `output/`: Build artifacts
- `run_qemu.sh`: Script to boot the custom kernel

## Quick Start

1.  **Build Kernel**:
    ```bash
    cd linux
    make defconfig
    make -j$(nproc)
    ```
2.  **Rebuild Rootfs** (if needed):
    ```bash
    # (Already automated in setup, but if you change BusyBox config)
    cd busybox
    make -j$(nproc)
    make install
    cp -a _install/* ../rootfs/
    # Re-pack cpio
    cd ../rootfs
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
    ```
3.  **Run QEMU**:
    ```bash
    ./run_qemu.sh
    ```

## Learning Roadmap Status

[Excel Link](https://1drv.ms/x/c/5fc11ebe42bb59a8/IQDpwQhR0EnEQJeXpBbggF2SAXl3q4efD4m2TKfLtJNlRHE?e=bBzYfl&nav=MTVfezAwMDAwMDAwLTAwMDEtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMH0)
