"""
Tests for health check endpoints.

Validates that liveness and readiness probes return
correct status codes and response schemas.
"""

import pytest


@pytest.mark.asyncio
async def test_health_returns_200(client):
    """Liveness probe should always return 200 with status healthy."""
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert "service" in data


@pytest.mark.asyncio
async def test_readiness_returns_200(client):
    """Readiness probe should return 200 with all checks passing."""
    response = await client.get("/ready")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ready"
    assert "checks" in data
    assert data["checks"]["database"] == "ok"
    assert data["checks"]["cache"] == "ok"


@pytest.mark.asyncio
async def test_root_returns_welcome(client):
    """Root endpoint should return welcome message with navigation links."""
    response = await client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "docs" in data
    assert "health" in data


@pytest.mark.asyncio
async def test_docs_endpoint_accessible(client):
    """Swagger UI should be accessible at /docs."""
    response = await client.get("/docs")
    assert response.status_code == 200
