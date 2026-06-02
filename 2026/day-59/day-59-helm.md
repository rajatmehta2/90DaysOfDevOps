# Day 59: Helm — The Kubernetes Package Manager

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Helm](https://img.shields.io/badge/Helm-0F162D?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh)
[![DevOps](https://img.shields.io/badge/DevOps-90%20Days-orange?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 59** of the 90 Days of DevOps challenge! Over the past eight days, we have manually written and managed individual Kubernetes manifests: Deployments, Services, ConfigMaps, Secrets, and Persistent Volume Claims. While managing 3–4 YAML files is simple, production applications can consist of dozens of resource manifests with environment-specific configurations.

Today, we dive into **Helm**, the de facto package manager for Kubernetes. Helm allows you to define, install, upgrade, and manage even the most complex Kubernetes applications as reusable packages called **Charts**.

---

## 🎯 Learning Objectives & Deliverables
* [x] Install and configure Helm on the local workstation.
* [x] Understand Helm's Core Architecture and the **Three Pillars** (Chart, Release, Repository).
* [x] Add public Helm registries and search for verified packages.
* [x] Deploy, inspect, and interact with a pre-packaged Bitnami Nginx application.
* [x] Customize chart configurations using interactive CLI arguments (`--set`) and a declarative `custom-values.yaml` file.
* [x] Perform zero-downtime application upgrades and robust release rollbacks.
* [x] Scaffold, build, validate (`lint`), and install a **custom Helm Chart** from scratch using Go Templating engines.

---

## 🏗️ Helm Architecture & The Three Pillars

Helm is a client-side CLI tool that communicates directly with the Kubernetes API server (using the configuration defined in your `kubeconfig` file). It eliminates the need for an in-cluster server-side component (since Helm v3 replaced the legacy Tiller daemon).

```
                  +--------------------------+
                  |    Public Repositories   |
                  |     (Artifact Hub)       |
                  +-------------+------------+
                                |
                           helm pull
                                |
                                v
+------------------+      +-----+------+      +----------------------+
|                  |      |            |      |                      |
|   DevOps Engineer|----->|  Helm CLI  |----->|  Kubernetes Cluster  |
|                  |      |            |      |  (kube-apiserver)    |
+------------------+      +------------+      +-----------+----------+
                                                          |
                                                      installs
                                                          |
                                                          v
                                              +-----------+----------+
                                              | Kubernetes Resources |
                                              | (Pods, Services, etc)|
                                              +----------------------+
```

### The Three Core Pillars of Helm
1. **Chart**: A structured bundle of Kubernetes manifest templates, metadata (`Chart.yaml`), and default variables (`values.yaml`). It represents the blueprint of your application.
2. **Repository**: An online registry where charts are published, cataloged, and shared (similar to npmjs or apt repositories).
3. **Release**: A running instance of a chart inside a Kubernetes cluster. You can deploy the same chart multiple times in the same cluster, each getting a unique release name.

---

## 🛠️ Step-by-Step Practical Implementation

### Task 1: Install & Verify Helm

Install Helm using the package manager appropriate for your operating system:

#### Installation Methods
* **macOS (Homebrew):** `brew install helm`
* **Linux (Debian/Ubuntu):**
  ```bash
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm
  ```
* **Windows (Chocolatey):** `choco install kubernetes-helm`

#### Verification
Check your installed version and environment settings to ensure Helm is properly linked to your cluster.

```bash
helm version
```

**Realistic Terminal Output:**
```text
version.BuildInfo{Version:"v3.14.2", GitCommit:"99e181e1a8a25c1103c2004245fe92a6c23a7e58", GitTreeState:"clean", GoVersion:"go1.21.7"}
```

```bash
helm env
```

**Realistic Terminal Output:**
```text
HELM_BIN="helm"
HELM_CACHE_HOME="/Users/devops/.cache/helm"
HELM_CONFIG_HOME="/Users/devops/.config/helm"
HELM_DATA_HOME="/Users/devops/.local/share/helm"
HELM_PLUGINS="/Users/devops/.local/share/helm/plugins"
HELM_REGISTRY_CONFIG="/Users/devops/.config/helm/registry/config.json"
HELM_REPOSITORY_CACHE="/Users/devops/.cache/helm/repository"
HELM_REPOSITORY_CONFIG="/Users/devops/.config/helm/repositories.yaml"
```

> [!NOTE]  
> Helm automatically inherits credentials from your active `kubectl` context (`~/.kube/config`). Ensure your Kubernetes cluster is running and accessible before proceeding.

---

### Task 2: Add public registries & search for charts

To download pre-packaged application templates, add the **Bitnami** chart repository (a widely trusted registry for production-grade applications) and search for target charts.

#### 1. Add Repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

**Realistic Terminal Output:**
```text
"bitnami" has been added to your repositories
```

#### 2. Update Registries
```bash
helm repo update
```

**Realistic Terminal Output:**
```text
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

#### 3. Search for Nginx Charts
```bash
helm search repo nginx
```

**Realistic Terminal Output:**
```text
NAME                               CHART VERSION APP VERSION DESCRIPTION
bitnami/nginx                      15.14.0       1.25.4      An HTTP and reverse proxy server with web serv...
bitnami/nginx-ingress-controller   10.3.1        1.9.6       The NGINX Ingress Controller is an Ingress ...
bitnami/nginx-intel                2.1.15        1.25.3      NGINX Open Source with Intel modular extensions...
```

![Helm Repo Add & Search](../screenshots/day-59-helm-repo-search.png)
*Caption: Adding the Bitnami repository and executing searches for validated Nginx charts.*

---

### Task 3: Install an Application Chart

Let's deploy a standard Nginx server release using the `bitnami/nginx` chart. We will name this release `my-nginx`.

```bash
helm install my-nginx bitnami/nginx
```

**Realistic Terminal Output:**
```text
NAME: my-nginx
LAST DEPLOYED: Tue Jun  2 16:45:00 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 15.14.0
APP VERSION: 1.25.4

** Please be patient while the chart is being deployed **

NGINX can be accessed through the following gateway:
  
  Get the NGINX URL:

  export SERVICE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].port}" services my-nginx)
  export SERVICE_IP=$(kubectl get --namespace default -o jsonpath="{.status.loadBalancer.ingress[0].ip}" services my-nginx)
  echo "http://${SERVICE_IP}:${SERVICE_PORT}"
```

#### Verification of Kubernetes Resources
Verify that Helm automatically created all relevant Kubernetes objects with a single command.

```bash
kubectl get all
```

**Realistic Terminal Output:**
```text
NAME                            READY   STATUS    RESTARTS   AGE
pod/my-nginx-546db98c8c-xt9pw   1/1     Running   0          45s

NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/my-nginx   LoadBalancer   10.96.142.105   <pending>     80:31254/TCP   45s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   1/1     1            1           45s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-546db98c8c   1         1         1       45s
```

#### Inspecting the Active Release
List all active Helm releases inside your namespace:

```bash
helm list
```

**Realistic Terminal Output:**
```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-nginx        default         1               2026-06-02 16:45:00.254124 +0530 IST    deployed        nginx-15.14.0   1.25.4     
```

```bash
helm status my-nginx
```

**Realistic Terminal Output:**
```text
NAME: my-nginx
LAST DEPLOYED: Tue Jun  2 16:45:00 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
...
```

---

### Task 4: Customizing Charts with Values

Helm charts come with built-in default configuration options stored in `values.yaml`. You can customize these configurations either imperatively (via CLI arguments) or declaratively (via custom values files).

#### 1. Inspect Default Chart Parameters
```bash
helm show values bitnami/nginx | head -n 25
```

**Realistic Terminal Output:**
```yaml
## @section Global parameters
## Global parameters
##
global:
  imageRegistry: ""
  imagePullSecrets: []
  storageClass: ""

## @section Common parameters
## Common parameters
##
nameOverride: ""
fullnameOverride: ""

## @section NGINX parameters
## NGINX parameters
##
image:
  registry: docker.io
  repository: bitnami/nginx
  tag: 1.25.4-debian-12-r0
  digest: ""
  pullPolicy: IfNotPresent
```

#### 2. Declarative Overrides using `custom-values.yaml`
Creating a clean yaml file listing specific parameters ensures infrastructure configurations remain version-controlled and reproducible.

Here is our declarative configuration file `custom-values.yaml`:

```yaml
# custom-values.yaml - Overrides for bitnami/nginx Helm Chart
# Day 59: Helm - Kubernetes Package Manager

# 1. Scaling Configuration
replicaCount: 3

# 2. Service Configuration
service:
  type: NodePort
  ports:
    http: 80

# 3. Resource Management
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

# 4. Ingress Configuration (Disabled by default, but ready for production)
ingress:
  enabled: false
  hostname: nginx.local
  path: /
  annotations: {}

# 5. Pod Disruption Budget (Optional but nice to define)
pdb:
  create: true
  minAvailable: 2
```

#### 3. Deploy customized releases
Deploy a customized release (`custom-nginx`) using the configurations declared in `custom-values.yaml`:

```bash
helm install custom-nginx bitnami/nginx -f custom-values.yaml
```

**Realistic Terminal Output:**
```text
NAME: custom-nginx
LAST DEPLOYED: Tue Jun  2 16:48:12 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

Verify that the custom parameters (3 replicas and service type `NodePort`) were correctly applied:

```bash
kubectl get all -l app.kubernetes.io/instance=custom-nginx
```

**Realistic Terminal Output:**
```text
NAME                                READY   STATUS    RESTARTS   AGE
pod/custom-nginx-68f77d4c78-6sfn4   1/1     Running   0          30s
pod/custom-nginx-68f77d4c78-gq2mw   1/1     Running   0          30s
pod/custom-nginx-68f77d4c78-wzpq8   1/1     Running   0          30s

NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/custom-nginx   NodePort   10.96.182.202   <none>        80:30154/TCP   30s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/custom-nginx   3/3     3            3           30s
```

#### 4. Query Overridden Values
To audit custom settings on an active release, run:

```bash
helm get values custom-nginx
```

**Realistic Terminal Output:**
```yaml
USER-SUPPLIED VALUES:
ingress:
  annotations: {}
  enabled: false
  hostname: nginx.local
  path: /
pdb:
  create: true
  minAvailable: 2
replicaCount: 3
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
service:
  ports:
    http: 80
  type: NodePort
```

---

### Task 5: Upgrade and Rollback Releases

One of Helm’s greatest benefits is release lifecycle management. Instead of deleting and re-creating manifests, Helm allows seamless upgrades and instantaneous rollbacks.

#### 1. Perform an Upgrade
Let's scale the `my-nginx` release up to 5 replicas:

```bash
helm upgrade my-nginx bitnami/nginx --set replicaCount=5
```

**Realistic Terminal Output:**
```text
Release "my-nginx" has been upgraded. Happy Helming!
NAME: my-nginx
LAST DEPLOYED: Tue Jun  2 16:51:24 2026
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
```

#### 2. Inspect Revision History
Helm tracks every operation (installations, upgrades, rollbacks) in secret-based backend storage.

```bash
helm history my-nginx
```

**Realistic Terminal Output:**
```text
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION     
1               Tue Jun  2 16:45:00 2026        superseded      nginx-15.14.0   1.25.4          Install complete
2               Tue Jun  2 16:51:24 2026        deployed        nginx-15.14.0   1.25.4          Upgrade to 2    
```

#### 3. Execute a Rollback
If an upgrade causes errors or unexpected regressions, instantly revert the stack back to a previous safe state (e.g., Revision 1):

```bash
helm rollback my-nginx 1
```

**Realistic Terminal Output:**
```text
Rollback release to 1 was successful. Happy Helming!
```

Let's check history again:

```bash
helm history my-nginx
```

**Realistic Terminal Output:**
```text
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION     
1               Tue Jun  2 16:45:00 2026        superseded      nginx-15.14.0   1.25.4          Install complete
2               Tue Jun  2 16:51:24 2026        superseded      nginx-15.14.0   1.25.4          Upgrade to 2    
3               Tue Jun  2 16:53:15 2026        deployed        nginx-15.14.0   1.25.4          Rollback to 1   
```

> [!WARNING]  
> A rollback does **not** erase revision 2 from history. It creates a brand-new release revision (Revision 3), ensuring full auditability of your cluster deployments.

![Helm History & Rollback](../screenshots/day-59-helm-history-rollback.png)
*Caption: Successfully tracking release revisions and executing safe, zero-downtime rollbacks.*

---

### Task 6: Creating Custom Helm Charts from Scratch

To package custom applications, we can scaffold a standard directory structure using Helm’s scaffolding command.

#### 1. Scaffold a New Chart
```bash
helm create my-app
```

**Realistic Terminal Output:**
```text
Creating my-app
```

#### 2. Explore the Generated Directory
```bash
tree my-app
```

**Realistic Terminal Output:**
```text
my-app/
├── Chart.yaml             # Metadata containing chart name, version, and apiVersion
├── values.yaml            # Default template variables 
├── charts/                # Sub-charts or dependent charts directory (empty)
├── templates/             # Kubernetes template manifests
│   ├── NOTES.txt          # Help message output upon installation
│   ├── _helpers.tpl       # Reusable template helper macros and variables
│   ├── deployment.yaml    # Deployment manifest template
│   ├── hpa.yaml           # Horizontal Pod Autoscaler template
│   ├── ingress.yaml       # Ingress controller template
│   ├── service.yaml       # Service definition template
│   ├── serviceaccount.yaml# ServiceAccount template
│   └── tests/             # Connection/smoke verification tests
│       └── test-connection.yaml
```

#### 3. Understanding Go Templating Syntax
Helm uses Go’s text/template engine. Take a look inside `templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-app.fullname" . }}
...
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
```
* **`{{ .Values.replicaCount }}`**: Replaced by the value defined in `values.yaml` under `replicaCount`.
* **`{{ .Chart.Name }}`**: Dynamically extracts the application name defined in `Chart.yaml`.

#### 4. Customizing Default Values
Open `my-app/values.yaml` and modify the default configuration parameters to scale out of the box with `nginx:1.25`:

```yaml
# my-app/values.yaml (Partial Overrides)
replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.25"
```

#### 5. Linting and Validating the Chart
Before installing, run static analysis and validation tests to ensure template syntax is completely valid.

```bash
helm lint ./my-app
```

**Realistic Terminal Output:**
```text
==> Linting ./my-app
[INFO] Chart.yaml: icon is recommended

1 file(s) linted, 0 chart(s) failed
```

#### 6. Dry Run & Template Compilation
Verify how raw Kubernetes manifests compile without installing them using the `template` command:

```bash
helm template my-release ./my-app | head -n 30
```

**Realistic Terminal Output:**
```yaml
---
# Source: my-app/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-release-my-app
  labels:
    helm.sh/chart: my-app-0.1.0
    app.kubernetes.io/name: my-app
    app.kubernetes.io/instance: my-release
---
# Source: my-app/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-release-my-app
  labels:
    helm.sh/chart: my-app-0.1.0
    app.kubernetes.io/name: my-app
    app.kubernetes.io/instance: my-release
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
```

#### 7. Deploy Custom App Release
Deploy the locally scaffolded chart:

```bash
helm install my-release ./my-app
```

**Realistic Terminal Output:**
```text
NAME: my-release
LAST DEPLOYED: Tue Jun  2 17:02:14 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

Verify that 3 Pods are spinning up as declared in our default values:

```bash
kubectl get pods -l app.kubernetes.io/instance=my-release
```

**Realistic Terminal Output:**
```text
NAME                                  READY   STATUS    RESTARTS   AGE
my-release-my-app-7f44d5cbfd-98sjw    1/1     Running   0          40s
my-release-my-app-7f44d5cbfd-jklmn    1/1     Running   0          40s
my-release-my-app-7f44d5cbfd-opqrs    1/1     Running   0          40s
```

#### 8. Live Update of the Local Release
Scale up the custom chart deployment to 5 replicas dynamically:

```bash
helm upgrade my-release ./my-app --set replicaCount=5
```

**Realistic Terminal Output:**
```text
Release "my-release" has been upgraded. Happy Helming!
NAME: my-release
LAST DEPLOYED: Tue Jun  2 17:05:00 2026
REVISION: 2
```

---

### Task 7: Clean Up All Releases

To ensure resource isolation and clean cluster states, tear down all deployed releases:

```bash
helm uninstall my-nginx
helm uninstall custom-nginx
helm uninstall my-release
```

**Realistic Terminal Output:**
```text
release "my-nginx" uninstalled
release "custom-nginx" uninstalled
release "my-release" uninstalled
```

Verify that all releases are deleted:

```bash
helm list
```

**Realistic Terminal Output:**
```text
NAME    NAMESPACE    REVISION    UPDATED    STATUS    CHART    APP VERSION
```

---

## 💡 Pro DevOps Tips & Best Practices
* **Use Dry-Run Flag:** Whenever performing installs or upgrades, test configuration logic safely using `helm install --dry-run --debug`.
* **Lock Versions:** Never rely on default `latest` tags. Always explicitly version-control your Helm charts in `Chart.yaml` and pin your Docker base images in `values.yaml`.
* **Separate Config per Environment:** Maintain unique values files for each environment, e.g., `values-dev.yaml`, `values-staging.yaml`, and `values-prod.yaml`, to control resources, endpoints, and database connection secrets cleanly.

---

## 📢 Share Your Learning in Public!

Ready to showcase today's milestones to the DevOps community? Copy-paste this template on LinkedIn:

```text
🚀 Day 59 of my #90DaysOfDevOps challenge completed! Today, I explored Helm — the package manager for Kubernetes! 

Instead of writing and maintaining dozens of distinct YAML manifests for Deployments, Services, and PV/PVCs, I automated the process! Here's what I achieved:
🔹 Mastered Helm's core architecture and pillars: Charts, Repositories, and Releases.
🔹 Configured, customized, and deployed external charts using custom-values.yaml.
🔹 Performed zero-downtime application upgrades and instantaneous release rollbacks.
🔹 Scaffolded and deployed my own Custom Helm Chart from scratch using Go Templating engines.

Helm makes managing complex microservices in Kubernetes amazingly scalable and consistent. 

Check out my full documentation and code templates in my repo: https://github.com/rajatmehta2/90DaysOfDevOps

#Kubernetes #Helm #DevOps #CloudNative #InfrastructureAsCode #DevOpsKaJosh #TrainWithShubham
```

---

*This guide was curated as part of the 90DaysOfDevOps learning journey. Keep learning!*
**TrainWithShubham**
