# BrinkByte Triton Server Docker Images

This project contains two Dockerfiles for building NVIDIA Triton Inference Server images for Jetson platforms.

## Architecture

The deployment process uses a two-stage approach:

1. **Base Image (`Dockerfile`)**: 
   - Contains the NVIDIA Triton Server installation and dependencies
   - Downloads Triton Server directly from GitHub releases
   - Creates the basic directory structure
   - Does not include any models

2. **Model Image (`Dockerfile.models`)**: 
   - Uses the base image as its foundation
   - Adds model configurations and scripts
   - Handles downloading and converting models
   - Runs the Triton server with the models

## Build and Deploy Process

### 1. Build and Deploy the Base Image

This builds a reusable base image with just the Triton Server installed:

```bash
./deploy_base_to_ecr.sh
```

The script will:
- Authenticate with AWS ECR
- Create the repository if it doesn't exist
- Build the base image for ARM64 architecture
- Push the image to ECR with tags (latest and date-based)

### 2. Build and Deploy the Model Image

This builds the model-specific image that uses the base image:

```bash
./deploy_to_ecr.sh
```

The script will:
- Authenticate with AWS ECR
- Create the repository if it doesn't exist
- Build the model image for ARM64 architecture using the base image
- Push the image to ECR with tags (latest and date-based)

## Running the Container

Update your `docker-compose.yml` to use the model image:

```yaml
image: 246261010633.dkr.ecr.ap-southeast-2.amazonaws.com/bbtriton-jetson:latest
```

Then start the container:

```bash
docker-compose up -d
```

## Volumes

The docker-compose configuration mounts these volumes:

- `./models:/apps/models` - Persist TensorRT engines between runs
- `./models_onnx:/apps/models_onnx` - Persist downloaded ONNX models
- `/dev/shm:/dev/shm` - Shared memory for model processing

## Environment Variables

Configure the container with these environment variables:

- `MAX_BATCH_SIZE` - Maximum batch size for TensorRT engines (default: 4)
- `OPT_BATCH_SIZE` - Optimal batch size for TensorRT engines (default: 2)
- `FORCE_BUILD` - Force rebuild of TensorRT engines (default: false)

## Update Process

When updating the base image:
1. Update `Dockerfile` with needed changes
2. Run `./deploy_base_to_ecr.sh`
3. Rebuild model image with `./deploy_to_ecr.sh`

When updating only models or scripts:
1. Update the relevant files
2. Run only `./deploy_to_ecr.sh` 