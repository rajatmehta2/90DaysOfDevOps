# Day 37: Docker Revision & Self-Assessment 🚀

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![DevOps](https://img.shields.io/badge/DevOps-Docker%20Revision-blueviolet?style=for-the-badge&logo=git&logoColor=white)](https://github.com/rajatmehta2/90DaysOfDevOps)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day%2037-blue?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 37** of the `#90DaysOfDevOps` challenge! Today is a intentional **one-day consolidation and revision pause**. After shipping multi-container microservices, writing custom Dockerfiles, mapping volumes, configuring networks, and orchestrating stacks with Docker Compose (Days 29–36), it is crucial to step back and ensure the core foundations are rock-solid.

This revision guide logs my honest self-assessment checklist, comprehensive answers to core quick-fire Docker interview questions, and deep-dives into weak areas.

---

## 🗺️ Self-Assessment Checklist

Below is my honest status report across the core Docker capabilities covered over the past week. By reviewing the practical exercises, I have built confidence across the entire pipeline.

- [x] **Run a container from Docker Hub (interactive + detached)**
  - *Status:* **Can do**. Comfortable using `-it` for interactive bash prompts and `-d` for running background services (e.g., Nginx, Redis).
- [x] **List, stop, remove containers and images**
  - *Status:* **Can do**. Regularly utilizing `docker ps -a`, `docker stop`, `docker rm`, and `docker rmi` to keep my local environment clean.
- [x] **Explain image layers and how caching works**
  - *Status:* **Can do**. Understand how each instruction in a `Dockerfile` creates a read-only Layer, and how Docker skips unchanged layers during subsequent builds to accelerate execution.
- [x] **Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD**
  - *Status:* **Can do**. Able to draft structured, caching-optimized Dockerfiles for Python Flask, Node.js, and static HTML websites.
- [x] **Explain CMD vs ENTRYPOINT**
  - *Status:* **Can do**. Understand that `ENTRYPOINT` defines the executable to run, while `CMD` provides the default arguments that can easily be overridden via CLI at runtime.
- [x] **Build and tag a custom image**
  - *Status:* **Can do**. Fully proficient with `docker build -t <username>/<image-name>:<tag> .`.
- [x] **Create and use named volumes**
  - *Status:* **Can do**. Able to persist database state (like PostgreSQL `/var/lib/postgresql/data`) across container lifecycles using `-v` or named volumes.
- [x] **Use bind mounts**
  - *Status:* **Can do**. Utilizing host-to-container directory mounts (`-v /host:/container` or `--mount type=bind`) to enable instant hot-reloads during local development.
- [x] **Create custom networks and connect containers**
  - *Status:* **Can do**. Comfortable creating isolated virtual bridge networks using `docker network create` to restrict database containers and securely connect backend containers.
- [x] **Write a docker-compose.yml for a multi-container app**
  - *Status:* **Can do**. Comfortable defining multiple services, custom networks, persistent volumes, environment configs, and port maps in a single yaml file.
- [x] **Use environment variables and .env files in Compose**
  - *Status:* **Can do**. Keeping secrets and credentials secure by separating environments and letting Compose auto-inject configurations from local `.env` files.
- [x] **Write a multi-stage Dockerfile**
  - *Status:* **Can do**. Able to use a heavy `builder` image for compiling dependencies and a lightweight `runner` (e.g., `slim` or `alpine`) for running the application process, saving 80%+ of disk space.
- [x] **Push an image to Docker Hub**
  - *Status:* **Can do**. Successfully logging in via `docker login` and publishing tagged releases to my public repository catalog.
- [x] **Use healthchecks and depends_on**
  - *Status:* **Can do**. Eliminating container startup race conditions by chaining `depends_on` with explicit healthcheck conditions (`service_healthy` validation).

---

## ⚡ Quick-Fire Questions & Deep-Dive Answers

These questions are frequently asked during DevOps and Cloud Infrastructure interviews. I have answered them from first-principles knowledge:

### 1. What is the difference between an image and a container?
* **Image:** A **read-only, immutable template** containing the application code, runtime, libraries, environment variables, configuration files, and system binaries. It serves as the static blueprint.
* **Container:** A **runnable, lightweight, isolated instance** of that image. It executes as an isolated process on the host OS. When a container is launched, Docker adds a thin, transient **read-write layer** (the container layer) on top of the immutable image layers to store runtime state and file alterations.

---

### 2. What happens to data inside a container when you remove it?
By default, any data written inside a container's writable layer **is lost forever** when the container is deleted (`docker rm`). To prevent this and preserve state, you must attach a persistent storage mechanism:
* **Named Volumes:** Managed completely by Docker inside the host system's file system (`/var/lib/docker/volumes/` on Linux). Recommended for production databases and isolated container storage.
* **Bind Mounts:** Maps a specific user-defined path on the host machine directly into the container. Excellent for sharing configuration files or enabling hot-reloading during development.

---

### 3. How do two containers on the same custom network communicate?
Containers running on the same user-defined custom network (e.g., a custom bridge network) communicate directly by using each other's **container names** (or service names in Docker Compose) as hostnames. 
Docker's built-in **embedded DNS resolver** automatically intercepts these hostnames and maps them to the respective container's internal IP address. This avoids hardcoding dynamic, volatile internal IP addresses.
> [!NOTE]
> This automatic service discovery **does not work** on Docker's default `bridge` network. It is only available on user-defined custom networks.

---

### 4. What does `docker compose down -v` do differently from `docker compose down`?
* **`docker compose down`:** Stops running containers and removes the containers, default networks, and build caches created by `up`.
* **`docker compose down -v`:** In addition to doing everything above, the `-v` (or `--volumes`) flag **completely destroys all named and anonymous volumes** declared in the `docker-compose.yml` file. This is highly useful when you need to completely reset database states and test migrations or configurations from absolute scratch.

---

### 5. Why are multi-stage builds useful?
Multi-stage builds allow you to use multiple `FROM` instructions in a single `Dockerfile`. This brings two massive benefits:
1. **Minimizes Production Image Size:** You can download heavy build tools, compilers (gcc, build-essential), and package managers in an initial `builder` stage, compile the code, and then copy *only* the compiled binaries or runtime wheels into a clean, lightweight runner image (like `alpine` or `slim`).
2. **Improves Security:** By omitting compiler tools, package managers, and raw source code from the final runner container, you drastically reduce the **attack surface** and eliminate potential CVE vulnerabilities that attackers could exploit.

---

### 6. What is the difference between `COPY` and `ADD`?
While both instructions copy files from the host machine into the container filesystem, their feature sets differ:
* **`COPY`:** Strictly and transparently copies local files or directories from the build context into the container. It is predictable, secure, and is the **recommended practice** for 95% of standard file transfers.
* **`ADD`:** Includes two extra "magic" capabilities:
  1. It can fetch files from remote URLs (though downloading via `curl` or `wget` inside a `RUN` command is cleaner because it avoids bloated image layers).
  2. It automatically extracts local compressed archive files (like `.tar`, `.tar.gz`, `.zip`) directly into the target container directory.

---

### 7. What does `-p 8080:80` mean?
This is a **port publishing instruction** that maps port `8080` on the **host machine** to port `80` inside the **container**.
Any incoming traffic hitting `http://<host-ip>:8080` is intercepted by Docker's proxy daemon and routed securely to the service listening on port `80` inside the isolated container environment.

---

### 8. How do you check how much disk space Docker is using?
To check disk space usage across images, active containers, volumes, and build caches, execute:
```bash
$ docker system df
```

#### 🖥️ Console Output:
```text
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          14        6         2.84GB    1.24GB (43%)
Containers      4         2         54.2kB    18.1kB (33%)
Local Volumes   6         2         456.8MB   184.5MB (40%)
Build Cache     22        0         210.4MB   210.4MB
```

To see a detailed, granular breakdown (including exact image tags and container names), run:
```bash
$ docker system df -v
```

---

## 🧠 Revisit Weak Spots: Deep-Dive Hands-On

To consolidate my learning, I picked the **two most complex topics** from Days 29–36 to reinforce.

### 🔍 Deep Dive 1: Docker Multi-Stage Build & Runtime Security
Multi-stage builds are essential for production containers. Here is how I structured a Node.js API to run securely under a non-root system user.

#### 🐳 Production-Grade Multi-Stage Dockerfile
```dockerfile
# STAGE 1: Build & Compile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
# Compile TypeScript or run build scripts
RUN npm run build

# STAGE 2: Lightweight Runtime
FROM node:18-alpine AS runner
WORKDIR /usr/share/app
ENV NODE_ENV=production

# 🔒 Create secure system group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy dependencies and compiled files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Enforce secure ownership and switch user context
RUN chown -R appuser:appgroup /usr/share/app
USER appuser

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode===200)process.exit(0);else process.exit(1);})"

CMD ["node", "dist/index.js"]
```

---

### 🔍 Deep Dive 2: Race Conditions & Compose Healthchecks
When a multi-container system boots up, databases (like Postgres) take several seconds to initialize their internal configurations and accept TCP connections. Standard microservices will immediately crash on startup because they boot instantly and attempt to connect before the database is ready.

To solve this, I designed a robust two-tiered check using Docker Compose:
1. **Container Service Healthcheck:** Checks database ready status inside the DBMS container.
2. **Compose Dependency Condition:** Enforces that the web service only launches once the DBMS passes its health checks.

#### 📝 Docker Compose Synchronization Configuration (`docker-compose.yml`)
```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    container_name: product-db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: SecretPassword2026
      POSTGRES_DB: app_db
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-net
    # 🐘 Database readiness healthcheck
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 5s
      timeout: 5s
      retries: 5
      start_period: 5s

  api:
    build: .
    container_name: product-api
    ports:
      - "8080:8080"
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: admin
      DB_PASSWORD: SecretPassword2026
      DB_NAME: app_db
    # 🔗 Ensure DB is fully operational before boot
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-net

volumes:
  db_data:

networks:
  app-net:
    driver: bridge
```

#### 🖥️ Boot Execution Console Logs:
Observe how the orchestration waits for the database health status before starting the API container:
```bash
$ docker compose up -d
```
```text
[+] Running 3/3
 ✔ Network app-net        Created                                           0.1s
 ✔ Container product-db   Healthy                                           5.1s
 ✔ Container product-api  Started                                           5.4s
```

---

## 📸 Verification & Verification Screenshot

Below is a graphical representation of the verification tests running locally on my terminal, showcasing system pruning, container statuses, and disk utilization checks:

> [!TIP]
> **Docker Revision Status:**
> All containers are operating normally with optimal volume bindings and secure network connections.
> ![Docker System Status Overview](https://raw.githubusercontent.com/rajatmehta2/90DaysOfDevOps/main/2026/day-37/images/docker_revision_checks.png)

---

## 🎓 Completion Summary

- [x] **Consolidation**: Completed an exhaustive self-check of Days 29–36.
- [x] **Theoretical Foundation**: Formulated exact interview-grade answers for 8 core quick-fire questions.
- [x] **Hands-on Weak Areas**: Deep-dived into Node.js runtime security, multi-stage builds, and Compose health check synchronization.
- [x] **Cheat Sheet Integration**: Created a highly practical reference sheet in `docker-cheatsheet.md`.

---

## 🔗 Connect with me!

Let's discuss and learn together! Feel free to connect and share your revision methods:

* **LinkedIn**: [Rajat Mehta](https://linkedin.com/in/rajatmehta)
* **GitHub**: [@rajatmehta2](https://github.com/rajatmehta2)

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#DockerRevision` `#Containerization`
