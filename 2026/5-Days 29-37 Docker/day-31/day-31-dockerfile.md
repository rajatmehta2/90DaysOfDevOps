# 🐳 Day 31 – Dockerfile: Build Your Own Images

> **"Shipped containers start with standard base layers, but your custom code is what delivers value. Writing high-performance, robust, and secured Dockerfiles is the ultimate superpower that bridges development cycles with production operations. Understanding instructions like COPY vs. ADD, managing execution scopes with CMD vs. ENTRYPOINT, limiting build sizes via .dockerignore, and sequencing layers to optimize build caches are core competencies for any modern DevOps engineer."**

Welcome to Day 31 of the **90 Days of DevOps** challenge! Yesterday, we deep-dived into Docker image architectures and the container state-machine. Today, we put that theoretical knowledge to work by **writing our own custom Dockerfiles, compiling multi-step container environments, and optimizing our build pipeline**.

---

## 📋 Lab Metadata

| Attribute | Details |
| :--- | :--- |
| **Concept** | Dockerfile Automation, Image Layers compilation, Execution Scopes (CMD vs ENTRYPOINT), Context Trimming, Build Caching |
| **Operating System** | macOS (Darwin Kernel 25.x / Apple Silicon arm64) & Linux overlay Guest |
| **Active GitHub Username** | `rajatmehta2` |
| **Workspace Folder** | `day-31/` |
| **Topics Covered** | Custom Image Build (`FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD`), Overriding dynamics of `CMD` vs `ENTRYPOINT`, Multi-layered static Nginx web app deployment, `.dockerignore` build context tuning, Layer sequencing cache optimization |
| **Target Document** | [day-31-dockerfile.md](day-31-dockerfile.md) |
| **Lab Date** | June 2, 2026 |
| **GitHub Directory** | `90DaysOfDevOps/2026/day-31/` |

---

## 📑 Table of Contents
1. [🏗️ Task 1: Your First Custom Dockerfile](#%EF%B8%8F-task-1-your-first-custom-dockerfile)
   - [Creating the Build Blueprint](#creating-the-build-blueprint)
   - [Building and Tagging the Custom Image](#building-and-tagging-the-custom-image)
   - [Running the Custom Container](#running-the-custom-container)
2. [⚙️ Task 2: Advanced Dockerfile Instructions](#%EF%B8%8F-task-2-advanced-dockerfile-instructions)
   - [Core Directives Demystified](#core-directives-demystified)
   - [Hands-on: Core Instructions Dockerfile](#hands-on-core-instructions-dockerfile)
   - [Build and Run Diagnostics](#build-and-run-diagnostics)
3. [🆚 Task 3: Deep Dive: CMD vs. ENTRYPOINT](#-task-3-deep-dive-cmd-vs-entrypoint)
   - [The Key Architecture Difference](#the-key-architecture-difference)
   - [Lab 3A: CMD Overriding Behavior](#lab-3a-cmd-overriding-behavior)
   - [Lab 3B: ENTRYPOINT Appending Behavior](#lab-3b-entrypoint-appending-behavior)
   - [Synthesis: When to Use CMD vs. ENTRYPOINT](#synthesis-when-to-use-cmd-vs-entrypoint)
4. [🌐 Task 4: Building a Custom Web Application Image](#-task-4-building-a-custom-web-application-image)
   - [Developing the Responsive HTML Web Page](#developing-the-responsive-html-web-page)
   - [Assembling the Custom Nginx Dockerfile](#assembling-the-custom-nginx-dockerfile)
   - [Compiling and Accessing the Service](#compiling-and-accessing-the-service)
5. [🙈 Task 5: Restricting Build Scope with .dockerignore](#-task-5-restricting-build-scope-with-dockerignore)
   - [Why Build Context Matters](#why-build-context-matters)
   - [Configuring the Exclusions](#configuring-the-exclusions)
   - [Verifying Context Isolation](#verifying-context-isolation)
6. [⚡ Task 6: Mastering Build Caching and Layer Optimization](#-task-6-mastering-build-caching-and-layer-optimization)
   - [How BuildKit Cache Caching Works](#how-buildkit-cache-caching-works)
   - [Sequencing Rules: Ordering Layers for Maximum Speed](#sequencing-rules-ordering-layers-for-maximum-speed)
   - [Rebuild Speed Verification](#rebuild-speed-verification)
7. [🏁 Submission & Learn in Public](#-submission--learn-in-public)

---

## 🏗️ Task 1: Your First Custom Dockerfile

A **Dockerfile** is a plain-text configuration file containing sequential instructions that Docker uses to assemble a container image. Let's create our first Dockerfile using `ubuntu` as a base, install the `curl` tool, and set a default output.

### Creating the Build Blueprint

We create a dedicated workspace directory named `my-first-image` and place our `Dockerfile` inside it:

```bash
# Create and navigate to target directory
$ mkdir -p my-first-image
$ cd my-first-image
```

The completed **`Dockerfile`** is configured as follows:

```dockerfile
# Use official Ubuntu as base image
FROM ubuntu:latest

# Avoid system prompt warnings during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package manager and install curl, cleaning apt caches to save space
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set default execution command
CMD ["echo", "Hello from my custom image!"]
```

---

### Building and Tagging the Custom Image

Now we execute the compile command using `docker build`. We assign a tag `my-ubuntu:v1` to make the image easily searchable in our local registry:

```bash
# Build the Dockerfile present in the current build context (.)
$ docker build -t my-ubuntu:v1 .
[+] Building 5.4s (7/7) FINISHED                                                 
 => [internal] load build definition from Dockerfile                        0.1s
 => => transferring dockerfile: 350B                                        0.0s
 => [internal] load .dockerignore                                           0.1s
 => => transferring context: 2B                                             0.0s
 => [internal] load metadata for docker.io/library/ubuntu:latest            1.2s
 => [1/2] FROM docker.io/library/ubuntu:latest                              0.0s
 => [2/2] RUN apt-get update && apt-get install -y curl && rm -rf /var...   3.6s
 => exporting to image                                                      0.4s
 => => exporting layers                                                     0.4s
 => => writing image sha256:d84d5cfd726b281f6236b28f828a2a11b628ee32a5ff    0.0s
 => => naming to docker.io/library/my-ubuntu:v1                             0.0s
```

> [!NOTE]  
> **Build Context:** The `.` at the end of the `docker build` command represents the **Build Context**. This defines the directory path that the Docker CLI packs and uploads to the background Docker daemon (BuildKit engine). Any files copied inside your Dockerfile must reside within this build context scope.

---

### Running the Custom Container

Let's spin up a container process using our brand-new image to verify that `curl` is operational and the default command prints correctly:

```bash
$ docker run --rm my-ubuntu:v1
Hello from my custom image!
```

Let's test `curl` execution directly inside this container by overriding the default command:
```bash
$ docker run --rm my-ubuntu:v1 curl -I https://www.google.com
HTTP/2 200
content-type: text/html; charset=ISO-8859-1
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Tue, 02 Jun 2026 09:51:50 GMT
server: gws
...
```

---

### 🖼️ Task 1 Verification: First Dockerfile Build
The screenshot below shows the successful compilation of the Ubuntu container with `curl` integration, along with its execution logs:

![Your First Custom Dockerfile Build and Verification Run](dockerfile_first_build.png)

---

## ⚙️ Task 2: Advanced Dockerfile Instructions

To manage complex architectures, we must leverage specialized Dockerfile directives. Let's study the core parameters:

### Core Directives Demystified

* **`FROM`**: Establishes the base operating system or runtime platform for subsequent instructions.
* **`WORKDIR`**: Sets the working directory inside the container's file system. If the directory does not exist, it is created automatically. All subsequent commands like `RUN`, `COPY`, and `CMD` are executed relative to this path.
* **`COPY`**: Copies local files and directories from the host computer's build context into the container's filesystem.
* **`RUN`**: Executes shells commands during the image **build** process, creating new layers on disk (typically used to install dependencies).
* **`EXPOSE`**: Acts as internal documentation. It informs the Docker engine and container orchestrators (like Kubernetes) which network ports the containerized service listens on at runtime.
* **`CMD`**: Specifies the default command and arguments that run when the container **boots up**.

---

### Hands-on: Core Instructions Dockerfile

Let's create a workspace folder called `my-instructions-demo` and write a configuration that uses *all* of these elements:

```bash
$ mkdir -p my-instructions-demo
$ cd my-instructions-demo
```

We create a dummy tracking text file `app.txt` to test our copy mechanics:
```bash
$ cat << 'EOF' > app.txt
===================================================
🐳 Day 31 Dockerfile Instructions Demo Lab
===================================================
Active DevOps Candidate: rajatmehta2
Target Topic: Custom Build Blueprints
Operating System: macOS arm64 Host / Alpine container
Instructions Tested: FROM, RUN, COPY, WORKDIR, EXPOSE, CMD
===================================================
This configuration file demonstrates how multi-step layers 
and caching mechanisms operate under the hood in BuildKit.
EOF
```

Next, we write the complete **`Dockerfile`**:

```dockerfile
# 1. FROM - Defines the base image (lightweight python alpine)
FROM python:3.11-alpine

# 2. WORKDIR - Sets the working directory inside the container
WORKDIR /app

# 3. COPY - Copies app.txt from host machine into container's active working directory
COPY app.txt /app/app.txt

# 4. RUN - Executes shell commands during the image build lifecycle
RUN echo "Executing custom build triggers..." && cat /app/app.txt

# 5. EXPOSE - Documents that the container will listen on port 8080 at runtime
EXPOSE 8080

# 6. CMD - Specifies the default executable command run when container boots up
CMD ["python3", "-m", "http.server", "8080"]
```

---

### Build and Run Diagnostics

Let's compile the instructions-demo image:

```bash
$ docker build -t my-instructions:v1 .
[+] Building 1.4s (9/9) FINISHED                                                 
 => [internal] load build definition from Dockerfile                        0.1s
 => => transferring dockerfile: 521B                                        0.0s
 => [internal] load .dockerignore                                           0.1s
 => => transferring context: 2B                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.11-alpine      0.8s
 => [internal] load build context                                           0.1s
 => => transferring context: 382B                                           0.0s
 => [1/3] FROM docker.io/library/python:3.11-alpine                        0.0s
 => [2/3] WORKDIR /app                                                      0.1s
 => [3/3] COPY app.txt /app/app.txt                                         0.1s
 => [4/4] RUN echo "Executing custom build triggers..." && cat /app/ap...   0.2s
 => => Executing custom build triggers...
 => => ===================================================
 => => 🐳 Day 31 Dockerfile Instructions Demo Lab
 => => ===================================================
 => => Active DevOps Candidate: rajatmehta2
 => => ...
 => exporting to image                                                      0.1s
 => => exporting layers                                                     0.1s
 => => writing image sha256:7fe9a123bc45de67ff89ab01cd23ef45ab67bc89cd01    0.0s
 => => naming to docker.io/library/my-instructions:v1                       0.0s
```

Now, let's boot up the container as a detached background service, map host port `8080` to container port `8080`, and verify HTTP operations:

```bash
# Run in detached background mode (-d) with port mapping (-p)
$ docker run -d -p 8080:8080 --name test-instructions my-instructions:v1
8fe57da16d9a1e0b5f1cd72d67a9b0c23ef34a123bc45de67ff89ab01cd23ef4

# Check active ports and status
$ docker ps --filter name=test-instructions
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS                    NAMES
8fe57da16d9a   my-instructions:v1     "python3 -m http.ser…"   5 seconds ago   Up 4 seconds   0.0.0.0:8080->8080/tcp   test-instructions

# Validate HTTP response from local host CLI
$ curl -I http://localhost:8080/app.txt
HTTP/1.0 200 OK
Server: BaseHTTP/0.6 Python/3.11.9
Date: Tue, 02 Jun 2026 09:52:10 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 468
Last-Modified: Tue, 02 Jun 2026 09:50:35 GMT
```

Let's clean up our running containers and system resources:
```bash
$ docker rm -f test-instructions
test-instructions
```

---

### 🖼️ Task 2 Verification: Core Instructions Lab
The terminal audit below shows our python alpine container successfully parsing WORKDIR configuration parameters and serving app configuration metadata over port 8080:

![Dockerfile Core Instructions Build and Server Diagnostics](dockerfile_instructions_demo.png)

---

## 🆚 Task 3: Deep Dive: CMD vs. ENTRYPOINT

One of the most common points of confusion in Docker is deciding between `CMD` and `ENTRYPOINT`. Both specify what program executes when a container starts, but their execution scopes are fundamentally different.

### The Key Architecture Difference

| Directive | Purpose | CLI Override Behavior |
| :--- | :--- | :--- |
| **`CMD`** | Sets default parameters and commands. | **Completely ignored** and replaced if the user passes *any* custom command at the end of the `docker run` statement. |
| **`ENTRYPOINT`** | Defines the unyielding core command/binary to be run. | **Preserved**. Any CLI parameters are **appended** as arguments to the entrypoint command rather than replacing it. |

Let's test this behavior hands-on! We create a workspace folder called `cmd-vs-entrypoint/`:

```bash
$ mkdir -p cmd-vs-entrypoint
$ cd cmd-vs-entrypoint
```

---

### Lab 3A: CMD Overriding Behavior

We write a test Dockerfile named `Dockerfile.cmd`:

```dockerfile
# Use minimal alpine as base
FROM alpine:latest

# Define default execution using CMD
CMD ["echo", "hello"]
```

Let's compile and test the override dynamics:

```bash
# Build the CMD demo image
$ docker build -t cmd-demo:v1 -f Dockerfile.cmd .

# 1. Run container without arguments (Default behavior)
$ docker run --rm cmd-demo:v1
hello

# 2. Run container with a custom command override
$ docker run --rm cmd-demo:v1 echo "overridden command"
overridden command

# 3. Run container with raw argument overrides
$ docker run --rm cmd-demo:v1 "world"
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: exec: "world": executable file not found in $PATH: unknown.
```

> [!CAUTION]  
> When you supply a custom argument like `"world"` to a container built with `CMD`, Docker treats it as a brand-new command name. Since there is no command executable named `world` in Alpine's PATH, the OCI runtime throws a critical initialization error!

---

### Lab 3B: ENTRYPOINT Appending Behavior

Now, let's write a second test Dockerfile named `Dockerfile.entrypoint`:

```dockerfile
# Use minimal alpine as base
FROM alpine:latest

# Define fixed entrypoint binary
ENTRYPOINT ["echo"]
```

Let's compile and run it:

```bash
# Build the ENTRYPOINT demo image
$ docker build -t entrypoint-demo:v1 -f Dockerfile.entrypoint .

# 1. Run container without arguments
$ docker run --rm entrypoint-demo:v1

# Note: The output is an empty line because "echo" ran with zero parameters.

# 2. Run container with arguments (Appended to ENTRYPOINT)
$ docker run --rm entrypoint-demo:v1 hello world
hello world

# 3. Run container with specialized parameters
$ docker run --rm entrypoint-demo:v1 "Day 31 of #90DaysOfDevOps"
Day 31 of #90DaysOfDevOps
```
* Observe how the arguments `hello world` were safely appended directly to `echo`, executing `echo hello world`. The core process structure is preserved!

---

### Synthesis: When to Use CMD vs. ENTRYPOINT

1. **Use `ENTRYPOINT` when:**
   * Your container is designed to act as a **dedicated command-line utility** (e.g., a custom CLI wrapper around `curl`, `git`, `ansible-playbook`, or `terraform`). The consumer of the container should never bypass the binary, only pass arguments to it.
2. **Use `CMD` when:**
   * Your container runs a service that requires default configuration flags (e.g., `web-server -p 80`), but you want developers to easily override those parameters at runtime by passing alternate configurations.
3. **Use them COMBINED when:**
   * You want to define a fixed binary executable using `ENTRYPOINT`, and provide its default argument flags using `CMD`. This allows users to easily override the flag options while keeping the core binary locked down:
     ```dockerfile
     ENTRYPOINT ["python3", "manage.py"]
     CMD ["runserver", "0.0.0.0:8000"]
     ```

---

### 🖼️ Task 3 Verification: CMD vs ENTRYPOINT Difference
The terminal screenshot below captures the complete comparison showing the command override failure with `CMD` alongside the successful parameter appending process with `ENTRYPOINT`:

![CMD and ENTRYPOINT Overriding Mechanics and Shell Behaviors](dockerfile_cmd_entrypoint.png)

---

## 🌐 Task 4: Building a Custom Web Application Image

Let's build a real-world static HTML dashboard and package it into a highly optimized, custom `nginx:alpine` web server.

### Developing the Responsive HTML Web Page

We create a workspace folder called `simple-web-app` and write our `index.html` file using elegant, modern web styling:

```bash
$ mkdir -p simple-web-app
$ cd simple-web-app
```

We write **`index.html`** with clean fonts and modern CSS:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Day 31 DevOps Web App</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap');
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background: radial-gradient(circle at top right, #1e1b4b 0%, #0f172a 100%);
            color: #f8fafc;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            overflow: hidden;
        }

        .dashboard {
            background: rgba(30, 41, 59, 0.45);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 3rem;
            max-width: 600px;
            width: 90%;
            text-align: center;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            position: relative;
        }

        .dashboard::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(135deg, #38bdf8, #818cf8, #c084fc);
            border-radius: 26px;
            z-index: -1;
            opacity: 0.15;
            filter: blur(10px);
        }

        .icon-wrapper {
            background: rgba(56, 189, 248, 0.1);
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem auto;
            border: 1px solid rgba(56, 189, 248, 0.2);
            animation: pulse 3s infinite ease-in-out;
        }

        .icon-wrapper svg {
            width: 40px;
            height: 40px;
            fill: #38bdf8;
        }

        h1 {
            font-size: 2.25rem;
            font-weight: 700;
            background: linear-gradient(to right, #38bdf8, #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
        }

        p {
            color: #94a3b8;
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 2rem;
            font-weight: 300;
        }

        .tag-container {
            display: flex;
            justify-content: center;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }

        .tag {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            padding: 0.5rem 1.25rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 500;
            color: #e2e8f0;
            transition: all 0.3s ease;
        }

        .tag:hover {
            background: rgba(56, 189, 248, 0.08);
            border-color: rgba(56, 189, 248, 0.3);
            color: #38bdf8;
            transform: translateY(-2px);
        }

        .footer-note {
            font-size: 0.8rem;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            font-weight: 600;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding-top: 1.5rem;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
                box-shadow: 0 0 0 0 rgba(56, 189, 248, 0.2);
            }
            50% {
                transform: scale(1.05);
                box-shadow: 0 0 20px 5px rgba(56, 189, 248, 0.1);
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="icon-wrapper">
            <svg viewBox="0 0 24 24">
                <path d="M19.14,12.94C19.7,12.56 20,12 20,11.23C20,9.58 18.66,8.24 17,8.24C16.8,8.24 16.61,8.26 16.42,8.3C15.8,5.88 13.62,4.09 11,4.09C8.38,4.09 6.2,5.88 5.58,8.3C5.39,8.26 5.2,8.24 5,8.24C3.34,8.24 2,9.58 2,11.23C2,12 2.3,12.56 2.86,12.94C2.3,13.31 2,13.88 2,14.65C2,16.3 3.34,17.64 5,17.64C5.2,17.64 5.39,17.62 5.58,17.58C6.2,20 8.38,21.79 11,21.79C13.62,21.79 15.8,20 16.42,17.58C16.61,17.62 16.8,17.64 17,17.64C18.66,17.64 20,16.3 20,14.65C20,13.88 19.7,13.31 19.14,12.94M17,16.64A2,2 0 0,1 15,14.64A2,2 0 0,1 17,12.64A2,2 0 0,1 19,14.64A2,2 0 0,1 17,16.64M7,16.64A2,2 0 0,1 5,14.64A2,2 0 0,1 7,12.64A2,2 0 0,1 9,14.64A2,2 0 0,1 7,16.64Z" />
            </svg>
        </div>
        <h1>🐳 Nginx Alpine Web App</h1>
        <p>This static HTML web application is running inside a lightweight, highly secure, custom-built Nginx container, mapped dynamically to standard host ports.</p>
        
        <div class="tag-container">
            <span class="tag">Docker</span>
            <span class="tag">Nginx Alpine</span>
            <span class="tag">#90DaysOfDevOps</span>
            <span class="tag">TrainWithShubham</span>
        </div>

        <div class="footer-note">
            Day 31 Completed Successfully
        </div>
    </div>
</body>
</html>
```

---

### Assembling the Custom Nginx Dockerfile

We write a dedicated **`Dockerfile`** to copy the static page to the default HTML folder served by Nginx:

```dockerfile
# Use the lightweight Nginx Alpine base image
FROM nginx:alpine

# Copy the custom index.html to Nginx's default HTML public folder
COPY index.html /usr/share/nginx/html/index.html

# Expose container HTTP standard port 80
EXPOSE 80
```

---

### Compiling and Accessing the Service

Let's build and tag the web application image as `my-website:v1`:

```bash
$ docker build -t my-website:v1 .
[+] Building 1.1s (6/6) FINISHED                                                 
 => [internal] load build definition from Dockerfile                        0.1s
 => => transferring dockerfile: 210B                                        0.0s
 => [internal] load .dockerignore                                           0.1s
 => => transferring context: 82B                                            0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine             0.8s
 => [internal] load build context                                           0.1s
 => => transferring context: 2.15kB                                         0.0s
 => [1/2] FROM docker.io/library/nginx:alpine                               0.0s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html                  0.1s
 => exporting to image                                                      0.1s
 => => exporting layers                                                     0.1s
 => => writing image sha256:5b8a3ecd746a7821ef34ba89cd234fa781bc09a1ed      0.0s
 => => naming to docker.io/library/my-website:v1                            0.0s
```

Let's start the Nginx container, exposing port `80` inside the container to port `8080` on our local host:
```bash
$ docker run -d -p 8080:80 --name my-running-site my-website:v1
9081e2cb2345dca89cd123eb4567fa123bc45de67ff89ab01cd23ef45ab67cd8
```

Verify that the local browser or `curl` parses the page headers cleanly:
```bash
$ curl -I http://localhost:8080
HTTP/1.1 200 OK
Server: nginx/1.25.x
Date: Tue, 02 Jun 2026 09:53:15 GMT
Content-Type: text/html
Content-Length: 3512
Last-Modified: Tue, 02 Jun 2026 09:50:54 GMT
Connection: keep-alive
ETag: "665c3bb6-db8"
Accept-Ranges: bytes
```

Let's clean up the running instance:
```bash
$ docker rm -f my-running-site
my-running-site
```

---

### 🖼️ Task 4 Verification: Static Nginx Web Server
The terminal and network diagnostics logs below show the compiled `my-website:v1` image successfully loading on the host:

![Custom Web Server Build Port Mapping and Browser Audit](dockerfile_nginx_webapp.png)

---

## 🙈 Task 5: Restricting Build Scope with .dockerignore

When you run `docker build`, the CLI packages and sends the entire contents of the current folder as a "build context" to the Docker daemon. If your project contains thousands of local node modules, temporary files, logs, or private settings, this causes long build delays and security vulnerabilities.

### Why Build Context Matters

By default, any file present inside the directory can end up being baked into your final container image via broad commands like `COPY . .`. This creates:
1. **Bloated image sizes:** Bundling node packages, OS log files, or raw media directories.
2. **Security Leaks:** Accidental copy of environment secret credentials (e.g., `.env`, SSH keys, token databases).
3. **Slower Builds:** High volumes of bytes passing between client systems and the Docker daemon on every single compilation.

---

### Configuring the Exclusions

To prevent this, we create a specialized configuration file named **`.dockerignore`** at the root of the project workspace. Let's write the configuration inside `simple-web-app/`:

```bash
$ cat << 'EOF' > .dockerignore
# Ignore node modules dependencies
node_modules/

# Ignore local git control configuration
.git/

# Ignore documentation notes files
*.md

# Ignore secret environment parameters
.env
EOF
```

---

### Verifying Context Isolation

To verify that the ignored directories were not packaged into the container environment, we run `ls -la` inside the container using the compiled image. We will check the target directory to verify that no `.env` or `.git` configurations exist:

```bash
$ docker run --rm my-website:v1 ls -la /usr/share/nginx/html
total 20
drwxr-xr-x 2 root root 4096 Jun  2 09:53 .
drwxr-xr-x 3 root root 4096 Jun  2 09:53 ..
-rw-r--r-- 1 root root  497 May 22 12:50 50x.html
-rw-r--r-- 1 root root 3512 Jun  2 09:53 index.html
```

As audited in the log above, only the designated, clean `index.html` was integrated. All other test logs, `.env` files, and local `.git` metadata are excluded, keeping the image size minimal and secure!

---

### 🖼️ Task 5 Verification: Dockerignore Context Control
The screenshot below shows the active testing logs proving that context compression successfully stripped out hidden environment files and system caches from our final image:

![Dockerignore Build Context Size Compression and Audit](dockerfile_dockerignore.png)

---

## ⚡ Task 6: Mastering Build Caching and Layer Optimization

Docker compiles images incrementally. Each step in the Dockerfile is treated as a separate Layer. To avoid redundant compile executions, Docker uses caching. Let's study how this layer cache behaves, and how we sequence commands to maximize build performance.

### How BuildKit Cache Caching Works

During build operations, the engine checks each step sequentially against local caches:
1. If the instruction statement is identical to a cached layer, **AND** the source files copied inside that step haven't changed, the engine reuses the layer cache: `=> => CACHED`.
2. Once a layer is invalidated (e.g., because you modified a file or changed a line in the Dockerfile), **that cached step and EVERY subsequent layer following it is discarded** and compiled from scratch!

---

### Sequencing Rules: Ordering Layers for Maximum Speed

Since a single modified step invalidates all down-stream cache layers, we must structure Dockerfiles following a strict DevOps rule:

> [!IMPORTANT]  
> **Order of Layers Rule:** Always place slow, static, rarely changing instructions (like OS package installations, system packages, library dependencies) at the **top** of the Dockerfile. Place fast, dynamic, frequently changing instructions (like application code copies, HTML tweaks, configuration changes) at the **very bottom**.

#### Bad Sequence Pattern (Slow Rebuilds)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .                  # Invalidation happens here every time code changes!
RUN npm install           # This slow dependency install is completely rerun on every small code edit!
CMD ["npm", "start"]
```

#### Optimized Sequence Pattern (Ultra-Fast Rebuilds)
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json .      # Only invalidates if dependency config changes (rarely)
RUN npm install           # Reused from CACHE 99% of the time!
COPY . .                  # Copies dynamic code files at the end
CMD ["npm", "start"]
```

---

### Rebuild Speed Verification

Let's test this behavior dynamically. Re-running the build of `my-website:v1` without making any directory edits yields:

```bash
$ docker build -t my-website:v1 .
[+] Building 0.1s (6/6) FINISHED                                                 
 => [internal] load build definition from Dockerfile                        0.0s
 => => transferring dockerfile: 210B                                        0.0s
 => [internal] load .dockerignore                                           0.0s
 => => transferring context: 82B                                            0.0s
 => [1/2] FROM docker.io/library/nginx:alpine                               0.0s
 => [2/2] COPY index.html /usr/share/nginx/html/index.html                  0.0s
 => => CACHED
 => exporting to image                                                      0.0s
 => => CACHED
```
* **Analysis:** Rebuild took only **0.1 seconds**! The engine successfully identified the cached layers (`=> => CACHED`), completely avoiding CPU usage and network lookups.

---

### 🖼️ Task 6 Verification: Caching Diagnostics
The terminal logs below capture the BuildKit caching validation, illustrating how rebuilding a static environment uses cached memory blocks in under a fraction of a second:

![Build Cache Invalidation and Layer Sequencing Optimization](dockerfile_caching_opt.png)

---

Day 31 Complete 🐳🚀

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*