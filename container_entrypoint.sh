#!/bin/bash
set -e

# Default batch sizes - can be overridden with environment variables
MAX_BATCH_SIZE=${MAX_BATCH_SIZE:-4}
OPT_BATCH_SIZE=${OPT_BATCH_SIZE:-2}
FORCE_BUILD=${FORCE_BUILD:-false}

echo "=== Starting Triton Server container ==="

# Make sure all scripts are executable
chmod +x /apps/models_onnx/download_models.sh
chmod +x /apps/start-triton-server.sh

# Step 1: Download models if they don't exist
echo "Checking for ONNX models..."
if [[ ! -f "./models_onnx/yolov7/yolov7_end2end.onnx" || ! -f "./models_onnx/yolov7_qat/yolov7_qat_end2end.onnx" ]]; then
    echo "Models not found, downloading..."
    cd ./models_onnx
    bash ./download_models.sh
    cd ..
    echo "Models downloaded successfully."
else
    echo "ONNX models already exist, skipping download."
fi

# Step 2: Check if TensorRT engines need to be built
BUILD_FLAG=""
if [[ "$FORCE_BUILD" == "true" ]]; then
    BUILD_FLAG="--force-build"
    echo "Force build flag set, will rebuild TensorRT engines."
fi

# Step 3: Run the start-triton-server script
echo "Starting Triton server with max_batch_size=$MAX_BATCH_SIZE, opt_batch_size=$OPT_BATCH_SIZE"
bash ./start-triton-server.sh "$MAX_BATCH_SIZE" "$OPT_BATCH_SIZE" $BUILD_FLAG

# If the server exits, keep the container running for debugging
if [[ $# -gt 0 ]]; then
    exec "$@"
else
    # If no command was provided, just sleep infinitely
    echo "Triton server has exited. Container will remain running for debugging."
    tail -f /dev/null
fi 