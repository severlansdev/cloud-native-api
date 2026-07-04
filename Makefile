.PHONY: help install dev test lint format build run up down clean logs

# ============================================================
# 🚀 Cloud-Native Production-Ready API - Makefile
# ============================================================

APP_NAME    := cloud-native-api
IMAGE_TAG   := latest
DOCKER_IMG  := $(APP_NAME):$(IMAGE_TAG)

help: ## Show this help message
	@echo ""
	@echo "  Cloud-Native API - Available Commands"
	@echo "  ======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---- Local Development ----

install: ## Install Python dependencies
	pip install -r requirements.txt

dev: ## Run the app locally with hot reload
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

test: ## Run tests with coverage report
	pytest app/tests/ -v --cov=app --cov-report=term-missing --cov-fail-under=80

lint: ## Run linter (ruff)
	ruff check app/

format: ## Auto-format code (ruff)
	ruff format app/

# ---- Docker ----

build: ## Build the Docker image (multi-stage, distroless)
	docker build -t $(DOCKER_IMG) .

run: ## Run the Docker container standalone
	docker run --rm -p 8000:8000 --env-file .env.example $(DOCKER_IMG)

# ---- Docker Compose (Full Stack) ----

up: ## Start full stack: API + Prometheus + Grafana + LocalStack
	docker compose up -d --build
	@echo ""
	@echo "  ✅ Stack is running!"
	@echo "  ────────────────────────────────────"
	@echo "  🌐 API:        http://localhost:8000"
	@echo "  📖 Swagger:    http://localhost:8000/docs"
	@echo "  ❤️  Health:     http://localhost:8000/health"
	@echo "  📊 Metrics:    http://localhost:8000/metrics"
	@echo "  🔥 Prometheus: http://localhost:9090"
	@echo "  📈 Grafana:    http://localhost:3000 (admin/admin)"
	@echo "  ────────────────────────────────────"

down: ## Stop and remove all containers
	docker compose down -v

logs: ## Tail logs from all services
	docker compose logs -f

clean: ## Remove containers, images, and volumes
	docker compose down -v --rmi local
	docker rmi $(DOCKER_IMG) 2>/dev/null || true
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache htmlcov .coverage
