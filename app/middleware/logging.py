"""
Structured logging middleware using structlog.

Produces JSON-formatted logs in production for easy parsing by
log aggregation systems (ELK, CloudWatch, Datadog, etc.).
"""

import logging
import time

import structlog
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.config import get_settings

settings = get_settings()

# Resolve log level name to integer using stdlib logging
_log_level = getattr(logging, settings.log_level.upper(), logging.INFO)

# Choose renderer based on environment
_renderer = (
    structlog.processors.JSONRenderer()
    if settings.log_format == "json"
    else structlog.dev.ConsoleRenderer()
)

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        _renderer,
    ],
    wrapper_class=structlog.make_filtering_bound_logger(_log_level),
)

logger = structlog.get_logger()


class StructuredLoggingMiddleware(BaseHTTPMiddleware):
    """
    Middleware that logs every HTTP request with structured data.

    Captures: method, path, status code, duration, client IP.
    Output format depends on LOG_FORMAT env var (json or console).
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        start_time = time.perf_counter()

        response = await call_next(request)

        duration_ms = round((time.perf_counter() - start_time) * 1000, 2)

        await logger.ainfo(
            "http_request",
            method=request.method,
            path=str(request.url.path),
            status_code=response.status_code,
            duration_ms=duration_ms,
            client_ip=request.client.host if request.client else "unknown",
        )

        return response
