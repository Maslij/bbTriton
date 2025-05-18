FROM nvcr.io/nvidia/l4t-tensorrt:r8.5.2-runtime

# Install required dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    wget \
    libre2-5 \
    libb64-0d \
    libssl1.1 \
    tensorrt-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Triton Server for Jetson directly from GitHub
WORKDIR /opt
RUN wget -q https://github.com/triton-inference-server/server/releases/download/v2.27.0/tritonserver2.27.0-jetpack5.0.2.tgz && \
    mkdir -p /opt/tritonserver && \
    tar -xzf tritonserver2.27.0-jetpack5.0.2.tgz -C /opt/tritonserver && \
    rm tritonserver2.27.0-jetpack5.0.2.tgz

# Set up application directories
WORKDIR /apps
RUN mkdir -p /apps/models && \
    mkdir -p /apps/models_onnx && \
    mkdir -p /apps/models_config

# Expose Triton server ports
EXPOSE 8000 8001 8002

# Set default environment variables
ENV MAX_BATCH_SIZE=4
ENV OPT_BATCH_SIZE=2
ENV FORCE_BUILD=false

# Default command to start Triton server
CMD ["/opt/tritonserver/bin/tritonserver", "--model-repository=/apps/models", "--disable-auto-complete-config", "--log-verbose=0"] 