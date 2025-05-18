#!/bin/bash
set -e

# Configuration
AWS_REGION="ap-southeast-2"
ECR_REGISTRY="246261010633.dkr.ecr.ap-southeast-2.amazonaws.com"
ECR_REPOSITORY="bbtriton-base"
IMAGE_TAG=$(date +%Y%m%d-%H%M%S)

echo "Building and deploying bbTriton base image to ECR..."
echo "Repository: ${ECR_REGISTRY}/${ECR_REPOSITORY}"
echo "Tag: ${IMAGE_TAG}"

# Authenticate Docker to ECR
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Check if repository exists, create if not
aws ecr describe-repositories --repository-names ${ECR_REPOSITORY} --region ${AWS_REGION} > /dev/null 2>&1 || \
  aws ecr create-repository --repository-name ${ECR_REPOSITORY} --region ${AWS_REGION}

# Set up Docker Buildx for multi-architecture builds
echo "Setting up Docker Buildx..."
docker buildx inspect bbtriton-builder >/dev/null 2>&1 || docker buildx create --name bbtriton-builder --platform linux/arm64
docker buildx use bbtriton-builder
docker buildx inspect --bootstrap

# Build and push the image
echo "Building and pushing base Docker image for ARM64 (NVIDIA Jetson)..."
docker buildx build --platform linux/arm64 \
  -f Dockerfile \
  --tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} \
  --tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest \
  --push \
  .

echo "Base image deployment completed successfully!"
echo "Base Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
echo "Base Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest" 