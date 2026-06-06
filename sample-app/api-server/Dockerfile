# Multi-stage Dockerfile for Flask API

# Build stage
FROM python:3.11-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --target="/build/packages" --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim

LABEL maintainer="DevOps Learning Labs"
LABEL version="1.0.0"

# Install tini (init process)
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependencies from builder to app directory
COPY --from=builder /build/packages .

# Copy application code
COPY app.py .
COPY requirements.txt .

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Add Python path for installed packages
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Use tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["python", "app.py"]
