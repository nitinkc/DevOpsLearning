# 02: Containerization & Docker

## Definition

**Container** = A lightweight, isolated package containing:

- Application code
- Dependencies (libraries, runtime)
- Configuration files
- Everything needed to run the app

**Docker** = Platform that builds, packages, and runs containers

### **Why Containers?**

```
Traditional: "It works on my machine"
  My Laptop:  Python 3.9, Node 14, Ubuntu 20.04, PostgreSQL 12
  Your Laptop: Python 3.8, Node 16, macOS, PostgreSQL 13
  → App breaks on your laptop

With Docker:
  Container = complete environment packaged
  → Works identically everywhere (laptop, server, cloud)
```


## Docker Architecture

<div class="mermaid">
graph TB
    A["Dockerfile<br/>(instructions)"] -->|docker build| B["Docker Image<br/>(blueprint)"]
    B -->|docker run| C["Docker Container<br/>(running instance)"]
    B -->|docker push| D["Container Registry<br/>(Docker Hub, ghcr.io, ECR)"]
    D -->|docker pull| E["Deployed Container<br/>(production)"]
    
    style A fill:#e3f2fd
    style B fill:#f3e5f5
    style C fill:#fff3e0
    style D fill:#e8f5e9
    style E fill:#fce4ec
</div>

### **Key Terms**

| Term           | Definition                          | Analogy            |
|:---------------|:------------------------------------|:-------------------|
| **Image**      | Blueprint for container (immutable) | Class definition   |
| **Container**  | Running instance of image           | Object instance    |
| **Registry**   | Central storage for images          | Package repository |
| **Dockerfile** | Instructions to build image         | Recipe             |
| **Layer**      | Cached step in image build          | Snapshot           |

## Dockerfile Best Practices

### **Basic Dockerfile Structure**

```docker
# Base image (includes OS + runtime)
FROM python:3.11-slim

# Metadata
LABEL author="DevOps Team"
LABEL version="1.0.0"

# Working directory
WORKDIR /app

# Copy files
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Default command to run
CMD ["python", "app.py"]
```

### **Best Practices**

#### **1. Use Specific Base Image Versions**

❌ **Bad:**
```docker
FROM python:latest  # Could break anytime
```

✅ **Good:**
```docker
FROM python:3.11.4-slim-bookworm  # Reproducible
```

#### **2. Multi-Stage Builds (Reduce Image Size)**

❌ **Bad:**
```docker
FROM golang:1.20  # 1GB - includes build tools
COPY . .
RUN go build -o app
CMD ["./app"]
# Result: 1GB image with build tools still included
```

✅ **Good:**
```docker
# Build stage
FROM golang:1.20 AS builder
COPY . .
RUN go build -o app

# Runtime stage (small)
FROM alpine:latest  # 5MB
COPY --from=builder /app /app
CMD ["./app"]
# Result: ~50MB image
```

#### **3. Minimize Layers**

❌ **Bad:**
```docker
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
# Creates 3 separate layers
```

✅ **Good:**
```docker
RUN apt-get update && apt-get install -y curl wget
# Single layer
```

#### **4. Use .dockerignore**

```
# .dockerignore
node_modules/
.git/
*.log
.env
.DS_Store
```

#### **5. Run as Non-Root User**

❌ **Bad:**
```docker
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
# Runs as root (security risk)
```

✅ **Good:**
```docker
RUN useradd -m appuser
USER appuser
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
# Runs as non-root
```

---

## Docker Image Layers

When you build an image, Docker creates **layers** for caching:

```
FROM python:3.11          Layer 1: Base image (200MB)
WORKDIR /app              Layer 2: Set working dir (0MB)
COPY requirements.txt .   Layer 3: Copy file (1MB)
RUN pip install ...       Layer 4: Install deps (50MB)
COPY . .                  Layer 5: Copy code (50KB)
CMD ["python", "app.py"]  Layer 6: Metadata (0MB)
─────────────────────────────────────────────
Total image size: ~250MB
```

**Layer Caching:**
```
First build:  Builds all layers (slow)
Second build: Code changes, recreates layers 5-6 only (fast)
           → Layers 1-4 reused from cache
```

**Key insight:** Put things that change infrequently (base image, dependencies) before things that change frequently (your code).

---

## Docker Commands

### **Building Images**

```bash
# Build image from Dockerfile
docker build -t myapp:1.0.0 .
  # -t = tag (name:version)
  # . = use Dockerfile in current directory

# Build with custom Dockerfile
docker build -f ./custom.Dockerfile -t myapp:1.0.0 .

# Build and push in one go
docker buildx build --push -t ghcr.io/user/myapp:1.0.0 .
```

### **Running Containers**

```bash
# Run a container
docker run -d -p 8080:5000 --name mycontainer myapp:1.0.0
  # -d = detach (background)
  # -p 8080:5000 = map port
  # --name = container name

# Run with environment variables
docker run -e DB_HOST=localhost -e DB_USER=admin myapp:1.0.0

# Run with volume mount
docker run -v /host/path:/container/path myapp:1.0.0

# Run interactively
docker run -it myapp:1.0.0 /bin/bash
```

### **Inspecting Containers**

```bash
# List running containers
docker ps

# Show all containers (including stopped)
docker ps -a

# View container logs
docker logs <container-id>

# Follow logs (like `tail -f`)
docker logs -f <container-id>

# Inspect container details
docker inspect <container-id>

# Execute command in running container
docker exec -it <container-id> /bin/bash
```

### **Image Management**

```bash
# List images
docker images

# View image history (layers)
docker history myapp:1.0.0

# Tag image for registry
docker tag myapp:1.0.0 ghcr.io/user/myapp:1.0.0

# Push to registry
docker push ghcr.io/user/myapp:1.0.0

# Pull from registry
docker pull ghcr.io/user/myapp:1.0.0

# Remove image
docker rmi myapp:1.0.0
```

---

## Container Registries

### **Where Images Live**

```
Docker Hub (docker.io)
  └─ library/ubuntu:22.04
  └─ library/python:3.11
  └─ yourname/myapp:1.0.0

GitHub Container Registry (ghcr.io)
  └─ ghcr.io/yourname/myapp:1.0.0

Google Container Registry (gcr.io)
  └─ gcr.io/my-project/myapp:1.0.0

AWS Elastic Container Registry (ECR)
  └─ 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:1.0.0
```

### **Pushing to Registry**

```bash
# Login to registry
docker login ghcr.io

# Tag image
docker tag myapp:1.0.0 ghcr.io/yourname/myapp:1.0.0

# Push
docker push ghcr.io/yourname/myapp:1.0.0

# Others can now pull
docker pull ghcr.io/yourname/myapp:1.0.0
```

---

## Container Lifecycle

<div class="mermaid">
graph LR
    A["docker create"] --> B["Created"]
    B --> C["docker start"]
    C --> D["Running"]
    D -->|docker pause| E["Paused"]
    E -->|docker unpause| D
    D -->|docker stop| F["Stopped"]
    F --> G["docker rm"]
    G --> H["Removed"]
    D -->|crash| F
    
    style A fill:#e3f2fd
    style D fill:#c8e6c9
    style F fill:#ffccbc
    style H fill:#f5f5f5
</div>


---

## Common Patterns

### **Pattern 1: Application Config**

```docker
# Get config from environment or files
FROM python:3.11
WORKDIR /app
COPY app.py .
EXPOSE 5000

# These can be overridden at runtime
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV LOG_LEVEL=INFO

CMD ["python", "app.py"]
```

### **Pattern 2: Health Checks**

```docker
FROM python:3.11
WORKDIR /app
COPY . .
EXPOSE 5000

# Docker checks if container is healthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
```

### **Pattern 3: Init Process**

```docker
FROM python:3.11

# Use init process (handles signals properly)
ENTRYPOINT ["/sbin/tini", "--"]

COPY app.py .
CMD ["python", "app.py"]
```

---

## Anti-Patterns to Avoid

### ❌ **Large Image (Bloated Base)**

```docker
FROM ubuntu:22.04  # 77MB
RUN apt-get update && apt-get install -y python3
# Image becomes ~800MB
```

✅ **Use slim/alpine images**
```docker
FROM python:3.11-slim  # 120MB (includes Python)
# Image becomes ~150MB
```

### ❌ **Running as Root**

Opens security vulnerabilities

### ❌ **Hardcoding Secrets**

```
ENV DB_PASSWORD=secret123  # Never do this!
```

✅ Pass secrets at runtime:
```bash
docker run -e DB_PASSWORD=secret123 myapp:1.0.0
```

### ❌ **No Health Checks**

Kubernetes doesn't know if your app crashed

✅ Add HEALTHCHECK

### ❌ **Latest Tag**

```docker
FROM node:latest  # Could be 18, 20, or 22
# Breaks reproducibility
```

✅ Use specific versions
```docker
FROM node:20.9.0
```

---

## Docker Compose (Multi-Container)

Running a single container is rare. Usually you need multiple services (API, database, cache):

```yaml
version: '3.8'
services:
  api:
    build: ./api
    ports:
      - "8080:5000"
    environment:
      DB_HOST: postgres
    depends_on:
      - postgres
  
  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Run all services:
```bash
docker-compose up
```

---

## Interview Questions

**Q: What's the difference between an image and a container?**

A: Image is a blueprint (immutable), container is a running instance (mutable). You can have one image and 100 containers running from it.

**Q: Why use multi-stage builds?**

A: To reduce final image size by excluding build tools. Example: 1GB golang builder becomes 50MB final image.

**Q: How do you pass configuration to a container?**

A: Environment variables, volumes (config files), or command-line arguments.

---

## Key Takeaways

✅ **Docker = packaging your app + dependencies**  
✅ **Images are immutable blueprints, containers are running instances**  
✅ **Use multi-stage builds to reduce image size**  
✅ **Always use specific base image versions**  
✅ **Never hardcode secrets in images**  
✅ **Layer caching speeds up builds**  
✅ **Registries are where images live (Docker Hub, ghcr.io, etc.)**  

---

## Next Steps

- **Read**: [Theory 03: Kubernetes Fundamentals](03-kubernetes-fundamentals.md)
- **Do**: [Lab 01: Docker Basics](../labs/01-docker-basics.md) — Build your first image
