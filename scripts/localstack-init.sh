#!/bin/bash
# ============================================================
# LocalStack Initialization Script
# ============================================================
# Creates AWS resources in LocalStack for local development.
# Run this after `docker compose up` if you need ECR emulation.
#
# Usage: bash scripts/localstack-init.sh
# ============================================================

set -euo pipefail

LOCALSTACK_URL="http://localhost:4566"
REGION="us-east-1"
REPO_NAME="cloud-native-api-dev"

echo "🔧 Initializing LocalStack resources..."

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack..."
until curl -s "$LOCALSTACK_URL/_localstack/health" | grep -q '"ecr": "available"'; do
  sleep 2
done
echo "✅ LocalStack is ready!"

# Create ECR repository
echo "📦 Creating ECR repository: $REPO_NAME"
aws --endpoint-url="$LOCALSTACK_URL" \
    --region "$REGION" \
    ecr create-repository \
    --repository-name "$REPO_NAME" \
    --image-tag-mutability IMMUTABLE \
    2>/dev/null || echo "   (repository already exists)"

# Verify
echo ""
echo "🎉 LocalStack resources initialized!"
echo "   ECR: $LOCALSTACK_URL"
echo ""
echo "   To push an image to LocalStack ECR:"
echo "   docker tag cloud-native-api:latest localhost:4566/$REPO_NAME:latest"
echo "   docker push localhost:4566/$REPO_NAME:latest"
