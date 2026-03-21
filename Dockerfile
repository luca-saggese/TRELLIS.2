
# Container Version	Ubuntu	CUDA Toolkit	PyTorch	TensorRT
# 25.01	24.04	NVIDIA CUDA 12.8.0	2.6.0a0+ecf3bae40a	TensorRT 10.8.0.40
FROM nvcr.io/nvidia/pytorch:25.01-py3

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MAX_JOBS=4 \
    HF_HOME=/huggingface \
    HUGGINGFACE_HUB_CACHE=/huggingface/hub \
    TORCH_HOME=/huggingface/torch \
    XDG_CACHE_HOME=/huggingface/.cache \
    CUDA_HOME=/usr/local/cuda \
    OPENCV_IO_ENABLE_OPENEXR=1 \
    PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

WORKDIR /workspace/TRELLIS.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    ffmpeg \
    git \
    libgl1 \
    libglib2.0-0 \
    libjpeg-dev \
    pkg-config \
    libxext6 \
    libxrender1 \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN . ./setup.sh --basic --nvdiffrast --nvdiffrec --cumesh --o-voxel --flexgemm --wheel-dir /tmp/trellis-wheels
RUN python -m pip install --no-cache-dir --force-reinstall "numpy<2" "opencv-python-headless<4.11"

EXPOSE 7860

CMD ["python", "app.py"]