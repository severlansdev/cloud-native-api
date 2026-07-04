"""
Cloud-Native Production-Ready API

A FastAPI application built with production-grade practices:
- Health checks (liveness + readiness probes)
- Prometheus metrics instrumentation
- Structured JSON logging
- Pydantic-based configuration (12-Factor App)

Author: Brayan PD
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

from app.config import get_settings
from app.middleware.logging import StructuredLoggingMiddleware
from app.routers import items

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler for startup/shutdown events."""
    # Startup: Initialize Prometheus instrumentation
    Instrumentator(
        should_group_status_codes=True,
        should_ignore_untemplated=True,
        excluded_handlers=["/health", "/ready", "/metrics"],
    ).instrument(app).expose(app, endpoint="/metrics", include_in_schema=True)
    yield
    # Shutdown: cleanup resources if needed


app = FastAPI(
    title="Cloud-Native Production-Ready API",
    description=(
        "A production-grade REST API demonstrating DevOps/SRE best practices: "
        "containerization, observability, CI/CD, and Infrastructure as Code."
    ),
    version=settings.app_version,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# ---- Middleware ----
app.add_middleware(StructuredLoggingMiddleware)

# ---- Routers ----
app.include_router(items.router)


# ---- Health Checks ----

@app.get(
    "/health",
    tags=["Health"],
    summary="Liveness probe",
    response_model=dict,
)
async def health_check():
    """
    Liveness probe for Kubernetes / ECS.

    Returns 200 if the process is alive. Used by container
    orchestrators to determine if the container should be restarted.
    """
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version,
    }


@app.get(
    "/ready",
    tags=["Health"],
    summary="Readiness probe",
    response_model=dict,
)
async def readiness_check():
    """
    Readiness probe for Kubernetes / ECS.

    Returns 200 if the service is ready to accept traffic.
    In a real app, this would check database connections,
    cache availability, and downstream service health.
    """
    checks = {
        "database": "ok",  # Replace with real DB ping
        "cache": "ok",     # Replace with real Redis ping
    }
    all_healthy = all(v == "ok" for v in checks.values())

    return {
        "status": "ready" if all_healthy else "degraded",
        "checks": checks,
    }


@app.get("/", tags=["Root"], include_in_schema=False)
async def root():
    """Root endpoint - redirects to API documentation."""
    return {
        "message": f"Welcome to {settings.app_name}",
        "docs": "/docs",
        "health": "/health",
        "metrics": "/metrics",
    }
