# 🐳 The Ultimate Docker Cheat Sheet

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![DevOps](https://img.shields.io/badge/DevOps-Docker%20Cheatsheet-blueviolet?style=for-the-badge&logo=git&logoColor=white)](https://github.com/rajatmehta2/90DaysOfDevOps)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day%2037-blue?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to the **Ultimate Docker Cheat Sheet**! Compiled during **Day 37** of the `#90DaysOfDevOps` challenge, this is a highly optimized, production-grade quick-reference guide. It is categorized logically, with concise one-line syntax, practical examples, and production-tested workflows that you'll actually use on the job.

---

## 🏗️ 1. Container Lifecycle Commands

Manage the active runtime state of your microservices and applications.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker run` | `-d` Detached<br>`-it` Interactive<br>`-p` Port Map<br>`--name` Name<br>`--rm` Auto-remove | Create and start a container from an image. | `docker run -d -p 8080:80 --name my-web nginx` |
| `docker ps` | `-a` All<br>`-q` Quiet (IDs only) | List running (or all) containers. | `docker ps -a` |
| `docker stop` | *None* | Gracefully stop one or more active containers (sends `SIGTERM`). | `docker stop my-web` |
| `docker start` | *None* | Start one or more stopped containers. | `docker start my-web` |
| `docker restart` | *None* | Restart a running container. | `docker restart my-web` |
| `docker rm` | `-f` Force remove | Delete one or more stopped containers. | `docker rm my-web` |
| `docker logs` | `-f` Follow<br>`--tail N` Last N lines | Fetch and monitor the logs of a container. | `docker logs -f --tail 100 my-web` |
| `docker exec` | `-it` Interactive TTY | Execute a command inside a running container. | `docker exec -it my-web bash` |
| `docker inspect` | *None* | Return low-level metadata of a container (JSON format). | `docker inspect my-web` |
| `docker port` | *None* | List port mappings or a specific mapping for a container. | `docker port my-web` |
| `docker top` | *None* | Display the running processes of a container. | `docker top my-web` |
| `docker stats` | *None* | Display a live stream of container resource usage statistics. | `docker stats` |

---

## 📦 2. Image Management Commands

Build, share, tag, and manage the immutable blueprints of your environment.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker build` | `-t` Tag<br>`--no-cache` Fresh Build | Build a Docker image from a local Dockerfile. | `docker build -t rajatmehta2/api-app:v1.0 .` |
| `docker images` | `-a` All | List all locally cached Docker images. | `docker images` |
| `docker rmi` | `-f` Force remove | Delete one or more local Docker images. | `docker rmi rajatmehta2/api-app:v1.0` |
| `docker pull` | *None* | Download an image from Docker Hub or a private registry. | `docker pull postgres:15-alpine` |
| `docker push` | *None* | Upload a tagged image to a remote registry (Docker Hub). | `docker push rajatmehta2/api-app:v1.0` |
| `docker tag` | *None* | Create a reference tag (alias) pointing to an existing image. | `docker tag api-app:latest api-app:v1.0.0` |
| `docker history` | *None* | Show the history of an image (layers, sizes, and commands). | `docker history postgres:15-alpine` |
| `docker save` | `-o` Output file | Save an image to a tar archive (for offline sharing). | `docker save -o my-image.tar nginx` |
| `docker load` | `-i` Input file | Load an image from a tar archive. | `docker load -i my-image.tar` |

---

## 💾 3. Volume Commands (Data Persistence)

Manage persistent volumes to prevent data loss when containers are destroyed.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker volume create` | *None* | Create a new named volume managed by Docker. | `docker volume create pg_data` |
| `docker volume ls` | *None* | List all volumes created on the host system. | `docker volume ls` |
| `docker volume inspect` | *None* | Show detailed information about a volume (e.g., Mountpoint). | `docker volume inspect pg_data` |
| `docker volume rm` | *None* | Remove one or more unused/stopped volumes. | `docker volume rm pg_data` |
| `docker volume prune` | `-f` Force (no prompt) | Remove all unused local volumes to free up space. | `docker volume prune -f` |

---

## 🌐 4. Network Commands (Container Communication)

Create and manage isolated virtual network bridges to connect or restrict container communication.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker network create`| `-d` Driver type | Create a new user-defined network (default: `bridge`). | `docker network create -d bridge app-net` |
| `docker network ls` | *None* | List all Docker networks available on the host. | `docker network ls` |
| `docker network inspect`| *None* | Show detailed JSON metadata of a specific network. | `docker network inspect app-net` |
| `docker network connect`| *None* | Connect a running container to an existing network. | `docker network connect app-net my-web` |
| `docker network disconnect`|*None*| Disconnect a container from a specific network. | `docker network disconnect app-net my-web`|
| `docker network rm` | *None* | Remove one or more networks. | `docker network rm app-net` |
| `docker network prune` | `-f` Force (no prompt) | Remove all unused networks. | `docker network prune -f` |

---

## 🐙 5. Docker Compose Orchestration Commands

Orchestrate complex multi-container application stacks declared inside `docker-compose.yml` files.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker compose up` | `-d` Detached<br>`--build` Rebuild | Build, create, start, and connect all containers. | `docker compose up -d --build` |
| `docker compose down` | `-v` Destroy volumes<br>`--rmi` Remove images | Stop and remove containers, networks, and volumes. | `docker compose down -v` |
| `docker compose ps` | `-a` All | List status of all containers belonging to the stack. | `docker compose ps` |
| `docker compose logs` | `-f` Follow | Display logs output from all services running in the stack. | `docker compose logs -f --tail 50` |
| `docker compose build` | `--no-cache` Fresh Build | Rebuild services defined inside the Compose schema. | `docker compose build --no-cache` |
| `docker compose exec` | *None* | Execute a command inside a specific service container. | `docker compose exec db psql -U postgres` |
| `docker compose restart`| *None* | Restart all services running within the stack. | `docker compose restart` |
| `docker compose top` | *None* | Display the running processes of the stack services. | `docker compose top` |

---

## 🧹 6. System Cleanup & Disk Space Commands

Reclaim precious host storage space by purging unused caching layers, networks, volumes, and stopped containers.

| Command | Key Flags | Description / Use Case | Real-World Example |
| :--- | :--- | :--- | :--- |
| `docker system df` | `-v` Verbose | Show Docker disk usage (images, containers, volumes). | `docker system df` |
| `docker container prune`| `-f` Force | Remove all stopped containers. | `docker container prune -f` |
| `docker image prune` | `-a` All unused | Remove unused images (dangling ones, or all unused). | `docker image prune -a -f` |
| `docker system prune` | `-a` All unused<br>`--volumes` Prune volumes | Remove all stopped containers, unused networks, dangling images, and build caches. | `docker system prune -a --volumes -f` |

---

## 🐳 7. Dockerfile Reference Sheet

Key instructions used to program custom, security-optimized Docker images.

| Instruction | Practical Purpose | Optimization Best Practice | Example |
| :--- | :--- | :--- | :--- |
| **`FROM`** | Defines the parent base image. | Use official, lightweight images (e.g., `-alpine`, `-slim`). | `FROM python:3.11-slim` |
| **`WORKDIR`**| Sets the working directory inside the container. | Always set an absolute path, avoid leaving files in root `/`. | `WORKDIR /app` |
| **`RUN`** | Executes command binaries during the build layer. | Chain commands with `&&` and clean up package managers in the same layer to minimize size. | `RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*` |
| **`COPY`** | Copies files from the host build context to the container. | Copy dependencies files (`package.json`, `requirements.txt`) *first* before the app code to maximize layer cache efficiency. | `COPY requirements.txt .` |
| **`ADD`** | Advanced copy: downloads URLs & auto-extracts `.tar` | Avoid for standard files. Prefer `COPY` for predictability. | `ADD source.tar.gz /app/` |
| **`EXPOSE`** | Documents the container's operational network port. | Strictly matches the application's runtime listening port. | `EXPOSE 5000` |
| **`ENV`** | Sets persistent environment variables. | Keep environment variables for application configuration, not sensitive credentials. | `ENV NODE_ENV=production` |
| **`USER`** | Sets the runtime non-root system user ID. | **CRITICAL for Security**: Always create a non-root system user and switch to it before running processes. | `USER devopsuser` |
| **`HEALTHCHECK`**| Tells Docker how to test the container's health. | Essential for microservice synchronization in Compose or Kubernetes. | `HEALTHCHECK CMD curl -f http://localhost:5000/ || exit 1` |
| **`ENTRYPOINT`**| Defines the executable binary that always runs at boot. | Use this for command-line tools or fixed execution wrappers. | `ENTRYPOINT ["gunicorn"]` |
| **`CMD`** | Provides default arguments for `ENTRYPOINT` (or standalone process command). | Overridden easily by passing arguments at runtime via CLI. | `CMD ["--bind", "0.0.0.0:5000", "app:app"]` |

---

## 🔥 8. Extreme Production One-Liners

Advanced Docker commands utilized by DevOps engineers to solve common issues on the fly.

### 🗑️ Wipe Everything (Nuclear Option)
Completely wipe containers, networks, volumes, build caches, and images:
```bash
$ docker system prune -a --volumes -f
```

### 🛑 Stop All Running Containers
Instantly stop all executing container instances:
```bash
$ docker stop $(docker ps -q)
```

### ❌ Remove All Stopped Containers
Delete all inactive container containers from memory:
```bash
$ docker rm $(docker ps -a -q)
```

### 🧹 Delete Dangling & Unused Images
Clear intermediate untagged layers and dangling images:
```bash
$ docker rmi $(docker images -f "dangling=true" -q)
```

### 🕵️ Find Container Internal IP Address
Extract the specific internal virtual bridge IP address of a container:
```bash
$ docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>
```

### 📊 Real-Time Resource Monitoring
Monitor CPU, memory bandwidth, network packets, and disk I/O in a clean table format:
```bash
$ docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
```

---

> [!IMPORTANT]
> **Production Best Practice Reminders:**
> * **Never run as root:** Always declare a `USER` in your Dockerfiles.
> * **Pin versions:** Do not use `latest` tags in production base images (e.g., use `node:18.16.0-alpine` instead of `node:alpine` or `node:latest`).
> * **Leverage `.dockerignore`:** Exclude `/node_modules`, `.git`, `.env`, and local caches to keep build context transmission fast and prevent secret leaks.

---

## 🔗 Connect & Support!

If you find this cheat sheet helpful, share it with others or check out my primary repository for other daily DevOps logs:

* **LinkedIn**: [Rajat Mehta](https://linkedin.com/in/rajatmehta)
* **GitHub**: [@rajatmehta2](https://github.com/rajatmehta2)

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#DockerCheatsheet` `#DevOpsEngineers`
