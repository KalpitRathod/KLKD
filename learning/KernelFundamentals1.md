Day 1 – Kernel Fundamentals
Goal of the Day

Understand what the Linux kernel is, how it differs from user space, how the kernel is structured, and prove it hands-on using real commands.

1. Theory (Concepts to Understand)
   Kernel vs User Space

Kernel Space

Runs in ring 0 (highest privilege)

Manages:

Process scheduling

Memory

Hardware drivers

System calls

User Space

Runs in ring 3

Applications like:

bash, gcc, vim, chrome

Cannot access hardware directly

👉 Key idea:
User programs request services → kernel executes safely.

Linux Kernel Architecture

Understand this mental model:

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

Important architecture components:

Monolithic kernel (Linux)

Loadable Kernel Modules (LKM)

System call interface

2. Reading (Mandatory)

📂 From kernel source:

linux/Documentation/
linux/Documentation/core-api/
linux/Documentation/process/

📂 For drivers:

linux/drivers/
linux/drivers/char/
linux/drivers/block/

Don’t read everything — scan structure, filenames, comments.

3. Hands-On (This Is the Core)
   A. Verify Kernel vs User Space
   uname -a # Kernel info
   ps aux | head # User-space processes
   ls /proc # Kernel interface

Check CPU rings indirectly:

cat /proc/cpuinfo

B. Kernel Messages (Kernel talking to you)
dmesg | less

Filter messages:

dmesg | grep usb
dmesg | grep kernel

👉 Key learning:
Kernel logs ≠ normal logs. They live in kernel memory.

C. Your First Kernel Module (Hello Kernel)

Create a file:

nano hello.c

#include <linux/module.h>
#include <linux/kernel.h>

static int \_\_init hello_init(void)
{
printk(KERN_INFO "Hello from the Linux Kernel!\n");
return 0;
}

static void \_\_exit hello_exit(void)
{
printk(KERN_INFO "Goodbye from the Linux Kernel!\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Kalpit");
MODULE_DESCRIPTION("Day 1 Hello Kernel Module");

Create Makefile:

obj-m += hello.o

all:
make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

Build:

make

Load module:

sudo insmod hello.ko

Check kernel log:

dmesg | tail

Unload:

sudo rmmod hello
dmesg | tail

🔥 This is the exact moment you cross into kernel space.

4. Git Basics (Kernel Dev Essential)
   git status
   git log --oneline --max-count=5

Inside kernel tree:

git describe
git branch

Understand:

Kernel dev = patches

Git is not optional

5. Day-1 Checklist (You’re Done If You Can Do This)

✅ Explain kernel vs user space in your own words
✅ Locate Documentation/ and drivers/
✅ Use dmesg confidently
✅ Load & unload a kernel module
✅ See your own printk() output
✅ Understand why sudo is required

What Comes on Day 2 (Teaser 👀)

Kernel build process

vmlinux, bzImage

init, initramfs

Boot flow (BIOS → kernel → user space)
