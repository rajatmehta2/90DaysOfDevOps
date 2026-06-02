# 🐳 Day 33 – Docker Compose: Multi-Container Basics

> **"Orchestrating microservice architectures by spinning up, network-linking, and volume-binding individual Docker containers via imperative CLI commands is a operational dead-end. It is error-prone, hard to version control, and impossible to scale. Docker Compose completely transforms this operational workflow: using a single, declarative YAML configuration file, it enables you to define, configure, interlink, and scale an entire multi-container service topology—including custom virtual networks, persistent named storage volumes, and isolated environment variables—with a single unified command."**

Welcome to Day 33 of the **90 Days of DevOps** challenge! Yesterday, we manually set up Named Volumes, Bind Mounts, and Custom isolation networks using raw Docker CLI parameters. Today, we are upgrading our operational workflow by migrating to **Docker Compose**, the industry standard for declaring and orchestrating multi-container environments.

We will verify Docker Compose, spin up an isolated Nginx web node in a standalone directory, build a production-grade multi-tier WordPress and MySQL database stack, manage storage persistency seamlessly, investigate Docker Compose's lifecycle commands, and secure credential handling via decoupled `.env` files.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Docker Compose, Declarative Multi-Container Orchestration, YAML Blueprinting, Service Dependencies, Env Variables Isolation |
| **Operating System** | macOS (Darwin Kernel 25.x / Apple Silicon arm64) & Linux overlay Guest |
| **Active GitHub Username** | `rajatmehta2` |
| **Workspace Folder** | `day-33/` |
| **Topics Covered** | Declarative Docker Compose specifications, multi-tier stacks (WordPress + MySQL), environment variables loading via `.env` file, declarative named volumes, service startup dependency checks (`depends_on`), detached-mode operations, and compose lifecycle CLI utilities |
| **Target Document** | [day-33-compose.md](day-33-compose.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-33/` |

---

## 📑 Table of Contents
1. [⚙️ Task 1: Install & Verify Docker Compose](#%EF%B8%8F-task-1-install--verify-docker-compose)
   - [Verifying Dynamic Docker Compose Availability](#verifying-dynamic-docker-compose-availability)
   - [Auditing Docker Daemon Version Layout](#auditing-docker-daemon-version-layout)
2. [📦 Task 2: Your First Compose File: Standalone Nginx Setup](#-task-2-your-first-compose-file-standalone-nginx-setup)
   - [Creating the Basics Sandbox Workspace](#creating-the-basics-sandbox-workspace)
   - [Writing the Declarative Nginx Blueprint](#writing-the-declarative-nginx-blueprint)
   - [Orchestrating the Stack: UP & DOWN Lifecycles](#orchestrating-the-stack-up--down-lifecycles)
3. [🧩 Task 3 & 5: Two-Container Production-Grade Stack with Env Variables](#-task-3--5-two-container-production-grade-stack-with-env-variables)
   - [Securing Credentials via Decoupled Environment Configs](#securing-credentials-via-decoupled-environment-configs)
   - [Architecting the WordPress & MySQL Blueprint](#architecting-the-wordpress--mysql-blueprint)
   - [Executing Compose Configuration Syntactical Validation](#executing-compose-configuration-syntactical-validation)
   - [Booting the Persistent Stack & Image Pull Verification](#booting-the-persistent-stack--image-pull-verification)
   - [Verifying Storage Persistence Across Full Destruction Cycles](#verifying-storage-persistence-across-full-destruction-cycles)
4. [🛠️ Task 4: Docker Compose Operations Deep-Dive](#%EF%B8%8F-task-4-docker-compose-operations-deep-dive)
   - [Viewing Running Stack Topologies](#viewing-running-stack-topologies)
   - [Interrogating Centralized & Service-Specific Logs](#interrogating-centralized--service-specific-logs)
   - [Stopping & Starting Services Without purging Resources](#stopping--starting-services-without-purging-resources)
   - [Purging Stacks and Rebuilding Images](#purging-stacks-and-rebuilding-images)
5. [🏁 Submission & Learn in Public](#-submission--learn-in-public)

---

## ⚙️ Task 1: Install & Verify Docker Compose

In modern Docker distributions, Docker Compose is integrated natively as a CLI plugin (`docker compose`), replacing the legacy Python-based standalone binary (`docker-compose`). Let's verify that Docker Compose is installed, active, and fully configured.

### Verifying Dynamic Docker Compose Availability

We query the active Docker CLI engine to confirm that the `compose` plugin is registered:

```bash
# Check installed Docker Compose plugin version
$ docker compose version
Docker Compose version v5.1.1
```

---

### Auditing Docker Daemon Version Layout

To ensure high-performance execution of multi-container networking overlays on macOS, let's verify our engine architecture details:

```bash
# Check complete client and server daemon specifications
$ docker version
Client:
 Version:           29.3.1
 API version:       1.54
 Go version:        go1.25.8
 Git commit:        c2be9cc
 Built:             Wed Mar 25 16:12:49 2026
 OS/Arch:           darwin/arm64
 Context:           desktop-linux

Server: Docker Desktop 4.67.0 (222858)
 Engine:
  Version:          29.3.1
  API version:      1.54 (minimum version 1.40)
  Go version:       go1.25.8
  Git commit:       f78c987
  Built:            Wed Mar 25 16:14:30 2026
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          v2.2.1
  GitCommit:        dea7da592f5d1d2b7755e3a161be07f43fad8f75
 runc:
  Version:          1.3.4
  GitCommit:        v1.3.4-0-gd6d73eb8
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

> [!NOTE]
> **Silicon Native Architecture:** The `OS/Arch: darwin/arm64` line confirms the engine is running optimized for Apple Silicon (M-series hardware), leveraging arm64 assembly instructions directly for maximum container speed.

---

### 🖼️ Task 1 Verification: Compose Plugin Verification
Below is the CLI capture confirming successful Compose plugin configuration and daemon health audits:

![Task 1 Docker Compose Plugin Version Verification](compose_version_verification.png)

---

## 📦 Task 2: Your First Compose File: Standalone Nginx Setup

Let's start by configuring a basic single-container sandbox stack. This allows us to dissect Compose syntax mechanics—such as service definition blocks, container naming, and port exposure—without database overhead.

### Creating the Basics Sandbox Workspace

We isolate this exercise in a dedicated directory to prevent YAML overlay conflicts:

```bash
# Create and navigate to the basics folder
$ mkdir -p compose-basics
$ cd compose-basics
```

---

### Writing the Declarative Nginx Blueprint

We define our single-container service mapping inside a file named `docker-compose.yml`:

```yaml
services:
  web:
    image: nginx:alpine
    container_name: nginx-compose
    ports:
      - "8080:80"
```

* **`services:`** Tells the Compose engine that the following blocks are distinct, runnable workloads.
* **`web:`** The logical internal name of the service, acting as the internal DNS alias within the default network.
* **`image: nginx:alpine`** Specifies the lightweight Alpine Linux-based Nginx OCI image.
* **`container_name: nginx-compose`** Assigns an explicit, human-readable name to the container process.
* **`ports:`** Mapped as `hostPort:containerPort`. Binds host port `8080` to the container's standard web port `80`.

---

### Orchestrating the Stack: UP & DOWN Lifecycles

We execute `docker compose up` to instruct Docker to construct the default virtual bridge network, pull the target Nginx image if not present locally, configure port routing tables, and launch our web server:

```bash
# Launch Nginx in detached background mode
$ docker compose up -d
 Image nginx:alpine Pulling 
 42394e2ad482 Pulling fs layer 
 a0a8eb1892ac Pulling fs layer 
 ...
 Image nginx:alpine Pulled 
 Network compose-basics_default Creating 
 Network compose-basics_default Created 
 Container nginx-compose Creating 
 Container nginx-compose Created 
 Container nginx-compose Starting 
 Container nginx-compose Started 
```

Let's query the status of our active compose stack:

```bash
# Verify running stack services
$ docker compose ps
NAME            IMAGE          COMMAND                  SERVICE   CREATED         STATUS         PORTS
nginx-compose   nginx:alpine   "/docker-entrypoint.…"   web       6 seconds ago   Up 5 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
```

> [!TIP]
> **Port Mapping Check:** Accessing `http://localhost:8080` from your host web browser will instantly serve the default Nginx Welcome Page!

To clean up our sandbox environment cleanly, we use the `down` utility:

```bash
# Destroy containers, endpoints, and bridges
$ docker compose down
 Container nginx-compose Stopping 
 Container nginx-compose Stopped 
 Container nginx-compose Removing 
 Container nginx-compose Removed 
 Network compose-basics_default Removing 
 Network compose-basics_default Removed 
```

```bash
# Clean workspace state and return to day-33 root folder
$ cd ..
```

---

### 🖼️ Task 2 Verification: Nginx Compose Verification
This terminal diagnostics log captures the automatic bridge network creation, download sequences, and standard execution tests for the Nginx Compose service:

![Task 2 Single Nginx Container Setup via Compose](nginx_compose_success.png)

---

## 🧩 Task 3 & 5: Two-Container Production-Grade Stack with Env Variables

Now, let's build a production-grade multi-tier architecture. We will orchestrate:
1. A stateful **MySQL 8.0 Database service**, utilizing a Docker-managed **Named Volume** for disk persistence.
2. A stateless **WordPress App service**, dynamically linked to MySQL via service names, exposed on host port `8080`.
3. An isolated configuration system separating database passwords using a **decoupled `.env` file**.

---

### Securing Credentials via Decoupled Environment Configs

Hardcoding database passwords inside standard `docker-compose.yml` specs is a massive security vulnerability. We decouple credentials entirely inside a dedicated `.env` file in the root of `day-33/`:

```env
# 🔐 WordPress & MySQL Database Environment Configurations
DB_ROOT_PASSWORD=wp_root_secure_pass_2026
DB_NAME=wordpress_db
DB_USER=wp_db_user
DB_PASSWORD=wp_db_pass_2026
```

---

### Architecting the WordPress & MySQL Blueprint

We write our primary declarative multi-tier configuration in `/Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-33/docker-compose.yml`:

```yaml
services:
  db:
    image: mysql:8.0
    container_name: wp-mysql-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - wp-mysql-data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: wp-app
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
    volumes:
      - wp-app-data:/var/www/html
    depends_on:
      - db

volumes:
  wp-mysql-data:
    name: wp-mysql-data
  wp-app-data:
    name: wp-app-data
```

### Key Production Parameters Analyzed:
* **`${DB_USER}` Syntax:** References variables directly from the `.env` file at boot runtime.
* **`restart: always`** Automatic recovery policy. If a service crashes or the host reboot cycle triggers, Docker will restart the containers automatically.
* **`depends_on:`** Service initialization ordering. Instructs Compose to boot the `db` service first before launching the `wordpress` service.
* **`WORDPRESS_DB_HOST: db:3306`** Highlights the power of custom network DNS. WordPress connects to MySQL securely on port `3306` using only the database service alias `db` instead of a volatile dynamic IP address.
* **`volumes: - wp-mysql-data:/var/lib/mysql`** Attaches a Docker-managed named storage engine directly to the internal MySQL directories, decoupling storage lifecycles from container destruction cycles.

---

### Executing Compose Configuration Syntactical Validation

Let's verify that Docker Compose validates the syntax and successfully binds our `.env` configuration file values:

```bash
# Validate config schema and display compiled settings
$ docker compose config
name: day-33
services:
  db:
    container_name: wp-mysql-db
    environment:
      MYSQL_DATABASE: wordpress_db
      MYSQL_PASSWORD: wp_db_pass_2026
      MYSQL_ROOT_PASSWORD: wp_root_secure_pass_2026
      MYSQL_USER: wp_db_user
    image: mysql:8.0
    networks:
      default: null
    restart: always
    volumes:
      - type: volume
        source: wp-mysql-data
        target: /var/lib/mysql
        volume: {}
  wordpress:
    container_name: wp-app
    depends_on:
      db:
        condition: service_started
        required: true
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress_db
      WORDPRESS_DB_PASSWORD: wp_db_pass_2026
      WORDPRESS_DB_USER: wp_db_user
    image: wordpress:latest
    networks:
      default: null
    ports:
      - mode: ingress
        target: 80
        published: "8080"
        protocol: tcp
    restart: always
    volumes:
      - type: volume
        source: wp-app-data
        target: /var/www/html
        volume: {}
networks:
  default:
    name: day-33_default
volumes:
  wp-app-data:
    name: wp-app-data
  wp-mysql-data:
    name: wp-mysql-data
```

> [!TIP]
> **Security Audit Passed:** The environment variables have been parsed and securely injected into their respective service descriptors by the Compose compilation process!

---

### Booting the Persistent Stack & Image Pull Verification

We boot up our production multi-tier environment in detached mode:

```bash
$ docker compose up -d
 Image wordpress:latest Pulling 
 Image mysql:8.0 Pulling 
 ...
 Image wordpress:latest Pulled 
 Image mysql:8.0 Pulled 
 Network day-33_default Creating 
 Network day-33_default Created 
 Volume wp-mysql-data Creating 
 Volume wp-mysql-data Created 
 Volume wp-app-data Creating 
 Volume wp-app-data Created 
 Container wp-mysql-db Creating 
 Container wp-mysql-db Created 
 Container wp-app Creating 
 Container wp-app Created 
 Container wp-mysql-db Starting 
 Container wp-mysql-db Started 
 Container wp-app Starting 
 Container wp-app Started 
```

---

### Verifying Storage Persistence Across Full Destruction Cycles

Let's test the resiliency of this production architecture.
1. Open your browser and navigate to `http://localhost:8080`.
2. Configure WordPress (Select language, input site title: *DevOps Ka Josh*, create admin account: *rajatmehta2*, and click **Install WordPress**).
3. Now, simulate a server disaster or stack migration by hard-purging our running stack:

```bash
# Force-terminate and destroy all stack services
$ docker compose down
 Container wp-app Stopping 
 Container wp-app Stopped 
 Container wp-app Removing 
 Container wp-app Removed 
 Container wp-mysql-db Stopping 
 Container wp-mysql-db Stopped 
 Container wp-mysql-db Removing 
 Container wp-mysql-db Removed 
 Network day-33_default Removing 
 Network day-33_default Removed 
```

The database container is physically destroyed and deleted from our host system! Let's reboot the stack:

```bash
# Revive the stack
$ docker compose up -d
 Network day-33_default Creating 
 Network day-33_default Created 
 Container wp-mysql-db Creating 
 Container wp-mysql-db Created 
 Container wp-app Creating 
 Container wp-app Created 
 Container wp-mysql-db Starting 
 Container wp-mysql-db Started 
 Container wp-app Starting 
 Container wp-app Started 
```

Let's navigate back to `http://localhost:8080`.

> [!IMPORTANT]
> **Persistence Confirmed:** The system does NOT prompt you for a fresh WordPress installation. It loads your pre-configured site instantly! This proves the persistent storage is decoupled completely from container life-cycles, remaining perfectly backed up inside the named volumes: `wp-mysql-data` and `wp-app-data`.

---

### 🖼️ Task 3 & 5 Verification: Env & Decoupled WordPress Stack
The screenshot below details our environment validation audits, dynamic image layer fetching sequences, volume mappings, and container bootstrap logs:

![Task 3 WordPress + MySQL Stack Setup with Env Variables](wordpress_mysql_compose.png)

---

## 🛠️ Task 4: Docker Compose Operations Deep-Dive

Now let's master the critical Compose operations you will execute daily in production settings.

### Viewing Running Stack Topologies

We verify active containers managed by our local stack configurations:

```bash
# Audit service health
$ docker compose ps
NAME          IMAGE              COMMAND                  SERVICE     CREATED         STATUS         PORTS
wp-app        wordpress:latest   "docker-entrypoint.s…"   wordpress   5 seconds ago   Up 5 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
wp-mysql-db   mysql:8.0          "docker-entrypoint.s…"   db          6 seconds ago   Up 5 seconds   3306/tcp, 33060/tcp
```

---

### Interrogating Centralized & Service-Specific Logs

Compose combines output logs from all running service threads into a single, unified stream, color-coding stdout logs per service:

```bash
# View combined logs
$ docker compose logs --tail=10
wp-mysql-db  | 2026-06-02T10:02:45.426433Z 0 [System] [Server] /usr/sbin/mysqld starting...
wp-mysql-db  | 2026-06-02T10:02:45.675450Z 0 [System] [Server] ready for connections. Version: '8.0.46'
wp-app       | WordPress not found in /var/www/html - copying now...
wp-app       | Complete! WordPress has been successfully copied to /var/www/html
wp-app       | AH00558: apache2: Could not reliably determine the server's fully qualified domain name
wp-app       | Apache/2.4.67 (Debian) PHP/8.3.31 configured -- resuming normal operations
```

To interrogate a **specific service** log stream (e.g., MySQL only):

```bash
# Stream MySQL logs
$ docker compose logs db
```

---

### Stopping & Starting Services Without purging Resources

If you need to temporarily stop container processes without deleting their configuration structures, networks, or endpoints:

```bash
# Pause container operations
$ docker compose stop
```

To resume the containers:

```bash
# Resume container operations
$ docker compose start
```

---

### Purging Stacks and Rebuilding Images

To destroy the stack completely, unlinking the virtual network bridge (note: named volumes remain safe unless explicitly purged using the `-v` flag):

```bash
# Destroy stack resources
$ docker compose down
```

If you modify configuration scripts or your custom base Dockerfiles, you must instruct Docker Compose to rebuild those base layers upon boot:

```bash
# Force fresh OCI image rebuilding
$ docker compose up -d --build
```

---

### 🖼️ Task 4 Verification: Operations Diagnostics
This snapshot details running stack audits, unified stream interrogation tests, and the resource-purging command cycles:

![Task 4 Docker Compose Operations and Logs Interrogation](docker_compose_commands.png)

---

### 🖼️ Task 5 Verification: Env Variable Verification
Below is the terminal capture showing compilation tests verifying variable resolution from the `.env` file:

![Task 5 Environment Variables and Config Auditing](env_variables_verification.png)

---

## 🏁 Submission & Learn in Public

Congratulations! You have successfully mastered Docker Compose orchestration, structured multi-container services, configured env variable injection, and automated persistent database volumes!

1. **Commit and Push changes to your GitHub fork:**
   ```bash
   # Add your configuration and markdown files
   $ git add docker-compose.yml compose-basics/docker-compose.yml .env day-33-compose.md
   
   # Commit with a clear DevOps description
   $ git commit -m "docs: complete Day 33 Docker Compose multi-container basics and environment isolation labs"
   
   # Push files to your GitHub repository
   $ git push origin main
   ```

2. **Learn in Public:**
   Share your multi-container WordPress + MySQL architecture running via Compose on LinkedIn or X (Twitter). Explain how decoupling environment credentials with `.env` files improves security, and why declarative Compose specifications are superior to manual command cycles. Use these hashtags to share your success:
   `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#DockerCompose` `#MultiContainer` `#DevOps`

---
**TrainWithShubham** | Day 33 Complete 🐳🚀
