Date: 19 May 2026

📌 Day 03: Linux Commands Practice & Cheat Sheet
  
    This is a production-grade Linux command toolkit optimized for fast scanning, real-world troubleshooting, and infrastructure operations. It is grouped logically by operational categories to help quickly reduce downtime during live incidents.

  ⚙️ 1. Process Management & System Metrics
  
    Use these commands to monitor system health, track resource consumption, and manage runaway processes.

        top — Displays real-time, interactive system resource usage, CPU/memory consumption, and active processes.
        
        ps aux — Generates a comprehensive snapshot of all currently running processes across the system for all users.
        
        kill -9 <PID> — Forcefully terminates a stubborn process immediately by sending the `SIGKILL` signal using its Process ID.
        
        pkill <process_name> — Kills running processes by matching their specific names instead of searching for the numeric PID.
        
        df -h — Displays disk space usage across all mounted filesystems in a human-readable format (GB/MB).
        
        du -sh * — Shows the summarized, total disk space calculation for each file and directory in the current path.
        
        free -m — Checks total, used, and available system physical RAM and Swap memory memory allocated in Megabytes.
        
        uptime — Provides a quick check of how long the system has been running, active user counts, and system load averages.

  📂 2. File System, Directory Navigation & Log Analysis
  
    Essential commands for moving through directories, manipulating configurations, and parsing through heavy infrastructure logs.

        pwd — Prints the absolute path of the current working directory from the root.
        
        ls -la — Lists all files and subdirectories in long-format, including hidden files, permissions, owners, and sizes.
        
        mkdir -p /path/to/dir — Creates a new directory along with any required nested parent directories if they do not exist.
        
        cp -r <source> <destination> — Copies files or entire directories recursively from a source location to a destination path.
        
        mv <source> <destination> — Moves or renames files and directories from one path location to another.
        
        rm -rf <path> — Recursively and forcefully deletes directories and files without prompting for user confirmation. (Use with caution).
        
        chmod 755 <file> — Modifies file permissions so the owner can read/write/execute, while groups and others can only read/execute.
        
        chown user:group <file> — Changes both the user and group ownership permissions for a specific file or directory.
        
        grep -i "error" app.log — Searches for the case-insensitive string "error" inside a specific application log file.
        
        tail -f /var/log/nginx/access.log — Streams and views real-time, appending log data live as requests hit the server.
        
        head -n 20 config.yaml — Prints exactly the first 20 lines of a configuration file to inspect headers or setup blocks.
        
        cat /etc/os-release — Concatenates and prints the full contents of the file to verify the exact Linux distribution and version.

  🔌 3. Networking & Infrastructure Troubleshooting
    
    Critical networking utilities used to verify connectivity, map ports, test DNS resolution, and query cloud API endpoints.

        ping -c 4 8.8.8.8 — Sends exactly 4 ICMP echo request packets to a specific IP to verify basic network-level reachability.
        
        ip addr show — Displays all active network interfaces, loopback configurations, and assigned IPv4/IPv6 addresses on the host.
        
        dig google.com — Performs detailed DNS lookups to query domain records (A, MX, CNAME) and verify domain name resolution.
        
        curl -I https://example.com — Fetches only the HTTP response headers from an endpoint to verify status codes (e.g., 200 OK, 404).
        
        netstat -tuln — Lists all active, listening TCP and UDP network ports along with their corresponding numerical addresses.

  📜 4. Operational Commitment
  
    "Real production issues are resolved at the command line. The faster you can inspect logs and network issues, the faster you restore services."
