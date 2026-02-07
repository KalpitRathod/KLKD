# Day 1 – Kernel Fundamentals

## Goal of the Day

Understand what the Linux kernel is, how it differs from user space, how the kernel is structured, and prove it hands-on using real commands.

---

## 1. Theory (Concepts to Understand)

### Kernel vs User Space

#### Kernel Space

- Runs in **Ring 0** (highest privilege).
- Manages:
  - Process scheduling
  - Memory
  - Hardware drivers
  - System calls

#### User Space

- Runs in **Ring 3** (lowest privilege).
- Applications like: `bash`, `gcc`, `vim`, `chrome`.
- **Cannot** access hardware directly.

> **Key Idea:** User programs request services → kernel executes safely.

### Linux Kernel Architecture

Understand this mental model:

```
User Space
├─ Applications (bash, gcc)
└─ Libraries (glibc)
      ↓ system calls
Kernel Space
├─ Scheduler
├─ Memory Manager
├─ VFS
├─ Networking Stack
└─ Device Drivers
      ↓
Hardware
```

#### Important Architecture Components

- **Monolithic Kernel (Linux)**: The entire OS runs in a single address space.
- **Loadable Kernel Modules (LKM)**: Drivers can be loaded/unloaded at runtime.
- **System Call Interface**: The bridge between user space and kernel space.

---

## 2. Reading (Mandatory)

📂 **From kernel source:**

- `linux/Documentation/`
- `linux/Documentation/core-api/`
- `linux/Documentation/process/`

📂 **For drivers:**

- `linux/drivers/`
- `linux/drivers/char/`
- `linux/drivers/block/`

> **Note:** Don’t read everything — scan structure, filenames, comments.

---

## 3. Hands-On (This Is the Core)

### A. Verify Kernel vs User Space

```bash
uname -a        # Kernel info
ps aux | head   # User-space processes
ls /proc        # Kernel interface
```

Check CPU rings indirectly:

```bash
cat /proc/cpuinfo
```

### B. Kernel Messages (Kernel talking to you)

View the kernel ring buffer:

```bash
dmesg | less
```

Filter messages:

```bash
dmesg | grep usb
dmesg | grep kernel
```

> **Key Learning:** Kernel logs ≠ normal logs. They live in kernel memory.

### C. Your First Kernel Module (Hello Kernel)

1.  Create a file `hello.c`:

    ```c
    #include <linux/module.h>
    #include <linux/kernel.h>

    static int __init hello_init(void)
    {
        printk(KERN_INFO "Hello from the Linux Kernel!\n");
        return 0;
    }

    static void __exit hello_exit(void)
    {
        printk(KERN_INFO "Goodbye from the Linux Kernel!\n");
    }

    module_init(hello_init);
    module_exit(hello_exit);

    MODULE_LICENSE("GPL");
    MODULE_AUTHOR("Kalpit");
    MODULE_DESCRIPTION("Day 1 Hello Kernel Module");
    ```

2.  Create a `Makefile`:

    ```makefile
    obj-m += hello.o

    all:
    	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

    clean:
    	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
    ```

3.  Build the module:

    ```bash
    make
    ```

4.  Load the module:

    ```bash
    sudo insmod hello.ko
    ```

5.  Check kernel log:

    ```bash
    dmesg | tail
    ```

6.  Unload the module:
    ```bash
    sudo rmmod hello
    dmesg | tail
    ```

> 🔥 **This is the exact moment you cross into kernel space.**

---

## 4. Git Basics (Kernel Dev Essential)

Check status and logs:

```bash
git status
git log --oneline --max-count=5
```

Inside kernel tree:

```bash
git describe
git branch
```

**Understand:**

- Kernel dev = patches
- Git is **not** optional

---

## 5. Day-1 Checklist (You’re Done If You Can Do This)

- [ ] Explain kernel vs user space in your own words
- [ ] Locate `Documentation/` and `drivers/`
- [ ] Use `dmesg` confidently
- [ ] Load & unload a kernel module
- [ ] See your own `printk()` output
- [ ] Understand why `sudo` is required

---

## What Comes on Day 2 (Teaser 👀)

- Kernel build process
- `vmlinux`, `bzImage`
- `init`, `initramfs`
- Boot flow (BIOS → kernel → user space)
