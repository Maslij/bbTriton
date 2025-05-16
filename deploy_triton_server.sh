#!/bin/bash

# Script to automate deployment of Triton Server with YOLOv7 models on Jetson Xavier
# This script will be executed inside the container

set -e  # Exit on error

# Default parameters for TensorRT engine optimization
MAX_BATCH_SIZE=16
OPT_BATCH_SIZE=8
FORCE_BUILD_FLAG="--force-build"  # Always build for first-time deployment

# First, download the ONNX models
echo "Downloading YOLOv7 models..."
cd /apps/models_onnx
bash ./download_models.sh
cd /apps

# Convert models to TensorRT and start the Triton server
echo "Converting models and starting Triton server..."
bash ./start-triton-server.sh ${MAX_BATCH_SIZE} ${OPT_BATCH_SIZE} ${FORCE_BUILD_FLAG} 