Date: 20 May 2026

🐧 Day 04: Linux Practice — Processes and Services

  🏔️ 1. Core Milestones (Executed Commands Log)

    📈 Process Checks
      
      🔍 Command 1: ps aux | grep docker
      Detailed Explanation: This command dumps a snapshot of every running process on the system (ps aux) and pipes the output into grep to filter out lines matching "docker". It allows me to confirm if the primary Docker daemon engine is actively consuming memory or CPU in user space.
      Expected Output Pattern: Shows details like root, PID, %CPU, %MEM, VSZ, RSS, and the command path /usr/bin/dockerd.

      ⚡ Command 2: pgrep -l dockerd
      Detailed Explanation: Looks up the specific Process ID (PID) belonging to the named daemon process (dockerd) and lists it alongside the process name (-l). It provides a clean, automated way to verify process existence without processing huge system-wide data streams.
      Expected Output Pattern: 1422 dockerd

    ⚙️ Service Checks
      
      🏥 Command 3: systemctl status docker
      Detailed Explanation: Queries systemd (the main system initialization daemon) to inspect the precise configuration status, runtime state, memory footprint, and recent log snippets of the docker.service unit.
      Expected Output Pattern: Displays Active: active (running) in green text along with the main PID, task counts, and system group ownership metadata.

      📋 Command 4: systemctl list-units --type=service --state=active
      Detailed Explanation: Queries the system manager to list all dynamically active application units filtered strictly by the service type. This is vital to understand what other background dependencies are running alongside our target infrastructure.
      Expected Output Pattern: A clean table layout displaying columns for UNIT, LOAD, ACTIVE, SUB, and a short description of each active system service daemon.

    📑 Log Checks
      
      🗃️ Command 5: journalctl -u docker -n 50 --no-pager
      Detailed Explanation: Queries the centralized systemd journal logs, filtering strictly for logs produced by the docker unit (-u docker). It fetches exactly the most recent 50 lines (-n 50) and dumps them directly to the screen without forcing interactive terminal paging mode (--no-pager).
      Expected Output Pattern: Timestamps followed by the hostname, dockerd[PID], and runtime logs mapping bridge network allocations or container layer initializations.

      📊 Command 6: tail -n 50 /var/log/syslog
      Detailed Explanation: Streams exactly the last 50 lines from the global operating system system log file (/var/log/syslog). This helps correlate internal Docker subsystem errors with broader operating system changes, kernel alerts, or resource starvation issues.
      Expected Output Pattern: General OS system logs, cron tasks, auth events, and overlapping daemon resource allocations.

  🛠️ 2. Mini Troubleshooting Steps
  
    When tracking down an unhealthly application or an unexpected service failure, I use this explicit triage routine:
      1. 📌 Step 1 (Process Evaluation): Check if the process table entry exists using pgrep or ps aux. If the process is absent or stuck in a Zombie/Uninterruptible state, the application engine has broken down completely.
      2. 📌 Step 2 (Service Lifecycle Verification): Run systemctl status to evaluate the exit code or check if systemd is caught in an infinite crash-restart loop. 
      3. 📌 Step 3 (Log Deep-Dive Analysis): Isolate the root cause by querying journalctl -u and trailing the system logs to identify explicit infrastructure errors (e.g., storage exhaustion, bad configs, permission blocks).
      4. 📌 Step 4 (Remediation & Recovery): Adjust configurations, verify system constraints, and use systemctl restart to cleanly restore container workloads and application availability.

  📜 3. Execution Commitment
    
    "Discipline, ownership, and consistency outweigh perfection. Hands-on practice builds absolute terminal confidence."
