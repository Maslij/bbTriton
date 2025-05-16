#!/bin/bash

# Entrypoint script for Triton Server container
# This allows the container to automatically start the deployment process

# Make sure all scripts are executable
chmod +x /apps/deploy_triton_server.sh
chmod +x /apps/models_onnx/download_models.sh
chmod +x /apps/start-triton-server.sh

# Run the deployment script
bash /apps/deploy_triton_server.sh 