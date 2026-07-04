# ============================================================
# Multi-Stage Dockerfile - Production-Ready & Secure
# ============================================================
# Stage 1: Build dependencies in a full Python image
# Stage 2: Copy only what's needed into a minimal runtime image
#
# Result: ~80MB image vs ~900MB with a standard Ubuntu base
# Security: No shell, no package manager, minimal attack surface
# ============================================================

# ---- Stage 1: Builder ----
FROM python:3.12-slim AS builder

WORKDIR /build

# Install dependencies into a clean prefix (no system pollution)
COPY requirements.txt .
RUN pip install \
    --no-cache-dir \
    --prefix=/install \
    --no-warn-script-location \
    -r requirements.txt

# Copy application source
COPY app/ ./app/

# ---- Stage 2: Runtime (Distroless) ----
FROM gcr.io/distroless/python3-debian12:nonroot

# Labels for container metadata (OCI standard)
LABEL org.opencontainers.image.title="cloud-native-api" \
      org.opencontainers.image.description="Production-ready FastAPI with observability" \
      org.opencontainers.image.authors="Brayan PD <brayanpd23@gmail.com>" \
      org.opencontainers.image.source="https://github.com/severlansdev/cloud-native-api"

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /install/lib/python3.12/site-packages /usr/lib/python3.12/site-packages
# Copy application code
COPY --from=builder /build/app ./app

# Expose the application port
EXPOSE 8000

# Health check for Docker / ECS
# Note: Distroless has no curl/wget, so we use Python's urllib
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python3", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

# Run as non-root user (distroless:nonroot runs as UID 65534)
# Using uvicorn directly via Python module
ENTRYPOINT ["python3", "-m", "uvicorn", "app.main:app", \
            "--host", "0.0.0.0", \
            "--port", "8000", \
            "--workers", "2", \
            "--log-level", "info", \
            "--proxy-headers", \
            "--forwarded-allow-ips", "*"]
