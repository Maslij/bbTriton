# Triton Inference Server for Jetson

This directory contains a Docker Compose setup for running NVIDIA Triton Inference Server on a Jetson Xavier NX device.

## Prerequisites

- Jetson Xavier NX with JetPack installed
- Docker and Docker Compose installed
- NVIDIA Container Runtime installed

## Usage

### Starting the server

```bash
cd bbTriton
docker-compose up
```

This will:
1. Download the ONNX models if they don't exist
2. Convert the ONNX models to TensorRT engines (if needed)
3. Start the Triton Inference Server

### Configuration

You can configure the behavior by setting environment variables:

```bash
# Set batch sizes
MAX_BATCH_SIZE=8 OPT_BATCH_SIZE=4 docker-compose up

# Force rebuilding of TensorRT engines
FORCE_BUILD=true docker-compose up
```

### Stopping the server

```bash
docker-compose down
```

## Data Persistence

The Docker Compose setup mounts the following directories to ensure data persistence:

- `./models`: Contains the TensorRT engine files
- `./models_onnx`: Contains the downloaded ONNX model files

This means the models will only be downloaded and converted once, saving time on subsequent runs. 