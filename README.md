<p align="center">
  <h1 align="center">☁️ Cloud-Native Production-Ready API</h1>
  <p align="center">
    <strong>A production-grade FastAPI application with DevSecOps, IaC, and full observability</strong>
  </p>
  <p align="center">
    <a href="#-quick-start">Quick Start</a> •
    <a href="#-architecture">Architecture</a> •
    <a href="#-tech-stack">Tech Stack</a> •
    <a href="#-infrastructure">Infrastructure</a> •
    <a href="#-cicd-pipeline">CI/CD</a> •
    <a href="#-monitoring">Monitoring</a>
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/python-3.12-blue?logo=python&logoColor=white" alt="Python">
    <img src="https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white" alt="FastAPI">
    <img src="https://img.shields.io/badge/Docker-Distroless-2496ED?logo=docker&logoColor=white" alt="Docker">
    <img src="https://img.shields.io/badge/Terraform-AWS-7B42BC?logo=terraform&logoColor=white" alt="Terraform">
    <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions">
    <img src="https://img.shields.io/badge/Security-Trivy-1904DA?logo=aquasecurity&logoColor=white" alt="Trivy">
    <img src="https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-E6522C?logo=prometheus&logoColor=white" alt="Monitoring">
  </p>
</p>

---

## 📋 Overview

This project demonstrates **production-ready cloud-native practices** for deploying and operating a REST API. It's not just a "Hello World" — it's the complete DevOps/SRE toolkit you'd use in a real production environment:

| Feature | What it demonstrates |
|---|---|
| 🐳 **Multi-stage Distroless Docker** | Secure, minimal images (~80MB vs ~900MB) |
| 🏗️ **Terraform IaC** | Full AWS infrastructure: VPC, ECR, ECS Fargate, ALB |
| 🔄 **CI/CD Pipeline** | Automated lint → test → security scan → build → deploy |
| 🛡️ **DevSecOps** | Trivy CVE scanning on every build |
| 📊 **Observability** | Prometheus metrics + Grafana dashboards |
| 🩺 **Health Probes** | Kubernetes/ECS-compatible liveness & readiness checks |
| 📝 **Structured Logging** | JSON logs ready for ELK/CloudWatch/Datadog |
| 🧪 **Testing** | pytest with 80%+ coverage gate |

---

## 🚀 Quick Start

Get the full stack running in **3 commands**:

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/cloud-native-api.git
cd cloud-native-api

# 2. Start the full stack (API + Prometheus + Grafana + LocalStack)
make up

# 3. Open the API docs
# 🌐 API:        http://localhost:8000
# 📖 Swagger:    http://localhost:8000/docs
# ❤️  Health:     http://localhost:8000/health
# 📊 Metrics:    http://localhost:8000/metrics
# 🔥 Prometheus: http://localhost:9090
# 📈 Grafana:    http://localhost:3000 (admin/admin)
```

### Local Development (without Docker)

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# Install dependencies
make install

# Run with hot-reload
make dev

# Run tests
make test

# Lint
make lint
```

---

## 🏛️ Architecture

### Cloud Infrastructure (AWS)

```
                    ┌──────────────────────────────────────┐
                    │           AWS Cloud (VPC)             │
                    │                                      │
   Internet ──────▶│  ALB (:80) ──▶ ECS Fargate Cluster  │
                    │                 ├─ Task #1 (AZ-1)   │
                    │                 └─ Task #2 (AZ-2)   │
                    │                                      │
                    │  ECR (Images)   CloudWatch (Logs)    │
                    └──────────────────────────────────────┘
```

### Local Development Stack

```
   docker compose up
        │
        ├── FastAPI API (:8000)     → Your application
        ├── Prometheus  (:9090)     → Metrics collection
        ├── Grafana     (:3000)     → Dashboards
        └── LocalStack  (:4566)     → AWS emulation
```

> 📐 For detailed architecture diagrams, see [`docs/architecture.md`](docs/architecture.md)

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Application** | Python 3.12 + FastAPI | High-performance async REST API |
| **Configuration** | Pydantic Settings | Type-safe, 12-Factor App config |
| **Logging** | structlog (JSON) | Machine-parseable structured logs |
| **Metrics** | prometheus-fastapi-instrumentator | Auto-instrumented Prometheus metrics |
| **Container** | Docker (Distroless) | Minimal, secure runtime image |
| **Orchestration** | Docker Compose | Local multi-service development |
| **IaC** | Terraform | AWS infrastructure provisioning |
| **CI/CD** | GitHub Actions | Automated pipeline with 5 stages |
| **Security** | Trivy | Container vulnerability scanning |
| **Monitoring** | Prometheus + Grafana | Metrics collection & visualization |
| **AWS Mock** | LocalStack | Free local AWS emulation |
| **Testing** | pytest + httpx | Async API testing with coverage |
| **Linting** | ruff | Fast Python linter & formatter |

---

## 🏗️ Infrastructure

All infrastructure is defined as code using **Terraform** and designed for AWS:

```
terraform/
├── main.tf              # Provider config (AWS + LocalStack toggle)
├── variables.tf         # Parameterized variables with validation
├── vpc.tf               # VPC, subnets (2 AZs), IGW, security groups
├── ecr.tf               # Container registry with lifecycle policies
├── ecs.tf               # Fargate cluster, task definition, service
├── alb.tf               # Application Load Balancer + health checks
├── outputs.tf           # Resource IDs and API URL
└── terraform.tfvars.example
```

### Key Infrastructure Features

- **Multi-AZ deployment** for high availability
- **Security groups** with least-privilege access (ALB → ECS only)
- **Immutable image tags** in ECR for deployment safety
- **Container Insights** enabled for ECS monitoring
- **CloudWatch Logs** with 30-day retention
- **LocalStack toggle** for free local testing

### Test with LocalStack (No AWS Account Needed)

```bash
# Start LocalStack
docker compose up localstack -d

# Initialize resources
bash scripts/localstack-init.sh

# Run Terraform against LocalStack
cd terraform
terraform init
terraform apply -var="use_localstack=true"
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline runs on every push and PR:

```
  ┌─────────┐     ┌──────────┐     ┌───────────────┐     ┌──────────────┐     ┌──────────┐
  │  Lint   │────▶│  Test    │────▶│ Security Scan │────▶│ Docker Build │────▶│ Push ECR │
  │ (ruff)  │     │ (pytest) │     │   (Trivy)     │     │ (Distroless) │     │ (AWS)    │
  └─────────┘     │ cov ≥80% │     │ CRITICAL/HIGH │     └──────────────┘     └──────────┘
                  └──────────┘     └───────────────┘
```

- **Lint**: Code quality enforcement with `ruff`
- **Test**: Unit tests with 80% minimum coverage
- **Security**: Trivy scans for CRITICAL/HIGH CVEs, results uploaded to GitHub Security tab
- **Build**: Multi-stage Docker build with OCI labels
- **Push**: Conditional push to AWS ECR (only on `main`, only if AWS secrets are configured)

---

## 📊 Monitoring

### Pre-configured Grafana Dashboard

The project includes a production-ready Grafana dashboard with:

| Panel | Metric |
|---|---|
| 🟢 Request Rate | Requests per second by method/status |
| ⏱️ Latency | P50, P95, P99 response times |
| 🔴 Error Rate | 5xx error percentage with thresholds |
| 📊 Total Requests | Cumulative request counter |
| ⬆️ Uptime | Process uptime in seconds |
| 💾 Memory | Resident memory usage |
| 📈 Status Codes | Pie chart of HTTP status distribution |
| 🌡️ Duration Heatmap | Request duration distribution |

### Endpoints

| Endpoint | Purpose |
|---|---|
| `GET /health` | Liveness probe (is the process alive?) |
| `GET /ready` | Readiness probe (is the service ready?) |
| `GET /metrics` | Prometheus metrics endpoint |
| `GET /docs` | Swagger UI (interactive API docs) |
| `GET /redoc` | ReDoc (alternative API docs) |

---

## 📁 Project Structure

```
cloud-native-api/
├── app/                          # Application source code
│   ├── main.py                   # FastAPI app with health probes
│   ├── config.py                 # 12-Factor config (Pydantic Settings)
│   ├── routers/items.py          # CRUD REST endpoints
│   ├── middleware/logging.py     # Structured JSON logging
│   └── tests/                    # pytest test suite (80%+ coverage)
├── terraform/                    # AWS Infrastructure as Code
├── monitoring/                   # Prometheus + Grafana configs
│   ├── prometheus/               # Scrape configuration
│   └── grafana/                  # Dashboards + datasource provisioning
├── .github/workflows/ci.yml     # CI/CD pipeline (5 stages)
├── Dockerfile                    # Multi-stage → Distroless
├── docker-compose.yml            # Full observability stack
├── Makefile                      # Developer-friendly commands
└── scripts/                      # Utility scripts
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`make test`)
4. Run linter (`make lint`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <sub>Built with ❤️ by <a href="https://github.com/YOUR_USERNAME">Brayan PD</a> — DevOps / SRE Engineer</sub>
</p>
