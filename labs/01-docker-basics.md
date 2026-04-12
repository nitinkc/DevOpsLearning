# Lab 01: Docker Basics

## Objectives

- ✅ Examine sample Dockerfile
- ✅ Build Docker image locally
- ✅ Run container and test it
- ✅ Push image to registry (Docker Hub)
- ✅ Pull and verify on clean system

## Prerequisites

- Lab 00 complete (Docker + cluster running)
- Docker Hub account (create at hub.docker.com)
- ~1-2 hours

## Step 1: Review Sample Docker Structure

Navigate to sample app:

```bash
cd sample-app/api-server/
ls -la

# You'll see:
# - Dockerfile (build instructions)
# - app.py (simple Flask API)
# - requirements.txt (Python dependencies)
```

### Dockerfile Structure

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ../docs/labs .
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"
CMD ["python", "app.py"]
```

## Step 2: Build Image

```bash
# From api-server directory
docker build -t myapp:1.0.0 .

# Verify image created
docker images | grep myapp
```

## Step 3: Test Image Locally

```bash
# Run container
docker run -d -p 5000:5000 --name myapi myapp:1.0.0

# Test API
curl http://localhost:5000/health
# Should return: {"status":"healthy"}

# View logs
docker logs myapi

# Stop container
docker stop myapi
docker rm myapi
```

## Step 4: Push to Registry

```bash
# Login to Docker Hub
docker login

# Tag image for registry (YOUR_USERNAME is your Docker Hub username)
docker tag myapp:1.0.0 YOUR_USERNAME/myapp:1.0.0

# Push
docker push YOUR_USERNAME/myapp:1.0.0

# Verify in Docker Hub web UI
# Go to hub.docker.com and check your repo
```

## Step 5: Pull and Verify

```bash
# Pull from another context (or remove locally first to test)
docker rmi YOUR_USERNAME/myapp:1.0.0

# Pull from registry
docker pull YOUR_USERNAME/myapp:1.0.0

# Verify
docker run -d -p 5000:5000 YOUR_USERNAME/myapp:1.0.0
curl http://localhost:5000/health
```

## Validation

```bash
# Image exists
docker images | grep YOUR_USERNAME/myapp

# Container runs and responds
curl http://localhost:5000/health
# Returns: {"status":"healthy"}

# Push succeeded
docker push YOUR_USERNAME/myapp:1.0.0
# Output includes: sha256: <hash> Pushed
```

## Challenge (Optional)

Build with multi-stage to reduce image size:

```dockerfile
# Build stage
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

## Cleanup

```bash
docker stop myapi
docker rm myapi
docker rmi myapp:1.0.0
docker logout docker.io
```

---

**Next**: [Lab 02: Kubernetes Pods](02-kubernetes-pods.md)
