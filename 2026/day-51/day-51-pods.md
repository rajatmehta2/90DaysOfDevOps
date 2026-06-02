# Day 51: Kubernetes Manifests and Your First Pods

![Kubernetes Pods & Manifests](./k8s_pods_guide.png)

Welcome to **Day 51** of the **90 Days of DevOps** challenge! Yesterday, we established our foundational knowledge of Kubernetes architecture and successfully launched a local cluster using **kind**. Today, we take our first step in actually running applications on that cluster. 

We will explore the anatomy of a Kubernetes declarative manifest (YAML definition), construct Pods from scratch, learn to manipulate them using the `kubectl` CLI, explore labels and selectors, analyze validation workflows, and understand the core behavioral differences between imperative and declarative deployments.

---

## 🧩 Part 1: The Anatomy of a Kubernetes Manifest

In Kubernetes, we use **declarative manifests** written in YAML to define the *desired state* of our resources. The control plane constantly works to ensure the cluster's *actual state* matches this desired state.

Every Kubernetes API object (whether it is a Pod, Service, Deployment, or ConfigMap) requires four top-level root fields:

| Field Name | Type | Description | Required Value / Example for Pods |
| :--- | :--- | :--- | :--- |
| **`apiVersion`** | String | Which version of the Kubernetes API schema to use when creating the object. | `v1` |
| **`kind`** | String | The type of resource or API object we are defining. | `Pod` |
| **`metadata`** | Object | Data that uniquely identifies the object (e.g., name, namespace, labels, annotations). | `name: nginx-pod` |
| **`spec`** | Object | The actual technical specification of the resource (containers, volumes, ports, environment variables). | `containers: - name: nginx` |

### Visual Blueprint of a Basic Pod Manifest

```yaml
apiVersion: v1          # Schema version (Pods are core resources, so apiVersion is v1)
kind: Pod               # Resource type we want to deploy
metadata:               # Identity information about this resource
  name: my-pod          # The unique identifier of this Pod in its namespace
  labels:               # Arbitrary key-value pairs used for queries and filtering
    app: web-app
    env: dev
spec:                   # The specification of the containers that live in this Pod
  containers:           # A Pod can host one or multiple tightly coupled containers
  - name: my-container  # Name of the container inside the Pod
    image: nginx:latest # Docker Hub image to pull and run
    ports:              # Ports to expose on the container level
    - containerPort: 80
```

---

## 🚀 Part 2: Task 1 - Deploying Your First Pod (Nginx Web Server)

Let's begin by writing a declarative YAML configuration file to deploy an Nginx web server Pod.

### 1. The Pod Manifest: `nginx-pod.yaml`
We create a manifest named `nginx-pod.yaml` containing the Nginx specification:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

### 2. Deploying the Manifest
To send this declaration to the cluster's API Server, we use the `kubectl apply -f` command:

```bash
kubectl apply -f nginx-pod.yaml
```

**Real Terminal Output:**
```text
pod/nginx-pod created
```

---

### 3. Verifying and Exploring the Running Pod

Let's check if the Pod is running and explore its characteristics.

```bash
# Get general pod status
kubectl get pods

# Get detailed network and host details
kubectl get pods -o wide
```

**Real Terminal Output:**
```text
NAME        READY   STATUS    RESTARTS   AGE   IP           NODE                           NOMINATED NODE   READINESS GATES
nginx-pod   1/1     Running   0          62s   10.244.0.5   devops-cluster-control-plane   <none>           <none>
```

> [!TIP]
> The `-o wide` option exposes the Pod's internal IP address (`10.244.0.5`) allocated by the Container Network Interface (CNI), as well as the name of the worker node where it was scheduled.

---

### 4. Deep Inspection and Container Execution

To thoroughly debug and understand how the Pod is running, we can check detailed cluster events or execute a command inside its container.

#### A. Describing the Pod's Lifecycle Events
```bash
kubectl describe pod nginx-pod
```
This lists detailed specification parameters, environment states, and a chronological event log showing scheduling, image pulling, container creation, and startup:

```text
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11s   default-scheduler  Successfully assigned default/nginx-pod to devops-cluster-control-plane
  Normal  Pulling    10s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     5s    kubelet            Successfully pulled image "nginx:latest" in 4.8s (4.8s including waiting)
  Normal  Created    5s    kubelet            Created container nginx
  Normal  Started    5s    kubelet            Started container nginx
```

#### B. Reading Container Logs
```bash
kubectl logs nginx-pod
```

#### C. Getting a Shell & Fetching the Web Page
We can run `curl` directly inside the running container to verify that Nginx is successfully serving web traffic on port 80:

```bash
kubectl exec nginx-pod -- curl -s http://localhost
```

**Real Web Server Response Output:**
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy, 
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional 
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

---

## 🛠️ Part 3: Task 2 - Creating a Custom Long-Running Pod (BusyBox)

A crucial Kubernetes concept to grasp is **container lifecycle management**. When we launch a Pod, Kubernetes monitors the main process running inside the container. If that process exits, the container stops, and the Pod restarts or transitions to a terminated state.

For instance, the **BusyBox** container image doesn't run a background server (like Nginx) by default. If we run it without specifying a persistent instruction, the container exits immediately, leading to a `CrashLoopBackOff` loop. 

### 1. The Pod Manifest: `busybox-pod.yaml`
To keep the container active, we inject a custom persistent script under the `command` attribute:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

### 2. Deploying and Verifying Logs

```bash
# Apply the manifest
kubectl apply -f busybox-pod.yaml

# Check its running state
kubectl get pods

# Read the stdout log output
kubectl logs busybox-pod
```

**Real Terminal Output:**
```text
Hello from BusyBox
```

Because of the `sleep 3600` instruction, our BusyBox container maintains an active process and continues running peacefully inside the cluster!

---

## ⚡ Part 4: Task 3 - Imperative vs. Declarative Approaches

Kubernetes allows you to manage resources in two distinct ways: **Imperative** (run direct command lines) and **Declarative** (write and apply configuration files).

| Feature | Imperative (`kubectl run`) | Declarative (`kubectl apply -f`) |
| :--- | :--- | :--- |
| **Primary Method** | Execute quick shell commands to directly alter state. | Write manifest files detailing the desired configuration. |
| **Best Used For** | Fast scaffolding, quick debugging, dry-run template generation. | Production deployments, source-control history (GitOps), long-term management. |
| **Change Audits** | Hard to track who changed what. | Simple to review, audit, and trace version changes in Git. |
| **Complexity** | Becomes extremely cluttered with flags for large resources. | Highly organized, readable structure that scales easily. |

### 1. Launching an Imperative Pod (Redis)
Instead of writing a YAML file, let's create a Redis Pod instantly using the imperative CLI:

```bash
kubectl run redis-pod --image=redis:latest
```

**Real Terminal Output:**
```text
pod/redis-pod created
```

---

### 2. Contrasting Declarative and Imperative YAML structures

When we execute `kubectl run`, Kubernetes generates the full manifest on the server side, saves it to `etcd`, and populates default settings. 

Let's export the full, live manifest generated under the hood by Kubernetes:

```bash
kubectl get pod redis-pod -o yaml
```

**Live System Generated YAML Output (Abridged):**
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2026-06-02T10:41:37Z"
  generation: 1
  labels:
    run: redis-pod
  name: redis-pod
  namespace: default
  resourceVersion: "818"
  uid: d3a268d6-a0c3-45b0-a85c-4658c46c1780
spec:
  containers:
  - image: redis:latest
    imagePullPolicy: Always
    name: redis-pod
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
...
status:
  phase: Running
  podIP: 10.244.0.8
```

> [!NOTE]
> Observe the structural differences: Kubernetes dynamically added operational fields such as `creationTimestamp`, `uid`, `resourceVersion`, automated network default options (`imagePullPolicy: Always`), and a live `status` tree.

---

### 💡 Pro-Tip: Scaffolding Declarative Templates Imperatively
You can leverage imperative commands to rapidly scaffold clean YAML templates without actually launching the resource. This is your best friend when writing configurations under pressure:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

**Real Terminal Output:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: test-pod
  name: test-pod
spec:
  containers:
  - image: nginx
    name: test-pod
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

---

## 🔍 Part 5: Task 4 - Manifest Validation Workflows

Before applying changes in production, we can run static validations to identify schema errors or cluster-side validation issues.

### 1. Client-Side Validation (`--dry-run=client`)
Matches the local structure against standard client rules. This ensures basic YAML syntax correctness:

```bash
kubectl apply -f nginx-pod.yaml --dry-run=client
```
**Output:**
```text
pod/nginx-pod configured (dry run)
```

### 2. Server-Side Validation (`--dry-run=server`)
Sends the manifest to the Kubernetes API Server, verifying that the values meet API schema definitions and that your target properties are fully valid in the running cluster:

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```
**Output:**
```text
pod/nginx-pod unchanged (server dry run)
```

---

### 🚨 Simulating and Analyzing a Validation Failure

What happens if we intentionally break our configuration? Let's try to apply a Pod manifest where the critical container `image` field is completely missing:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: bad-container
    # Missing image attribute!
```

Let's test this with server-side validation:
```bash
cat <<EOF | kubectl apply -f - --dry-run=server
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: bad-container
EOF
```

**Real Error Output Response:**
```text
The Pod "bad-pod" is invalid: spec.containers[0].image: Required value
```

This clear, descriptive message highlights the power of dry-run validation. It prevents buggy deployments from ever hitting your production environment!

---

## 🏷️ Part 6: Task 5 - Pod Labels, Filters, and Live Labeling

**Labels** are key-value pairs attached to API objects. They are how Kubernetes organizes, selects, and establishes routing links between different components (like attaching Services or Ingresses to the correct Pods).

Let's write a third manifest with a robust set of metadata labels to practice filtering.

### 1. The Pod Manifest: `db-pod.yaml`
We create a Postgres database Pod called `db-pod` with three distinct labels (`app`, `environment`, `team`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  labels:
    app: postgres
    environment: dev
    team: backend
spec:
  containers:
  - name: postgres
    image: postgres:15-alpine
    ports:
    - containerPort: 5432
    env:
    - name: POSTGRES_PASSWORD
      value: mysecretpassword
```

Apply the third pod:
```bash
kubectl apply -f db-pod.yaml
```

---

### 2. Querying and Filtering with Labels

Now that multiple Pods are running, let's explore their metadata tags.

#### A. Show All Labels Attached to Running Pods
```bash
kubectl get pods --show-labels
```

**Real Terminal Output:**
```text
NAME          READY   STATUS    RESTARTS   AGE    LABELS
busybox-pod   1/1     Running   0          111s   app=busybox,environment=dev
db-pod        1/1     Running   0          111s   app=postgres,environment=dev,team=backend
nginx-pod     1/1     Running   0          111s   app=nginx
redis-pod     1/1     Running   0          111s   run=redis-pod
```

#### B. Filter Pods by Selector Flags (`-l`)
```bash
# Query pods matching "app=nginx"
kubectl get pods -l app=nginx

# Query pods matching "environment=dev"
kubectl get pods -l environment=dev

# Query pods matching "team=backend"
kubectl get pods -l team=backend
```

**Real Terminal Output:**
```text
$ kubectl get pods -l app=nginx
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          2m

$ kubectl get pods -l environment=dev
NAME          READY   STATUS    RESTARTS   AGE
busybox-pod   1/1     Running   0          2m
db-pod        1/1     Running   0          2m

$ kubectl get pods -l team=backend
NAME     READY   STATUS    RESTARTS   AGE
db-pod   1/1     Running   0          2m
```

---

### 3. Dynamic Runtime Label Management
Labels can also be added, updated, or removed from existing API resources on-the-fly without needing to recreate or modify your source configuration files.

#### A. Add a Label to a Running Pod
Let's add the tag `environment=production` to the active `nginx-pod`:

```bash
kubectl label pod nginx-pod environment=production
```
**Output:**
```text
pod/nginx-pod labeled
```

Let's verify the change:
```bash
kubectl get pod nginx-pod --show-labels
```
**Output:**
```text
NAME        READY   STATUS    RESTARTS   AGE   LABELS
nginx-pod   1/1     Running   0          2m    app=nginx,environment=production
```

#### B. Remove a Label from a Running Pod
To remove a label key, we specify the label name followed immediately by a minus sign (`-`):

```bash
kubectl label pod nginx-pod environment-
```
**Output:**
```text
pod/nginx-pod unlabeled
```

Verification shows the tag has been cleanly removed:
```bash
kubectl get pod nginx-pod --show-labels
```
**Output:**
```text
NAME        READY   STATUS    RESTARTS   AGE    LABELS
nginx-pod   1/1     Running   0          2m3s   app=nginx
```

---

## 🧹 Part 7: Task 6 - Clean Up & Standalone Pod Lifecycles

Let's clean up our running resources by deleting all the Pods created today.

### 1. Deleting Pods
You can delete Pods either by specifying their names directly or by referencing the original YAML manifest files used to create them:

```bash
# Delete pods by name
kubectl delete pod nginx-pod busybox-pod db-pod redis-pod
```

**Real Terminal Output:**
```text
pod "nginx-pod" deleted from default namespace
pod "busybox-pod" deleted from default namespace
pod "db-pod" deleted from default namespace
pod "redis-pod" deleted from default namespace
```

Let's verify that the default namespace is completely clean:
```bash
kubectl get pods
```
**Output:**
```text
No resources found in default namespace.
```

---

### ❓ What Happens When You Delete a Standalone Pod?

> [!IMPORTANT]
> When you deploy and run a **standalone (bare) Pod**, it is scheduled directly onto a node by the Control Plane. 
> 
> If you manually execute a delete command, or if the underlying Worker Node crashes, **the Pod is gone forever**. There is no administrative agent or controller overseeing its status to recreate it. 
> 
> To run production workloads reliably, DevOps engineers rarely deploy bare Pods. Instead, they use high-level abstraction resources called **Deployments** (which we will cover in-depth on Day 52). A Deployment creates and controls a **ReplicaSet**, which constantly monitors our Pod states. If a Pod is deleted, the ReplicaSet immediately spawns a replacement Pod to guarantee service availability.

---

## 💡 Day 51 Summary & Reference Guide

*   **`kubectl apply -f <file.yaml>`** — Deploys or updates resources defined in a local manifest.
*   **`kubectl get pods -o wide`** — Displays basic status, internal cluster IP addresses, and node locations.
*   **`kubectl describe pod <name>`** — Displays configuration details, active states, and lifecycle event streams.
*   **`kubectl logs <name>`** — Fetches the stdout and stderr streams of containerized runtimes.
*   **`kubectl exec -it <name> -- /bin/sh`** — Spawns an interactive shell inside a target container.
*   **`kubectl label pod <name> key=value`** — Applies tags to existing resources at runtime.
*   **`--dry-run=client -o yaml`** — Instantly generates standardized declarative configurations.

---

## 🔗 Learn in Public: Share Your Progress!

Share your learning milestones on LinkedIn or Twitter to inspire the community:

```text
Day 51 of the #90DaysOfDevOps challenge completed! 🚀

Today, I took my first major step inside the Kubernetes runtime layer:
• Mastered the declarative anatomy of K8s YAML manifests (apiVersion, kind, metadata, spec).
• Wrote multi-label Pod manifests (Nginx, BusyBox, PostgreSQL) completely from scratch.
• Traced real-time shell executions and verified validation dry-runs (client vs. server).
• Explored dynamic label selectors and understood the volatility of bare standalone Pod lifecycles.

The foundations are locked in. Ready to orchestrate deployments next! 🐳☸️

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #Kubernetes #CloudNative #DevOps
```

---

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*
