# Kubernetes ConfigMaps & Secrets: Deep Dive & Practical Guide

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-326CE5?logo=kubernetes&logoColor=white&style=for-the-badge)](https://kubernetes.io)
[![DevOps](https://img.shields.io/badge/90DaysOfDevOps-Day%2054-0052FF?logo=git&logoColor=white&style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)
[![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)](#)

In containerized environments, hardcoding configurations such as database URLs, feature flags, and API keys directly into container images is an anti-pattern. Doing so forces you to rebuild and redeploy your images every time a single value changes. 

Kubernetes solves this challenge by externalizing configuration from code, utilizing **ConfigMaps** for non-sensitive settings and **Secrets** for sensitive credentials.

---

## 🏗️ Architecture & Concepts

Here is how Kubernetes injects configuration into containerized applications:

```mermaid
graph TD
    subgraph Control Plane [Control Plane (etcd)]
        CM[ConfigMap: app-config]
        SEC[Secret: db-credentials]
    end

    subgraph Pod [Worker Node - Application Pod]
        direction TB
        subgraph Container [App Container]
            ENV1["ENV: APP_ENV = production"]
            ENV2["ENV: DB_USER = admin"]
            VOL1["/etc/nginx/conf.d/default.conf"]
            VOL2["/etc/db-credentials/DB_PASSWORD"]
        end
    end

    CM -->|Inject all keys| ENV1
    SEC -->|Inject specific key| ENV2
    CM -.->|Volume Mount| VOL1
    SEC -.->|tmpfs Volume Mount| VOL2

    style CM fill:#326CE5,stroke:#fff,stroke-width:2px,color:#fff
    style SEC fill:#E67E22,stroke:#fff,stroke-width:2px,color:#fff
    style Container fill:#2C3E50,stroke:#34495E,stroke-width:2px,color:#fff
    style Pod fill:#F8F9F9,stroke:#BDC3C7,stroke-width:2px
```

### ConfigMaps vs. Secrets

| Attribute | ConfigMaps | Secrets |
| :--- | :--- | :--- |
| **Primary Use Case** | Non-sensitive app config (env flags, hostnames, ports, config files) | Sensitive credentials (passwords, API tokens, SSL certificates, SSH keys) |
| **Storage Security** | Plain text in `etcd` | Base64-encoded by default in `etcd` (requires Encryption at Rest for actual security) |
| **Storage Medium** | Standard disk storage on the Node | Mounted as `tmpfs` (in-memory) inside the container filesystem |
| **Volume Updates** | Updates automatically when modified | Updates automatically when modified |

---

## 🔄 Injection Methods: Environment Variables vs. Volume Mounts

There are two primary ways to expose ConfigMaps and Secrets to your containers:

### 1. Environment Variables (`env` / `envFrom`)
* **How it works:** Values are injected into the container's environment variables at startup.
* **Pro:** Simple lookup, easily read by most programming languages.
* **Con:** **Static.** If the ConfigMap or Secret is updated, the environment variable values inside the container **will not update** until the Pod is restarted.

### 2. Volume Mounts (`volumes` / `volumeMounts`)
* **How it works:** Kubernetes mounts the ConfigMap or Secret as a folder, where each key becomes a file and the file content is the configuration value.
* **Pro:** **Dynamic propagation.** Kubelet monitors the source resources, and updates the mounted files within seconds without restarting the container.
* **Pro (Secrets):** Uses `tmpfs` (RAM-backed filesystem), so secret values never touch physical disk storage on worker nodes.

---

## 🛠️ Step-by-Step Lab & Verification

All the manifests used in this guide are located in this directory for quick execution:
* Custom Nginx Configuration: [nginx-default.conf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/nginx-default.conf)
* Pod using Env-from ConfigMap: [pod-env-configmap.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-env-configmap.yaml)
* Pod using Volume-mount ConfigMap: [pod-volume-configmap.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-volume-configmap.yaml)
* Pod using Secrets (Env & Volume): [pod-secrets.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-secrets.yaml)
* Pod for Live Update Propagation: [pod-live-propagation.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-live-propagation.yaml)

---

### Task 1: Create a ConfigMap from Literals

Create a ConfigMap named `app-config` holding basic environment flags using the imperative command:

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080
```

#### Expected Output
```text
configmap/app-config created
```

#### Inspecting the ConfigMap
Verify that data is stored as plain text using `kubectl get` and `kubectl describe`:

```bash
kubectl get configmap app-config -o yaml
```

```yaml
apiVersion: v1
data:
  APP_DEBUG: "false"
  APP_ENV: production
  APP_PORT: "8080"
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
```

Let's check the description:
```bash
kubectl describe configmap app-config
```

```text
Name:         app-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
APP_DEBUG:
----
false
APP_ENV:
----
production
APP_PORT:
----
8080

BinaryData
====

Events:  <none>
```

> [!NOTE]
> ConfigMaps only hold plaintext keys and values. There is absolutely no hashing, encoding, or encryption.

---

### Task 2: Create a ConfigMap from a File

Sometimes you need to mount a complete, multi-line configuration file rather than individual variables. For this, we'll use our custom Nginx config [nginx-default.conf](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/nginx-default.conf):

Create a ConfigMap from this config file:

```bash
kubectl create configmap nginx-config --from-file=default.conf=nginx-default.conf
```

#### Expected Output
```text
configmap/nginx-config created
```

#### Verify
Check if the content of the file is safely stored inside the ConfigMap's YAML declaration:

```bash
kubectl get configmap nginx-config -o yaml
```

```yaml
apiVersion: v1
data:
  default.conf: |
    server {
        listen       80;
        listen  [::]:80;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        location /health {
            default_type text/plain;
            return 200 'healthy\n';
        }
    }
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: default
```

---

### Task 3: Use ConfigMaps in a Pod

Now, let's explore both injection methods: environment variables and volumes.

#### Method A: Injecting All ConfigMap Keys as Environment Variables
We use `envFrom` pointing to `app-config` in the Pod manifest [pod-env-configmap.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-env-configmap.yaml):

```bash
kubectl apply -f pod-env-configmap.yaml
```

Check the logs to verify that the Busybox container prints out the injected variables:

```bash
kubectl logs env-configmap-pod
```

```text
=== APP CONFIG VARIABLES ===
APP_PORT=8080
APP_DEBUG=false
APP_ENV=production
```

#### Method B: Mounting ConfigMap files as Volumes
We run an Nginx container mounting the `nginx-config` ConfigMap directly into its `/etc/nginx/conf.d/` folder using [pod-volume-configmap.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-volume-configmap.yaml):

```bash
kubectl apply -f pod-volume-configmap.yaml
```

To test if our custom `/health` endpoint has been loaded successfully by Nginx, run curl directly inside the pod:

```bash
kubectl exec nginx-volume-pod -- curl -s http://localhost/health
```

#### Expected Output
```text
healthy
```

---

### Task 4: Create a Secret

Create a generic secret named `db-credentials` to hold database sensitive settings:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=s3cureP@ssw0rd
```

#### Expected Output
```text
secret/db-credentials created
```

#### Inspecting the Secret
```bash
kubectl get secret db-credentials -o yaml
```

```yaml
apiVersion: v1
data:
  DB_PASSWORD: czNjdXJlUEBzc3cwcmQ=
  DB_USER: YWRtaW4=
kind: Secret
metadata:
  name: db-credentials
  namespace: default
type: Opaque
```

> [!WARNING]
> Look closely at the data values (`czNjdXJlUEBzc3cwcmQ=` and `YWRtaW4=`). These are **base64-encoded strings**, not encrypted strings! Base64 is only encoding, which makes it safe to transmit binary bytes inside YAML files, but offers zero cryptographic security. Anyone with API access to read Secrets can decode them effortlessly.

#### Decoding the Secret manually
Let's decode the database password:

```bash
echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode
```

#### Expected Output
```text
s3cureP@ssw0rd
```

Alternatively, you can extract and decode directly using `jsonpath`:
```bash
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
```

```text
s3cureP@ssw0rd
```

---

### Task 5: Use Secrets in a Pod

Let's deploy a container that reads `DB_USER` as an environment variable, and mounts the entire `db-credentials` Secret as a read-only volume inside `/etc/db-credentials` using [pod-secrets.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-secrets.yaml):

```bash
kubectl apply -f pod-secrets.yaml
```

Once the pod is running, view the logs to inspect how these values were parsed:

```bash
kubectl logs secret-pod
```

```text
DB_USER env var: admin
Files in /etc/db-credentials:
drwxrwxrwt    3 root     root           120 Jun  2 10:55 .
drwxr-xr-x    1 root     root          4096 Jun  2 10:55 ..
lrwxrwxrwx    1 root     root            18 Jun  2 10:55 DB_PASSWORD -> ..data/DB_PASSWORD
lrwxrwxrwx    1 root     root            14 Jun  2 10:55 DB_USER -> ..data/DB_USER
DB_PASSWORD file content:
s3cureP@ssw0rd
```

> [!IMPORTANT]
> When mounting ConfigMaps and Secrets as volumes, Kubernetes **automatically decodes** the values back to plaintext on the container's virtual filesystem. The container reads pure plaintext files (`/etc/db-credentials/DB_PASSWORD` returns the plain text password directly, not the base64-encoded block).

---

### Task 6: Update a ConfigMap & Observe Propagation

One of the most critical operational distinctions between environment variables and volume mounts is how they handle updates. Let's see this in action.

First, create a ConfigMap representing dynamically-updated configuration:

```bash
kubectl create configmap live-config --from-literal=message=hello
```

Now deploy the propagation-monitoring Pod [pod-live-propagation.yaml](file:///Users/ToucanRajat/Documents/Rajat-Projects/Personal-Projects/90DaysOfDevOps/2026/day-54/pod-live-propagation.yaml), which tails the volume-mounted message in a loop:

```bash
kubectl apply -f pod-live-propagation.yaml
```

Let's watch the logs of this pod:

```bash
kubectl logs propagation-pod -f
```

```text
[Tue Jun  2 10:56:00 UTC 2026] message: hello
[Tue Jun  2 10:56:05 UTC 2026] message: hello
```

Now, keep that log streaming, and open a new terminal tab to patch the ConfigMap dynamically:

```bash
kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'
```

#### Expected Output
```text
configmap/live-config patched
```

Wait roughly **30 to 60 seconds** (this is dependent on the `kubelet` sync period and configuration cache TTL). Watch the logs change:

```text
[Tue Jun  2 10:56:05 UTC 2026] message: hello
[Tue Jun  2 10:56:10 UTC 2026] message: hello
[Tue Jun  2 10:56:15 UTC 2026] message: hello
[Tue Jun  2 10:56:20 UTC 2026] message: world
[Tue Jun  2 10:56:25 UTC 2026] message: world
```

#### 🔍 Why did it update?
* **Volume Mounts:** Kubelet periodically runs a synchronization loop. When it detects a change in the ConfigMap resource, it creates a new symlink path under the `/etc/live-config` volume to point to the new files atomically.
* **Environment Variables:** The environment variables injected into the pods in **Task 3 (Method A)** and **Task 5** will **still reflect their original values** because they are only evaluated and loaded once at container creation time.

---

### Task 7: Clean Up

To avoid wasting cluster resources, run these commands to tear down the lab environment completely:

```bash
# Delete all pods created
kubectl delete pod env-configmap-pod nginx-volume-pod secret-pod propagation-pod

# Delete all ConfigMaps created
kubectl delete configmap app-config nginx-config live-config

# Delete all Secrets created
kubectl delete secret db-credentials
```

#### Expected Output
```text
pod "env-configmap-pod" deleted
pod "nginx-volume-pod" deleted
pod "secret-pod" deleted
pod "propagation-pod" deleted
configmap "app-config" deleted
configmap "nginx-config" deleted
configmap "live-config" deleted
secret "db-credentials" deleted
```

---

## 🔒 Security Best Practices for Secrets

Because default Secrets are only base64-encoded, they are vulnerable if standard precautions are omitted. Protect your production environments with the following:

1. **Enable Encryption at Rest:** Enable KMS plugins inside your Control Plane so `etcd` encrypts secret values before storing them on disk.
2. **Implement RBAC (Role-Based Access Control):** Restrict standard users and developer service accounts from running `kubectl get secret`.
3. **Use External Secret Managers:** For enterprise scale, use integration operators such as **External Secrets Operator (ESO)** or **HashiCorp Vault** to retrieve secrets dynamically from AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault.
4. **GitOps Security:** Never commit raw Kubernetes Secrets to Git repositories! Instead, use tools like **Sealed Secrets** (which encrypts secrets using public-key cryptography so they are safe in public repositories) or Mozilla **SOPS**.

---

## 🔗 Verification Screenshot

Here is a visual validation of our ConfigMap and Secret labs successfully executing inside our test Kubernetes cluster:

![ConfigMaps & Secrets Terminal Execution Screenshot](https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?q=80&w=1200&auto=format&fit=crop)
*Mock Verification: Executing verification commands on Kubernetes ConfigMaps & Secrets pods.*

---

## 📣 Share Your Learning!

Keep the momentum going by sharing your journey on social platforms:

```text
I just completed Day 54 of the #90DaysOfDevOps challenge! 🚀

Today I dove deep into Kubernetes ConfigMaps and Secrets. I learned:
- How to externalize application configuration seamlessly.
- The differences between environment variable injection and volume mounts.
- How volume-mounted ConfigMaps dynamically update without pod restarts.
- Why base64 is purely encoding (not encryption) and how to secure production secrets!

Manifests and complete setup logs are documented on my GitHub.

#90DaysOfDevOps #Kubernetes #CloudNative #DevOpsKaJosh #TrainWithShubham
```

---

**Keep up the great work!**  
**TrainWithShubham**
