#!/bin/bash
set -e

# Configuration
AWS_REGION="ap-southeast-2"
ECR_REGISTRY="246261010633.dkr.ecr.ap-southeast-2.amazonaws.com"
BASE_REPOSITORY="bbtriton-base"
MODEL_REPOSITORY="bbtriton-jetson"
IMAGE_TAG=$(date +%Y%m%d-%H%M%S)

echo "Building and deploying bbTriton model image to ECR..."
echo "Base Repository: ${ECR_REGISTRY}/${BASE_REPOSITORY}"
echo "Model Repository: ${ECR_REGISTRY}/${MODEL_REPOSITORY}"
echo "Tag: ${IMAGE_TAG}"

# Authenticate Docker to ECR
echo "Authenticating with AWS ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Check if repository exists, create if not
aws ecr describe-repositories --repository-names ${MODEL_REPOSITORY} --region ${AWS_REGION} > /dev/null 2>&1 || \
  aws ecr create-repository --repository-name ${MODEL_REPOSITORY} --region ${AWS_REGION}

# Set up Docker Buildx for multi-architecture builds
echo "Setting up Docker Buildx..."
docker buildx inspect bbtriton-builder >/dev/null 2>&1 || docker buildx create --name bbtriton-builder --platform linux/arm64
docker buildx use bbtriton-builder
docker buildx inspect --bootstrap

# Build and push the image
echo "Building and pushing model Docker image for ARM64 (NVIDIA Jetson)..."
docker buildx build --platform linux/arm64 \
  -f Dockerfile.models \
  --build-arg ECR_REGISTRY=${ECR_REGISTRY} \
  --build-arg BASE_IMAGE=${BASE_REPOSITORY}:latest \
  --tag ${ECR_REGISTRY}/${MODEL_REPOSITORY}:${IMAGE_TAG} \
  --tag ${ECR_REGISTRY}/${MODEL_REPOSITORY}:latest \
  --push \
  .

echo "Model image deployment completed successfully!"
echo "Model Image: ${ECR_REGISTRY}/${MODEL_REPOSITORY}:${IMAGE_TAG}"
echo "Model Image: ${ECR_REGISTRY}/${MODEL_REPOSITORY}:latest"
echo ""
echo "To pull this image on your Jetson device:"
echo "1. Authenticate with ECR:"
echo "   aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
echo ""
echo "2. Update your docker-compose.yml to use the new image:"
echo "   image: ${ECR_REGISTRY}/${MODEL_REPOSITORY}:latest"
echo ""
echo "3. Run the container with docker-compose:"
echo "   docker-compose up -d" 