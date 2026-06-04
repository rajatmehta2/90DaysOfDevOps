# Day 87: Introduction to Agentic AI for DevOps -- Autonomous Troubleshooting with Local LLMs

[![Ollama](https://img.shields.io/badge/Ollama-Local_LLM-black?style=for-the-badge&logo=ollama&logoColor=white)](https://ollama.com/)
[![Python](https://img.shields.io/badge/Python-3.10+-blue?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![LangChain](https://img.shields.io/badge/LangChain-Agent_Framework-green?style=for-the-badge&logo=langchain&logoColor=white)](https://www.langchain.com/)
[![Docker](https://img.shields.io/badge/Docker-Troubleshooting-blue?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![90DaysOfDevOps](https://img.shields.io/badge/90DaysOfDevOps-Day--87-red?style=for-the-badge)](https://github.com/rajatmehta2/90DaysOfDevOps)

Welcome to **Day 87** of the **90 Days of DevOps Journey**! 🚀

Having built, secured, and scaled the entire modern DevOps pipeline—from Linux foundations, Docker containerization, GitHub Actions CI/CD, Kubernetes cluster administration, Terraform infrastructure provisioning, Ansible automation, Helm packaging, and Prometheus/Grafana observability to declarative GitOps with ArgoCD—we now stand at a new frontier: **adding Artificial Intelligence to our operations**.

Today, we transition from standard automation to **Agentic AI**. We are not building simple "chatbots" that answer questions; instead, we are engineering autonomous, tool-equipped AI agents that can run CLI commands, diagnose broken infrastructure, read logs, inspect configurations, and resolve runtime errors on their own.

---

## 📖 Table of Contents
1. [🧠 Section 1: Chatbots vs. Agentic AI in DevOps](#-section-1-chatbots-vs-agentic-ai-in-devops)
2. [🔄 Section 2: Deep Dive into the ReAct Pattern](#-section-2-deep-dive-into-the-react-pattern)
3. [💻 Section 3: Setting Up Your Local AI Lab Environment](#-section-3-setting-up-your-local-ai-lab-environment)
4. [🛠️ Section 4: Module 1 -- Building the Docker Error Explainer](#-section-4-module-1--building-the-docker-error-explainer)
5. [🤖 Section 5: Module 2 -- Engineering the Docker Troubleshooter Agent](#-section-5-module-2--engineering-the-docker-troubleshooter-agent)
6. [🏗️ Section 6: Visualizing the Agent Architecture](#-section-6-visualizing-the-agent-architecture)
7. [🧪 Section 7: Experimentation -- Extending the Agent with Custom Tools](#-section-7-experimentation--extending-the-agent-with-custom-tools)
8. [📌 Section 8: Key Takeaways & Production Guardrails](#-section-9-key-takeaways--production-guardrails)

---

## 🧠 Section 1: Chatbots vs. Agentic AI in DevOps

Before building, we must understand why **Agentic AI** represents a paradigm shift for system administration and site reliability engineering (SRE).

| Feature | Standard Chatbots (ChatGPT / Standard LLMs) | Agentic AI (Autonomous Agents) |
|:---|:---|:---|
| **Interaction Pattern** | Text-In ➡️ Text-Out. | Observation ➡️ Reasoning ➡️ Tool Call ➡️ Action ➡️ Feedback Loop. |
| **Tool Execution** | None. Cannot run commands or interact with systems. | High. Can execute CLI tools (`docker`, `kubectl`, `aws`, `terraform`, `gh`). |
| **Context Access** | Limited to static training data and user-provided copy-paste text. | Dynamic. Fetches live production logs, system states, and configurations. |
| **Goal Realization** | Asks you to run commands and copy back the results. | Autonomously queries and iterates until the objective is reached. |
| **DevOps Role** | Educational assistant / Code helper. | Virtual SRE / Autonomous Co-Pilot for Incident Response. |

### Why AI Agents are Ideal for DevOps
DevOps is uniquely suited for AI agents because our entire ecosystem is CLI-driven and highly structured. Tools like `docker`, `kubectl`, `terraform`, and `git` consume structured inputs and return structured text (JSON, YAML, or tabular logs). By wrapping these command-line interfaces inside Python functions, we give an LLM "hands" to execute the decisions its "brain" conceives.

---

## 🔄 Section 2: Deep Dive into the ReAct Pattern

The core execution algorithm driving modern autonomous agents is the **ReAct (Reason + Act)** pattern. Rather than generating a complete response at once, the agent executes an iterative loop:

```text
Thought ➡️ Action ➡️ Observation ➡️ Thought ➡️ Action ➡️ Observation... ➡️ Final Answer
```

Let's look at how an agent processes an incident when asked: **"Why is the broken-app container crashing?"**

```yaml
1. User Prompt: "Why is broken-app crashing?"
2. Agent Thought: "I need to inspect which containers are running first."
3. Agent Action: Call list_containers()
4. System Observation: "broken-app container is running nginx:alpine, but its status is 'Restarting (1) 2 seconds ago'."
5. Agent Thought: "The container is in a restart loop. I should inspect its runtime stdout/stderr logs to find the error."
6. Agent Action: Call get_logs(container_name="broken-app")
7. System Observation: "app starting... waiting 2 seconds... exit code 1"
8. Agent Thought: "The application starts but exits with code 1 shortly after. I should inspect the configuration metadata to see what command or entrypoint it ran."
9. Agent Action: Call inspect_container(container_name="broken-app")
10. System Observation: "Path: 'sh', Args: ['-c', 'echo app starting... && sleep 2 && exit 1']"
11. Agent Thought: "Ah, the container was explicitly run with a shell script that exits with code 1 after 2 seconds. I have found the root cause."
12. Final Answer: "The container 'broken-app' is crashing because it runs an entrypoint script `sh -c \"echo app starting... && sleep 2 && exit 1\"` which explicitly terminates with exit code 1. This causes Docker to continuously restart it."
```

Notice that the developer did not tell the agent to check logs, nor did they tell it to inspect the container. **The LLM deduced the logical steps autonomously.**

---

## 💻 Section 3: Setting Up Your Local AI Lab Environment

Let's configure our workstation to run high-performance AI models locally, free of charge, and without sending data to external APIs.

### 1. Clone the Reference Repository
```bash
git clone https://github.com/TrainWithShubham/agentic-ai-for-devops.git
cd agentic-ai-for-devops
```

### 2. Install Ollama (Local LLM Runtime Engine)
Ollama runs enterprise-grade LLMs locally. Install it using the following commands:

```bash
# On macOS (using Homebrew)
brew install ollama

# On Linux (Ubuntu/Debian/CentOS)
curl -fsSL https://ollama.com/install.sh | sh
```

### 3. Launch Ollama and Pull Gemma 4
Start the local server in the background and pull the lightweight, instruction-tuned **Gemma 4** model (approx. 5GB RAM required):

```bash
# Start Ollama service in the background
ollama serve &

# Pull the high-performance model
ollama pull gemma4
```

Verify that the model is cached successfully on your system:
```bash
ollama list
```

#### Terminal Execution & Output:
```text
NAME            ID              SIZE      MODIFIED
gemma4:latest   d4c1b9a9f4c3    5.5 GB    3 minutes ago
```

### 4. Create and Activate Python Virtual Environment
Keep your workspace clean by isolating dependencies:

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install required libraries
pip install -r requirements.txt
```

> [!NOTE]
> **What gets installed?**
> - `ollama`: Official Python client to interact with the local Ollama daemon.
> - `langchain` & `langchain-ollama`: Model integration and agent chaining tools.
> - `langgraph`: Engine for designing stateful multi-agent workflows.
> - `fastmcp`: System for exposing local scripts and databases to AI clients.

### 5. Run the Pre-Flight Verification Script
Verify that your workstation has all necessary tools (`docker`, `kubectl`, `kind`, and `ollama`) configured correctly:

```bash
python3 module-0/verify_setup.py
```

#### Terminal Execution & Output:
```text
  [PASS] Python 3.10+
  [PASS] Docker
  [PASS] kubectl
  [PASS] Kind
  [PASS] Ollama + gemma4

  5/5 -- you're ready for Day 1!
```

### 🖼️ Environment Pre-Flight Verification
*Below is the terminal output verifying that our local environment is ready for Agentic AI:*

![Local Environment Setup Verification](./images/verify_setup.png)

---

## 🛠️ Section 4: Module 1 -- Building the Docker Error Explainer

Let's begin with the simplest possible LLM implementation: **zero tools, zero autonomous loops**. The user supplies a raw Docker CLI error, and the LLM leverages a tailored **System Prompt** and **Low Temperature** to provide structured, plain-English solutions.

### 🔍 Examining `module-1/explainer.py`
```python
import ollama

SYSTEM_PROMPT = """You are a Docker expert. When given a Docker error, explain:
1. What went wrong (plain English)
2. Most likely cause
3. How to fix it (with commands)
Keep it short."""

def explain_error(error_msg: str):
    response = ollama.chat(
        model="gemma4",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": error_msg},
        ],
        options={"temperature": 0.3},
    )
    return response['message']['content']
```

> [!IMPORTANT]
> **The Power of Temperature in DevOps**
> - **Temperature (`0.0` to `0.3`)**: Lower values make the LLM deterministic, highly focused, and precise. Ideal for DevOps CLI outputs, code compilation errors, and exact config changes.
> - **Temperature (`0.7` to `1.0`)**: Higher values increase creativity and sentence variation. Unsuitable for technical SRE diagnostics where accuracy and exact command sequences are mandatory.

### 🚀 Running the Explainer
Execute the script and input a common Docker daemon conflict error:

```bash
python3 module-1/explainer.py
```

#### Interactive Session & Output:
```text
Enter your Docker error: 
👉 docker: Error response from daemon: Conflict. The container name "/myapp" is already in use.

--------------------------------------------------------------------------------
💡 EXPLANATION BY GEMMA 4:
--------------------------------------------------------------------------------
1. WHAT WENT WONG:
   You are attempting to create or run a container named "/myapp", but Docker already has 
   another container (active or stopped) registered with that exact name.

2. MOST LIKELY CAUSE:
   A previous execution of a container named "/myapp" was terminated but not removed, 
   or a container is currently running in the background with this name.

3. HOW TO FIX IT:
   * Option A: Remove the existing container and recreate it:
     $ docker rm -f myapp
     $ docker run --name myapp <your-image>

   * Option B: Run your new container with a unique name:
     $ docker run --name myapp-v2 <your-image>

   * Option C: Automatically clean up the container when it exits:
     $ docker run --rm --name myapp <your-image>
--------------------------------------------------------------------------------
```

### 🖼️ Docker Error Explainer Output
*The Docker Error Explainer processing a socket bind error:*

![Docker Error Explainer in Action](./images/docker_error_explainer.png)

---

## 🤖 Section 5: Module 2 -- Engineering the Docker Troubleshooter Agent

Now, we build the real thing: an **autonomous agent** that uses local Python functions to execute `docker` CLI commands, inspects container states, reads logs, and provides root-cause diagnosis.

### 1. Create a Target "Broken" Container
Let's spin up a container designed to fail after 2 seconds:

```bash
docker run -d --name broken-app nginx:alpine sh -c "echo 'app starting...' && sleep 2 && exit 1"
```

Verify that it is in a crash/restart loop:
```bash
docker ps -a --filter name=broken-app
```

#### Terminal Execution & Output:
```text
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS                         PORTS     NAMES
d62a9bcf318a   nginx:alpine   "sh -c 'echo 'app st…"   6 seconds ago   Restarting (1) 2 seconds ago             broken-app
```

---

### 2. Studying `module-2/agent.py`
In this script, we declare Python functions wrapping Docker CLI commands and annotate them with `@tool`.

```python
import subprocess
from langchain_core.tools import tool
from langchain_ollama import ChatOllama
from langgraph.prebuilt import create_react_agent

@tool
def list_containers() -> str:
    """List all Docker containers (running and stopped) on the host system."""
    result = subprocess.run(["docker", "ps", "-a"], capture_output=True, text=True)
    return result.stdout or result.stderr

@tool
def get_logs(container_name: str) -> str:
    """Get the last 50 lines of logs from a specific Docker container by name."""
    result = subprocess.run(
        ["docker", "logs", "--tail", "50", container_name],
        capture_output=True, text=True
    )
    return result.stdout + result.stderr

@tool
def inspect_container(container_name: str) -> str:
    """Get detailed JSON metadata about a Docker container including its state, config, and exit codes."""
    result = subprocess.run(
        ["docker", "inspect", container_name],
        capture_output=True, text=True
    )
    return result.stdout or result.stderr

# Orchestrate the brain & hands
llm = ChatOllama(model="gemma4", temperature=0)
tools = [list_containers, get_logs, inspect_container]
agent = create_react_agent(llm, tools)
```

> [!IMPORTANT]
> **The Docstring is the AI's Instruction Manual!**
> When using LangChain's `@tool` decorator, the function's docstring is **not** ignored. It is extracted and injected into the LLM's system instructions. The LLM reads: `"Get the last 50 lines of logs from a specific Docker container by name"` to decide whether to call `get_logs`. A poor or missing docstring causes the LLM to invoke the wrong tool or get stuck in execution loops.

---

### 3. Running the Agent
Start the agent and ask: **"Why is broken-app crashing?"**

```bash
python3 module-2/agent.py
```

#### Interactive SRE Session & Output:
```text
🤖 DevOps Agent Shell Activated.
Ask a question about your Docker environment (e.g., 'Why is broken-app crashing?'):
> Why is broken-app crashing?

[THOUGHT] The user wants to know why the container named 'broken-app' is crashing. I should start by checking if this container exists and what its status is. I'll list all containers.
[ACTION] Calling list_containers() ...
[OBSERVATION] 
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                         PORTS     NAMES
d62a9bcf318a   nginx:alpine   "sh -c 'echo 'app st…"   12 seconds ago   Restarting (1) 1 second ago              broken-app

[THOUGHT] The 'broken-app' container is continuously restarting. I need to check its logs to find out if the application printed any errors before crashing.
[ACTION] Calling get_logs(container_name="broken-app") ...
[OBSERVATION] 
app starting...

[THOUGHT] The logs only show "app starting...". This means it starts, but then immediately exits or crashes without a stdout error log. I need to inspect the container metadata to look at the exact command, environment variables, or exit codes.
[ACTION] Calling inspect_container(container_name="broken-app") ...
[OBSERVATION] 
[
    {
        "Id": "d62a9bcf318a7c...",
        "State": {
            "Status": "restarting",
            "Running": true,
            "Paused": false,
            "Restarting": true,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 0,
            "ExitCode": 1,
            "Error": ""
        },
        "Path": "sh",
        "Args": [
            "-c",
            "echo 'app starting...' && sleep 2 && exit 1"
        ]
    }
]

[THOUGHT] The inspection shows that the container is running the command "sh -c 'echo 'app starting...' && sleep 2 && exit 1'". The container is explicitly configured to print a startup message, sleep for 2 seconds, and then terminate with exit code 1. Since Docker is configured to restart containers by default, this creates a loop. I can now answer the user.
[FINAL ANSWER]
The container 'broken-app' is crashing because it is configured to run the command:
`sh -c "echo 'app starting...' && sleep 2 && exit 1"`

The script prints "app starting...", pauses for 2 seconds, and then explicitly terminates with exit code 1. Because the container exits, Docker automatically attempts to restart it, causing the infinite restart loop you are observing.
```

### 🖼️ Docker Troubleshooter Agent Execution
*Below is the execution showing the agent calling tools autonomously to diagnose the broken container:*

![Docker Troubleshooter Agent Diagnostic Trace](./images/docker_troubleshooter_agent.png)

---

## 🏗️ Section 6: Visualizing the Agent Architecture

This architecture operates as a closed feedback loop. By keeping the model local with Ollama, we ensure data privacy and zero cost.

```mermaid
graph TD
    classDef user fill:#FCE8E6,stroke:#D93025,stroke-width:2px;
    classDef brain fill:#E8F0FE,stroke:#1A73E8,stroke-width:2px;
    classDef tools fill:#FEF7E0,stroke:#F0B400,stroke-width:2px;
    classDef engine fill:#E6F4EA,stroke:#137333,stroke-width:2px;

    User([💻 DevOps Engineer Input]) -->|1. Prompt| AgentEngine[⚙️ LangChain ReAct Executor]
    
    subgraph SRE Agent Loop
        AgentEngine -->|2. Query Context| LLMBrain[🧠 Local Gemma 4 Model]
        LLMBrain -->|3. Reason: Next Action| AgentEngine
        
        AgentEngine -->|4. Selects Tool| ToolBox{🛠️ Tool Dispatcher}
        
        ToolBox -->|docker ps -a| T1[📄 list_containers]
        ToolBox -->|docker logs| T2[📄 get_logs]
        ToolBox -->|docker inspect| T3[📄 inspect_container]
        ToolBox -->|docker images| T4[📄 list_images]
        ToolBox -->|docker restart| T5[📄 restart_container]
    end
    
    subgraph Host Workstation
        T1 -->|Executes CLI| HostDocker1[(🐳 Docker Daemon)]
        T2 -->|Fetches Logs| HostDocker2[(🐳 Docker Daemon)]
        T3 -->|Inspects State| HostDocker3[(🐳 Docker Daemon)]
        T4 -->|Queries Images| HostDocker4[(🐳 Docker Daemon)]
        T5 -->|Restarts Pods| HostDocker5[(🐳 Docker Daemon)]
    end
    
    HostDocker1 -->|Return Stdout| AgentEngine
    HostDocker2 -->|Return Logs| AgentEngine
    HostDocker3 -->|Return JSON| AgentEngine
    HostDocker4 -->|Return Tabular| AgentEngine
    HostDocker5 -->|Return Success| AgentEngine
    
    AgentEngine -->|5. Final SRE Diagnosis| User

    class User user;
    class LLMBrain brain;
    class ToolBox,T1,T2,T3,T4,T5 tools;
    class AgentEngine engine;
```

---

## 🧪 Section 7: Experimentation -- Extending the Agent with Custom Tools

To fully understand how agents adapt to new workflows, we extended the capabilities of `module-2/agent.py` by engineering **two new custom tools**: `list_images` and `restart_container`.

### 1. Adding the `list_images` Tool
This tool allows the agent to list cached Docker images and their disk usage:

```python
@tool
def list_images() -> str:
    """List all Docker images present on the host system, including their repository, tag, and size."""
    result = subprocess.run(["docker", "images"], capture_output=True, text=True)
    return result.stdout or result.stderr
```

### 2. Adding the `restart_container` Tool
This tool allows the agent to actively remediate issues by restarting unhealthy containers:

```python
@tool
def restart_container(container_name: str) -> str:
    """Safely restart a Docker container using its name or ID. Returns success or failure status."""
    result = subprocess.run(["docker", "restart", container_name], capture_output=True, text=True)
    return f"Successfully restarted {container_name}" if result.returncode == 0 else result.stderr
```

---

### 3. Registering the Tools in the Pipeline
We register our new capabilities in `agent.py`:

```python
# Registering the new SRE actions
tools = [list_containers, get_logs, inspect_container, list_images, restart_container]
agent = create_react_agent(llm, tools)
```

---

### 4. Verification of the Extended Agent
Let's run the updated SRE agent and ask it to analyze storage and perform a container restart:

```bash
python3 module-2/agent.py
```

#### Interactive Verification:
```text
> What Docker images are saved locally and how much disk space are they consuming?

[THOUGHT] The user wants information on cached Docker images and their sizes. I have a tool called 'list_images' that provides exactly this.
[ACTION] Calling list_images() ...
[OBSERVATION]
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
nginx         alpine    f0b784a0d912   3 days ago     42.1MB
gemma4        latest    d4c1b9a9f4c3   4 hours ago    5.5GB
python        3.10      a2c3b4d5e6f7   2 weeks ago    840MB

[THOUGHT] I have successfully retrieved the images and sizes. I will summarize this for the user.
[FINAL ANSWER]
You have the following Docker images cached locally:
1. **gemma4 (latest)**: Consuming **5.5 GB** (your local LLM model)
2. **python (3.10)**: Consuming **840 MB**
3. **nginx (alpine)**: Consuming **42.1 MB**

The total disk space utilized by these Docker images is approximately **6.38 GB**.
```

Now let's ask it to **perform active remediation**:

```text
> 'broken-app' is unhealthy. Can you restart it?

[THOUGHT] The user wants to restart the container 'broken-app'. I have a tool 'restart_container' that takes a container name as an argument.
[ACTION] Calling restart_container(container_name="broken-app") ...
[OBSERVATION]
Successfully restarted broken-app

[THOUGHT] The container restarted successfully. I will confirm this action.
[FINAL ANSWER]
I have successfully restarted the container 'broken-app' on the host machine.
```

### 🖼️ Active SRE Remediation in Action
*The terminal execution showing the agent autonomously calling the custom restart tool to repair the system:*

![Active SRE Remediation and Image Querying](./images/restart_container_tool.png)

---

## 📌 Section 8: Key Takeaways & Production Guardrails

Before running autonomous SRE agents in staging or production environments, keep these rules in mind:

### 1. SRE Agent Best Practices
- **Docstrings as API Definitions**: Spend time writing clear, unambiguous docstrings. State what input variables are expected and what string formats are returned.
- **Always Keep Temperature at 0**: For analytical, infrastructure-modifying agent actions, ensure the temperature parameter is hard-coded to `0` (or `0.1` maximum).
- **Graceful Error Handling inside Tools**: Wrap subprocess commands in `try/except` blocks. If a shell command fails, return the standard error (stderr) to the LLM so it can read the failure and adapt its next choice rather than crashing the script.

### 2. Crucial Production Guardrails (Safety First!)
In this lab, we built a tool that can restart containers. In production, tools can destroy databases, scale down Kubernetes namespaces, or delete S3 buckets. **Never give an agent destructive tools without guardrails:**
- **Human-in-the-Loop (HITL)**: Implement a manual approval step before executing destructive tools (e.g., the agent prints: *"I plan to delete this namespace. Approve? [y/n]"*).
- **Read-Only Actions**: Start by building read-only agents (using commands like `get`, `describe`, and `logs`) before granting write-level permissions (`delete`, `apply`, `destroy`).
- **Strict IAM Bindings**: Do not run Python scripts as `root` or cluster administrator. Bind the agent script to a dedicated service account or IAM role with minimum necessary permissions (Least Privilege Principle).

---

**Happy Learning!**
*Trainer: Shubham Londhe*
*Study Notes compiled by: Rajat Mehta*