"""
Application configuration using Pydantic Settings.

Follows the 12-Factor App methodology: all configuration is loaded
from environment variables, with sensible defaults for development.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Application
    app_name: str = "cloud-native-api"
    app_env: str = "development"
    app_debug: bool = False
    app_port: int = 8000
    app_version: str = "1.0.0"

    # Logging
    log_level: str = "info"
    log_format: str = "json"  # "json" for production, "console" for development

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "case_sensitive": False,
    }


@lru_cache
def get_settings() -> Settings:
    """
    Cached settings instance.

    Uses lru_cache so the .env file is only read once,
    and the same Settings object is reused across the app.
    """
    return Settings()
