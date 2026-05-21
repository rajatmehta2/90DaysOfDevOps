Date: 23 May 2026

🐧 Day 07: Linux File System Hierarchy & Scenario-Based Practice

Part 1: Linux File System Hierarchy

--------------------------------------------------------------------------------------------------------------------------------------------

  Core Directories (Must Know):

    1. / (root) - The top-level directory of the entire Linux filesystem hierarchy. Every single file, directory, and mounted device starts here.

<img width="335" height="120" alt="Screenshot 2026-05-21 at 1 16 50 PM" src="https://github.com/user-attachments/assets/02f5aebf-1343-461b-8768-a8af35cc50cd" />

I would use this when I need to navigate to the absolute base of the system to locate top-level directories like /etc or /var.


    2. /home - The personal directories for all non-root, standard users to store documents, keys, and personal configurations.

<img width="480" height="119" alt="Screenshot 2026-05-21 at 1 48 04 PM" src="https://github.com/user-attachments/assets/05aa5a68-1c4c-4ffe-a8f1-be7cebe26bb8" />

I would use this when I need to deploy user-specific SSH keys, check developer application files, or modify a specific user's .bashrc profile.


    3. /root - The dedicated, protected home directory for the superuser (root account).

<img width="551" height="89" alt="Screenshot 2026-05-21 at 1 49 51 PM" src="https://github.com/user-attachments/assets/982c5c46-af63-4085-9c97-7e9e077934a8" />

I would use this when I am logged in as root and need to store scripts or configuration keys meant exclusively for system administrator execution.


    4. /etc - System-wide configuration files and startup scripts for applications and core services.

<img width="495" height="204" alt="Screenshot 2026-05-21 at 1 51 11 PM" src="https://github.com/user-attachments/assets/5724414f-edb2-4770-9f5b-f0719e25240f" />

I would use this when I need to configure Nginx host files, modify server hostnames, or tweak network interface properties.


    5. /var/log - The central repository for all system, kernel, and package execution log files.

<img width="512" height="200" alt="Screenshot 2026-05-21 at 1 52 23 PM" src="https://github.com/user-attachments/assets/2ad07825-5854-4f61-8488-0579c8dc5a60" />

I would use this when An application drops or breaks, and I need to parse the runtime logs to diagnose what caused the failure.


    6. /tmp - Volatile, temporary files created by applications or system processes that are wiped clean upon machine reboot.

<img width="307" height="88" alt="Screenshot 2026-05-21 at 1 53 28 PM" src="https://github.com/user-attachments/assets/6b5ed323-db3f-4b6a-9999-fad0b3b59224" />

I would use this when I am running a quick testing script, extracting a compressed archive temporarily, or staging raw files before installation.

--------------------------------------------------------------------------------------------------------------------------------------------

  Additional Directories (Good to Know):

    1. /bin - Essential command binaries required for system booting and single-user recovery operations (often symlinked to /usr/bin).

<img width="477" height="92" alt="Screenshot 2026-05-21 at 1 54 59 PM" src="https://github.com/user-attachments/assets/97bb3842-92d2-4532-9523-74743b741c0d" />

I would use this when Running primary, day-to-day command line utilities like ls, cp, or cat.


    2. /usr/bin - The vast majority of standard executable programs and binaries intended for general users after the OS boots.

<img width="479" height="155" alt="Screenshot 2026-05-21 at 1 57 28 PM" src="https://github.com/user-attachments/assets/822a8f96-7151-43f3-90d5-37859f1fbfeb" />

I would use this when Utilizing day-to-day administrative tools such as curl, git, or python3.


    3. /opt - Add-on, third-party software packages that don't follow the native package manager file system conventions.

<img width="303" height="90" alt="Screenshot 2026-05-21 at 1 57 58 PM" src="https://github.com/user-attachments/assets/9a4bfb58-5178-4699-ad81-faed736f9449" />

I would use this when Installing stand-alone enterprise applications like Datadog agents, AWS CLI tools, or proprietary databases.

--------------------------------------------------------------------------------------------------------------------------------------------

  Hands-on task:

  1. Find the largest log file in /var/log

          du -sh /var/log/* 2>/dev/null | sort -h | tail -5

<img width="606" height="203" alt="Screenshot 2026-05-21 at 2 02 20 PM" src="https://github.com/user-attachments/assets/47a96b0f-4a9d-4870-afbb-df53f8537b00" />

  2. Look at a config file in /etc

          cat /etc/hostname

<img width="349" height="90" alt="Screenshot 2026-05-21 at 2 02 49 PM" src="https://github.com/user-attachments/assets/a88e0562-40a9-4b1a-bc0e-89a970470b4d" />

  3. Check your home directory

          ls -la ~

<img width="530" height="261" alt="Screenshot 2026-05-21 at 2 03 22 PM" src="https://github.com/user-attachments/assets/3bc39392-e330-4ed4-b25f-7027b1e80555" />

--------------------------------------------------------------------------------------------------------------------------------------------

Part 2: Scenario-Based Practice

--------------------------------------------------------------------------------------------------------------------------------------------

  Scenario 1: Service Not Starting

Step 1: Check service status
    
    Command: systemctl status nginx

<img width="1393" height="524" alt="Screenshot 2026-05-21 at 2 28 38 PM" src="https://github.com/user-attachments/assets/3d0b2fcd-ea45-44de-bd9e-616f71959d3d" />

    Why: This shows the immediate state of the service (active, dead, or crashed) and pulls the last few error trace strings from systemd.

Step 2: Check latest 50 logs

    Command: journalctl -u nginx -n 50 --no-pager

<img width="1377" height="236" alt="Screenshot 2026-05-21 at 2 32 24 PM" src="https://github.com/user-attachments/assets/d03b608c-15f3-46de-929d-6176718446b1" />

    Why: This pulls the last 50 detailed log messages specific to the application unit, revealing code syntax bugs or database connection drop errors.

Step 3: Check if service is enabled on boot

    Command: systemctl is-enabled nginx

<img width="663" height="68" alt="Screenshot 2026-05-21 at 2 33 31 PM" src="https://github.com/user-attachments/assets/134134b7-e987-461e-a7d5-88285c1f7f21" />

    Why: This verifies whether the system is set to automatically start this process upon server initialization.

--------------------------------------------------------------------------------------------------------------------------------------------

  Scenario 2: High CPU Usage

    1. Run top or htop to visualize continuous system resource consumption.

    top

<img width="1170" height="358" alt="Screenshot 2026-05-21 at 2 37 06 PM" src="https://github.com/user-attachments/assets/1de164b8-9683-4a1a-badd-96ba317f65ef" />

    htop

<img width="1179" height="743" alt="Screenshot 2026-05-21 at 2 37 35 PM" src="https://github.com/user-attachments/assets/8d05ec57-9992-406f-8f97-a617bfce5919" />

    2. In top, press P to automatically sort your active processes by descending CPU usage percentage.

    3. To view an instant snapshot without interactive navigation, run this below command:

<img width="734" height="203" alt="Screenshot 2026-05-21 at 2 36 25 PM" src="https://github.com/user-attachments/assets/7c964778-0423-49f5-acf5-4f7b55090147" />

--------------------------------------------------------------------------------------------------------------------------------------------

  Scenario 3: Finding Service Logs

Step 1: Status View

    Command: systemctl status docker
    
<img width="1435" height="463" alt="Screenshot 2026-05-21 at 2 39 29 PM" src="https://github.com/user-attachments/assets/e0914fe8-3fc3-4cf7-bef9-f6e5f34391a7" />

    Why: Provides an operational summary along with file descriptors and the most recent logging outputs.

Step 2: Historical Investigation

    Command: journalctl -u docker -n 50

<img width="1427" height="237" alt="Screenshot 2026-05-21 at 2 40 42 PM" src="https://github.com/user-attachments/assets/72df02b8-0dae-4a52-90ae-d4874779b6f6" />

    Why: Displays exactly 50 log records from the journald index for faster analysis.

Step 3: Live Streaming Debugging

    Command: journalctl -u docker -f

<img width="1429" height="319" alt="Screenshot 2026-05-21 at 2 41 26 PM" src="https://github.com/user-attachments/assets/2855bc97-971f-4fbd-ad7b-b8301e3f4b04" />

    Why: This mirrors standard tail -f mechanics, streaming runtime warnings directly onto your terminal shell as they trigger.

--------------------------------------------------------------------------------------------------------------------------------------------

  Scenario 4: File Permissions Issue

Step 1: Check current permissions

    Command: ls -l /home/user/backup.sh

<img width="514" height="182" alt="Screenshot 2026-05-21 at 2 43 16 PM" src="https://github.com/user-attachments/assets/c6c2d122-33a2-4d0b-bcec-15dae5029614" />

    Why: Notice that the string reads -rw-r--r--. There is no execution (x) flag present across user, group, or global permissions matrices.

Step 2: Add execute permission

    Command: chmod +x /home/user/backup.sh

<img width="517" height="175" alt="Screenshot 2026-05-21 at 2 44 09 PM" src="https://github.com/user-attachments/assets/26d82228-48b8-4737-a9c7-38e5ad01a7b1" />

Step 3: Verify execution matrix updates

    Command: ls -l /home/user/backup.sh

<img width="523" height="152" alt="Screenshot 2026-05-21 at 2 44 36 PM" src="https://github.com/user-attachments/assets/3bcaf02c-e6ca-4e03-b6d0-d7a7dca7874a" />

    Why: The flag successfully transformed to -rwxr-xr-x. The file is now executable.

Step 4: Execute the script safely

    Command: ./backup.sh
