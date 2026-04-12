# Multi-stage Dockerfile for Flask API

# Build stage (not used here, but shown for reference)
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim

LABEL maintainer="DevOps Learning Labs"
LABEL version="1.0.0"

# Install tini (init process)
RUN apt-get update && apt-get install -y tini && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY app.py .
COPY requirements.txt .

# Create non-root user
RUN useradd -m appuser
USER appuser

# Add Python path
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Use tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["python", "app.py"]
