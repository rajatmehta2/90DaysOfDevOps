# 🌐 Day 08: Cloud Server Setup — Docker, Nginx & Web Deployment

> **"In modern cloud architectures, the ability to deploy, secure, and monitor high-performance web servers on-demand is a baseline DevOps super-power. Whether you're standing up standard host instances, configuring firewalls and ingress points, or extracting and transport-routing server log telemetry, mastering cloud server configuration separates local-machine developers from professional DevOps engineers."**

Welcome to Day 08 of the **90 Days of DevOps** challenge! Today's goal is to provision a live cloud virtual machine, establish a secure SSH connection, configure a security firewall (Security Groups) to expose Nginx over HTTP port 80, install container engines (Docker) alongside traditional web services, and capture real-time request logs for remote diagnostics.

---

## 📋 Practice Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Cloud Infrastructure Provisioning & Web Server Deployment |
| **Cloud Provider** | AWS EC2 (t3.micro - Free Tier) |
| **Operating System** | Ubuntu Server 22.04 LTS |
| **Web Server / Services** | Nginx Web Server, Docker Engine |
| **Diagnostics & Tools** | SSH, SCP, Systemctl, Tail, Chmod |
| **Practice Date** | May 24, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-08/` |

---

## 🗺️ Cloud Deployment & Network Architecture Flowchart

The following flowchart maps out the networking pathway, security boundaries, and logging pipelines configured during today's session:

```mermaid
flowchart TD
    Client[Local Client Terminal / Web Browser] -->|HTTP Port 80| Internet((Internet))
    Internet -->|Traffic Filtering| SG{AWS Security Group}
    SG -->|Blocked| Drop[Connection Timeout]
    SG -->|Allowed HTTP on Port 80| EC2[AWS EC2 Instance (Ubuntu 22.04)]
    
    subgraph EC2 Instance
        SSH[SSH Daemon Port 22]
        Nginx[Nginx Web Server]
        Docker[Docker Engine]
        
        Nginx -->|Generates logs| LogFile[/var/log/nginx/access.log]
    end
    
    Client -->|SSH Port 22 with .pem Key| SSH
    LogFile -->|tail -n 50| HomeLog[~/nginx-logs.txt]
    HomeLog -->|scp download| Client
```

---

## 📑 Table of Contents
1. [☁️ Part 1: Launch Cloud Instance & SSH Access](#-part-1-launch-cloud-instance--ssh-access)
   - [Step 1: Create a Cloud Instance](#step-1-create-a-cloud-instance)
   - [Step 2: Connect via SSH](#step-2-connect-via-ssh)
2. [📦 Part 2: Install Docker & Nginx](#-part-2-install-docker--nginx)
   - [Step 1: Update System Package Repositories](#step-1-update-system-package-repositories)
   - [Step 2: Install and Enable Docker Engine](#step-2-install-and-enable-docker-engine)
   - [Step 3: Install Nginx Web Server](#step-3-install-nginx-web-server)
   - [Step 4: Verify Service Statuses](#step-4-verify-service-statuses)
3. [🛡️ Part 3: Security Group Configuration & Web Access Verification](#-part-3-security-group-configuration--web-access-verification)
   - [Test Web Access & Verify Inbound Traffic](#test-web-access--verify-inbound-traffic)
4. [📜 Part 4: Extract Nginx Logs & Secure Remote Transport](#-part-4-extract-nginx-logs--secure-remote-transport)
   - [Step 1: Stream Real-Time access logs](#step-1-stream-real-time-access-logs)
   - [Step 2: Save Target Logs to Text File](#step-2-save-target-logs-to-text-file)
   - [Step 3: Securely Download Log File to Local Machine](#step-3-securely-download-log-file-to-local-machine)
5. [📊 Day 08 Commands Cheatsheet](#-day-08-commands-cheatsheet)
6. [🛠️ Challenges Faced & Core Resolutions](#️-challenges-faced--core-resolutions)
7. [🧠 What I Learned](#-what-i-learned)
8. [📢 Learn in Public & Community Engagement](#-learn-in-public--community-engagement)

---

## ☁️ Part 1: Launch Cloud Instance & SSH Access

### Step 1: Create a Cloud Instance
We logged into our AWS Console and provisioned a new cloud instance through the Amazon EC2 dashboard:
1. **Name:** `Rajat-Demo-Instance`
2. **OS Image (AMI):** `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type` (Free-tier eligible)
3. **Instance Type:** `t3.micro`
4. **Key Pair:** Created a secure RSA private key named `KEY_FILE_NAME.pem` and downloaded it safely to the local workspace.
5. **Network Settings / Firewalls:**
   - Allowed inbound **SSH (Port 22)** from anywhere (`0.0.0.0/0`) for configuration work.
   - Allowed inbound **HTTP (Port 80)** from anywhere (`0.0.0.0/0`) to accept public web requests.

* **Console Configuration Visuals:**
  <p align="left">
    <img width="1914" height="201" alt="AWS EC2 Launch Form" src="https://github.com/user-attachments/assets/1c8603a0-e970-4172-814a-99b81ce52dc8" />
  </p>
  
  <p align="left">
    <img width="1625" height="261" alt="AWS EC2 Running Instance" src="https://github.com/user-attachments/assets/7502291b-296b-4aee-8913-672795832ff8" />
  </p>

---

### Step 2: Connect via SSH
Open a local terminal, navigate to the directory housing your private key file, and execute connection commands:

1. **Restrict Private Key Access Privileges:**
   ```bash
   chmod 400 KEY_FILE_NAME.pem
   ```
   * **Why:** Open SSH standards refuse keys that are readable by other local accounts to prevent keys from leaking. `400` restricts read access exclusively to the owner.

2. **Establish Remote Terminal Connection:**
   ```bash
   ssh -i "KEY_FILE_NAME.pem" ubuntu@YOUR_INSTANCE_PUBLIC_IP_OR_DNS
   ```
   * **Why:** Directs the SSH client to present the cryptographic private key to authenticate against the user account `ubuntu` hosted on our target EC2 public address.

* **Terminal Connection Output:**
  <p align="left">
    <img width="849" height="580" alt="SSH Connection Terminal" src="https://github.com/user-attachments/assets/03840bc1-61be-4d2a-ae40-652cd07abed5" />
  </p>

---

## 📦 Part 2: Install Docker & Nginx

### Step 1: Update System Package Repositories
Before fetching system services, ensure package repositories are completely up-to-date:
```bash
sudo apt update && sudo apt upgrade -y
```
* **Why:** Instructs the Advanced Package Tool (apt) to check remote sources for the latest package manifests, preventing version mismatches during service provisioning.

---

### Step 2: Install and Enable Docker Engine
Install the underlying containerization engine to host containerized workloads:
```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```
* **Why:** Installs Docker, triggers the background service (daemon), configures the daemon to launch on host startup, and maps our non-root developer user `ubuntu` to the `docker` security group to run container commands without typing `sudo`.

> [!NOTE]
> * **Note on User Privileges:** You must exit your active SSH terminal and log back in, or run the command `newgrp docker` in your current terminal to refresh the security token and activate Docker permissions.

---

### Step 3: Install Nginx Web Server
Provision the traditional high-performance web reverse proxy to serve static index files:
```bash
sudo apt install nginx -y
```
* **Why:** Installs the core Nginx package suite and maps files to `/etc/nginx` and static pages to `/var/www/html`.

* **Package Setup Logs:**
  <p align="left">
    <img width="1908" height="864" alt="Package installation execution" src="https://github.com/user-attachments/assets/eb74d0cb-fe07-4e6b-99c4-4115096aabd4" />
  </p>

---

### Step 4: Verify Service Statuses
Verify both services are operational and running cleanly:

1. **Verify Nginx Status:**
   ```bash
   sudo systemctl status nginx
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="1180" height="460" alt="Nginx systemctl status" src="https://github.com/user-attachments/assets/90c2abb1-026d-41b1-a499-de89c2c07338" />
     </p>

2. **Verify Docker Status & Version:**
   ```bash
   docker --version
   ```
   * **Terminal Verification:**
     <p align="left">
       <img width="336" height="24" alt="Docker version check" src="https://github.com/user-attachments/assets/5a6485b0-fbbc-44e9-8c51-b0dbbe5ccfaa" />
     </p>

---

## 🛡️ Part 3: Security Group Configuration & Web Access Verification

### Test Web Access & Verify Inbound Traffic
To test server accessibility, open a local browser and navigate to the public IP:
`http://<your-instance-ip>`

* **Why:** Standard browsers issue HTTP requests over TCP Port 80. Since we exposed Port 80 in our Security Groups and launched Nginx, the Nginx welcome screen is successfully displayed to the world.

* **Alternative CLI Verification (from local host):**
  ```bash
  curl -I <YOUR_INSTANCE_PUBLIC_IP>
  ```
  * **Why:** Quickly inspects HTTP response headers (e.g. `HTTP/1.1 200 OK` and `Server: nginx/...`) directly in your command shell to isolate network routes from local rendering issues.

* **Browser Web Verification:**
  <p align="left">
    <img width="1086" height="318" alt="Nginx Welcome Page Browser" src="https://github.com/user-attachments/assets/6fd7f821-1d05-4c73-a890-fc35a8af1bcb" />
  </p>

---

## 📜 Part 4: Extract Nginx Logs & Secure Remote Transport

### Step 1: Stream Real-Time access logs
Log into your EC2 terminal and monitor live network requests to Nginx:
```bash
tail -f /var/log/nginx/access.log
```
* **Why:** Real-time log monitoring is vital during deployment debugging. The `-f` flag keeps the stream open, outputting new HTTP access hits immediately as they occur on the web server.

* **Log Stream Visual:**
  <p align="left">
    <img width="1893" height="161" alt="Tail log stdout stream" src="https://github.com/user-attachments/assets/8679dd46-be10-47bc-9ff4-d48a3067885a" />
  </p>

---

### Step 2: Save Target Logs to Text File
Isolate historical logs and save them into a permanent text file inside your home folder:
```bash
sudo tail -n 50 /var/log/nginx/access.log > ~/nginx-logs.txt
cat ~/nginx-logs.txt
```
* **Why:** Captures the last 50 recorded HTTP connections for analysis and dumps them cleanly into a local output file `~/nginx-logs.txt`.

* **Dumping Logs & Verification:**
  <p align="left">
    <img width="1893" height="173" alt="Nginx log dump stdout" src="https://github.com/user-attachments/assets/d5c63c5f-9906-4284-aa40-2faef378fa83" />
  </p>

---

### Step 3: Securely Download Log File to Local Machine
Exiting the remote system, launch a terminal window on your local machine to download the file:
```bash
scp -i KEY_FILE_NAME.pem ubuntu@YOUR_INSTANCE_PUBLIC_IP_OR_DNS:~/nginx-logs.txt .
```
* **Why:** Launches a Secure Copy Protocol (SCP) transaction over SSH. The client uses the SSH cryptographic parameters to authenticate and pull `nginx-logs.txt` from the remote `~/` directory to the local folder.

* **Secure Copy Output:**
  <p align="left">
    <img width="1868" height="203" alt="SCP transfer terminal output" src="https://github.com/user-attachments/assets/df6409e8-325c-47d5-839d-da478375fd56" />
  </p>

---

## 📊 Day 08 Commands Cheatsheet

| Command | Category | Purpose |
| :--- | :--- | :--- |
| `chmod 400 key.pem` | SSH Security | Restricts key file access to owner read-only (critical for SSH) |
| `ssh -i key.pem ubuntu@ip` | SSH Connection | Establishes a secure remote terminal session to the EC2 host |
| `sudo apt update && upgrade` | OS Maintenance | Refreshes apt repos and upgrades running operating system packages |
| `sudo apt install docker.io nginx` | Package Install | Provisions the Docker daemon and Nginx web server packages |
| `sudo systemctl status nginx` | Service Audit | Inspects the active process state and diagnostic log block for Nginx |
| `tail -f /var/log/nginx/access.log` | Monitoring | Streams incoming real-time web browser client request metrics |
| `tail -n 50 [log] > ~/logs.txt` | I/O Redirection | Writes the last 50 web access request events to a localized flat file |
| `scp -i key.pem user@ip:src dest` | Telemetry Transport | Downloads logs over standard SSH secure tunneling protocols |

---

## 🛠️ Challenges Faced & Core Resolutions

### 1. Connection Timeout (Security Group Boundary)
* **Symptom / Problem:** Typing the EC2 Instance Public IP in a local web browser led to an infinite spinning wheel, ending in a connection timeout.
* **Root Cause:** By default, standard AWS Security Group inbound traffic matrices only permit SSH (Port 22). Inbound HTTP traffic (Port 80) was being blocked before it could reach the EC2 networking interface.
* **Resolution:** Logged into AWS Management Console, navigated to EC2 Security Groups, and edited the Inbound Rules to append a rule allowing HTTP on Port `80` from source `0.0.0.0/0` (anywhere). The site loaded instantly.

### 2. Unprotected SSH Private Key File Warning
* **Symptom / Problem:** Connecting to the instance via SSH returned an error stating `UNPROTECTED PRIVATE KEY FILE!` and closed the connection.
* **Root Cause:** OpenSSH requires that key files must be highly restricted. Since the key was downloaded with default file system permissions (`644`), SSH blocked connection to prevent credentials from being read.
* **Resolution:** Ran `chmod 400 KEY_FILE_NAME.pem` to restrict access permissions to owner read-only. Secure terminal connectivity was established immediately after.

---

## 🧠 What I Learned

1. **Cloud Instance Provisioning:** Gained practical understanding of launching, configuring, and maintaining remote server resources (Ubuntu Server 22.04 LTS) inside Amazon AWS.
2. **Security & Firewalls:** Learned to handle and manage cloud network parameters, managing firewalls through Inbound Security Groups to control network ports.
3. **SSH Key Cryptography:** Understood standard key permission states and the practical application of `chmod 400` to secure private credential logs.
4. **Service Daemon Control:** Configured package services (Docker/Nginx) using `systemctl` controls to ensure automatic boots on host restarts.
5. **Log Harvest & Transport:** Mastered reading log streams in real-time (`tail -f`), isolating data blocks (`>`), and securely downloading them over SSH tunnels (`scp`).

---

Day 08 Complete 🚀