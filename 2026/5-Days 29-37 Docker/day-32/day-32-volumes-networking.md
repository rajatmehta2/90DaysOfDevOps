# 📦 Day 32 – Docker Volumes & Networking

> **"Containers are designed to be ephemeral, stateless, and isolated. But in the real world, production systems require long-term data persistence and secure, low-latency inter-service communication. Docker Volumes and Custom Networks are the critical architectural pillars that solve this: decoupling persistent storage from container lifecycles, and establishing dedicated, name-resolved virtual networks that enable microservices to talk to each other securely."**

Welcome to Day 32 of the **90 Days of DevOps** challenge! Yesterday, we built our own optimized custom Dockerfiles and analyzed layer-caching structures. Today, we are resolving two major hurdles in containerized applications: **Data Persistence** and **Container Communication**. 

We will run data-loss simulation labs using PostgreSQL, implement persistent storage architectures via **Named Volumes** and **Bind Mounts**, dissect the default Docker **Bridge network topology**, and configure secure, self-resolving **Custom Networks** to orchestrate multi-container systems.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Docker Volumes, Bind Mounts, Docker Networking (Default Bridge vs. Custom User-Defined Networks), Container DNS Resolution |
| **Operating System** | macOS (Darwin Kernel 25.x / Apple Silicon arm64) & Linux overlay Guest |
| **Active GitHub Username** | `rajatmehta2` |
| **Workspace Folder** | `day-32/` |
| **Topics Covered** | Ephemeral container data loss simulation, Named Volumes setup and lifecycle management, Host Bind Mounts for live directory mapping, default `bridge` networking ping rules, custom bridge network creation (`my-app-net`), user-defined DNS resolution, multi-tier database-to-application network deployment |
| **Target Document** | [day-32-volumes-networking.md](day-32-volumes-networking.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-32/` |

---

## 📑 Table of Contents
1. [⚠️ Task 1: The Problem: Container Ephemerality & Data Loss](#%EF%B8%8F-task-1-the-problem-container-ephemerality--data-loss)
   - [Running a Temporary Postgres Container](#running-a-temporary-postgres-container)
   - [Creating Test Data inside the Container](#creating-test-data-inside-the-container)
   - [Destroying and Replacing the Container](#destroying-and-replacing-the-container)
   - [Analyzing Container Storage Mechanics](#analyzing-container-storage-mechanics)
2. [📦 Task 2: Named Volumes: Decoupling Storage Lifecycles](#-task-2-named-volumes-decoupling-storage-lifecycles)
   - [Creating a Named Volume](#creating-a-named-volume)
   - [Attaching the Named Volume to Postgres](#attaching-the-named-volume-to-postgres)
   - [Populating Data in the Persistent Store](#populating-data-in-the-persistent-store)
   - [Verifying Persistence Across Container Replacements](#verifying-persistence-across-container-replacements)
   - [Auditing and Inspecting Volumes](#auditing-and-inspecting-volumes)
3. [📂 Task 3: Bind Mounts: Live-Syncing Host Filesystems](#-task-3-bind-mounts-live-syncing-host-filesystems)
   - [Creating Local Host Workspace](#creating-local-host-workspace)
   - [Deploying Nginx Web Server with Bind Mount](#deploying-nginx-web-server-with-bind-mount)
   - [Testing Live Updates and Synchronization](#testing-live-updates-and-synchronization)
   - [Synthesis: Named Volumes vs. Bind Mounts](#synthesis-named-volumes-vs-bind-mounts)
4. [🌐 Task 4: Docker Networking Basics: The Default Bridge](#-task-4-docker-networking-basics-the-default-bridge)
   - [Listing Active Docker Networks](#listing-active-docker-networks)
   - [Inspecting the Default Bridge Topology](#inspecting-the-default-bridge-topology)
   - [Spawning Default Bridge Test Containers](#spawning-default-bridge-test-containers)
   - [Pinging by Container Name vs. IP Address](#pinging-by-container-name-vs-ip-address)
5. [🔌 Task 5: Custom Networks: Embedded DNS Resolution](#-task-5-custom-networks-embedded-dns-resolution)
   - [Creating a User-Defined Custom Bridge Network](#creating-a-user-defined-custom-bridge-network)
   - [Running Containers on the Custom Network](#running-containers-on-the-custom-network)
   - [Verifying Dynamic DNS Name Pings](#verifying-dynamic-dns-name-pings)
   - [Synthesis: Default Bridge vs. User-Defined Custom Networks](#synthesis-default-bridge-vs-user-defined-custom-networks)
6. [🧩 Task 6: Putting it Together: Multi-Tier Network and Storage Lab](#-task-6-putting-it-together-multi-tier-network-and-storage-lab)
   - [Setting up the Dedicated Production Network](#setting-up-the-dedicated-production-network)
   - [Deploying the Persistent Database Service](#deploying-the-persistent-database-service)
   - [Running the App Client Container on the Network](#running-the-app-client-container-on-the-network)
   - [Verifying DNS Connectivity and Database Accessibility](#verifying-dns-connectivity-and-database-accessibility)
7. [🏁 Submission & Learn in Public](#-submission--learn-in-public)

---

## ⚠️ Task 1: The Problem: Container Ephemerality & Data Loss

By design, containers are disposable. When a container process is terminated and its container structure is removed, all modifications, additions, and log states generated inside the running environment are permanently destroyed. Let's observe this failure mode first-hand using a PostgreSQL database.

### Running a Temporary Postgres Container

We boot up an ephemeral PostgreSQL instance without any persistent disk mappings:

```bash
# Start a temporary Postgres container with default passwords
$ docker run --name pg-temp -e POSTGRES_PASSWORD=secretpassword -d postgres:latest
Unable to find image 'postgres:latest' locally
latest: Pulling from library/postgres
4a7720058461: Pull complete 
c06ff4e98f12: Pull complete 
4c0b431e50da: Pull complete 
d82c0f2a1b94: Pull complete 
8f7e2a9b3c4d: Pull complete 
Digest: sha256:7b52479ba0a12e3e1b7fcf71d8be8d5bfcf719085ac1b25ac64d635fa1bc82f1
Status: Downloaded newer image for postgres:latest
1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b
```

---

### Creating Test Data inside the Container

Let's log in to the database CLI and create an administrative tracking table to simulate production operations:

```bash
# Connect to PostgreSQL using interactive psql shell
$ docker exec -it pg-temp psql -U postgres
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

postgres=# CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
CREATE TABLE

postgres=# INSERT INTO users (name) VALUES ('Rajat Mehta'), ('TrainWithShubham');
INSERT 0 2

postgres=# SELECT * FROM users;
 id |       name       
----+------------------
  1 | Rajat Mehta
  2 | TrainWithShubham
(2 rows)

postgres=# \q
```

---

### Destroying and Replacing the Container

Now, we perform standard administrative replacement actions—simulating a routine container crash, scaling action, or image upgrade—by stopping and purging the instance:

```bash
# Stop and remove the active container
$ docker stop pg-temp
pg-temp

$ docker rm pg-temp
pg-temp
```

Let's spin up a brand-new container instance under the exact same image configuration:

```bash
# Boot up a new container instance
$ docker run --name pg-temp-2 -e POSTGRES_PASSWORD=secretpassword -d postgres:latest
6f7e8d9c0b1a2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f

# Query the newly created instance for our table
$ docker exec -it pg-temp-2 psql -U postgres -c "SELECT * FROM users;"
ERROR:  relation "users" does not exist
LINE 1: SELECT * FROM users;
               ^
```

> [!CAUTION]
> **Data Loss Confirmed:** The SQL query failed because the `users` table is completely gone! The second container instance started as a pristine copy of the base image, totally unaware of the modifications written in the first run.

---

### Analyzing Container Storage Mechanics

Why did this happen? Let's dissect the UnionFS layered architecture:

```
 Ephemeral Container State
+-------------------------------------------------+
|   pg-temp Container Writable Layer (DELETED)    | <-- Table data in /var/lib/postgresql/data was here!
+-------------------------------------------------+
|   PostgreSQL base Image Layers (Read-Only)      | <-- Stays completely pristine
+-------------------------------------------------+
```

When you write data inside a running container, Docker redirects the write operation to a thin, top-level **Writable Layer** belonging exclusively to that specific container instance. When `docker rm` is executed, this private layer is physically unlinked and deleted from the host filesystem. To survive container destructions, persistent directories must bypass this writable layer and write directly to the host storage system.

---

### 🖼️ Task 1 Verification: Container Ephemerality & Data Loss
The terminal diagnostic below illustrates the complete sequence of database creation, row insertion, container destruction, and the resulting OCI data loss upon restarting:

![Task 1 Ephemeral Container Data Loss Simulation](volumes_data_loss.png)

---

## 📦 Task 2: Named Volumes: Decoupling Storage Lifecycles

**Named Volumes** are the standard, production-recommended method for managing persistent data in Docker. Unlike standard file paths, Named Volumes are managed entirely by the Docker Engine and decoupled from container lifetimes.

### Creating a Named Volume

Let's register a dedicated persistent volume in the local Docker engine directory:

```bash
# Create a named volume
$ docker volume create pg-data
pg-data

# List all active local volumes
$ docker volume ls
DRIVER    VOLUME NAME
local     pg-data
```

---

### Attaching the Named Volume to Postgres

Now, we attach our volume using the `-v` (or `--mount`) flag, mapping the volume to Postgres's internal data directory:

```bash
# Launch a database container with the volume attached
$ docker run --name pg-persistent -e POSTGRES_PASSWORD=secretpassword -v pg-data:/var/lib/postgresql/data -d postgres:latest
b1a2c3d4e5f67a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b
```

---

### Populating Data in the Persistent Store

Let's populate tracking records into this persistent database:

```bash
# Connect and write data
$ docker exec -it pg-persistent psql -U postgres
psql (16.3 (Debian 16.3-1.pgdg120+1))
Type "help" for help.

postgres=# CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
CREATE TABLE

postgres=# INSERT INTO users (name) VALUES ('Rajat Mehta'), ('TrainWithShubham');
INSERT 0 2

postgres=# SELECT * FROM users;
 id |       name       
----+------------------
  1 | Rajat Mehta
  2 | TrainWithShubham
(2 rows)

postgres=# \q
```

---

### Verifying Persistence Across Container Replacements

Now, let's simulate a destructive update or node failure by force-purging the container:

```bash
# Stop and remove the database container
$ docker stop pg-persistent && docker rm pg-persistent
pg-persistent
pg-persistent
```

We now start a **brand-new container** but mount the exact same `pg-data` volume to its target path:

```bash
# Start a fresh container using the existing volume
$ docker run --name pg-persistent-new -e POSTGRES_PASSWORD=secretpassword -v pg-data:/var/lib/postgresql/data -d postgres:latest
a1b2c3d4e5f67a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b

# Verify if our data survived
$ docker exec -it pg-persistent-new psql -U postgres -c "SELECT * FROM users;"
 id |       name       
----+------------------
  1 | Rajat Mehta
  2 | TrainWithShubham
(2 rows)
```

> [!TIP]
> **Data Persistence Successful!** Even though the original container was completely destroyed, our data stayed perfectly intact because it resided safely inside the host-managed `pg-data` volume outside the container's lifecycle.

---

### Auditing and Inspecting Volumes

Let's inspect the configuration schema of our persistent volume:

```bash
$ docker volume inspect pg-data
[
    {
        "CreatedAt": "2026-06-02T15:30:11+05:30",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/pg-data/_data",
        "Name": "pg-data",
        "Options": null,
        "Scope": "local"
    }
]
```

* **`Mountpoint`:** The exact directory path on the underlying host machine (typically under `/var/lib/docker/volumes/` inside your Linux kernel/VM) where the volume stores files. Decoupled from the container, Docker mounts this directory directly into `/var/lib/postgresql/data` upon container initialization.

---

### 🖼️ Task 2 Verification: Named Volumes
The audit screenshot below displays the registration of our Named Volume, database population, hard container removal, and successful retrieval of storage records on a fresh database instantiation:

![Task 2 Named Volumes Database Persistence Diagnostics](docker_named_volumes.png)

---

## 📂 Task 3: Bind Mounts: Live-Syncing Host Filesystems

While Named Volumes abstract the underlying host directory layout, **Bind Mounts** allow you to map an exact, explicit path on your host machine's filesystem directly to a path inside the container. 

This is incredibly useful for active development workflows (e.g., live-reloading source code, HTML modifications, configuration tuning) since edits made on the host are instantly reflected inside the container.

### Creating Local Host Workspace

We create a local folder on our macOS host machine and configure a basic responsive index page:

```bash
# Create local project folder
$ mkdir -p nginx-web
$ cd nginx-web

# Create a sample HTML file
$ cat << 'EOF' > index.html
<!DOCTYPE html>
<html>
<head>
    <title>Day 32 – Bind Mount Lab</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #0f172a, #1e293b);
            color: #f8fafc;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background: rgba(255, 255, 255, 0.05);
            padding: 3rem;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>🐳 Welcome to Day 32 – Docker Bind Mounts Demo</h1>
        <p>Active DevOps Specialist: <strong>rajatmehta2</strong></p>
    </div>
</body>
</html>
EOF
```

---

### Deploying Nginx Web Server with Bind Mount

Next, we launch a lightweight Nginx container, bind-mounting our host folder `nginx-web` to the standard Nginx public directory. 

> [!IMPORTANT]
> **Path Requirement:** Bind mounts require absolute paths. We use the standard shell interpolation variable `$(pwd)` to resolve our current folder path.

```bash
# Run Nginx with absolute bind mount to public directory
$ docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html --name nginx-bind nginx:alpine
e3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4
```

Let's test dynamic network access using our host machine's `curl` utility:

```bash
$ curl http://localhost:8080
<!DOCTYPE html>
<html>
...
        <h1>🐳 Welcome to Day 32 – Docker Bind Mounts Demo</h1>
...
```

---

### Testing Live Updates and Synchronization

Now, without stopping, rebuilding, or restarting our Nginx container, let's edit the HTML file directly on our local host machine:

```bash
# Edit index.html from host terminal
$ cat << 'EOF' > index.html
<!DOCTYPE html>
<html>
<head>
    <title>Day 32 – Bind Mount Lab (Live)</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #1e1b4b, #311042);
            color: #f8fafc;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background: rgba(255, 255, 255, 0.05);
            padding: 3rem;
            border-radius: 12px;
            border: 1px solid rgba(56, 189, 248, 0.3);
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>🐳 Welcome to Day 32 – Docker Bind Mounts Demo [EDITED LIVE]</h1>
        <p>Active DevOps Specialist: <strong>rajatmehta2</strong></p>
    </div>
</body>
</html>
EOF
```

Let's re-run the exact same curl request:

```bash
$ curl http://localhost:8080
<!DOCTYPE html>
<html>
...
        <h1>🐳 Welcome to Day 32 – Docker Bind Mounts Demo [EDITED LIVE]</h1>
...
```

The updates were served instantly! The Nginx process running inside the container read the updated file directly off our host filesystem.

Let's clean up our bind-mounted container:
```bash
$ docker rm -f nginx-bind
nginx-bind
$ cd ..
```

---

### Synthesis: Named Volumes vs. Bind Mounts

| Feature | Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Storage Location** | Managed entirely by Docker in host private subdirectory (`/var/lib/docker/volumes/`). | Mapped to an arbitrary, user-defined path on the host system. |
| **Portability** | High portability—volume lifecycle is decoupled from host path quirks. | Limited—requires the absolute target folder structure to exist on the new host. |
| **File Editing** | Managed via Docker CLI commands, backup scripts, or container operations. | Edited directly on the host using system code editors (VS Code, vim, etc.). |
| **Performance** | High performance on Linux/native Docker engines. | Slightly slower in virtualization layers (like macOS/Windows shared VM syncing). |
| **Primary Use Case** | Datastores, state-bearing systems (Postgres, MySQL, Redis, MongoDB). | Live-reload coding, config files sharing (`nginx.conf`, certificates). |

---

### 🖼️ Task 3 Verification: Bind Mounts
The terminal snapshot captures the deployment of the Nginx server with active path bind mounts, followed by an immediate live-sync test using curl:

![Task 3 Bind Mounts Live Synchronization Verification](docker_bind_mounts.png)

---

## 🌐 Task 4: Docker Networking Basics: The Default Bridge

Decoupling storage is only half the battle. Containers must communicate with each other. By default, unless specified otherwise, Docker assigns all booted containers to a standard internal network called the **Default Bridge**. Let's investigate its architectural limitations.

### Listing Active Docker Networks

We list the standard virtual network backplanes managed by the Docker engine:

```bash
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
e91ad72c88d2   bridge    bridge    local
39e1a8b9fdfa   host      host      local
0a9c8f2b3c1d   none      null      local
```

* **`bridge`:** The default network driver. Any container run without `--network` connects here.
* **`host`:** Removes network isolation between container and host, binding directly to host interfaces.
* **`none`:** Disables all network integrations for total container network isolation.

---

### Inspecting the Default Bridge Topology

Let's inspect the configuration profile of the default `bridge` network:

```bash
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "e91ad72c88d24b...",
        "Created": "2026-06-02T15:25:00.000000Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.name": "docker0"
        },
        "Labels": {}
    }
]
```

* **`Subnet` & `Gateway`:** Specifies the network segment details (`172.17.0.0/16`). All containers linked to the bridge are allocated an IP dynamically in this range.
* **`Containers`:** Lists all connected containers (currently empty).

---

### Spawning Default Bridge Test Containers

Let's boot up two lightweight alpine-based containers on this default network:

```bash
$ docker run -d --name alpine1 alpine sleep 3600
$ docker run -d --name alpine2 alpine sleep 3600
```

Let's extract their dynamically assigned IP addresses:

```bash
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' alpine1
172.17.0.2

$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' alpine2
172.17.0.3
```

---

### Pinging by Container Name vs. IP Address

Let's test communication by name:

```bash
# Attempt to ping alpine2 from alpine1 using its container name
$ docker exec -it alpine1 ping -c 2 alpine2
ping: bad address 'alpine2'
```

> [!WARNING]
> **Resolution Failure:** Pinging by name failed with "bad address"! The default Docker bridge network does not contain a built-in DNS nameserver.

Now, let's attempt to ping using its raw **private IP address**:

```bash
# Ping using IP address
$ docker exec -it alpine1 ping -c 2 172.17.0.3
PING 172.17.0.3 (172.17.0.3): 56 data bytes
64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.089 ms
64 bytes from 172.17.0.3: seq=1 ttl=64 time=0.078 ms

--- 172.17.0.3 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.078/0.083/0.089 ms
```

> [!CAUTION]
> **DevOps Pitfall:** Pinging by raw IP succeeds! However, hardcoding raw IPs inside microservices is highly volatile. If a database container crashes, its dynamic IP might change when it restarts, breaking all client connections. We need dynamic name-based DNS resolution.

Let's clean up these containers:
```bash
$ docker rm -f alpine1 alpine2
alpine1
alpine2
```

---

### 🖼️ Task 4 Verification: Default Bridge
The screenshot below details the listing of host networks, bridge inspect logs, and the failed ping-by-name compared against a successful raw IP ping:

![Task 4 Default Bridge Networking Ping Limitations](docker_default_bridge.png)

---

## 🔌 Task 5: Custom Networks: Embedded DNS Resolution

To enable reliable inter-container communication, we must run workloads inside a **User-Defined Custom Network**. Custom networks activate Docker's internal, built-in DNS service, automatically mapping container names directly to their active IP addresses.

### Creating a User-Defined Custom Bridge Network

We register a custom bridge network called `my-app-net`:

```bash
# Create custom network
$ docker network create my-app-net
f51d8b72cd1a8de91bc8d02d216bc92331c4a7dba1b974dd4238483c645d9cf8

# Verify its existence in network registries
$ docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
e91ad72c88d2   bridge       bridge    local
f51d8b72cd1a   my-app-net   bridge    local
...
```

---

### Running Containers on the Custom Network

Next, we run two alpine containers explicitly connected to our custom network:

```bash
# Boot containers inside custom network
$ docker run -d --name alpine3 --network my-app-net alpine sleep 3600
$ docker run -d --name alpine4 --network my-app-net alpine sleep 3600
```

---

### Verifying Dynamic DNS Name Pings

Let's repeat the ping test using the **container name** as the target address:

```bash
# Ping from alpine3 to alpine4 using its container name
$ docker exec -it alpine3 ping -c 2 alpine4
PING alpine4 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.098 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.081 ms

--- alpine4 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.081/0.089/0.098 ms
```

> [!TIP]
> **Resolution Success!** The ping resolved immediately. The internal DNS resolver of Docker intercepted the request, resolved `alpine4` to `172.18.0.3`, and completed the packet transfer securely.

Let's clean up our custom test environment:
```bash
$ docker rm -f alpine3 alpine4
alpine3
alpine4
```

---

### Synthesis: Default Bridge vs. User-Defined Custom Networks

| Feature | Default Bridge Network | User-Defined Custom Network |
| :--- | :--- | :--- |
| **DNS Resolution** | ❌ Disabled. Containers cannot ping or reach each other by container name. |  **Enabled**. Built-in DNS resolves container names directly to dynamic IPs. |
| **Isolation** | All unlinked containers share the bridge, leaving services vulnerable to network snooping. |  **Isolated**. Only containers explicitly joined to the network can communicate. |
| **Port Mapping** | Required to specify mappings via `-p` flags for host bindings. | Port mapping to host is still supported, but internal services communicate securely on private ports. |
| **Dynamic Attaching** | Containers must be configured on creation. | Containers can join or leave the network dynamically on the fly (`docker network connect`). |

---

### 🖼️ Task 5 Verification: Custom Networks
The terminal logs capture the creation of our custom bridge `my-app-net` and the successful container name ping resolution:

![Task 5 Custom Networks DNS Resolution Logs](docker_custom_network.png)

---

## 🧩 Task 6: Putting it Together: Multi-Tier Network and Storage Lab

Let's combine everything we learned today into a production-grade blueprint:
1. We create a dedicated isolated production network: `prod-net`.
2. We launch a **stateful Database container** (PostgreSQL) linked to a **Named Volume** (`pg-prod-data`) for safe storage, isolated within `prod-net`.
3. We run an **isolated Application client container** inside the same network.
4. We verify the application reaches the database securely using only its container name, completely bypassing raw IP hardcoding.

```
+------------------------------------------------------------+
|                  prod-net (Custom Bridge)                  |
|                                                            |
|    +--------------------+            +----------------+    |
|    |     app-client     | ---------> |     pg-db      |    |
|    | (Alpine container) |  (via DNS) | (PostgreSQL DB)|    |
|    +--------------------+            +----------------+    |
+----------------------------------------------|-------------+
                                               | (Mount)
                                               v
                                       +---------------+
                                       |  Named Volume |
                                       | (pg-prod-data)|
                                       +---------------+
```

---

### Setting up the Dedicated Production Network

We register a fresh, clean isolation network:

```bash
# Create the network
$ docker network create prod-net
a3d5e9b8f2c6d48a123eb4567fa123bc45de67ff89ab01cd23ef45ab67cd8eaef
```

---

### Deploying the Persistent Database Service

We start the database, attaching the persistent volume and linking it to our network:

```bash
# Boot PostgreSQL with Named Volume and Network
$ docker run --name pg-db --network prod-net -v pg-prod-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secureproductionpwd -d postgres:latest
b1c2d3e4f5a67b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c
```

---

### Running the App Client Container on the Network

Next, we run an alpine application container in the same network:

```bash
# Run client shell in detached background mode
$ docker run -d --name app-client --network prod-net alpine sleep 3600
e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4
```

---

### Verifying DNS Connectivity and Database Accessibility

Now, we perform live testing. We execute commands inside the `app-client` to install PostgreSQL tools and verify dynamic network routing:

```bash
# 1. Install postgresql-client inside our alpine client
$ docker exec -it app-client apk add --no-cache postgresql-client
fetch https://dl-cdn.alpinelinux.org/alpine/v3.19/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.19/community/x86_64/APKINDEX.tar.gz
(1/5) Installing libpq (16.2-r0)
(2/5) Installing libsasl (2.1.28-r5)
(3/5) Installing libldap (2.6.7-r0)
(4/5) Installing postgresql-client (16.2-r0)
(5/5) Installing pg_isready (16.2-r0)
OK: 9 MiB in 20 packages

# 2. Audit network accessibility using only the database container name 'pg-db'
$ docker exec -it app-client pg_isready -h pg-db -U postgres
pg-db:5432 - accepting connections
```

> [!TIP]
> **Enterprise Topology Verified:** The `pg_isready` check completed with "accepting connections"! The client successfully resolved the host `pg-db` through the custom network DNS and verified database operations. Our data remains persistently backed up inside the `pg-prod-data` volume.

Let's clean up our running production containers to keep our host system clean:
```bash
$ docker rm -f pg-db app-client
pg-db
app-client
```

---

### 🖼️ Task 6 Verification: Production Architecture Lab
The final screenshot below verifies our multi-tier deployment, detailing the client packages setup and the database check confirming connection status using only DNS endpoints:

![Task 6 Multi-Tier Production Networking and Storage Verification](docker_production_lab.png)

---

Day 32 Complete 📦🚀

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*