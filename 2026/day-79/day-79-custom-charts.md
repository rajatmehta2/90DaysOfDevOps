# Day 79: Creating a Custom Helm Chart for AI-BankApp

[![Helm](https://img.shields.io/badge/Helm-v3.x-blue?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day--79-orange?style=for-the-badge)](https://github.com/TrainWithShubham/90DaysOfDevOps)

---

## 📖 Table of Contents
1. [Introduction & Architectural Design](#-introduction--architectural-design)
2. [Task Overview](#-task-overview)
3. [Phase 1: Scaffolding the Custom Helm Chart](#-phase-1-scaffolding-the-custom-helm-chart)
4. [Phase 2: Defining Chart Metadata & Configuration Layer (`values.yaml`)](#-phase-2-defining-chart-metadata--configuration-layer-valuesyaml)
5. [Phase 3: Deep Dive into Helm Core Templates](#-phase-3-deep-dive-into-helm-core-templates)
6. [Phase 4: Side-by-Side Comparison: Raw Manifests vs. Helm Templates](#-phase-4-side-by-side-comparison-raw-manifests-vs-helm-templates)
7. [Phase 5: Go Template Syntax Cheat Sheet](#-phase-5-go-template-syntax-cheat-sheet)
8. [Phase 6: Linting, Templating, and Deployment Runthrough](#-phase-6-linting-templating-and-deployment-runthrough)
9. [Phase 7: Conditional Deployment Feature Focus (`ollama.enabled=false`)](#-phase-7-conditional-deployment-feature-focus-ollamaenabledfalse)
10. [🖼️ Execution & UI Verification Screenshots](#%EF%B8%8F-execution--ui-verification-screenshots)
11. [💡 Best Practices & Key Takeaways](#-best-practices--key-takeaways)

---

## 🏛️ Introduction & Architectural Design

Yesterday, we successfully deployed a MySQL database using a standard community Helm chart. Today, we take a massive step forward in cloud packaging by building a **fully customized, enterprise-grade Helm Chart** for the **AI-BankApp** stack from scratch. 

Instead of managing **12 raw, hardcoded Kubernetes YAML manifests**, we will consolidate and modularize the entire stack into a single dynamic, parameterized packaging system. 

```mermaid
graph TD
    subgraph Client Space
        helm[Helm CLI Client]
    end

    subgraph Kubernetes Cluster (bankapp Namespace)
        direction TB
        
        subgraph Secret & Config Layer
            sec[Secret: DB Credentials]
            cm[ConfigMap: URLs & DB Config]
        end

        subgraph Core Workloads
            bank[Spring Boot BankApp Deployment]
            mysql[MySQL Database Deployment]
            ollama[Ollama AI Chatbot Deployment]
        end

        subgraph Networking & Scaling
            svc_bank[Service: bankapp-service]
            svc_mysql[Service: bankapp-mysql]
            svc_ollama[Service: bankapp-ollama]
            hpa[Horizontal Pod Autoscaler]
        end

        subgraph Storage Layer
            sc[StorageClass: gp3]
            pvc_mysql[PVC: mysql-storage-5Gi]
            pvc_ollama[PVC: ollama-storage-10Gi]
        end
    end

    %% Helm Deploy
    helm -->|1. Applies templates & values| Kubernetes Cluster
    
    %% Config Mounts
    sec -.->|envFrom| bank
    sec -.->|env| mysql
    cm -.->|envFrom| bank
    cm -.->|env| mysql

    %% Storage Mounts
    sc -.-> PVCs
    pvc_mysql -->|Mounts /var/lib/mysql| mysql
    pvc_ollama -->|Mounts /root/.ollama| ollama

    %% Inter-Pod Communication (Init Containers)
    bank -->|Init Container: wait-for-mysql| svc_mysql
    bank -->|Init Container: wait-for-ollama| svc_ollama
    
    %% Target references
    hpa -.->|Autoscales 2-4 Replicas| bank
```

---

## 🎯 Task Overview
- Convert **12 raw Kubernetes manifests** (`namespace`, `configmap`, `secrets`, `pv`, `pvc`, `deployments`, `services`, `hpa`, `gateway`, etc.) into a cohesive Helm package.
- Extract every environment-specific parameter into a central, clean `values.yaml` file.
- Implement conditional deployments, allowing sub-components (such as the Ollama AI engine) to be enabled or disabled via simple toggle booleans.
- Validate and deploy the custom Helm chart onto a local **Kind (Kubernetes-in-Docker)** cluster, adjusting parameters dynamically.

---

## 🛠️ Phase 1: Scaffolding the Custom Helm Chart

We begin by establishing a clear and organized repository context. We clone the AI-BankApp repository and scaffold a brand-new Helm structure under `helm-chart/`.

```bash
# Step 1: Navigate to the active repository directory
cd AI-BankApp-DevOps

# Step 2: Create a directory for our custom Helm Chart scaffolding
mkdir -p helm-chart && cd helm-chart

# Step 3: Scaffold the default Helm Chart structure
helm create bankapp
```

### Cleaning Up Default Scaffolding
By default, Helm creates several template manifests (like `deployment.yaml`, `service.yaml`, etc.) populated with generic setups. We will wipe these out and build our own custom templates tailored to the complex requirements of the Spring Boot + MySQL + Ollama AI Architecture.

```bash
# Step 4: Clean the template files to start from a blank canvas
rm -rf bankapp/templates/*.yaml bankapp/templates/tests/
```

> [!NOTE]
> We preserve `_helpers.tpl` (which contains reusable template helper definitions) and `NOTES.txt` (which renders installation updates).

---

## 🎛️ Phase 2: Defining Chart Metadata & Configuration Layer (`values.yaml`)

### 📝 Chart Metadata: `bankapp/Chart.yaml`
This file defines the high-level metadata for our package, specifying the versions and app versions conforming to SemVer standard.

```yaml
apiVersion: v2
name: bankapp
description: AI-BankApp -- Spring Boot banking application with MySQL and Ollama AI chatbot
type: application
version: 0.1.0
appVersion: "1.0.0"
maintainers:
  - name: TrainWithShubham
    url: https://github.com/TrainWithShubham
keywords:
  - bankapp
  - spring-boot
  - mysql
  - ollama
  - ai
```

### ⚙️ Centralized Configuration Layer: `bankapp/values.yaml`
This is the single source of truth for the entire application stack. Instead of hardcoding details in individual Kubernetes resource manifests, they are exposed here to support environment specific overrides.

```yaml
# ==============================================================================
# AI-BankApp: Core Spring Boot Application Configuration
# ==============================================================================
bankapp:
  replicaCount: 4
  image:
    repository: trainwithshubham/ai-bankapp-eks
    tag: "latest"
    pullPolicy: Always
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  service:
    type: ClusterIP
    port: 8080
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 4
    targetCPUUtilization: 70

# ==============================================================================
# MySQL Database Configuration
# ==============================================================================
mysql:
  enabled: true
  image:
    repository: mysql
    tag: "8.0"
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    size: 5Gi
    storageClass: gp3

# ==============================================================================
# Ollama AI Engine Configuration
# ==============================================================================
ollama:
  enabled: true
  image:
    repository: ollama/ollama
    tag: "latest"
  model: tinyllama
  resources:
    requests:
      memory: "2Gi"
      cpu: "900m"
    limits:
      memory: "2.5Gi"
      cpu: "1500m"
  persistence:
    size: 10Gi
    storageClass: gp3

# ==============================================================================
# Shared Configuration
# ==============================================================================
config:
  mysqlDatabase: bankappdb
  ollamaUrl: ""  # Dynamically generated based on release naming schema if left blank

# ==============================================================================
# Secrets Layer (Will be safely Base64-encoded on rendering)
# ==============================================================================
secrets:
  mysqlRootPassword: Test@123
  mysqlUser: root
  mysqlPassword: Test@123

# ==============================================================================
# Storage Class Configuration
# ==============================================================================
storageClass:
  create: true
  name: gp3
  provisioner: ebs.csi.aws.com

# ==============================================================================
# Gateway (optional -- for EKS with Envoy Gateway)
# ==============================================================================
gateway:
  enabled: false
  hostname: ""
  tls:
    enabled: false
```

---

## 🧱 Phase 3: Deep Dive into Helm Core Templates

We systematically modularized the raw Kubernetes manifests into dynamic Go templates inside `bankapp/templates/`. Below are our production templates.

### 1. `bankapp/templates/configmap.yaml`
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "bankapp.fullname" . }}-config
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
data:
  MYSQL_HOST: {{ include "bankapp.fullname" . }}-mysql
  MYSQL_PORT: "3306"
  MYSQL_DATABASE: {{ .Values.config.mysqlDatabase | quote }}
  OLLAMA_URL: {{ default (printf "http://%s-ollama:11434" (include "bankapp.fullname" .)) .Values.config.ollamaUrl | quote }}
  SERVER_FORWARD_HEADERS_STRATEGY: "native"
```

### 2. `bankapp/templates/secrets.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "bankapp.fullname" . }}-secret
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: {{ .Values.secrets.mysqlRootPassword | b64enc | quote }}
  MYSQL_USER: {{ .Values.secrets.mysqlUser | b64enc | quote }}
  MYSQL_PASSWORD: {{ .Values.secrets.mysqlPassword | b64enc | quote }}
```

### 3. `bankapp/templates/storage.yaml`
```yaml
{{- if .Values.storageClass.create }}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ .Values.storageClass.name }}
provisioner: {{ .Values.storageClass.provisioner }}
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
{{- end }}
---
{{- if .Values.mysql.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql-pvc
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  storageClassName: {{ .Values.mysql.persistence.storageClass }}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.mysql.persistence.size }}
{{- end }}
---
{{- if .Values.ollama.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama-pvc
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  storageClassName: {{ .Values.ollama.persistence.storageClass }}
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.ollama.persistence.size }}
{{- end }}
```

### 4. `bankapp/templates/bankapp-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  {{- if not .Values.bankapp.autoscaling.enabled }}
  replicas: {{ .Values.bankapp.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}
    spec:
      initContainers:
        - name: wait-for-mysql
          image: busybox:1.36
          command: ["/bin/sh", "-c", "until nc -z {{ include "bankapp.fullname" . }}-mysql 3306; do sleep 2; done"]
          resources:
            requests: { memory: "32Mi", cpu: "50m" }
            limits: { memory: "64Mi", cpu: "100m" }
        {{- if .Values.ollama.enabled }}
        - name: wait-for-ollama
          image: busybox:1.36
          command: ["/bin/sh", "-c", "until nc -z {{ include "bankapp.fullname" . }}-ollama 11434; do sleep 2; done"]
          resources:
            requests: { memory: "32Mi", cpu: "50m" }
            limits: { memory: "64Mi", cpu: "100m" }
        {{- end }}
      containers:
        - name: bankapp
          image: "{{ .Values.bankapp.image.repository }}:{{ .Values.bankapp.image.tag }}"
          imagePullPolicy: {{ .Values.bankapp.image.pullPolicy }}
          ports:
            - containerPort: 8080
          envFrom:
            - configMapRef:
                name: {{ include "bankapp.fullname" . }}-config
            - secretRef:
                name: {{ include "bankapp.fullname" . }}-secret
          {{- with .Values.bankapp.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 30
            failureThreshold: 15
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 5
```

### 5. `bankapp/templates/mysql-deployment.yaml`
```yaml
{{- if .Values.mysql.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}-mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}-mysql
    spec:
      containers:
        - name: mysql
          image: "{{ .Values.mysql.image.repository }}:{{ .Values.mysql.image.tag }}"
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "bankapp.fullname" . }}-secret
                  key: MYSQL_ROOT_PASSWORD
            - name: MYSQL_DATABASE
              valueFrom:
                configMapKeyRef:
                  name: {{ include "bankapp.fullname" . }}-config
                  key: MYSQL_DATABASE
          {{- with .Values.mysql.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
          readinessProbe:
            exec:
              command: ["mysqladmin", "ping", "-h", "localhost"]
            initialDelaySeconds: 15
            failureThreshold: 10
          livenessProbe:
            exec:
              command: ["mysqladmin", "ping", "-h", "localhost"]
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 5
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: {{ include "bankapp.fullname" . }}-mysql-pvc
{{- end }}
```

### 6. `bankapp/templates/ollama-deployment.yaml`
```yaml
{{- if .Values.ollama.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      app: {{ include "bankapp.fullname" . }}-ollama
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ include "bankapp.fullname" . }}-ollama
    spec:
      containers:
        - name: ollama
          image: "{{ .Values.ollama.image.repository }}:{{ .Values.ollama.image.tag }}"
          ports:
            - containerPort: 11434
          {{- with .Values.ollama.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: ollama-storage
              mountPath: /root/.ollama
          lifecycle:
            postStart:
              exec:
                command:
                  - /bin/sh
                  - -c
                  - |
                    until ollama list > /dev/null 2>&1; do sleep 2; done
                    ollama pull {{ .Values.ollama.model }}
          readinessProbe:
            exec:
              command: ["/bin/sh", "-c", "ollama list | grep -q {{ .Values.ollama.model }}"]
            initialDelaySeconds: 30
            failureThreshold: 30
          livenessProbe:
            httpGet:
              path: /
              port: 11434
            initialDelaySeconds: 60
            periodSeconds: 10
            failureThreshold: 5
      volumes:
        - name: ollama-storage
          persistentVolumeClaim:
            claimName: {{ include "bankapp.fullname" . }}-ollama-pvc
{{- end }}
```

### 7. `bankapp/templates/services.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-mysql
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    app: {{ include "bankapp.fullname" . }}-mysql
  ports:
    - port: 3306
---
{{- if .Values.ollama.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-ollama
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    app: {{ include "bankapp.fullname" . }}-ollama
  ports:
    - port: 11434
{{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "bankapp.fullname" . }}-service
  namespace: {{ .Release.Namespace }}
spec:
  type: {{ .Values.bankapp.service.type }}
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
  selector:
    app: {{ include "bankapp.fullname" . }}
  ports:
    - port: {{ .Values.bankapp.service.port }}
      targetPort: 8080
```

### 8. `bankapp/templates/hpa.yaml`
```yaml
{{- if .Values.bankapp.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "bankapp.fullname" . }}-hpa
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "bankapp.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "bankapp.fullname" . }}
  minReplicas: {{ .Values.bankapp.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.bankapp.autoscaling.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.bankapp.autoscaling.targetCPUUtilization }}
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30
      policies:
        - type: Pods
          value: 2
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 1
          periodSeconds: 60
{{- end }}
```

---

## 🔄 Phase 4: Side-by-Side Comparison: Raw Manifests vs. Helm Templates

To highlight the value of Helm packaging, let's analyze how raw files map to our dynamic Helm templates.

### 🛡️ Example 1: Secrets Management (`secrets.yaml`)
In a raw Kubernetes manifest, credentials are statically base64 encoded and exposed. Helm abstracts this configuration layer.

| Raw Manifest (`k8s/secrets.yml`) | Dynamic Helm Template (`templates/secrets.yaml`) |
| :--- | :--- |
| <pre lang="yaml">apiVersion: v1<br>kind: Secret<br>metadata:<br>  name: bankapp-secret<br>  namespace: bankapp<br>type: Opaque<br>data:<br>  MYSQL_ROOT_PASSWORD: VGVzdEAxMjM=<br>  MYSQL_USER: cm9vdA==<br>  MYSQL_PASSWORD: VGVzdEAxMjM=</pre> | <pre lang="yaml">apiVersion: v1<br>kind: Secret<br>metadata:<br>  name: &#123;&#123; include "bankapp.fullname" . &#125;&#125;-secret<br>  namespace: &#123;&#123; .Release.Namespace &#125;&#125;<br>type: Opaque<br>data:<br>  MYSQL_ROOT_PASSWORD: &#123;&#123; .Values.secrets.mysqlRootPassword \| b64enc \| quote &#125;&#125;<br>  MYSQL_USER: &#123;&#123; .Values.secrets.mysqlUser \| b64enc \| quote &#125;&#125;<br>  MYSQL_PASSWORD: &#123;&#123; .Values.secrets.mysqlPassword \| b64enc \| quote &#125;&#125;</pre> |

**💡 Strategic Upgrade:**
1. Secrets are written in plain text in `values.yaml` (which can be protected, decrypted dynamically via Vault/External Secrets, or set in environment variables during execution).
2. The Helm template automatically applies the pipe function `b64enc` to dynamically encode passwords at deployment runtime.

---

### 📊 Example 2: ConfigMap (`configmap.yaml`)
Environment endpoints in raw manifests are hardcoded. Under Helm, the URL changes automatically depending on the release name.

| Raw Manifest (`k8s/configmap.yml`) | Dynamic Helm Template (`templates/configmap.yaml`) |
| :--- | :--- |
| <pre lang="yaml">apiVersion: v1<br>kind: ConfigMap<br>metadata:<br>  name: bankapp-config<br>  namespace: bankapp<br>data:<br>  MYSQL_HOST: bankapp-mysql<br>  MYSQL_PORT: "3306"<br>  OLLAMA_URL: "http://bankapp-ollama:11434"</pre> | <pre lang="yaml">apiVersion: v1<br>kind: ConfigMap<br>metadata:<br>  name: &#123;&#123; include "bankapp.fullname" . &#125;&#125;-config<br>  namespace: &#123;&#123; .Release.Namespace &#125;&#125;<br>data:<br>  MYSQL_HOST: &#123;&#123; include "bankapp.fullname" . &#125;&#125;-mysql<br>  MYSQL_PORT: "3306"<br>  OLLAMA_URL: &#123;&#123; default (printf "http://%s-ollama:11434" (include "bankapp.fullname" .)) .Values.config.ollamaUrl \| quote &#125;&#125;</pre> |

**💡 Strategic Upgrade:**
1. The MySQL host and Ollama URL are dynamically linked using Helm's standard release fullnames.
2. If multiple instances of `bankapp` are deployed within the same cluster (e.g., for dev, QA, staging), their hostnames will isolate and resolve perfectly without conflict (e.g. `dev-bankapp-mysql` and `qa-bankapp-mysql`).

---

## 📝 Phase 5: Go Template Syntax Cheat Sheet

This custom Helm Chart utilizes modern Go templates engine patterns. Below is an administrative cheat sheet mapping syntax features to their actual use cases.

| Syntax Feature | Description / Use Case | Examples in Our Chart |
| :--- | :--- | :--- |
| `{{ .Values.path }}` | Renders a variable directly defined in the `values.yaml` hierarchy. | `{{ .Values.bankapp.replicaCount }}` |
| `{{-` and `-}}` | Trims leading or trailing whitespace blocks to ensure valid YAML structure indentation. | `{{- if .Values.mysql.enabled }}` |
| `include` | Evaluates a template helper block and yields a text string output. Safe for pipes. | `{{ include "bankapp.fullname" . }}` |
| `toYaml` | Renders a rich structured map/object from the values block directly into raw YAML formatting. | `{{- toYaml . | nindent 12 }}` |
| `nindent <n>` | Indents the target block with `<n>` spaces and prepends a newline, maintaining YAML structural alignment. | `{{- include "bankapp.labels" . | nindent 4 }}` |
| `b64enc` | Utility function to safely translate values into standard Base64 format. | `{{ .Values.secrets.mysqlUser | b64enc }}` |
| `printf` | Standard formatting function to build custom interpolated strings dynamically. | `printf "http://%s-ollama:11434"` |
| `if` / `else` / `end` | Evaluates logical conditional paths, skipping sections of templating based on criteria. | Conditionally building PVCs or Pods. |
| `with` | Scopes the context block (`.`) to the targeted configuration structure for simplicity. | `{{- with .Values.bankapp.resources }}` |

---

## 🚀 Phase 6: Linting, Templating, and Deployment Runthrough

### 🔎 Step 1: Linting the Chart
Before executing or deploying, we run `helm lint` to confirm syntactical correctness and verify standard packaging compliance.

```bash
helm lint bankapp/
```

#### Terminal Execution & Output:
```text
==> Linting bankapp/
[INFO] Chart.yaml: icon is recommended

1 file(s) linted, 0 chart(s) failed with 0 error(s)
```

---

### 🧪 Step 2: Render Templates Locally (`helm template`)
We render our charts locally to inspect exactly how our Go templates evaluate and verify our values map perfectly into clean Kubernetes YAML.

```bash
helm template my-bankapp bankapp/
```

#### Partial Manifest Output:
```yaml
# Source: bankapp/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-bankapp-secret
  namespace: default
  labels:
    helm.sh/chart: bankapp-0.1.0
    app.kubernetes.io/name: bankapp
    app.kubernetes.io/instance: my-bankapp
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: "VGVzdEAxMjM="
  MYSQL_USER: "cm9vdA=="
  MYSQL_PASSWORD: "VGVzdEAxMjM="
---
# Source: bankapp/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-bankapp-config
  namespace: default
  labels:
    helm.sh/chart: bankapp-0.1.0
    app.kubernetes.io/name: bankapp
    app.kubernetes.io/instance: my-bankapp
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm
data:
  MYSQL_HOST: my-bankapp-mysql
  MYSQL_PORT: "3306"
  MYSQL_DATABASE: "bankappdb"
  OLLAMA_URL: "http://my-bankapp-ollama:11434"
  SERVER_FORWARD_HEADERS_STRATEGY: "native"
```

---

### 🛡️ Step 3: Run dry-run Validation Against the Live Cluster
Before actually writing resources to the cluster database, we test the api translation live with `--dry-run --debug`.

```bash
helm install my-bankapp bankapp/ --dry-run --debug -n bankapp --create-namespace
```

---

### 🏁 Step 4: Live Cluster Deployment (Local EKS / Kind Workaround)
Since standard Kubernetes-in-Docker (Kind) clusters do not have an active EBS CSI controller by default (unlike standard AWS EKS running `ebs.csi.aws.com`), we run our install with dynamic parameter overrides:
1. Turn off `storageClass.create` because Kind provides its standard class.
2. Route PVC storage requests to the native `standard` provisioner in Kind.

```bash
helm install my-bankapp bankapp/ \
  -n bankapp --create-namespace \
  --set storageClass.create=false \
  --set mysql.persistence.storageClass=standard \
  --set ollama.persistence.storageClass=standard
```

#### Terminal Execution & Output:
```text
NAME: my-bankapp
LAST DEPLOYED: Tue Jun  2 22:15:33 2026
NAMESPACE: bankapp
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  kubectl --namespace bankapp port-forward svc/my-bankapp-service 8080:8080
```

---

### 🩺 Step 5: Verification of Running Resources
We monitor the workloads inside the target `bankapp` namespace to confirm perfect deployment execution.

```bash
# Check all resource deployments
kubectl get all -n bankapp
```

#### Terminal Execution & Output:
```text
NAME                                    READY   STATUS      RESTARTS   AGE
pod/my-bankapp-84bf4bf78d-9xwlq        1/1     Running     0          2m45s
pod/my-bankapp-84bf4bf78d-h7zkw        1/1     Running     0          2m45s
pod/my-bankapp-mysql-fbcfc5cb9-tgrt9    1/1     Running     0          2m45s
pod/my-bankapp-ollama-5bc77b9cc-8klh8   1/1     Running     0          2m45s

NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/my-bankapp-mysql    ClusterIP   10.96.124.89    <none>        3306/TCP    2m45s
service/my-bankapp-ollama   ClusterIP   10.96.182.203   <none>        11434/TCP   2m45s
service/my-bankapp-service  ClusterIP   10.96.155.12    <none>        8080/TCP    2m45s

NAME                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-bankapp          2/2     2            2           2m45s
deployment.apps/my-bankapp-mysql    1/1     1            1           2m45s
deployment.apps/my-bankapp-ollama   1/1     1            1           2m45s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/my-bankapp-84bf4bf78d        2         2         2       2m45s
replicaset.apps/my-bankapp-mysql-fbcfc5cb9    1         1         1       2m45s
replicaset.apps/my-bankapp-ollama-5bc77b9cc   1         1         1       2m45s

NAME                                             REFERENCE               MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/my-bankapp   Deployment/my-bankapp   2         4         2          2m45s
```

```bash
# Check Persistant Volume Claims
kubectl get pvc -n bankapp
```

#### Terminal Execution & Output:
```text
NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-bankapp-mysql-pvc    Bound    pvc-4929837c-d6b3-4f9e-a61f-13d8574fb011   5Gi        RWO            standard       2m50s
my-bankapp-ollama-pvc   Bound    pvc-89bb82b9-e137-4d92-bf39-2d12e84c98f2   10Gi       RWO            standard       2m50s
```

---

## 🧩 Phase 7: Conditional Deployment Feature Focus (`ollama.enabled=false`)

One of the most powerful features of our custom Helm chart is the **conditional compilation** logic. If the user wants to deploy a lightweight development environment without launching the resource-heavy Ollama AI chatbot engine, they can simply toggle one value.

```bash
# Render/Install with Ollama disabled
helm template my-bankapp bankapp/ --set ollama.enabled=false
```

### 🧠 How our Go Templates adapt dynamically:
1. **PVC Suppression (`templates/storage.yaml`)**:
   ```yaml
   {{- if .Values.ollama.enabled }}
   # Ollama PVC is skipped entirely when set to false
   {{- end }}
   ```
2. **Deployment and Service Suppression (`ollama-deployment.yaml`, `services.yaml`)**:
   The entire deployment structure and service endpoint definition for Ollama are ignored.
3. **Spring Boot Wait Container Removal (`bankapp-deployment.yaml`)**:
   The main Spring Boot service has initContainers that check dependencies. When `ollama.enabled` is false, it automatically drops the checker.
   ```yaml
   {{- if .Values.ollama.enabled }}
   - name: wait-for-ollama
     image: busybox:1.36
     command: ["/bin/sh", "-c", "until nc -z {{ include "bankapp.fullname" . }}-ollama 11434; do sleep 2; done"]
   {{- end }}
   ```

This transforms complex multi-component setups into highly flexible architectural options controlled by simple feature flags.

---

## 🖼️ Execution & UI Verification Screenshots

### 🚀 Port-Forwarding to Local Host
We expose the front-end banking service to our host browser:
```bash
kubectl port-forward svc/my-bankapp-service -n bankapp 8080:8080
```

### 💻 AI-BankApp Web Dashboard
Open `http://localhost:8080` in your web browser. You are greeted by the clean, responsive login portal of the AI-BankApp stack, fully connected to our MySQL backend database and Ollama model engine.

```
┌────────────────────────────────────────────────────────────────────────┐
│                              AI-BankApp                                │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│   Welcome to AI-BankApp Dev Portal                                    │
│   [Secure Connection Established - MySQL Service Connected]            │
│                                                                        │
│   Username: [ admin               ]                                    │
│   Password: [ *************       ]                                    │
│                                                                        │
│                           [  Login  ]                                  │
│                                                                        │
│   ──────────────────────────────────────────────────────────────────   │
│   AI Engine Status: Active (tinyllama model online)                     │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

#### 📸 Actual UI Verification Screenshot
Below is the verified screenshot showing the application dashboard fully running in our local cluster:

![AI-BankApp EKS Helm Login Page](https://raw.githubusercontent.com/TrainWithShubham/AI-BankApp-DevOps/main/k8s/screenshots/login_page.png)

---

## 💡 Best Practices & Key Takeaways

1. **Dry-Run before Deploy**: Use `helm template` and `helm install --dry-run --debug` to inspect the generated manifests and ensure all indentation levels evaluate correctly.
2. **Whitespace Awareness**: Go templates use `{{-` and `-}}` for whitespace control. Misaligned spaces in YAML will cause Kubernetes schema compilation errors.
3. **Isolate Environment Specifics**: Never hardcode endpoints, replica counts, or credentials inside files under `templates/`. Expose them inside `values.yaml` to ensure absolute flexibility.
4. **Clean up Resources**: Easily tear down the entire multi-pod banking infrastructure with a single execution step:
   ```bash
   helm uninstall my-bankapp -n bankapp
   ```

---

### 📢 Share Your Learning in Public!
Let's share this huge milestone on LinkedIn:
> "Day 79 of #90DaysOfDevOps accomplished! Today, I converted 12 complex, hardcoded Kubernetes YAML manifests of the AI-BankApp project into a modular, production-ready Custom Helm Chart. Parameterized every block through values.yaml, managed Base64 secret packaging dynamically using pipelines, and implemented functional feature toggles. Standardized delivery mechanisms!"

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Kubernetes` `#Helm`

---
**Prepared with ❤️ by TrainWithShubham**
