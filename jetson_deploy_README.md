# Triton Server YOLOv7 Deployment for Jetson Xavier

This guide explains how to deploy NVIDIA Triton Server with YOLOv7 models on a Jetson Xavier device.

## Prerequisites

- Jetson Xavier with JetPack 5.0+ installed
- Docker and Docker Compose installed on your Jetson
- NVIDIA Container Runtime installed
- At least 8GB of free storage space

## Quick Start

1. Clone this repository to your Jetson Xavier:
   ```bash
   git clone https://github.com/your-repo/triton-server-yolov7.git
   cd triton-server-yolov7
   ```

2. Make sure all scripts are executable:
   ```bash
   chmod +x *.sh
   chmod +x models_onnx/download_models.sh
   ```

3. Deploy the Triton Server using Docker Compose:
   ```bash
   docker-compose up -d
   ```

4. Check the container logs to monitor progress:
   ```bash
   docker logs -f triton-server-jetson
   ```

5. Verify server is running by checking the endpoints:
   ```bash
   curl localhost:8000/v2/health/ready
   ```

## Configuration

- The default batch size settings are:
  - Maximum Batch Size: 16
  - Optimal Batch Size: 8

- To change these settings, modify the values in `deploy_triton_server.sh`

## Ports

- HTTP endpoint: 8000
- gRPC endpoint: 8001
- Metrics endpoint: 8002

## Testing

After the server is up and running, you can test it using the Triton Client:

```bash
docker run -it --rm --net=host nvcr.io/nvidia/l4t-tensorrt:8.5.2-runtime /bin/bash

# Install Triton client
pip install tritonclient[all]

# Run a simple test script
python -c "
import tritonclient.http as tritonhttpclient
client = tritonhttpclient.InferenceServerClient(url='localhost:8000')
print(client.is_server_ready())
print(client.get_model_repository_index())
"
```

## Troubleshooting

- If the container fails to start, check the logs:
  ```bash
  docker logs triton-server-jetson
  ```

- For memory issues, you may need to reduce the batch sizes in `deploy_triton_server.sh`

- If models fail to download, check your internet connection and try downloading manually 