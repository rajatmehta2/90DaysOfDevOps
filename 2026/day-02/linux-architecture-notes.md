🐧 Day 02: Linux Architecture, Processes, and systemd

  🎯 1. Overview & Intent
      
      🧠 Core Objective: To understand how Linux operates under the hood, forming the essential architectural foundation required for high-level DevOps troubleshooting, resource optimization, and incident management.
      💼 Professional Context: As an IT professional, mastering Linux internals is the key to confidently debugging crashed services, resolving CPU/memory bottlenecks, and managing production workloads.
      ⏱️ Commitment: Keeping notes practical, actionable, and structured for quick reference during live production incidents.

  🏗️ 2. The Core Components of Linux
      
      💻 Kernel: The core of the OS that directly interacts with the underlying hardware, managing memory, CPU schedules, and device drivers.
      👥 User Space: The protected memory area where user applications, tools, and CLI commands execute, completely isolated from hardware access.
      🔄 Init / systemd: The very first process (`PID 1`) started by the kernel during boot. It acts as the parent of all other processes and initializes the user space components.

  🔄 3. Process Creation & Management
      
      🚦 Process States
          🟢 Running / Runnable (R): The process is either currently actively utilizing the CPU or waiting in the execution queue to be processed.
          💤 Sleeping (S / D):
                Interruptible (S): Waiting for an event or signal to wake up.
                Uninterruptible (D): Deep sleep, usually waiting directly for Hardware/IO operations.
          🛑 Stopped (T): The process has been suspended or paused by a specific operational signal (e.g., `Ctrl+Z`).
          🧟 Zombie (Z): A completed process that has terminated, but its entry remains in the process table because the parent process hasn't read its exit status yet.

  ⚙️ 4. What is systemd & Why It Matters
      
      🏗️ Service Manager: `systemd` is the modern init system used to bootstrap the user space and aggressively manage system services, daemons, and dependencies.
      🚀 Parallel Initialization: It speeds up system boot times significantly by starting independent services concurrently in parallel.
      🛠️ Reliability: It acts as a safety net, actively monitoring system daemons and automatically restarting them if they crash during production uptime.

  🛠️ 5. Daily Essential Linux Commands

      Command: ps aux
      Description & DevOps Use Case: View a snapshot of all active processes currently running across the entire system.

      Command: top
      Description & DevOps Use Case: Monitor real-time system resource consumption (CPU, Memory, uptime, Tasks).

      Command: systemctl status <service>
      Description & DevOps Use Case: Check the current health, operational status, and runtime logs of a specific managed daemon.

      Command: systemctl restart <service>
      Description & DevOps Use Case: Safely restart a crashed or updated service to apply new backend configurations.

      Command: journalctl -xe
      Description & DevOps Use Case: View deep, detailed kernel and systemd logs to quickly diagnose failing infrastructure components.

  📜 6. Execution Commitment
    
    "Understanding the operating system under the hood eliminates guesswork during production incidents."
